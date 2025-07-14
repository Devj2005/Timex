//
//  UserRegistrationVC 2.swift
//  Timex App
//
//  Created by DEVYAN JETHWA on 25/04/2025.
//


//
//  UserRegistrationVC.swift
//  Timex App
//
//  Created by DEVYAN JETHWA on 26/02/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserRegistrationVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var dobPicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let dob = dobPicker.date

        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            showAlert(message: "All fields are required.")
            return
        }

        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email address.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert(message: "Signup failed: \(error.localizedDescription)")
            } else if let user = result?.user {
                // Save extra user info in Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "name": name,
                    "email": email,
                    "dob": dob.timeIntervalSince1970
                ]) { error in
                    if let error = error {
                        print("❌ Firestore error: \(error.localizedDescription)")
                    } else {
                        print("✅ User info saved in Firestore!")
                    }
                }

                // Save local flag for logged-in status
                UserDefaults.standard.set(true, forKey: "isRegistered")

                // Navigate to MainTabBarVC
                DispatchQueue.main.async {
                    if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarVC") as? UITabBarController {
                            sceneDelegate.window?.rootViewController = tabBarController
                            sceneDelegate.window?.makeKeyAndVisible()
                        } else {
                            self.showAlert(message: "Failed to load main screen.")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Email Validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Email Format Check
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField, let email = textField.text {
            if !isValidEmail(email) {
                showAlert(message: "Invalid email format. Please enter a valid email.")
            }
        }
    }

    // MARK: - Show Alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
