//
//  MoviesViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/22/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import CoreStore
import Moya
import Moya_Argo
import KeychainAccess

import Kingfisher
import UIEmptyState

class MoviesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBAction func unwindToMoviesViewController(segue:UIStoryboardSegue) { }
    
    /* List Monitor */
    let monitor: ListMonitor<MovieEntity> = {
        
        /* Add Storage */
        CoreStoreDefault.addStorageAndWait()
        
        return CoreStore.monitorSectionedList(
            From<MovieEntity>()
                .sectionBy(\.section)
                .orderBy(.descending(\.date), .descending(\.createdAt))
        )
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.fetchMoviesRefreshControl(_:)), for: .valueChanged)
        refreshControl.tintColor = .red
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Navigation Bar */
        navigationController?.navigationBar.tintColor = .white
        
        /* Managing Data Source of `tableView` */
        tableView.dataSource = self
        tableView.delegate = self
        
        /* Add Pull to Refresh into Table */
        tableView.addSubview(refreshControl)
        
        /* Managing List Observer */
        self.monitor.addObserver(self)
        
        /* Update */
        self.fetchMoviesFromServer()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        self.reloadEmptyStateForTableView(self.tableView)
        
        /*  Fix black-screen when switching between tabs */
        self.definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UpdateMovieSegue") {
            /* Passing Data */
            let updateMovieViewController: UpdateMovieViewController = segue.destination as! UpdateMovieViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let cell = self.tableView.cellForRow(at: indexPath) as! MoviesTableViewCell
            let movieEntity = self.monitor[indexPath]
            
            updateMovieViewController.moviePosterImage = cell.movieImageView?.image
            updateMovieViewController.movieEntity = movieEntity
        }
    }
    
    @objc func fetchMoviesRefreshControl(_ refreshControl: UIRefreshControl) {
        self.fetchMoviesFromServer {
            self.fetchMoviesFromServer(completion: {
                refreshControl.endRefreshing()
            })
        }
    }
    
    func fetchMoviesFromServer(completion: (() -> ())? = nil)  {
        /* Setting Plugin */
        let provider = MoyaProvider<MovieService>(
            plugins: [
                AuthPlugin(token: Keychain(service: KeychainConstants.MainService)["token"]! )
            ]
        )
        provider.request(.movies()) { result in
            switch result {
            case let .success(response):
                let moviesJson = try! response.mapJSON() as! [[String: Any]]
                CoreStore.perform(
                    asynchronous: { (transaction) -> Void in
                        let objects = try! transaction.importUniqueObjects(
                            Into<MovieEntity>(),
                            sourceArray: moviesJson
                        )
                        if objects.isEmpty {
                            transaction.deleteAll(From<MovieEntity>())
                        } else {
                            let ids = objects.map { $0.uniqueIDValue }
                            transaction.deleteAll(From<MovieEntity>(),
                                                  Where<MovieEntity>("NOT (uuid IN %@)", ids))
                        }
                        
                },
                    completion: { _ in
                        completion?()
                    }
                )
            case let .failure(error):
                completion?()
                print(error)
            }
        }
    }
    
    func tableViewUpdateCell(cell: MoviesTableViewCell, indexPath: IndexPath) {
        let model: MovieEntity
        model = self.monitor[indexPath]
        
        /* Title Label */   
        cell.movieTitleLabel.text = model.title.value
        
        /* Type Label */
        cell.movieTypeLabel.text = model.type.value.uppercased()
        
        /* Genres Label */
        cell.movieGenresLabel.text = model.showGenres()
        
        /* Date Label */
        cell.movieDateLabel.text = DateConstants.dateFormatter.string(from: model.date.value)
        
        /* Created At Label */
        cell.movieCreatedAtLabel.text = DateConstants.dateTimeFormatter.string(from: model.createdAt.value)
        
        /* Rating Cosmos View */
        cell.movieRatingCosmosView.rating = Double(model.rating.value)
        
        /* Setting */
        if model.posterPath.value != "unknown" {
            let imageUrl = URL(string: APIConstants.TheMovieDatabaseImageUrl + model.posterPath.value)
            let placeholderImage = UIImage(named: "Poster Placeholder")
            cell.movieImageView!.kf.setImage(with: imageUrl,
                                             placeholder: placeholderImage,
                                             options: [.transition(.fade(0.2))])
        } else {
            cell.movieImageView.image = UIImage(named: "Poster Placeholder")
        }
    }
}

extension MoviesViewController: ListObserver {
    typealias ListEntityType = MovieEntity
    
    func listMonitorWillChange(_ monitor: ListMonitor<MovieEntity>) {
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<MovieEntity>) {
        self.tableView.endUpdates()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<MovieEntity>) {
    }
}

extension MoviesViewController: ListSectionObserver {
    func listMonitor(_ monitor: ListMonitor<MovieEntity>, didInsertObject object: MovieEntity, toIndexPath indexPath: IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<MovieEntity>, didUpdateObject object: MovieEntity, atIndexPath indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? MoviesTableViewCell {
            tableViewUpdateCell(cell: cell, indexPath: indexPath)
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<MovieEntity>, didDeleteObject object: MovieEntity, fromIndexPath indexPath: IndexPath) {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<MovieEntity>, didMoveObject object: MovieEntity, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        self.tableView.deleteRows(at: [fromIndexPath], with: .automatic)
        self.tableView.insertRows(at: [toIndexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<MovieEntity>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<MovieEntity>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
}

extension MoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.monitor.sectionInfoAtIndex(section).numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let model = self.monitor[indexPath]
            let title = model.title.value
            let date = DateConstants.dateFormatter.string(from: model.date.value)
            
            let alert = UIAlertController(title: "Attention!",
                                          message: "Would you like to delete \"\(title)\" watched on \(date)?",
                                          preferredStyle: UIAlertControllerStyle.actionSheet)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {
                action in
                    let provider = MoyaProvider<MovieService>(
                        plugins: [
                            AuthPlugin(token: Keychain(service: KeychainConstants.MainService)["token"]! )
                        ]
                    )
                    provider.request(.deleteMovie(uuid: model.uuid.value)) { result in
                        switch result {
                        case let .success(response):
                            if response.statusCode == 200 {
                                CoreStore.perform(
                                    asynchronous: { (transaction) -> Void in
                                        transaction.delete(model)
                                },
                                    completion: { _ in }
                                )
                            }
                        case let .failure(error):
                            print(error)
                        }
                    }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            

            self.present(alert, animated: true, completion: nil)

        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Define Cell */
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MoviesTableViewCell
        
        /* MovieEntity */
        tableViewUpdateCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    /* Sections */
    func numberOfSections(in tableView: UITableView) -> Int {
        self.reloadEmptyStateForTableView(self.tableView)
        return self.monitor.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 45))
        view.backgroundColor = UIColor(red: 0.0/255.0, green: 11.0/255.0, blue: 41.0/255.0, alpha: 1)
        
        let label = UILabel(frame: CGRect(x: 20, y: -9, width: tableView.bounds.width - 20, height: 45))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor(red: 248.0/255.0, green: 245.0/255.0, blue: 242.0/255.0, alpha: 1)
        
        label.text = self.monitor.sectionInfoAtIndex(section).indexTitle!
        view.addSubview(label)
        return view
    }
}


extension MoviesViewController: UIEmptyStateDataSource {
    var emptyStateImage: UIImage? {
        return #imageLiteral(resourceName: "No Movies")
    }
    
    var emptyStateImageSize: CGSize? {
        return CGSize(width: 215, height: 275)
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.00),
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold)]
        return NSAttributedString(string: "No movies...", attributes: attrs)
    }
    
    var emptyStateDetailMessage: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor(red: 0.101, green: 0.101, blue: 0.101, alpha: 1.00),
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        return NSAttributedString(string: "Please, add a movie in \"Add Movie\" tab.", attributes: attrs)
    }

    var emptyStateButtonTitle: NSAttributedString? {
        return nil
    }
}

extension MoviesViewController: UIEmptyStateDelegate { }

extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        self.performSegue(withIdentifier: "UpdateMovieSegue", sender: self)
    }
}
