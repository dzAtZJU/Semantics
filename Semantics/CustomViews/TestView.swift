//
//  TestView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/25.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI
import Combine

struct TestView: View {
    @State private var text = ""

    var body: some View {
        VStack {
            Spacer()
            
            TextField("Enter something", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .keyboardAdaptive()
    }
}
struct DetailView: View {

    @Binding var isActive: Bool
    @Binding var code: String

    var body: some View {
        Button(action: {
            self.code = "new code"
            self.isActive.toggle()
        }) {
            Text("Back")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
