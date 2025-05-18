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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if Auth.auth().currentUser == nil {
            redirectToLoginScreen()
        }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            displayUserEmail()
        }

        private func setupUI() {
            // UISwitch'in durumu, sistemin mevcut arayüz stiline göre ayarlanır.
            themeSwitch.isOn = traitCollection.userInterfaceStyle == .dark
            themeSwitch.addTarget(self, action: #selector(themeSwitchToggled), for: .valueChanged)
        }

        private func displayUserEmail() {
            if let user = Auth.auth().currentUser {
                mailLabel.text = "Logged in as: \(user.email ?? "Unknown Email")"
            } else {
                mailLabel.text = "Not logged in"
            }
        }

        @IBAction func logoutButtonTapped(_ sender: UIButton) {
            do {
                try Auth.auth().signOut()
                showAlert(message: "You have been logged out.") {
                    // Kullanıcıyı giriş ekranına yönlendirin
                    self.redirectToLoginScreen()
                }
            } catch {
                showAlert(message: "Logout failed: \(error.localizedDescription)")
            }
        }

        @objc private func themeSwitchToggled() {
            let isDarkMode = themeSwitch.isOn
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            updateAppTheme(isDarkMode: isDarkMode)
        }

        private func updateAppTheme(isDarkMode: Bool) {
            overrideUserInterfaceStyle = isDarkMode ? .dark : .light
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

}
