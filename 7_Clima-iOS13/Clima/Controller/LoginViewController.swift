//
//  LoginViewController.swift
//  Clima
//
//  Created by p10p093 on 2025/02/22.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        loginUser()
    }
    
    @IBAction func registerButton(_ sender: Any) {
        registerUser()
    }
    
    // 新規登録処理
    @objc func registerUser() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "メールアドレスとパスワードを入力してください")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "登録できません（\(error.localizedDescription)）")
            } else {
                self.showAlert(message: "ユーザー新規登録ができました！")
            }
        }
    }
    
    // ログイン処理
    @objc func loginUser() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "メールアドレスとパスワードを入力してください")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "ログインできません（\(error.localizedDescription)）")
            } else {
                // ログイン成功時
                self.showAlertWithCompletion(message: "ログインに成功しました") {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let weatherVC = storyboard.instantiateViewController(identifier: "WeatherViewController") as? WeatherViewController {
                            weatherVC.modalPresentationStyle = .fullScreen
                            self.present(weatherVC, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // アラート表示
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // アラート表示（完了後に処理を実行するバージョン）
        func showAlertWithCompletion(message: String, completion: @escaping () -> Void) {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion()
            })
            present(alert, animated: true)
        }
}
