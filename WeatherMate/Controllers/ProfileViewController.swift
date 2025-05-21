//
//  ProfileViewController.swift
//  WeatherMate
//
//  Created by Anıl Karacan on 18.05.2025.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if Auth.auth().currentUser == nil {
            redirectToLoginScreen()
        }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            displayUserEmail()
            setupSwitch()
            navigationItem.hidesBackButton = true
        }

      

        private func displayUserEmail() {
            if let user = Auth.auth().currentUser {
                mailLabel.text = "\(user.email ?? "Unknown Email")"
            } else {
                mailLabel.text = "Not logged in"
            }
        }


    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            showAlert(message: "You have been logged out.") {
                // Kullanıcıyı giriş ekranına yönlendirin
                self.navigationController?.popToRootViewController(animated: true)
            }
        } catch {
            showAlert(message: "Logout failed: \(error.localizedDescription)")
        }
    }
    
       

        private func showAlert(message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion?()
            }))
            present(alert, animated: true, completion: nil)
        }

        private func redirectToLoginScreen() {
            // Giriş ekranına yönlendirme işlemleri burada yapılır
            guard let window = UIApplication.shared.windows.first else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController")
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    
    func setupSwitch() {
            // Switch durumu UserDefaults'tan alınır
            themeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
            themeSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

            view.addSubview(themeSwitch)
        }
    
    @objc func switchChanged() {
            let isDarkMode = themeSwitch.isOn
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            applyTheme()
        }
    
    func applyTheme() {
            guard let window = UIApplication.shared.windows.first else { return }
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }

}
