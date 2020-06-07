//
//  SemanticsSetView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/24.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI
import CoreData

struct SemSetView: UIViewControllerRepresentable {
    
    let title: String
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    func updateUIViewController(_ uiViewController: SemSetVC, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> SemSetVC {
        let vc = SemSetVC(word: nil, title: title)
        vc.delegate = context.coordinator
        return vc
    }
    
    class Coordinator: SemSetVCDelegate {
        let parent: SemSetView
        
        init(parent: SemSetView) {
            self.parent = parent
        }
    }
}

//struct SemanticsSetView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let word = Word(context: context)
//        word.name = "word"
//        word.subWords = ["1", "23", "456"]
//        return SemanticsSetView(word: word)
//    }
//}
