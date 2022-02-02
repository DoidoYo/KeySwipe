//
//  QuickPickerDelegate.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import AppKit
import SwiftUI
import Cocoa

enum PickerStatus {
    case hidden
    case shown
}

class QuickPicker {
    
    static private var applicationMetaData = AppSearcher().getAllApplications().sorted(by: {$0.name < $1.name})
    private static var window:NSWindow!
    
    private var modifierFlags = NSEvent.ModifierFlags()
    private static let activatingModifier:NSEvent.ModifierFlags = .control
    
    private var pickerStatus:PickerStatus = .hidden
    private var previousSelection = -1
    private var initialMousePosition:CGVector
    
    init() {
        if QuickPicker.window == nil {
            QuickPicker.window = NSWindow(contentRect: CGRect.zero, styleMask: [NSWindow.StyleMask.borderless], backing: NSWindow.BackingStoreType.buffered, defer: true)
            QuickPicker.window.setFrame(CGRect(x: 0, y: 0, width: 0, height: 0), display: true)
            QuickPicker.window.level = .popUpMenu
            QuickPicker.window.isOpaque = false
            
            QuickPicker.window.ignoresMouseEvents = true
            QuickPicker.window.acceptsMouseMovedEvents = false
            
            QuickPicker.window.backgroundColor = .clear
            QuickPicker.window.isMovable=false
            QuickPicker.window.title = "Quick Picker Window"
            
            QuickPicker.window.isRestorable=false
            
            
            let contentView = QuickPickerView().environmentObject(UserPreferences.shared.applications).edgesIgnoringSafeArea(.top)
            QuickPicker.window.contentView = NSHostingView(rootView: contentView)
            
            
        }
        //initial mouse location
        self.initialMousePosition = CGVector(point: NSEvent.mouseLocation)
        
        //get applications from preference
    }
    
    //global listener to mouse
    var mouseListener:Any?
    func setModifierFlags(_ flags:NSEvent.ModifierFlags) {
        //exit if disabled
        if !UserPreferences.shared.quickPickerEnabled {
            if self.mouseListener != nil {
                NSEvent.removeMonitor(mouseListener)
                mouseListener = nil
            }
            return
        }
        
        // only set to none if changed
        //if it was turned on
        if flags.contains(QuickPicker.activatingModifier) && !self.modifierFlags.contains(QuickPicker.activatingModifier){
            self.initialMousePosition = CGVector(point: NSEvent.mouseLocation)
            
            if self.mouseListener == nil {
                self.mouseListener = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
                    self.onMouseMoveGesture(position: NSEvent.mouseLocation)
                }
            }
            
        } else if !flags.contains(QuickPicker.activatingModifier) && self.modifierFlags.contains(QuickPicker.activatingModifier) {
            NSEvent.removeMonitor(mouseListener)
            mouseListener = nil
            //turned off
            stop() //reset items
        }
        self.modifierFlags = flags
    }
    
    func onMouseMoveGesture(position: CGPoint) {
        let pVec = CGVector(point: position)
        
        if (pVec-self.initialMousePosition).length() < UserPreferences.shared.quickPickerMouseDeadzone { return }
        
        switch pickerStatus {
        case .hidden:
            QuickPicker.window.setFrame(CGRect(x: self.initialMousePosition.dx - (QuickPicker.window.frame.width/2), y: self.initialMousePosition.dy - (QuickPicker.window.frame.height/2), width: QuickPicker.window.frame.width, height: QuickPicker.window.frame.height), display: true, animate: false)
            QuickPicker.window.makeKeyAndOrderFront(self)
            pickerStatus = .shown
        case .shown:
            break
        }
        
        if (pVec-self.initialMousePosition).length() < UserPreferences.shared.quickPickerShowDistance {
            if previousSelection != -1 {
                UserPreferences.shared.applications.array[previousSelection]?.selected = false
                previousSelection = -1
            }
            return
        }
        
        var intNew = -1
        
        //            0 | 1 | 2
        //            3 |   | 4
        //            5 | 6 | 7
        let inc = ((QuickPicker.window.frame.height-15)/3) / 2
        let mouseLocation = position
        let initialMouseLocation = CGPoint(x: initialMousePosition.dx, y: initialMousePosition.dy)
        if (mouseLocation.x >= initialMouseLocation.x + inc && mouseLocation.y >= initialMouseLocation.y + inc) { //2
            intNew=2
        } else if (mouseLocation.y >= initialMouseLocation.y + inc && mouseLocation.x >= initialMouseLocation.x - inc && mouseLocation.x <= initialMouseLocation.x + inc) {
            intNew=1
        } else if (mouseLocation.x <= initialMouseLocation.x - inc && mouseLocation.y >= initialMouseLocation.y + inc) {
            intNew=0
        } else if (mouseLocation.x <= initialMouseLocation.x - inc && mouseLocation.y >= initialMouseLocation.y - inc && mouseLocation.y <= initialMouseLocation.y + inc) {
            intNew=3
        } else if (mouseLocation.y <= initialMouseLocation.y - inc && mouseLocation.x <= initialMouseLocation.x - inc) {
            intNew = 5
        } else if (mouseLocation.y <= initialMouseLocation.y - inc && mouseLocation.x >= initialMouseLocation.x - inc && mouseLocation.x <= initialMouseLocation.x + inc) {
            intNew=6
        } else if (mouseLocation.x >= initialMouseLocation.x + inc && mouseLocation.y <= initialMouseLocation.y - inc) {
            intNew = 7
        } else if (mouseLocation.x >= initialMouseLocation.x + inc && mouseLocation.y >= initialMouseLocation.y - inc && mouseLocation.y <= initialMouseLocation.y + inc) {
            intNew=4
        }
        
        if previousSelection != intNew {
            if previousSelection != -1 {
                UserPreferences.shared.applications.array[previousSelection]?.selected = false
            }
            if intNew != -1 {
                UserPreferences.shared.applications.array[intNew]?.selected = true
            }
            previousSelection = intNew
        }
    }
    
    func stop() {
        //open program
        if previousSelection != -1 {
            if let app = UserPreferences.shared.applications.array[previousSelection] {
                let configuration = NSWorkspace.OpenConfiguration()
                configuration.activates=true
                NSWorkspace.shared.openApplication(at: app.url, configuration: configuration) { rapp, error in
                }
            }
        }
        
        //reset
        QuickPicker.window.orderOut(QuickPicker.window)
        clearAppSelection()
        pickerStatus = .hidden
    }
    
    func clearAppSelection() {
        for (i,_) in UserPreferences.shared.applications.array.enumerated() {
            UserPreferences.shared.applications.array[i]?.selected = false
        }
    }
}
