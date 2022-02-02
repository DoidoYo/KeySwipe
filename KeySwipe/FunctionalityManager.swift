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
    private var windowMover:WindowMover?
    private var quickPicker:QuickPicker?
    
    private let VECTOR_UP_RIGHT = CGVector(dx: 1, dy: 1).normalized()
    private let VECTOR_UP_LEFT = CGVector(dx: -1, dy: 1).normalized()
    private let VECTOR_DOWN_RIGHT = CGVector(dx: 1, dy: -1).normalized()
    private let VECTOR_DOWN_LEFT = CGVector(dx: -1, dy: -1).normalized()
    
    let onData = Signal<(data:NSData, error:NSError)>()
    let onProgress = Signal<Float>()
    
    
    
    init() {
        self.quickPicker = QuickPicker()
        self.windowMover = WindowMover()
    }
    
    
    
    func setupInputListeners() {
        NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { event in
            self.windowMover?.scrollWheelEvent(event: event)
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            self.windowMover?.setModifierFlags(flags)
            self.quickPicker?.setModifierFlags(flags)
        }
        
    }
    
    func stop() {
        self.quickPicker?.stop()
        self.windowMover?.stop()
    }
    
    deinit {
        
    }
}
