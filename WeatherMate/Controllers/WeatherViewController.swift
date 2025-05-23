//api key = 38b19d794c1422d39a6452e99a6df31c

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Lottie

class WeatherViewController: UIViewController{
    
    //@IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var animationContainerView: UIView!
    
    var lottieAnimation: LottieAnimationView?
    
    @IBOutlet weak var favoriteButton: UIButton!
    //Branch commit denemesi
    
    var favorites: [FavoriteModel] = []
    var isFavorite: Bool = false
    var favCities: [String] = []
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var isUsingDeviceLocation = true
    
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTextField.delegate = self
        loadFavorites()
        //animationView.animation = LottieAnimation.named("rainy")
        //animationView.play()
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        isUsingDeviceLocation = true
        locationManager.requestLocation()
    }
    
    func isFavoriteCity(){
        if favCities.contains(cityLabel.text!){
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            isFavorite = true
        }else{
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            isFavorite = false
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        if !isFavorite{
            isFavorite = true
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            if let publisher = Auth.auth().currentUser?.email {
                db.collection("Favorites").addDocument(data: [
                    "usermail": publisher,
                    "cityName": cityLabel.text!
                ]){(error) in
                    if let e = error{
                        print("There was an issue saving data to firestore, \(e)")
                    }else{
                        print("Succesfully saved data")
                        self.loadFavorites()
                    }
                }
            }
        }else{
            isFavorite = false
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    func loadFavorites(){
        let db = Firestore.firestore()
        db.collection("Favorites")
            .addSnapshotListener{ querySnapshot, error in
                self.favorites = []
            
            if let e = error{
                print("Firestore couldnt get the data, \(e)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let usermail = data["usermail"] as? String,
                           let cityName = data["cityName"] as? String{
                            self.favCities.append(cityName)
                            let newFavorite = FavoriteModel(userMail: usermail, cityname: cityName)
                            self.favorites.append(newFavorite)
                            print(self.favorites[0].cityname)
                        }
                    }
                }
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        isFavoriteCity()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }else{
            textField.placeholder = "Type a city name."
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text{
            weatherManager.fetchWeather(cityName: city)
            isFavoriteCity()
            isUsingDeviceLocation = false
        }
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async{
            self.temperatureLabel.text = weather.temperatureString
            //self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.setupLottieAnimation(condition: weather.conditionName)
            self.updateBackground(for: weather.conditionName)
            self.cityLabel.text = weather.name
            self.isFavoriteCity()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, isUsingDeviceLocation{
            locationManager.startUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print("\(lat) - \(lon)")
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension WeatherViewController{
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
        backgroundImageView.image = UIImage(named: backgroundImageName)
    }
}
