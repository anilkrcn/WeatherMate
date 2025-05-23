//
//  FavoriteCell.swift
//  WeatherMate
//
//  Created by Anıl Karacan on 17.05.2025.
//

import Foundation
import UIKit
import Lottie

class FavoriteCell: UITableViewCell{
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var animationContainerView: UIView!
    
    var lottieAnimation: LottieAnimationView?
    
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
    
    func setupLottieAnimation(condition: String) {
         // Lottie animasyonunu başlat
        if lottieAnimation == nil {
                lottieAnimation = LottieAnimationView(name: condition)
                lottieAnimation?.frame = animationContainerView.bounds
                lottieAnimation?.contentMode = .scaleAspectFit
                lottieAnimation?.loopMode = .loop
                lottieAnimation?.tintColor = .blue
                if let lottieAnimation = lottieAnimation {
                    animationContainerView.addSubview(lottieAnimation)
                }
            } else {
                lottieAnimation?.animation = LottieAnimation.named(condition)
            }
            lottieAnimation?.play()
     }
    
    func updateBackground(for weatherCondition: String) {
        var backgroundImageName: String

        switch weatherCondition {
        case "sun":
            backgroundImageName = "sunWallpaper"
        case "snow":
            backgroundImageName = "snowWallpaper"
        case "fog":
            backgroundImageName = "fogWallpaper"
        case "bolt":
            backgroundImageName = "boltWallpaper"
        case "drizzle":
            backgroundImageName = "drizzleWallpaper"
        case "cloud":
            backgroundImageName = "cloudWallpaper"
        case "rainy":
            backgroundImageName = "rainyWallpaper"
        default:
            backgroundImageName = "cloudWallpaper"
        }

        // Arka planı güncelle
        weatherImage.image = UIImage(named: backgroundImageName)
    }
}
