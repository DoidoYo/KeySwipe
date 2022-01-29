//
//  testpref.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/28/22.
//

import SwiftUI
import Preferences


extension Preferences.PaneIdentifier {
    static let general = Self("general")
}

let PreferencesGeneralViewController: () -> PreferencePane = {
    /// Wrap your custom view into `Preferences.Pane`, while providing necessary toolbar info.
    
    
    
    let paneView = Preferences.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Accounts preferences")!
    ) {
        PreferencesGeneralView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

struct PreferencesGeneralView: View {
    @State private var colorSelecction = 0
        @State private var autoCloseWindowEditor = false
        @State private var notesSizeInGrid = 0.0
        @State private var autoCloseWindowTimer = 0
        
        private let contentWidth: Double = 600
        
        var body: some View {
            Preferences.Container(contentWidth: contentWidth) {
                Preferences.Section(title: "Default color:") {
                    Preferences.Section(title: "") {
                        Picker("", selection: $colorSelecction) {
                            Text("Yellow").tag(0)
                            Text("Pink").tag(1)
                        }
                        .labelsHidden()
                        .frame(width: 120.0)
                    }
                }
                Preferences.Section(title: "Grid notes size:") {
                    Preferences.Section(title: "") {
                        Slider(value: $notesSizeInGrid, in: 0...2, step: 1)
                    }
                }
                Preferences.Section(label: {
                    Toggle("Auto close editor window", isOn: $autoCloseWindowEditor)
                }) {
                    Picker("", selection: $autoCloseWindowTimer) {
                        Text("After 1 minute").tag(0)
                        Text("After 3 minute").tag(1)
                        Text("After 5 minute").tag(2)
                    }
                        .labelsHidden()
                        .frame(width: 120.0)
                    Text("The app will automatically close the window and save the note.")
                        .preferenceDescription()
                }
            }
        }
}

struct testpref_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesGeneralView()
    }
}
