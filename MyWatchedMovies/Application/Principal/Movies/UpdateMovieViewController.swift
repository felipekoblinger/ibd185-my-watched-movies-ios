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

class UpdateMovieViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    @IBOutlet weak var movieOverviewTextView: UITextView!
    @IBOutlet weak var movieGenresLabel: UILabel!
    
    /* Updatable */
    @IBOutlet weak var movieRatingCosmosView: CosmosView!
    @IBOutlet weak var movieTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var movieDateDatePicker: UIDatePicker!
    
    @IBOutlet weak var movieCreatedAtLabel: UILabel!
    @IBOutlet weak var movieUpdatedAtLabel: UILabel!
    
    var moviePosterImage: UIImage? = nil
    var movieEntity: MovieEntity? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieTitleLabel.text = self.movieEntity?.title.value
        
        self.moviePosterImageView.image = self.moviePosterImage
        self.backgroundImageView.image = self.moviePosterImage
        
        self.movieOverviewTextView.text = self.movieEntity?.overview.value!
        
        /* Setting Rating */
        self.movieRatingCosmosView.rating = Double((self.movieEntity?.rating.value)!)
        /* Setting Subbed */
        let movieType = self.movieEntity?.type.value
        let movieTypeIndex = MovieType.init(rawValue: movieType!)?.hashValue
        self.movieTypeSegmentedControl.selectedSegmentIndex = movieTypeIndex!
        /* Setting DatePicker Date */
        self.movieDateDatePicker.setDate((self.movieEntity?.date.value)!, animated: true)
        
        /* Genres */
        self.movieGenresLabel.text = self.movieEntity?.showGenres()
        self.movieReleaseDateLabel.text = self.movieEntity?.showReleaseDate()
        self.movieCreatedAtLabel.text = self.movieEntity?.showCreatedAt()
        self.movieUpdatedAtLabel.text = self.movieEntity?.showUpdatedAt()
        
        
        /* Define maximum date */
        self.movieDateDatePicker.maximumDate = Date()
        
        if (moviePosterImageView?.image == nil) {
            ImageDownloader.default.downloadTimeout = 1
            
            let imageUrl = URL(string: APIConstants.TheMovieDatabaseImageUrl + (movieEntity?.posterPath.value)!)
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
        let uuid = self.movieEntity?.uuid.value
        let title = (self.movieEntity?.title.value)!
        
        provider.request(.updateMovie(uuid: uuid!, date: date, rating: rating, type: type!)) { result in
            switch result {
            case let .success(response):
                
                let statusCode = response.statusCode
                
                switch statusCode {
                case 200:
                    let json = JSON(response.data)
                    let updatedAt = DateConstants.dateTimeFormatter.date(from: json["updatedAt"].stringValue)
                    /* Update in CoreData */
                    CoreStore.perform(
                        asynchronous: { (transaction) -> Void in
                            let movie = transaction.fetchOne(
                                From<MovieEntity>()
                                    .where(\.uuid == uuid!)
                            )
                            movie?.date.value = date
                            movie?.rating.value = rating
                            movie?.type.value = type!
                            movie?.updatedAt.value = updatedAt!
                    },
                        completion: { _ in }
                    )
                    
                    self.performSegue(withIdentifier: "unwindToMoviesViewController", sender: self)
                    let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "Movie Updated"),
                                                              title: "Movie updated!",
                                                              message: "The movie \(title) was updated!")
                    statusAlert.showInKeyWindow()
                default:
                    print("ERROR!")
                }
                
                
            case let .failure(error):
                print(error)
            }
        }
    }
}
