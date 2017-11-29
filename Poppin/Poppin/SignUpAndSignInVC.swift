//
//  SignUpAndSignInVC.swift
//  SamadeA-Poppin
//
//  Created by AbdulSamade on 10/27/17.
//  Copyright © 2017 AbdulSamade. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SignUpAndSignInVC: UIViewController {

    var handle: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func signinButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            if user != nil && error == nil {
                self.performSegue(withIdentifier: "HomeMapVC", sender: "")
                print("LOGIN : The user is logged in now as \(user?.email!)")
                print("LOGIN : The user is logged in now as \(user?.email!)")
                print("LOGIN : The user is logged in now as \(user?.email!)")
            } else {
                print("Here is the error: \(error)")
                print("Here is the user: \(user)")
            }

        }

    }

    @IBAction func signupButton(_ sender: Any) {

        let alert = UIAlertController(title: "Signup", message: "Sign up", preferredStyle: .alert)

        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }

        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"

        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            guard let email = alert.textFields?[0].text,
                let password = alert.textFields?[1].text else {
                return
            }
            Auth.auth().createUser(withEmail: email, password: password) {
                (user, error) in
                if let error = error {
                    print("We got an error signing up.", error)
                    return
                }
                Auth.auth().signIn(withEmail: email, password: password) {
                    (user, error) in
                    if let error = error {
                        print("We got an error while we were signing in.", error)
                    return
                    }
                    if let user = user {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "HomeMapVC", sender: nil)
                        }
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    override func viewDidLoad() {
        super.viewDidLoad()

//        Auth.auth().createUser(withEmail: "abdul_samade001@yahoo.com", password: "Password") { (user, error) in }
    }
}




