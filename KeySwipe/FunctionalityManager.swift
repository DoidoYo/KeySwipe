//
//  FunctionalityManager.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import Cocoa
import Signals
import AXSwift

class FunctionalityManager {
    static private var windowMover:WindowMover = WindowMover()
    private var quickPicker:QuickPicker?
    
    private let VECTOR_UP_RIGHT = CGVector(dx: 1, dy: 1).normalized()
    private let VECTOR_UP_LEFT = CGVector(dx: -1, dy: 1).normalized()
    private let VECTOR_DOWN_RIGHT = CGVector(dx: 1, dy: -1).normalized()
    private let VECTOR_DOWN_LEFT = CGVector(dx: -1, dy: -1).normalized()
    
    let onData = Signal<(data:NSData, error:NSError)>()
    let onProgress = Signal<Float>()
    
    
    
    init() {
        self.quickPicker = QuickPicker()
//        self.windowMover = WindowMover()
    }
    
    
    static var test = 1
    
    static var swipeObserver = Signal<NSEvent>()
    static var stopScrolling = false
    
    func setupInputListeners() {
        // Void pointer to `self`:
        _ = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: (1 << CGEventType.scrollWheel.rawValue), callback: { proxy, type, event, pointer in
            
            if FunctionalityManager.windowMover.scrollWheelEvent(event: NSEvent(cgEvent: event)!) {
                FunctionalityManager.stopScrolling = true
            }
            let nsevent = NSEvent(cgEvent: event)
            //if scroll has stopped, only start it again if its a new scroll action
            if FunctionalityManager.stopScrolling {
                if nsevent?.phase == .began || nsevent?.phase == .mayBegin {
                    FunctionalityManager.stopScrolling = false
                    return Unmanaged.passRetained(event)
                }
                return nil
            }
            return Unmanaged.passRetained(event)
        }, userInfo: nil)
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap!, enable: true)
        CFRunLoopRun()
        
//        NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { event in
//            FunctionalityManager.windowMover.scrollWheelEvent(event: event)
//        }
        
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            FunctionalityManager.windowMover.setModifierFlags(flags)
            self.quickPicker?.setModifierFlags(flags)
        }
        
    }
    
    func stop() {
        self.quickPicker?.stop()
        FunctionalityManager.windowMover.stop()
    }
    
    deinit {
        
    }
}
