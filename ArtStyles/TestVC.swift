//
//  TestVC.swift
//  SemanticsTests
//
//  Created by Zhou Wei Ran on 2020/7/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Jelly

class TestVC: UIViewController {
    override func viewDidLoad() {
        let textView = UITextView(frame: view.bounds)
        textView.layoutManager.delegate = self
        view.addSubview(textView)
    }
}

extension TestVC: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
    //        let characterRange = NSRange(lower: charIndexes[0], includedUpper: charIndexes[glyphRange.length - 1])
    //        let hiddenRanges = SemStyle.verticalLineOrBulletRegx.matches(in: text, range: characterRange).map(by: \.range)
    //        guard !hiddenRanges.isEmpty else {
    //            return 0
    //        }

        print("glyph: \(glyphRange)")
            var propsCopy = [NSLayoutManager.GlyphProperty]()
            for i in 0..<glyphRange.length {
                let charIndex = charIndexes[i]
                var prop = props[i]
                if layoutManager.textStorage!.mutableString.substring(with: NSRange(location: charIndex, length: 1)) == "*" {
                    prop.insert(.null)
                }
    //            if hiddenRanges.firstIndex(where: {
    //                $0.contains(charIndex)
    //            }) != nil {
    //                prop.insert(.null)
    //            }
                propsCopy.append(prop)
            }
            propsCopy.withUnsafeBufferPointer { bufferPointer in
                layoutManager.setGlyphs(glyphs, properties: bufferPointer.baseAddress!, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
            }
            return glyphRange.length
        }
    }
    //class TestVC: UIViewController {
    //    var animator: Jelly.Animator?
    //
    //    let newVC = SideVC()
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        view.backgroundColor = .systemPink
    //        view.cornerRadius = 50
    //
    //
    //        let interaction = InteractionConfiguration(presentingViewController: self, completionThreshold: 0.5, dragMode: .canvas)
    //        let uiConfigs = PresentationUIConfiguration(backgroundStyle: .dimmed(alpha: 0.7))
    //        let slide = SlidePresentation(uiConfiguration: uiConfigs, direction: .left, size: .custom(value: 340), parallax: 0.1, interactionConfiguration: interaction)
    //        animator = Animator(presentation: slide)
    //        animator?.prepare(presentedViewController: newVC)
    //    }
    //}
    //
    //class SideVC: UIViewController {
    //    override func viewDidLoad() {
    //        view.backgroundColor = .systemYellow
    //        view.cornerRadius = 50
    //
    //        let imgView = UIImageView(image: UIImage(named: "mimosa_pudica")!)
    //        imgView.frame = view.bounds
    //        imgView.contentMode = .scaleAspectFill
    //        imgView.clipsToBounds = true
    //        imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    //        view.addSubview(imgView)
    //    }
