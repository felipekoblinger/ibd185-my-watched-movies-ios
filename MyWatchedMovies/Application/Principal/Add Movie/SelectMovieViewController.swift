//
//  SelectMovieViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/22/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON
import Argo
import Moya_Argo
import Kingfisher
import KeychainAccess
import HGPlaceholders

class SelectMovieViewController: UIViewController {
    
    @IBOutlet weak var tableView: TableView!
    @IBAction func unwindToSelectMovieViewController(segue:UIStoryboardSegue) { }
    
    var searchTask: DispatchWorkItem?
    var searchArray = [TheMovieDatabase]()
    var keyboardHeight = CGFloat()
    let searchPlaceholder = PlaceholderKey.custom(key: "search")
    
    /* MARK: Create UISearch Controller */
    var movieSearchController: UISearchController = ({
        let controller = UISearchController(searchResultsController: nil)

        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        
        let searchBar = controller.searchBar
        searchBar.searchBarStyle = .minimal
        searchBar.sizeToFit()
        searchBar.placeholder = "Type to search"
        searchBar.tintColor = .white
        
        /* Color of TextField Text */
        return controller
    })()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white

        navigationItem.searchController = movieSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        /* Delegate Searchbar to class */
        movieSearchController.searchBar.delegate = self
        movieSearchController.searchResultsUpdater = self
        
        /* Make class to manage Data Source of `tableView` */
        tableView.dataSource = self
        tableView.delegate = self
        
        /* Placeholders */
        tableView?.placeholdersProvider = .custom
        tableView.showCustomPlaceholder(with: searchPlaceholder)
        
        /*  Fix black-screen when switching between tabs */
        self.definesPresentationContext = true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        self.keyboardHeight = frame.height
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddMovieCreateSegue") {
            /* Passing Data */
            let addMovieCreateViewController: AddMovieViewController = segue.destination as! AddMovieViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let cell = self.tableView.cellForRow(at: indexPath) as! SelectMovieTableViewCell
            let theMovieDatabase = self.searchArray[indexPath[1]]
            
            addMovieCreateViewController.moviePosterImage = cell.movieImageView?.image
            addMovieCreateViewController.theMovieDatabase = theMovieDatabase
        }
    }
}

extension SelectMovieViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            
            /* Back frame */
            self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top, left: 0, bottom: 0, right: 0)
            
            self.searchArray = [TheMovieDatabase]()
            self.tableView.reloadData()
            self.tableView.showCustomPlaceholder(with: searchPlaceholder)
        }
    }
}

extension SelectMovieViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        /* Set frame */
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight * 0.5, right: 0)
        self.tableView.contentInset = contentInsets
        
        self.tableView.showLoadingPlaceholder()

        
        var time = 0.5
        
        self.searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            self?.searchUpdate()
        }
        self.searchTask = task
        
        if searchBar.text?.count == 0 {
            time = 0
        }

        // Execute task in 0.5 seconds (if not cancelled !)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: task)
    }
    
    func searchUpdate() {
        var value = self.movieSearchController.searchBar.text
        if value?.utf8.count == 0 {
            /* Back frame */
            self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top, left: 0, bottom: 0, right: 0)
            
            searchArray = [TheMovieDatabase]()
            tableView.reloadData()
            tableView.showCustomPlaceholder(with: searchPlaceholder)
        } else {
            value = value?.replacingOccurrences(of: " ", with: "+")
            let provider = MoyaProvider<TheMovieDatabaseService>(
                plugins: [
                    AuthPlugin(token: Keychain(service: KeychainConstants.MainService)["token"]! )
                ]
            )
            provider.request(.searchMovies(term: value!)) { result in
                switch result {
                case let .success(response):
                    do {
                        let theMovieDatabase: [TheMovieDatabase] = try response.mapArrayWithRootKey(rootKey: "results")
                        self.searchArray = theMovieDatabase
                    } catch {
                        self.tableView.showNoResultsPlaceholder()
                        self.searchArray = [TheMovieDatabase]()
                    }
                    
                    /* Back frame */
                    self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top, left: 0, bottom: 0, right: 0)
                    
                    self.tableView.reloadData()
                case .failure:
                    self.tableView.showNoConnectionPlaceholder()
                }
            }
        }
    }
}

extension SelectMovieViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch movieSearchController.isActive {
        case true:
            return searchArray.count
        case false:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SelectMovieTableViewCell
        
        let model: TheMovieDatabase
        if movieSearchController.isActive && movieSearchController.searchBar.text != "" {
            model = searchArray[indexPath.row]
        } else {
            model = searchArray[indexPath.row]
        }
        cell.movieTitleLabel!.text = model.title!
        cell.movieReleaseDateLabel!.text = model.showReleaseDate()
        
        cell.movieOverviewLabel!.text = model.showOverview()
        cell.movieGenresLabel!.text = model.showGenre()
        
        if model.posterPath != nil {
            let imageUrl = URL(string: APIConstants.TheMovieDatabaseImageUrl + model.posterPath!)
            cell.movieImageView!.kf.indicatorType = .activity
            let placeholderImage = UIImage(named: "Poster Placeholder")
            cell.movieImageView!.kf.setImage(with: imageUrl,
                                             placeholder: placeholderImage,
                                             options: [.transition(.fade(0.2))])
        } else {
            cell.movieImageView.image = UIImage(named: "Poster Placeholder")
        }

        return cell
    }
}


extension SelectMovieViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
//        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "AddMovieCreateSegue", sender: self)
    }
}
