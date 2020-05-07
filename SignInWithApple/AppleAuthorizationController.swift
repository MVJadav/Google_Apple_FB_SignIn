//
//  AppleAuthorizationController.swift
//  SignInWithApple
//
//  Created by Mehul Jadav on 13/12/19.
//  Copyright © 2019 mac. All rights reserved.
//
/*
 
****************** Read Me ******************
 
 1. First add 'Sign In with Apple' from Signin & Capabilities.
 = >Add the Sign In with Apple capability in your project. This will add an entitlement that lets your app use Sign In with Apple.
 
 2. You need to add 'Sign In with Apple' into Apple identifier from https://developer.apple.com
    and you can Edit 'Enable as primary App ID' OR 'Group with an existing primary App ID'.
 => Configuring your Apple Developer Account
 When you try to sign in, you'll see an AUTH_ALERT_SIGN_UP_NOT_COMPLETED error message. Signing in won't work in your application until you create a key with Sign in with Apple enabled in your developer account.
 
*/


import Foundation
import AuthenticationServices


class AppleAuthorizationController : NSObject {

    public static let `default` = AppleAuthorizationController()
    var viewController : UIViewController = UIViewController()
    
    var signInWithAppleCompletion:((_ result:AppleUser?, _ status: Bool) -> Void)? = nil

    func showMessage(message : String) {
        let alert = UIAlertController(title: "Sign in with your Apple ID", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.viewController.present(alert, animated: true)
    }
    
}

//MARK:- ASAuthorization Controller Delegate Methods
@available(iOS 13.0, *)
extension AppleAuthorizationController : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func signIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controll = ASAuthorizationController(authorizationRequests: [request])
        controll.delegate = self
        controll.presentationContextProvider = self
        controll.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    
                    print("User Id - \(appleIDCredential.user)")
                    print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
                    print("User Email - \(appleIDCredential.email ?? "N/A")")
                    print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")
                    
                    if let identityTokenData = appleIDCredential.identityToken,
                        let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                        print("Identity Token \(identityTokenString)")
                    }
            self.signInWithAppleCompletion?(AppleUser(credentials: appleIDCredential), true)
                    
                }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("somthing bad happened : ", error)
        self.showMessage(message: error.localizedDescription)
        self.signInWithAppleCompletion?(nil, false)
        
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.viewController.view.window! //view.window!
    }
    
}


//MARK:- Apple User Model
class AppleUser {
    lazy var id              : String = ""
    lazy var firstName       : String = ""
    lazy var lastName        : String = ""
    lazy var email           : String = ""
    lazy var status          : Int = 0
    lazy var identityToken   : String = ""
    
    required init() {
        
    }
    
    @available(iOS 13.0, *)
    init(credentials:ASAuthorizationAppleIDCredential) {
        self.id             = credentials.user
        self.firstName      = credentials.fullName?.givenName ?? ""
        self.lastName       = credentials.fullName?.familyName ?? ""
        self.email          = credentials.email ?? ""
        self.status         = credentials.realUserStatus.rawValue
        if let identityTokenData = credentials.identityToken, let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
            self.identityToken = identityTokenString
        } else {
            self.identityToken = ""
        }
        
    }
    
    
    
}

