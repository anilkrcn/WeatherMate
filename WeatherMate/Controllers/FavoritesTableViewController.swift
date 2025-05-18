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

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFavorites()
        tableView.rowHeight = 150
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

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell
        let fav = favorites[indexPath.row]
        
        //weatherManager.fetchWeather(cityName: fav.cityname)
        cell.cityLabel.text = fav.cityname

        return cell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
