//
//  FeelingDetail.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI

struct SemanticsSetAddingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var name: String = ""
    
    var body: some View {
        TextField("name", text: $name, onCommit: { 
            let word = Word(context: self.managedObjectContext)
            word.name = self.name
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalError("Unresolved error \(error)")
            }
        })
    }
}

struct SemanticsSetAddingView_Previews: PreviewProvider {
    static var previews: some View {
        SemanticsSetAddingView()
    }
}
