//api key = 38b19d794c1422d39a6452e99a6df31c

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class WeatherViewController: UIViewController{
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    var favorites: [FavoriteModel] = []
    var isFavorite: Bool = false
    var favCities: [String] = []
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
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
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
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
        }
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async{
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
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
        if let location = locations.last{
            locationManager.startUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
