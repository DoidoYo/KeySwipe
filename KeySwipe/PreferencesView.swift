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
            GroupBox(label: Text("General").bold()) {
                HStack(){
                    Text("Launch at login:").frame(width: 150, alignment: .trailing)
                    LaunchAtLogin.Toggle().labelsHidden().frame(width: 100, alignment: .leading)
                }
            }
            
            GroupBox(label: Text("Window Mover").bold()) {
                HStack(){
                    Text("Activation Key:").frame(width: 150, alignment: .trailing)
                    Group{
                        KeyPicker(key: self.$defaults.windowMoverActivatingModifier).frame(width: 100, alignment: .leading)
                    }.frame(width: 100,alignment: .leading)
                }
                HStack(){
                    Text("3x3 Grid Modifier Key:").frame(width: 150, alignment: .trailing)
                    Group{
                        KeyPicker(key: self.$defaults.windowMoverSmallGridModifier).frame(width: 100, alignment: .leading)
                    }.frame(width: 100,alignment: .leading)
                }
            }
            GroupBox(label: Text("Quick Picker").bold()) {
                HStack(){
                    Text("Enabled:").frame(width: 150, alignment: .trailing)
                    Toggle("", isOn: self.$defaults.quickPickerEnabled).labelsHidden().frame(width: 100, alignment: .leading)
                }
                HStack(){
                    Text("Activation Key:").frame(width: 150, alignment: .trailing)
                    Group{
                        KeyPicker(key: self.$defaults.quickPickeractivatingModifier).frame(width: 100, alignment: .leading)
                    }.frame(width: 100,alignment: .leading)
                }
                Spacer().frame(height: 20)
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
            }
        }.padding()
        
//        Toggle("Enabled", isOn: self.$defaults.quickPickerEnabled)
        //                    Spacer()
        //                    Preferences.Section(title: "Activation Key:") {
        //                        Preferences.Section(title: "") {
        //                            KeyPicker(key: self.$defaults.quickPickeractivatingModifier).frame(width: 120.0)
        //                        }
        //                    }
        //        VStack {
        //
        //
        //
        //            GroupBox(label: Text("General").bold()) {
        //                Preferences.Section(title: "Launch at login:") {
        //                    Preferences.Section(title: "") {
        //                        LaunchAtLogin.Toggle().labelsHidden()
        //                    }
        //                }
        //            }.frame(width: 500)
        //            Spacer()
        //            GroupBox(label: Text("Window Mover").bold()) {
        //                Preferences.Section(title: "Activation Key:") {
        //                    Preferences.Section(title: "") {
        //                        KeyPicker(key: self.$defaults.windowMoverActivatingModifier).frame(width: 100.0)
        //                    }
        //                }
        //                Preferences.Section(title: "3x3 Grid Modifier Key:") {
        //                    Preferences.Section(title: "") {
        //                        KeyPicker(key: self.$defaults.windowMoverSmallGridModifier).frame(width: 100.0)
        //                    }
        //                }
        //            }.frame(width: 500)
        //            Spacer()
        //        }.padding()
        
        
        //            VStack {
        //            Spacer()
        //                GroupBox(label: Text("General").bold()) {
        //                    LaunchAtLogin.Toggle().padding()
        //                }.frame(width: .infinity)
        //                Spacer()
        //                GroupBox(label: Text("Window Snapping").bold()) {
        //
        //                    Preferences.Section(title: "Activation Key:") {
        //                        Preferences.Section(title: "") {
        //                            KeyPicker(key: self.$defaults.windowMoverActivatingModifier).frame(width: 120.0)
        //                        }
        //                    }
        //                    //                Spacer()
        //                    Preferences.Section(title: "3x3 Grid Modifier Key:") {
        //                        Preferences.Section(title: "") {
        //                            KeyPicker(key: self.$defaults.windowMoverSmallGridModifier).frame(width: 120.0)
        //                        }
        //                    }
        //
        //                }
        //                Spacer()
        //                GroupBox(label: Text("Quick Picker").bold()) {
        //                    Toggle("Enabled", isOn: self.$defaults.quickPickerEnabled)
        //                    Spacer()
        //                    Preferences.Section(title: "Activation Key:") {
        //                        Preferences.Section(title: "") {
        //                            KeyPicker(key: self.$defaults.quickPickeractivatingModifier).frame(width: 120.0)
        //                        }
        //                    }
        //                    HStack {
        //                        //picker view
        //                        VStack {
        //                            HStack {
        //                                ImageButtonPicker(idx: 0)
        //                                ImageButtonPicker(idx: 1)
        //                                ImageButtonPicker(idx: 2)
        //                            }
        //                            HStack {
        //                                ImageButtonPicker(idx: 3)
        //                                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
        //                                ImageButtonPicker(idx: 4)
        //                            }
        //                            HStack {
        //                                ImageButtonPicker(idx: 5)
        //                                ImageButtonPicker(idx: 6)
        //                                ImageButtonPicker(idx: 7)
        //                            }
        //                        }
        //                    }//.padding()
        ////                }
        //            }
        //        }.padding()
    }
}

struct KeyPicker: View {
    
    @Binding var key:NSEvent.ModifierFlags
    
    var body: some View {
        Menu {
            Button {
                key = .function
            } label: {
                Text("fn")
            }
            Button {
                key = .shift
            } label: {
                Text("⇧ shift")
            }
            Button {
                key = .control
            } label: {
                Text("⌃ control")
            }
            Button {
                key = .option
            } label: {
                Text("⌥ option")
            }
            Button {
                key = .command
            } label: {
                Text("⌘ command")
            }
            
        } label: {
            switch key {
            case .function:
                Text("fn")
            case .option:
                Text("⌥ option")
            case.shift:
                Text("⇧ shift")
            case.control:
                Text("⌃ control")
            case.command:
                Text("⌘ command")
            default:
                Text("Error")
            }
        }
    }
    
}

struct GeneralView: View {
    
    var body: some View {
        Color.red
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
