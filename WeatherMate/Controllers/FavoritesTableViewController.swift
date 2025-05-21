//
//  FavoritesTableViewController.swift
//  WeatherMate
//
//  Created by Anıl Karacan on 17.05.2025.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FavoritesTableViewController: UITableViewController {
    
    var favorites: [FavoriteModel] = []
    var weatherManager = WeatherManager()
    
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
        loadFavorites()
        tableView.rowHeight = 150
        navigationItem.hidesBackButton = true
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
                            
                            let newFavorite = FavoriteModel(userMail: usermail, cityname: cityName)
                            self.favorites.append(newFavorite)
                            print(self.favorites[0].cityname)
                        }
                    }
                    
                }
            }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }
        
        
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, name: name, temperature: temp)
            return weather
            //print(weather.temperatureString)
        } catch{
            return nil
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell
        let fav = favorites[indexPath.row]
        
        //weatherManager.fetchWeather(cityName: fav.cityname)
        if let url = URL(string: "\(weatherManager.weatherURL)&q=\(fav.cityname)"){
            //Create URLSession
            let session = URLSession(configuration: .default)
            
            //Create Task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        DispatchQueue.main.async {
                            cell.cityLabel.text = weather.name
                            cell.temperatureLabel.text = weather.temperatureString
                            cell.weatherImage.image = UIImage(systemName: weather.conditionName)
                        }
                    }
                }
            }
            //Start Task
            task.resume()
        }
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    



}
