//
//  ImageButtonPicker.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/29/22.
//

import SwiftUI

struct ImageButtonPicker: View {
    
    var idx:Int
    
    @State private var list_idx:Int?
    @State private var app:Application?
    
    let allApplication:[Application] = AppDelegate.applicationMetaData
    
    static var allApplication_icon_small = AppDelegate.applicationMetaData.map{$0.icon.resized(to: NSSize(width: 50, height: 50))}
    
    static let plus = NSImage(imageLiteralResourceName: "plus").resized(to: NSSize(width: 50, height: 50))!
    
    init(idx:Int) {
        self.idx = idx
        _app = State(wrappedValue: UserPreferences.shared.applications.array[idx])
        if app != nil {
            _list_idx = State(wrappedValue: allApplication.firstIndex(where: { $0.name == app?.name}))
        }
    }
    
    var body: some View {
        
        Menu() {
            Button {
                app = nil
                list_idx = nil
                UserPreferences.shared.applications.array[self.idx] = app
                save()
            } label: {
                Image(nsImage: ImageButtonPicker.plus)
                Text("None")
            }
            
            ForEach(0..<allApplication.count) { i in
                Button {
                    app = allApplication[i]
                    list_idx = i
                    UserPreferences.shared.applications.array[self.idx] = app
                    save()
                } label: {
                    Image(nsImage: ImageButtonPicker.allApplication_icon_small[i]!)
                    Text(allApplication[i].name)
                }
            }
            
        } label: {
            
            if app == nil {
                Image(nsImage: ImageButtonPicker.plus)
            } else {
                Image(nsImage: ImageButtonPicker.allApplication_icon_small[list_idx!]!)
                //.resized(to: NSSize(width: 50, height: 50))
            }
            
        }.menuStyle(.borderlessButton)
    }
    
    func save() {
        DispatchQueue.global(qos: .userInitiated).async {
            UserPreferences.shared.saveApps()
        }
    }
}

struct ImageButtonPicker_Previews: PreviewProvider {
    static var previews: some View {
        ImageButtonPicker(idx: 0)
    }
}
