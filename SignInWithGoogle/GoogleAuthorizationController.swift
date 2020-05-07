//
//  GoogleAuthorizationController.swift
//  CCMessenger
//
//  Created by Mehul Jadav on 04/03/20.
//  Copyright © 2020 Sudipta Biswas. All rights reserved.
//

import Foundation
import GoogleSignIn

class GoogleAuthorizationController : NSObject {
    
    public static let `default` = GoogleAuthorizationController()
    var viewController : UIViewController = UIViewController()
    
    var googleLoginCompletion:((_ result:GoogleUser?, _ status: Bool) -> Void)? = nil

    func showMessage(message : String) {
        let alert = UIAlertController(title: "Sign in with your Apple ID", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.viewController.present(alert, animated: true)
    }
    
    ///Logout from previos session
    func logout(){
        GIDSignIn.sharedInstance().signOut()
    }
    
}


//MARK: Google GIDSignInDelegate method
extension GoogleAuthorizationController: GIDSignInDelegate {
    
    func loginWithGoogle() {
        GoogleAuthorizationController.default.logout()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self.viewController
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            if let error = error {
                print("\(error.localizedDescription)")
                self.googleLoginCompletion?(nil, false)
            } else {
                let userModel = GoogleUser()
                userModel.id = user.userID
                if !user.profile.name.isEmpty {
                    let names = user.profile.name.components(separatedBy: " ")
                    userModel.firstName = names[0]
                    if names.count > 1 {
                        userModel.lastName = names[1]
                    }
                    userModel.name = user.profile.name
                }
                userModel.email = user.profile.email
                if user.profile.hasImage {
                    if let url = user.profile.imageURL(withDimension: 100) {
                        userModel.pictureUrl = url.absoluteString
                    }
                }
                self.googleLoginCompletion?(userModel, true)
            }
        }
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
            print("\(error.localizedDescription)")
            self.googleLoginCompletion?(nil, false)
        }
}



//MARK:- Apple User Model
class GoogleUser {
    lazy var id              : String = ""
    lazy var firstName       : String = ""
    lazy var lastName        : String = ""
    lazy var name            : String = ""
    lazy var email           : String = ""
    lazy var status          : Int = 0
    lazy var identityToken   : String = ""
    lazy var pictureUrl      : String = ""
    
    required init() {
        
    }

}

