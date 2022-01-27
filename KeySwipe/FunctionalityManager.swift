//
//  FunctionalityManager.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import Cocoa
import Swindler

class FunctionalityManager: GestureWindowDelegate {
    
    private var gestureWindows:[GestureWindow]
    
    private var swindler: Swindler.State
    private var windowMover:WindowMover?
    private var quickPicker:QuickPicker?
   
    init(swindler: Swindler.State) {
        self.swindler = swindler
        
        self.gestureWindows = [GestureWindow]()
        
        for (_, screen) in swindler.screens.enumerated() {
            let gestureWindow = GestureWindowManager.shared.acquire()
            gestureWindow.setDelegate(self)
            gestureWindow.setFrameAndTA(rect: screen.frame)
            gestureWindow.makeKeyAndOrderFront(gestureWindow)
            self.gestureWindows.append(gestureWindow)
        }
        
        self.quickPicker = QuickPicker()
        
        //check if selected window is close and can be moved
        if let _ = swindler.frontmostApplication.value?.focusedWindow.value {
            self.windowMover = WindowMover(swindler: swindler)
        }
    }
    
    func onTrackpadScrollGesture(delta: (vector: CGVector, timestamp: Double, direction: SwipeDirection)) {
        self.windowMover?.onTrackpadScrollGesture(delta: delta)
    }
    
    func trackpadTimedOut() {
        self.windowMover?.trackpadTimedOut()
    }
    //if user start swiping (w/out resting finger on trackspad) this function may not be called
    func onTrackpadScrollGestureMayBegin() {
        self.windowMover?.onTrackpadScrollGestureMayBegin()
    }
    func onTrackpadScrollGestureBegan() {
        self.windowMover?.onTrackpadScrollGestureBegan()
    }
    
    func onTrackpadScrollGestureEnded() {
        self.windowMover?.onTrackpadScrollGestureEnded()
    }
    
    func onMouseMoveGesture(position: CGPoint) {
        self.quickPicker?.onMouseMoveGesture(position: position)
    }
    
    func onMagnifyGesture(factor: (width: CGFloat, height: CGFloat)) {
        
    }
    
    func setModifierFlags(_ flags:[NSEvent.ModifierFlags]) {
        self.windowMover?.setModifierFlags(flags)
    }
    
    func stop() {
        self.quickPicker?.stop()
        self.windowMover?.stop()
        
        self.gestureWindows.forEach { (item) in
            item.orderOut(item)
            item.clear()
        }
    }
    
    deinit {
        self.gestureWindows.forEach { (item) in
            GestureWindowManager.shared.release(item)
        }
    }
}
