//
//  PreferencesView.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/28/22.
//

import SwiftUI
import AppKit
import Preferences

let PreferencesViewController: () -> PreferencePane = {
    /// Wrap your custom view into `Preferences.Pane`, while providing necessary toolbar info.
    
    let a = Applications()
    a.array = UserPreferences.shared.applications.array
    
    let paneView = Preferences.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Accounts preferences")!
    ) {
        //        PreferencesView(allApplication: AppDelegate.applicationMetaData).environmentObject(a)
        PreferencesView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}

struct PreferencesView: View {
    var body: some View {
        ImageButtonPicker()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}

func resize(image: NSImage, w: Int, h: Int) -> NSImage {
    var destSize = NSMakeSize(CGFloat(w), CGFloat(h))
    var newImage = NSImage(size: destSize)
    newImage.lockFocus()
    image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: .sourceOver, fraction: CGFloat(1))
    newImage.unlockFocus()
    newImage.size = destSize
    return NSImage(data: newImage.tiffRepresentation!)!
}
