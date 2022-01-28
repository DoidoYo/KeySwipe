//
//  Preferences.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/25/22.
//

import Foundation
import Cocoa
import ServiceManagement

final class Preferences {
    static let shared = Preferences()
    
    private static let key_trackpadDeadzone = "trackpadDeadzone"
    private static let default_trackpadDeadzone:Double = 2 //magnetude of swipes
    
    private static let key_quickPickerMouseDeadzone = "quickPickerMouseDeadzone"
    private static let default_quickPickerMouseDeadzone:Double = 5
    
    private static let key_quickPickerShowDistance = "quickPickerShowDistance"
    private static let default_quickPickerShowDistance:Double = 30
    
    private static let key_applicationsa = "applications"
    private static let default_applicationsa = [String](repeating: "", count: 8)
    
    init() {
        let defaults = UserDefaults.standard
        
        let trackpadSensitivity = defaults.object(forKey: Preferences.key_trackpadDeadzone) as? Double
        if trackpadSensitivity == nil {
            self.trackpadDeadzone = Preferences.default_trackpadDeadzone
            UserDefaults.standard.set(self.trackpadDeadzone, forKey: Preferences.key_trackpadDeadzone)
        } else {
            self.trackpadDeadzone = trackpadSensitivity!
        }
        
        let quickPickerMouseDeadzone = defaults.object(forKey: Preferences.key_quickPickerMouseDeadzone) as? Double
        if quickPickerMouseDeadzone == nil {
            self.quickPickerMouseDeadzone = Preferences.default_quickPickerMouseDeadzone
            UserDefaults.standard.set(self.quickPickerMouseDeadzone, forKey: Preferences.key_quickPickerMouseDeadzone)
        } else {
            self.quickPickerMouseDeadzone = quickPickerMouseDeadzone!
        }
        
        let quickPickerShowDistance = defaults.object(forKey: Preferences.key_quickPickerShowDistance) as? Double
        if quickPickerShowDistance == nil {
            self.quickPickerShowDistance = Preferences.default_quickPickerShowDistance
            UserDefaults.standard.set(self.quickPickerShowDistance, forKey: Preferences.key_quickPickerShowDistance)
        } else {
            self.quickPickerShowDistance = quickPickerShowDistance!
        }
        

        let applicationsa = defaults.object(forKey: Preferences.key_applicationsa) as? [String]
        if applicationsa == nil {
            self.applicationsa = Preferences.default_applicationsa
            UserDefaults.standard.set(self.applicationsa, forKey: Preferences.key_applicationsa)
        } else {
            self.applicationsa = applicationsa!
        }
        for i in 0..<self.applicationsa.count {
            let a = AppDelegate.applicationMetaData.filter{($0.name == self.applicationsa[i])}
            self.applications.array[i] = (a.count > 0) ? a.first : nil
        }
    }

    var trackpadDeadzone: Double {
        didSet {
            UserDefaults.standard.set(self.trackpadDeadzone, forKey: Preferences.key_trackpadDeadzone)
//            self.delegate?.onPreferencesChanged()
        }
    }
    
    var quickPickerMouseDeadzone: Double {
        didSet {
            UserDefaults.standard.set(self.quickPickerMouseDeadzone, forKey: Preferences.key_quickPickerMouseDeadzone)
//            self.delegate?.onPreferencesChanged()
        }
    }
    
    var quickPickerShowDistance: Double {
        didSet {
            UserDefaults.standard.set(self.quickPickerShowDistance, forKey: Preferences.key_quickPickerShowDistance)
//            self.delegate?.onPreferencesChanged()
        }
    }
    
    var applications: Applications = Applications()
    
    var applicationsa: [String]
    
    func saveApps() {
        for i in 0..<self.applications.array.count {
            self.applicationsa[i] = (self.applications.array[i] != nil) ? self.applications.array[i]!.name : ""
        }
        
        UserDefaults.standard.set(self.applicationsa, forKey: Preferences.key_applicationsa)
    }
    
    func reset() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        self.trackpadDeadzone = Preferences.default_trackpadDeadzone
    }
    
}
