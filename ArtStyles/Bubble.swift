//
//  Bubble.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import UIKit

class InspriationView: UIView {
    static private let D: CGFloat = 180
    static private let W: CGFloat = 108
    static private let H: CGFloat = 144
    
    private let bubbleBg: UIImageView = {
        let bubbleImage = UIImage(named: "bubble")!.scaled(toWidth: InspriationView.D)!
        
        let hue = CGFloat.random(in: 0...1)
        let bubbleColor = UIColor(hue: hue, saturation: 0.6, brightness: 0.7, alpha: 1)
        
        UIGraphicsBeginImageContextWithOptions(bubbleImage.size, false, 0.0)
        bubbleColor.setFill()
        let bounds = CGRect(x: 0, y: 0, width: bubbleImage.size.width, height: bubbleImage.size.height)
        UIRectFill(bounds)
        bubbleImage.draw(in: bounds, blendMode: .overlay, alpha: 1.0)
        bubbleImage.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        let coloredBubbleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let tmp = UIImageView(image: coloredBubbleImage)
        tmp.size = bubbleImage.size
        return tmp
    }()
    
    private let nameLabel: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.numberOfLines = 0
        
        return tmp
    }()
    
    init(text: String) {
        super.init(frame: bubbleBg.frame)
        
        addSubview(bubbleBg)
        
        addSubview(nameLabel)
        nameLabel.anchorCenterSuperview()
        nameLabel.widthAnchor.constraint(equalToConstant: Self.W).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Self.H).isActive = true
        nameLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
