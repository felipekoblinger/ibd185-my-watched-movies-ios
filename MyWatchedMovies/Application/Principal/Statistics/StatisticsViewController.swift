//
//  ActivityViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/22/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import Charts
import CoreStore
import Moya
import KeychainAccess
import SwiftyJSON

import PopupDialog
import SkeletonView

class StatisticsViewController: UIViewController {
    @IBOutlet weak var totalMoviesLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var monthlyMoviesHorizontalBarChartView: HorizontalBarChartView!
    
    @IBOutlet weak var moviesByTypePieChartView: PieChartView!
    
    var monitor: ObjectMonitor<MovieStatisticsEntity>?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.fetchRefreshControl(_:)), for: .valueChanged)
        refreshControl.tintColor = .red
        return refreshControl
    }()
    
    func updateLabels() {
        let total = self.monitor?.object?.total.value
        if total != nil {
            self.totalMoviesLabel.text = String(total!)
        }

    }
    
    func updateHorizontalBarChart() {
        let dataSet = BarChartDataSet()
        /* DataSet Styling */
        dataSet.colors = [.red]
        dataSet.valueTextColor = .white
        dataSet.valueFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        dataSet.valueFormatter = DigitValueFormatter()
        
        let monthly = self.monitor?.object?.monthly.value
        
        for (index, element) in (monthly?.enumerated())! {
            let dictionary = element as! NSDictionary
            let total = dictionary.value(forKey: "total") as! Double
            
            let dataEntry = BarChartDataEntry(x: Double(index), y: total)
            
            _ = dataSet.addEntry(dataEntry)
        }
        
        
        let data = BarChartData(dataSets: [dataSet])
        self.monthlyMoviesHorizontalBarChartView.data = data
        self.monthlyMoviesHorizontalBarChartView.xAxis.labelCount = (monthly?.count)!
        
        self.monthlyMoviesHorizontalBarChartView.xAxis.valueFormatter = DefaultAxisValueFormatter {
            (value, axis) in
            let dictionary = self.monitor?.object?.monthly.value.object(at: Int(value)) as! NSDictionary
            let yearMonth = dictionary.value(forKey: "yearMonth") as! String
            return yearMonth
        }
        
        self.monthlyMoviesHorizontalBarChartView.notifyDataSetChanged()
    }
    
    func setupHorizontalBarChart() {
        let horizontalBar = self.monthlyMoviesHorizontalBarChartView
        
        horizontalBar?.drawValueAboveBarEnabled = true
        horizontalBar?.fitBars = true
        horizontalBar?.animate(yAxisDuration: 1.5)
        horizontalBar?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        horizontalBar?.clipsToBounds = true
        horizontalBar?.doubleTapToZoomEnabled = false
        horizontalBar?.extraTopOffset = 35
        horizontalBar?.extraBottomOffset = 5
        
        let xAxis = horizontalBar?.xAxis
        xAxis?.labelPosition = .bottomInside
        xAxis?.labelFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        xAxis?.granularity = 1
        xAxis?.labelTextColor = .white
        xAxis?.gridColor = .white
        
        let yAxisFormatter = NumberFormatter()
        yAxisFormatter.minimumFractionDigits = 0
        yAxisFormatter.maximumFractionDigits = 0
        yAxisFormatter.numberStyle = .decimal
        let yAxisFormatterDefault = DefaultAxisValueFormatter(formatter: yAxisFormatter)

        let leftAxis = horizontalBar?.leftAxis
        leftAxis?.labelFont = .systemFont(ofSize: 10)
        leftAxis?.axisMinimum = 0
        leftAxis?.labelTextColor = .white
        leftAxis?.gridColor = .white
        leftAxis?.granularityEnabled = true
        leftAxis?.granularity = 1.0
        
        leftAxis?.valueFormatter = yAxisFormatterDefault
        
        let rightAxis = horizontalBar?.rightAxis
        rightAxis?.labelFont = .systemFont(ofSize: 10)
        rightAxis?.axisMinimum = 0
        rightAxis?.labelTextColor = .white
        rightAxis?.gridColor = .white
        rightAxis?.granularityEnabled = true
        rightAxis?.granularity = 1.0
        
        rightAxis?.valueFormatter = yAxisFormatterDefault
        
        let legend = horizontalBar?.legend
        legend?.enabled = false
    }
    
    func updatePieChart() {
        let pieChart = self.moviesByTypePieChartView
        
        let dictionary = self.monitor?.object?.type.value
        var entries = [PieChartDataEntry]()
        for (key, value) in dictionary! {
            let dataEntry = PieChartDataEntry(value: value as! Double, label: key as? String)
            entries.append(dataEntry)
        }

        let dataSet = PieChartDataSet(values: entries, label: "")

        /* DataSet Styling */
        dataSet.colors = [.purple, .orange, .magenta]
        dataSet.valueTextColor = .white
        dataSet.valueFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!

        let data = PieChartData(dataSets: [dataSet])

        pieChart?.data = data
        pieChart?.notifyDataSetChanged()
    }
    
    func setupPieChart() {
        let pieChart = self.moviesByTypePieChartView
        pieChart?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        pieChart?.extraTopOffset = 35
        pieChart?.legend.enabled = false
        pieChart?.centerText = "Categories"
        pieChart?.chartDescription?.enabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        /* Init */
        MovieStatisticsData.addStorageAndWait()
        
        if let movieStatistics = MovieStatisticsData.stack.fetchOne(From<MovieStatisticsEntity>()) {
            self.monitor = MovieStatisticsData.stack.monitorObject(movieStatistics)
        } else {
            _ = try? MovieStatisticsData.stack.perform(
                synchronous: { (transaction) in
                    transaction.create(Into<MovieStatisticsEntity>())
                }
            )
            
            let movieStatistics = MovieStatisticsData.stack.fetchOne(From<MovieStatisticsEntity>())!
            self.monitor = MovieStatisticsData.stack.monitorObject(movieStatistics)
        }
        
        super.init(coder: aDecoder)
    }
    
    func fetchFromServer(completion: (() -> ())? = nil) {
        let provider = MoyaProvider<MovieStatisticsService>(
            plugins: [
                AuthPlugin(token: Keychain(service: KeychainConstants.MainService)["token"]! )
            ]
        )
        provider.request(.overall()) { result in
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 200:
                    let movieStatisticsJson = JSON(response.data)
                    MovieStatisticsData.stack.perform(
                        asynchronous: { [weak self] (transaction) in
                            if let movieStatistics = transaction.edit(self?.monitor?.object) {
                                movieStatistics.total.value = movieStatisticsJson["total"].intValue
                                movieStatistics.monthly.value = movieStatisticsJson["monthly"].arrayObject! as NSArray
                                movieStatistics.type.value = movieStatisticsJson["type"].dictionaryObject! as NSDictionary
                                movieStatistics.enabled.value = true
                            }
                        },
                        completion: { _ in
                            self.view.hideSkeleton()
                        }
                    )
                case 401, 403:
                    /* Message that you can't see */
                    MovieStatisticsData.stack.perform(
                        asynchronous: { [weak self] (transaction) in
                            if let movieStatistics = transaction.edit(self?.monitor?.object) {
                                movieStatistics.enabled.value = false
                            }
                        },
                        completion: { _ in
                            self.checkPermission()
                        }
                    )
                default:
                    self.checkPermission()
                }
                
                completion?()

            case .failure:
                self.checkPermission()
                completion?()
            }
        }
    }
    
    @objc func fetchRefreshControl(_ refreshControl: UIRefreshControl) {
        self.fetchFromServer(completion: {
            refreshControl.endRefreshing()
        })
        
    }
    
    func checkPermission() {
        let movieStatistics = MovieStatisticsData.stack.fetchOne(From<MovieStatisticsEntity>())!
        if !movieStatistics.enabled.value {
            let title = "Sorry..."
            let message = "You can't access due permission or network issue."
            let image = UIImage(named: "Statistics - Permission")
            let popup = PopupDialog(title: title, message: message,
                                    image: image, gestureDismissal: false)
            
            let buttonOne = CancelButton(title: "Back") {
                /* Move to Movies */
                self.performSegue(withIdentifier: "unwindToMoviesViewController", sender: self)
            }
            popup.addButtons([buttonOne])

            self.present(popup, animated: true, completion: nil)
        } else {
            self.view.hideSkeleton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.monitor?.addObserver(self)
        self.scrollView.addSubview(self.refreshControl)
        
        self.updateLabels()
        
        self.setupHorizontalBarChart()
        self.updateHorizontalBarChart()
        
        self.setupPieChart()
        self.updatePieChart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.showAnimatedGradientSkeleton()
        self.fetchFromServer()
    }
}

extension StatisticsViewController: ObjectObserver {
    typealias ObjectEntityType = MovieStatisticsEntity
    
    func objectMonitor(_ monitor: ObjectMonitor<MovieStatisticsEntity>, didUpdateObject object: MovieStatisticsEntity, changedPersistentKeys: Set<KeyPathString>) {
        self.updateLabels()
        self.updateHorizontalBarChart()
        self.updatePieChart()
    }
    
}
