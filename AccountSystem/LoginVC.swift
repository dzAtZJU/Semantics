//
//  LoginVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/11.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import AuthenticationServices
import RealmSwift

class LoginVC: UIViewController {
    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let tmp = ASAuthorizationAppleIDButton()
        tmp.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
        return tmp
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let tmp = UIActivityIndicatorView(style: .large)
        tmp.color = .systemPurple
        tmp.hidesWhenStopped = true
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(appleSignInButton)
        view.addSubview(spinner)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appleSignInButton.size = .init(width: 169, height: 39)
        appleSignInButton.center = view.center
        spinner.center = view.center
    }
}

extension LoginVC {
    @objc func appleSignInButtonTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            fatalError()
        }
        if let givenName = appleIDCredential.fullName?.givenName {
            KeychainItem.currentUserName = givenName
        }
        guard let token = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
            fatalError()
        }
        
        spinner.startAnimating()
        RealmSpace.login(cred: Credentials.apple(idToken: token)) { _ in 
            RealmSpace.userInitiated.async {
                RealmSpace.userInitiated.publicRealm { publcRealm in
                    
                    RealmSpace.userInitiated.privatRealm { privateRealm in
                        privateRealm.queryOrCreateCurrentIndividual(userName: KeychainItem.currentUserName ?? String.random(ofLength: 6))
                        
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            NotificationCenter.default.post(name: .signedIn, object: nil)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
}
