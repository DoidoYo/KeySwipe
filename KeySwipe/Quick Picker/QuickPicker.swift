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
    
//    private var applications:Applications //passes apps to show on QuickPickerView
    private static var window:NSWindow!
    
    private var pickerStatus:PickerStatus = .hidden
    
    private var previousSelection = -1
    
    private var initialMousePosition:CGVector
    
    init() {
        if QuickPicker.window == nil {
            QuickPicker.window = NSWindow(contentRect: CGRect.zero, styleMask: [NSWindow.StyleMask.borderless], backing: NSWindow.BackingStoreType.buffered, defer: true)
            QuickPicker.window.setFrame(CGRect(x: 100, y: 100, width: 0, height: 0), display: true)
            QuickPicker.window.level = .popUpMenu
            QuickPicker.window.isOpaque = false
            
            QuickPicker.window.ignoresMouseEvents = true
            QuickPicker.window.acceptsMouseMovedEvents = false
            
//            QuickPicker.window.contentView!.allowedTouchTypes = [.indirect]
//            QuickPicker.window.contentView!.wantsRestingTouches = true
            
            QuickPicker.window.backgroundColor = .clear
            QuickPicker.window.isMovable=false
            QuickPicker.window.title = "Quick Picker Window"
            
            QuickPicker.window.isRestorable=false
            
            
            let contentView = QuickPickerView().environmentObject(AppDelegate.applications).frame(width: 210, height: 210).edgesIgnoringSafeArea(.top)
            QuickPicker.window.contentView = NSHostingView(rootView: contentView)
            
           
        }
        //initial mouse location
        self.initialMousePosition = CGVector(point: NSEvent.mouseLocation)
        
        //get applications from preference
    }
    
    func onMouseMoveGesture(position: CGPoint) {
        let pVec = CGVector(point: position)
        
        if (pVec-self.initialMousePosition).length() < Preferences.shared.quickPickerMouseDeadzone { return }
        
        switch pickerStatus {
        case .hidden:
            if let bw = GestureWindowManager.shared.getBackmostGestureWindow() {
                QuickPicker.window.setFrame(CGRect(x: self.initialMousePosition.dx - (QuickPicker.window.frame.width/2), y: self.initialMousePosition.dy - (QuickPicker.window.frame.height/2), width: QuickPicker.window.frame.width, height: QuickPicker.window.frame.height), display: true, animate: false)
                QuickPicker.window.order(.below, relativeTo: bw.windowNumber)
                pickerStatus = .shown
            }
        case .shown:
            break
        }
        
        if (pVec-self.initialMousePosition).length() < Preferences.shared.quickPickerShowDistance {
            if previousSelection != -1 {
                AppDelegate.applications.array[previousSelection]?.selected = false
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
            AppDelegate.applications.array[previousSelection]?.selected = false
            }
            if intNew != -1 {
            AppDelegate.applications.array[intNew]?.selected = true
            }
            previousSelection = intNew
        }
    }
    
    func stop() {
        //open program
        if previousSelection != -1 {
            if let app = AppDelegate.applications.array[previousSelection] {
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
        for (i,_) in AppDelegate.applications.array.enumerated() {
            AppDelegate.applications.array[i]?.selected = false
        }
    }
}
