//
//  AppDelegate.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import AppKit
import SwiftUI
import Cocoa
import Swindler
import Sparkle
import Preferences
import AXSwift
import Signals

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, KeyboardListenerDelegate, NSMenuDelegate {
    
    var keyboardListener:KeyboardListener!
    
    var swindler: Swindler.State!
    var functionalityManager: FunctionalityManager? = nil
    
    let updaterController: SPUStandardUpdaterController
    
    private lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            PreferencesViewController()
        ],
        style: .toolbarItems,
        animated: true,
        hidesToolbarForSingleItem: false
    )
    
    static var focusedWindow: Window? = nil
    static var applicationMetaData = AppSearcher().getAllApplications().sorted(by: {$0.name < $1.name})
    static var applications:Applications = Applications()
    
    var statusItem:NSStatusItem!// = NSStatusBar.system.statusItem(withLength: 28)
    
    override init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        //load apps
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = self.statusItem.button {
            button.image = #imageLiteral(resourceName: "menubar")
            button.image?.size = NSSize(width: 18.0, height: 18.0)
            button.image?.isTemplate = true
        }
        
        Swindler.initialize().done { state in
            self.swindler = state
            self.functionalityManager = FunctionalityManager(swindler: self.swindler)
            self.functionalityManager?.test()
        }.catch { error in
            print("Fatal error: failed to initialize Swindler: \(error)")
            NSApp.terminate(self)
        }
        
        if checkAccessibilityPermissions() {
            setupMenu()
            //            Preferences.shared.setDelegate(self)
            self.keyboardListener = KeyboardListener()
            self.keyboardListener.setDelegate(self)
            
            //            self.setupAboutWindow()
            //            self.onPreferencesChanged()
            
        } else {
            //            Does not work for some reason, cannot close modal
            let warnAlert = NSAlert()
            warnAlert.messageText = "Accessibility permissions needed";
            warnAlert.informativeText = "Penc relies upon having permission to 'control your computer'. If the permission prompt did not appear automatically, go to System Preferences, Security & Privacy, Accessibility, and add Penc to the list of allowed apps. Then relaunch Penc."
            warnAlert.layout()
            warnAlert.runModal()
            NSApplication.shared.terminate(self)
        }
        
        
    }
    
    func setupMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        //        let aboutMenuItem = NSMenuItem(title: "About Penc", action: #selector(AppDelegate.openAboutWindow(_:)), keyEquivalent: "")
        //        menu.addItem(aboutMenuItem)
        
        //        let checkForUpdatesMenuItem = NSMenuItem(title: "Check for updates", action: #selector(AppDelegate.checkForUpdates(_:)), keyEquivalent: "")
        let checkForUpdatesMenuItem = NSMenuItem(title: "Check for updates", action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)), keyEquivalent: "")
        checkForUpdatesMenuItem.target = updaterController
        menu.addItem(checkForUpdatesMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let preferencesMenuItem = NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.openPreferencesWindow(_:)), keyEquivalent: ",")
        //        let preferencesMenuItem = NSMenuItem(title: "Preferences...",action: <#T##Selector?#>, keyEquivalent: ",")
        menu.addItem(preferencesMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitMenuItem)
        
        self.statusItem.menu = menu
        self.statusItem.menu?.delegate = self
    }
    
    @objc func openPreferencesWindow(_ sender: Any?) {
        //
        preferencesWindowController.show(preferencePane: .general)
        //        self.preferencesWindowController.showWindow(self)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func onTrigger() { //pass down modifier keys on trigger
        
        //trigger
        if self.swindler != nil {
//            AppDelegate.focusedWindow = swindler.frontmostApplication.value?.focusedWindow.value
            
//            functionalityManager = FunctionalityManager(swindler: self.swindler)
            //            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    func onModifiers(flags: [NSEvent.ModifierFlags]) {
        if functionalityManager != nil {
            functionalityManager!.setModifierFlags(flags)
        }
    }
    func onTriggerEnded() {
        guard self.functionalityManager != nil else { return }
        functionalityManager?.stop()
        functionalityManager = nil
        //        NSRunningApplication(processIdentifier: processIdentifier())?.activate(options: .activateIgnoringOtherApps)
    }
    
    
    func checkAccessibilityPermissions() -> Bool {
        if AXIsProcessTrusted() {
            //            Logger.shared.log("We're trusted accessibility client")
            return true
        } else {
            let options = NSDictionary(object: kCFBooleanTrue as Any, forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionary
            let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
            return accessibilityEnabled
        }
    }
    
    func getAppfff(name:String,appData: [Application]) -> Application? {
        let f = appData.filter{$0.name.lowercased().contains(name)}
        return f[0]
    }
    
}
