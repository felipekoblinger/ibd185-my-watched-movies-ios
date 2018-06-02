//
//  MoviesTableViewCell.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 5/27/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import UIKit
import Cosmos

class MoviesTableViewCell: UITableViewCell {
    @IBOutlet weak var movieDateLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieCreatedAtLabel: UILabel!
    
    @IBOutlet weak var movieRatingCosmosView: CosmosView!
    @IBOutlet weak var movieImageView: UIImageView!
}
