//
//  PlaceVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/19.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Combine

protocol PlaceVCDelegate {
    func placeVCShouldStartFeedback(_ placeVC: PlaceVC)
    
    func placeVCShouldMarkVisited(_ placeVC: PlaceVC)
    
    func placeVCShouldDiscoverNext(_ placeVC: PlaceVC)
    
    func placeWillDisappear(_ placeVC: PlaceVC)
}

class PlaceVC: UIViewController, PanelContent {
    var panelContentVM: PanelContentVM!
    
    var vm: PlaceVM! {
        didSet {
            placeStateToken = vm.$placeState.sink { newValue in
                DispatchQueue.main.async {
                    switch newValue {
                    case .neverBeen:
                        self.stackView.addArrangedSubview(self.markVisitedBtn)
                        self.stackView.removeArrangedSubview(self.feedbackBtn)
                        self.feedbackBtn.removeFromSuperview()
                        self.stackView.removeArrangedSubview(self.findNextBtn)
                        self.findNextBtn.removeFromSuperview()
                        break
                    case .visited, .feedbacked:
                        self.stackView.removeArrangedSubview(self.markVisitedBtn)
                        self.markVisitedBtn.removeFromSuperview()
                        self.stackView.addArrangedSubview(self.feedbackBtn)
                        self.stackView.addArrangedSubview(self.findNextBtn)
                        break
                    }
                }
            }
        }
    }
    var placeStateToken: AnyCancellable?
    
    var panelContentDelegate: PanelContentDelegate!
    let showBackBtn = true
    
    var delegate: PlaceVCDelegate?
    
    private lazy var stackView: UIStackView = {
        let tmp = UIStackView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.axis = .horizontal
        tmp.alignment = .center
        tmp.spacing = 30
        return tmp
    }()
    
    private lazy var markVisitedBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.setTitleForAllStates("Visited")
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(markVisitedBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tmp
    }()
    
    private lazy var feedbackBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.setTitleForAllStates("Feedback")
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(feedbackBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tmp
    }()
    
    private lazy var findNextBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.setTitleForAllStates("Find Next")
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(findNextBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 10).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.placeWillDisappear(self)
    }
    
}

// MARK: Interaction
extension PlaceVC {
    @objc private func feedbackBtnTapped() {
        delegate?.placeVCShouldStartFeedback(self)
    }
    
    @objc private func markVisitedBtnTapped() {
        delegate?.placeVCShouldMarkVisited(self)
    }
    
    @objc private func findNextBtnTapped() {
        delegate?.placeVCShouldDiscoverNext(self)
    }
}
