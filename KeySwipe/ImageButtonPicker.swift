//
//  ImageButtonPicker.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/29/22.
//

import SwiftUI

struct ImageButtonPicker: View {
    
    var allApplication:[Application] = AppDelegate.applicationMetaData
    
    var body: some View {
        Menu() {
            Button {
                
            } label: {
                Image(nsImage: resize(image: NSImage(imageLiteralResourceName: "plus"), w: 40, h: 40))
                Text("None")
            }
            
            ForEach(0..<allApplication.count) { i in
                let app = allApplication[i]
                Button {
                    
                } label: {
                    Image(nsImage: resize(image: app.icon, w: 40, h: 40))
                    Text(app.name)
                }
            }
            
        } label: {
            Button {
                
            } label: {
                Image(nsImage: resize(image: NSImage(imageLiteralResourceName: "plus"), w: 80, h: 80))
            }
            
        }.menuStyle(.borderlessButton)
    }
}

struct ImageButtonPicker_Previews: PreviewProvider {
    static var previews: some View {
        ImageButtonPicker()
    }
}
