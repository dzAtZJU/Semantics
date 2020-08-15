//
//  LoginVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/11.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginVC: UIViewController {
    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let tmp = ASAuthorizationAppleIDButton()
        tmp.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .darkGray
        
        view.addSubview(appleSignInButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appleSignInButton.size = .init(width: 169, height: 39)
        appleSignInButton.center = view.bounds.center
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
        guard let token = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
            fatalError()
        }
        
        if let givenName = appleIDCredential.fullName?.givenName {
            KeychainItem.currentUserName = givenName
        }
        
        AccountLayer.shared.login(appleToken: token) {
                DispatchQueue.main.async {
                    RealmSpace.shared.loadPublicRealm()
                    SemWorldDataLayer.shared
                                       .queryOrCreateCurrentIndividual(userName: "Paper") { _ in }
                    SemWorldDataLayer.shared.createMockData()
                    NotificationCenter.default.post(name: .signedIn, object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        fatalError()
    }
}
