//
//  FunctionalityManager.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import Cocoa
import Swindler
import Signals
import AXSwift

class FunctionalityManager: GestureWindowDelegate {
    
    private var gestureWindows:[GestureWindow]
    
    private var swindler: Swindler.State
    private var windowMover:WindowMover?
    private var quickPicker:QuickPicker?
    
    private let VECTOR_UP_RIGHT = CGVector(dx: 1, dy: 1).normalized()
    private let VECTOR_UP_LEFT = CGVector(dx: -1, dy: 1).normalized()
    private let VECTOR_DOWN_RIGHT = CGVector(dx: 1, dy: -1).normalized()
    private let VECTOR_DOWN_LEFT = CGVector(dx: -1, dy: -1).normalized()
    
    let onData = Signal<(data:NSData, error:NSError)>()
    let onProgress = Signal<Float>()
    
    init(swindler: Swindler.State) {
        
        self.swindler = swindler
        
        self.gestureWindows = [GestureWindow]()
        
        for (_, screen) in swindler.screens.enumerated() {
            let gestureWindow = GestureWindowManager.shared.acquire()
            //            gestureWindow.setDelegate(self)
            //            gestureWindow.setFrameAndTA(rect: screen.frame)
            //            gestureWindow.makeKeyAndOrderFront(gestureWindow)
            self.gestureWindows.append(gestureWindow)
        }
        
        if UserPreferences.shared.quickPickerEnabled {
            //            self.quickPicker = QuickPicker()
        }
        
        //check if selected window is close and can be moved
        if let window = swindler.frontmostApplication.value?.focusedWindow.value {
            if !(window.isMinimized.value || window.isFullscreen.value) {
                //                self.windowMover = WindowMover(swindler: swindler)
            }
        }
    }
    
    var lastLoc = NSEvent.mouseLocation
    var overTop = false
    
    func test() {
        DispatchQueue.global(qos: .userInitiated).async {
            
            NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { [self] event in
                print(overTop)
                if lastLoc != NSEvent.mouseLocation {
                    let maxY = NSScreen.screens.map({$0.frame.height}).max()!
                    
                    let nPos = NSEvent.mouseLocation
                    lastLoc = nPos
                    let sPos = NSPoint(x: nPos.x, y: maxY - nPos.y)
                    
                    var clickedElement:AXUIElement? = nil
                    if AXError.success == AXUIElementCopyElementAtPosition(AXUIElementCreateSystemWide(), Float(sPos.x), Float(sPos.y), &clickedElement) {
                        
                        let element = AXSwift.UIElement(clickedElement!)
                        overTop = isTop(element: element)
                    } else {
                        print("Error getting UIelement from cursor position")
                        overTop = false
                    }
                }
                
                if !overTop {return}
                
                if windowMover == nil {
                    print("starting")
                    AppDelegate.focusedWindow = swindler.frontmostApplication.value?.focusedWindow.value
                    windowMover = WindowMover(swindler: swindler)
                    windowMover?.attachListeners()
                }
                
                let inputMan = InputNotfication.shared
                // Check if scroll is triggered from mouse wheel
                // https://stackoverflow.com/a/13981577
                if event.phase == NSEvent.Phase.init(rawValue: 0) &&
                    event.momentumPhase == NSEvent.Phase.init(rawValue: 0) {
                    return
                }
                //trackpad gesture
                if event.phase == NSEvent.Phase.mayBegin { //two fingers down, but not moving
                    inputMan.onTrackpadScrollGestureMayBegin.fire(1)
                }else if event.phase == NSEvent.Phase.began { //two fingers started moving
                    inputMan.onTrackpadScrollGestureBegan.fire(1)
                    
                } else if event.phase == NSEvent.Phase.changed {
                    // Moving or resizing (delta) window
                    //let factor: CGFloat = event.isDirectionInvertedFromDevice ? -1 : 1;
                    let vector = CGVector(dx: event.scrollingDeltaX, dy: -event.scrollingDeltaY)
                    
                    var direction = SwipeDirection.DIAGONAL
                    if (VECTOR_UP_RIGHT.crossprod(vector)>0 && vector.crossprod(VECTOR_UP_LEFT)>0) {
                        direction = SwipeDirection.UP
                    } else if (VECTOR_DOWN_LEFT.crossprod(vector)>0 && vector.crossprod(VECTOR_DOWN_RIGHT)>0) {
                        direction = SwipeDirection.DOWN
                    } else if (VECTOR_UP_LEFT.crossprod(vector)>0 && vector.crossprod(VECTOR_DOWN_LEFT)>0) {
                        direction = SwipeDirection.LEFT
                    } else if (VECTOR_DOWN_RIGHT.crossprod(vector)>0 && vector.crossprod(VECTOR_UP_RIGHT)>0) {
                        direction = SwipeDirection.RIGHT
                    }
                    
                    let delta = (
                        vector:CGVector(dx: event.scrollingDeltaX, dy: -event.scrollingDeltaY),
                        timestamp: event.timestamp,
                        direction: direction
                    )
                    
                    inputMan.onTrackpadScrollGesture.fire(delta)
                } else if (event.phase == NSEvent.Phase.ended || event.phase == NSEvent.Phase.cancelled) {
                    // Call the delegate method
                    inputMan.onTrackpadScrollGestureEnded.fire(1)
                    windowMover = nil
                }
            }
        }
    }
    
    func isTop(element: UIElement) -> Bool {
        if let role = try? element.getMultipleAttributes(.role)[.role] as? String {
            if role == "AXToolbar" || role == "AXTabGroup" {
                return true
            }
            if let parent = try? element.getMultipleAttributes(.parent)[.parent] as? UIElement {
                return isTop(element: parent)
            } else {
                return false
            }
        } else {
            return false
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
