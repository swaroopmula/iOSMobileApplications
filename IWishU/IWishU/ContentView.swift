//
//  ContentView.swift
//  IWishU
//
//  Created by Swaroop Mula on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: IWishUDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(IWishUDocument()))
}
