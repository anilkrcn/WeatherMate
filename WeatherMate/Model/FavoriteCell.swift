//
//  FavoriteCell.swift
//  WeatherMate
//
//  Created by Anıl Karacan on 17.05.2025.
//

import Foundation
import UIKit

class FavoriteCell: UITableViewCell{
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        temperatureLabel.adjustsFontSizeToFitWidth = true
        cityLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
