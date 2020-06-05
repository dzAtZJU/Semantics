//
//  CircleImage.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    let image: Image
    
    var body: some View {
        image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image: landmarkData[0].image)
    }
}
