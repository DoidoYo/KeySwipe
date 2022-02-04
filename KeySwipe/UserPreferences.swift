//
//  Preferences.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/25/22.
//

import Foundation
import Cocoa
import ServiceManagement
import SwiftUI

final class UserPreferences:ObservableObject {
    static let shared = UserPreferences()
    
    private static let key_trackpadDeadzone = "trackpadDeadzone"
    private static let default_trackpadDeadzone:Double = 2 //magnetude of swipes
    
    private static let key_quickPickerMouseDeadzone = "quickPickerMouseDeadzone"
    private static let default_quickPickerMouseDeadzone:Double = 5
    
    private static let key_quickPickerShowDistance = "quickPickerShowDistance"
    private static let default_quickPickerShowDistance:Double = 30
    
    private static let key_applicationsa = "applications"
    private static let default_applicationsa = [String](repeating: "", count: 8)
    
    private static let key_quickPickerEnabled = "quickPickerEnabled"
    private static let default_quickPickerEnabled:Bool = true //magnetude of swipes
    
    private static let key_quickPickeractivatingModifier = "quickPickeractivatingModifier"
    private static let default_quickPickeractivatingModifier:NSEvent.ModifierFlags = .control //magnetude of swipes
    
    private static let key_windowMoverActivatingModifier = "windowMoverActivatingModifier"
    private static let default_windowMoverActivatingModifier:NSEvent.ModifierFlags = .function //magnetude of swipes
    
    private static let key_windowMoverSmallGridModifier = "windowMoverSmallGridModifier"
    private static let default_windowMoverSmallGridModifier:NSEvent.ModifierFlags = .shift //magnetude of swipes
    
    init() {
        let defaults = UserDefaults.standard
        
        let trackpadSensitivity = defaults.object(forKey: UserPreferences.key_trackpadDeadzone) as? Double
        if trackpadSensitivity == nil {
            self.trackpadDeadzone = UserPreferences.default_trackpadDeadzone
            UserDefaults.standard.set(self.trackpadDeadzone, forKey: UserPreferences.key_trackpadDeadzone)
        } else {
            self.trackpadDeadzone = trackpadSensitivity!
        }
        
        let quickPickerMouseDeadzone = defaults.object(forKey: UserPreferences.key_quickPickerMouseDeadzone) as? Double
        if quickPickerMouseDeadzone == nil {
            self.quickPickerMouseDeadzone = UserPreferences.default_quickPickerMouseDeadzone
            UserDefaults.standard.set(self.quickPickerMouseDeadzone, forKey: UserPreferences.key_quickPickerMouseDeadzone)
        } else {
            self.quickPickerMouseDeadzone = quickPickerMouseDeadzone!
        }
        
        let quickPickerShowDistance = defaults.object(forKey: UserPreferences.key_quickPickerShowDistance) as? Double
        if quickPickerShowDistance == nil {
            self.quickPickerShowDistance = UserPreferences.default_quickPickerShowDistance
            UserDefaults.standard.set(self.quickPickerShowDistance, forKey: UserPreferences.key_quickPickerShowDistance)
        } else {
            self.quickPickerShowDistance = quickPickerShowDistance!
        }
        
        
        let applicationsa = defaults.object(forKey: UserPreferences.key_applicationsa) as? [String]
        if applicationsa == nil {
            self.applicationsa = UserPreferences.default_applicationsa
            UserDefaults.standard.set(self.applicationsa, forKey: UserPreferences.key_applicationsa)
        } else {
            self.applicationsa = applicationsa!
        }
        
        for i in 0..<self.applicationsa.count {
            let appName = self.applicationsa[i]
            let a = AppDelegate.applicationMetaData.filter{($0.name == appName)}
            self.applications.array[i] = (a.count > 0) ? a.first : nil
        }
        
        let quickPickerEnabled = defaults.object(forKey: UserPreferences.key_quickPickerEnabled) as? Bool
        if quickPickerEnabled == nil{
            self.quickPickerEnabled = UserPreferences.default_quickPickerEnabled
            UserDefaults.standard.set(UserPreferences.default_quickPickerEnabled, forKey: UserPreferences.key_quickPickerEnabled)
        } else{
            self.quickPickerEnabled = quickPickerEnabled!
        }
        
        let quickPickeractivatingModifier = defaults.object(forKey: UserPreferences.key_quickPickeractivatingModifier) as? NSEvent.ModifierFlags
        if quickPickeractivatingModifier == nil{
            self.quickPickeractivatingModifier = UserPreferences.default_quickPickeractivatingModifier
            UserDefaults.standard.set(UserPreferences.default_quickPickeractivatingModifier.rawValue, forKey: UserPreferences.key_quickPickeractivatingModifier)
        } else{
            self.quickPickeractivatingModifier = quickPickeractivatingModifier!
        }
        
        let windowMoverActivatingModifier = defaults.object(forKey: UserPreferences.key_windowMoverActivatingModifier) as? NSEvent.ModifierFlags
        if windowMoverActivatingModifier == nil{
            self.windowMoverActivatingModifier = UserPreferences.default_windowMoverActivatingModifier
            UserDefaults.standard.set(UserPreferences.default_windowMoverActivatingModifier.rawValue, forKey: UserPreferences.key_windowMoverActivatingModifier)
        } else{
            self.windowMoverActivatingModifier = windowMoverActivatingModifier!
        }
        
        let windowMoverSmallGridModifier = defaults.object(forKey: UserPreferences.key_windowMoverSmallGridModifier) as? NSEvent.ModifierFlags
        if windowMoverSmallGridModifier == nil{
            self.windowMoverSmallGridModifier = UserPreferences.default_windowMoverSmallGridModifier
            UserDefaults.standard.set(self.windowMoverSmallGridModifier.rawValue, forKey: UserPreferences.key_windowMoverSmallGridModifier)
        } else{
            self.windowMoverSmallGridModifier = windowMoverSmallGridModifier!
        }
    }
    @Published var windowMoverActivatingModifier: NSEvent.ModifierFlags {
        didSet{
            UserDefaults.standard.set(self.windowMoverActivatingModifier.rawValue, forKey: UserPreferences.key_windowMoverActivatingModifier)
        }
    }
    @Published var windowMoverSmallGridModifier: NSEvent.ModifierFlags {
        didSet{
            UserDefaults.standard.set(self.windowMoverSmallGridModifier.rawValue, forKey: UserPreferences.key_windowMoverSmallGridModifier)
        }
    }
    
    @Published var quickPickeractivatingModifier: NSEvent.ModifierFlags {
        didSet{
            UserDefaults.standard.set(self.quickPickeractivatingModifier.rawValue, forKey: UserPreferences.key_quickPickeractivatingModifier)
        }
    }
    
    @Published var quickPickerEnabled: Bool {
        didSet{
            UserDefaults.standard.set(self.quickPickerEnabled, forKey: UserPreferences.key_quickPickerEnabled)
            //            self.delegate?.onPreferencesChanged()
        }
    }
    
    var trackpadDeadzone: Double {
        didSet {
            UserDefaults.standard.set(self.trackpadDeadzone, forKey: UserPreferences.key_trackpadDeadzone)
            //            self.delegate?.onPreferencesChanged()
        }
    }
    
    var quickPickerMouseDeadzone: Double {
        didSet {
            UserDefaults.standard.set(self.quickPickerMouseDeadzone, forKey: UserPreferences.key_quickPickerMouseDeadzone)
            //            self.delegate?.onPreferencesChanged()
        }
    }
    
    var quickPickerShowDistance: Double {
        didSet {
            UserDefaults.standard.set(self.quickPickerShowDistance, forKey: UserPreferences.key_quickPickerShowDistance)
            //            self.delegate?.onPreferencesChanged()
        }
    }
    
    var applications: Applications = Applications()
    
    var applicationsa: [String]
    
    func saveApps() {
        for i in 0..<self.applications.array.count {
            self.applicationsa[i] = (self.applications.array[i] != nil) ? self.applications.array[i]!.name : ""
        }
        
        UserDefaults.standard.set(self.applicationsa, forKey: UserPreferences.key_applicationsa)
    }
    
    func reset() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        self.trackpadDeadzone = UserPreferences.default_trackpadDeadzone
    }
    
}
