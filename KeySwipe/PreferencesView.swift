//
//  PreferencesView.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/28/22.
//

import SwiftUI
import AppKit
import Preferences
import LaunchAtLogin

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
    
    @ObservedObject var defaults = UserPreferences.shared
    
    var body: some View {
        //        LaunchAtLogin.Toggle()
        VStack {
            LaunchAtLogin.Toggle()
            HStack {
                //picker view
                VStack {
                    HStack {
                        ImageButtonPicker(idx: 0)
                        ImageButtonPicker(idx: 1)
                        ImageButtonPicker(idx: 2)
                    }
                    HStack {
                        ImageButtonPicker(idx: 3)
                        Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                        ImageButtonPicker(idx: 4)
                    }
                    HStack {
                        ImageButtonPicker(idx: 5)
                        ImageButtonPicker(idx: 6)
                        ImageButtonPicker(idx: 7)
                    }
                }
                
                Toggle("QuickPicker Enabled", isOn: self.$defaults.quickPickerEnabled)
            }//.padding()
        }.padding()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        return nil
    }
}
