//
//  AddMovieCreateViewController.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/25/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import Kingfisher

import TransitionButton
import Cosmos
import StatusAlert
import CFNotify

import Moya_Argo
import Moya
import KeychainAccess

import SwiftyJSON
import CoreStore

class AddMovieViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var movieOverviewTextView: UITextView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var movieRatingCosmosView: CosmosView!
    @IBOutlet weak var movieTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var movieDateDatePicker: UIDatePicker!
    
    var moviePosterImage:UIImage? = nil
    var theMovieDatabase = TheMovieDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTitleLabel.text = theMovieDatabase.title!
        moviePosterImageView.image = moviePosterImage
        backgroundImageView.image = moviePosterImage
        movieOverviewTextView.text = theMovieDatabase.overview!
        
        /* Define maximum date */
        self.movieDateDatePicker.maximumDate = Date()
        
        if (moviePosterImageView?.image == nil) {
            ImageDownloader.default.downloadTimeout = 1
            
            let imageUrl = URL(string: APIConstants.TheMovieDatabaseImageUrl + theMovieDatabase.posterPath!)
            let placeholderImage = UIImage(named: "Poster Placeholder")
            
            moviePosterImageView!.kf.indicatorType = .activity
            
            moviePosterImageView!.kf.setImage(with: imageUrl,
                                              placeholder: placeholderImage,
                                              options: [.transition(.fade(0.2))])
            backgroundImageView!.kf.setImage(with: imageUrl,
                                             placeholder: placeholderImage,
                                             options: [.transition(.fade(0.2))])
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /* Setting scroll to top as default in TextView */
        self.movieOverviewTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func submitAction(_ button: TransitionButton) {
        button.startAnimation()
        
        let provider = MoyaProvider<MovieService>(
            plugins: [
                AuthPlugin(token: Keychain(service: KeychainConstants.MainService)["token"]! )
            ]
        )
        
        let date = self.movieDateDatePicker.date
        let rating = Int(self.movieRatingCosmosView.rating)
        let type = self.movieTypeSegmentedControl.titleForSegment(at: self.movieTypeSegmentedControl.selectedSegmentIndex)
        
        provider.request(.addMovie(date: date, rating: rating,  type: type!, theMovieDatabase: theMovieDatabase)) { result in
            switch result {
            case let .success(response):
                button.stopAnimation(animationStyle: .expand, completion: {
                    if response.statusCode == 201 {
                        let movieJson = try! response.mapJSON() as! [String: Any]
                        
                        CoreStoreDefault.addStorageAndWait()
                        
                        /* Adding to CoreData */
                        CoreStore.perform(asynchronous: { (transaction) -> Void in
                            try! _ = transaction.importObject(
                                Into<MovieEntity>(),
                                source: movieJson
                            )
                        },
                        completion: { _ in })

                        self.performSegue(withIdentifier: "unwindToSelectMovieController", sender: self)
                        let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "Movie Added"),
                                                                  title: "Movie added!",
                                                                  message: "The movie \(self.theMovieDatabase.title!) was added to my watched movies!")
                        statusAlert.showInKeyWindow()
                    }
                })
            case let .failure(error):
                print(error)
            }
        }
    }
}
