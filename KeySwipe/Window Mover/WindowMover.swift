//
//  WindowMover.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/27/22.
//

import Foundation
import Cocoa
import Swindler

enum TrackpadState {
    case idle
    case may_move
    case moving
    case modifier
    case aborted
}

enum SnapLocation {
    case FULLSCREEEN
    case LEFT_HALF
    case RIGHT_HALF
    case TOP_LEFT
    case TOP_RIGHT
    case BOTTOM_LEFT
    case BOTTOM_RIGHT
    
    case NONE
    
    case THIRD_MIDDLE
    case THIRD_LEFT
    case THIRD_RIGHT
    case THIRD_MIDDLE_RIGHT
    case THIRD_MIDDLE_LEFT
}

class WindowMover {
    private var swindler: Swindler.State
    
    private let haptic = NSHapticFeedbackManager.defaultPerformer
    
    private var previousLocation:SnapLocation = .NONE
    private var currentLocation:SnapLocation = .NONE
    private var modifierSelectionLocation:SnapLocation = .NONE
    private var trackpadState = TrackpadState.idle
    
    private var modifierFlags = [NSEvent.ModifierFlags]()
    private var modifierTimeTimeoutTask: DispatchWorkItem?
    private var modifierTime = 0.2
    private var abortTimeTimeoutTask: DispatchWorkItem?
    private var abortTime = 1.0
    
    private static var snapOverlayWindow:SnapOverlayWindow = SnapOverlayWindow(contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))
    
    init(swindler: Swindler.State) {
        self.swindler = swindler
    }
    
    func onTrackpadScrollGesture(delta: (vector: CGVector, timestamp: Double, direction: SwipeDirection)) {
        if trackpadState == .aborted { return }
        if delta.vector.length() < Preferences.shared.trackpadDeadzone { return }
        
        //user held first, then moved
        if trackpadState == .modifier && previousLocation == .NONE {
            //move it with same ratio
            let window = AppDelegate.focusedWindow
            if moveWindowToScreen(allScreens: swindler.screens, window_: window!, direction: delta.direction) {
                self.trackpadState = .aborted
            }
            return
        }
        //initial movement, or modifier after starting
        //trackpad is moving
        self.trackpadState = .moving
        //over lay window is shown on begin, but opacity is set to 0 ~ transparent
        //if new swipe, dont show initial window until valid side is input ** to prevent overlay from showing up if swiping down
        if !(previousLocation == SnapLocation.NONE && currentLocation == SnapLocation.NONE) {
            if WindowMover.snapOverlayWindow.alphaValue != 1 {
                WindowMover.snapOverlayWindow.alphaValue = 1
            }
        }
        //update previous location if current changed
        if previousLocation != currentLocation {
            previousLocation = currentLocation
        }
        //get new snap location if swipe direction is valid
        if modifierFlags.contains(.command) {
            if currentLocation == .NONE {
                currentLocation = get3x3SnapLocation(currentLocation: currentLocation, swipeDirection: delta.direction)
            } else {
                let newloc = get3x3SnapLocation(currentLocation: currentLocation, swipeDirection: delta.direction)
                if newloc != modifierSelectionLocation {
                    WindowMover.snapOverlayWindow.setFrameCustom(rect: getSnapLocationToScreen(location: newloc, screen: swindler.mainScreen!), animate: true)
                }
                modifierSelectionLocation = newloc
            }
        } else {
             let newloc = get2x2SnapLocation(currentLocation: currentLocation, swipeDirection: delta.direction)
            if newloc != currentLocation {
                WindowMover.snapOverlayWindow.setFrameCustom(rect: getSnapLocationToScreen(location: newloc, screen: swindler.mainScreen!), animate: true)
            }
            currentLocation = newloc
        }
        
        //modifier timer and timeout timer
        self.modifierTimeTimeoutTask?.cancel()
        self.modifierTimeTimeoutTask = DispatchWorkItem {
            if self.modifierFlags.contains(.command) {
                self.currentLocation = self.modifierSelectionLocation
            } else {
                self.trackpadState = .modifier
                self.currentLocation = .NONE
            }
            self.haptic.perform(.generic, performanceTime: .now)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.modifierTime, execute: self.modifierTimeTimeoutTask!)
        
        self.abortTimeTimeoutTask?.cancel()
        self.abortTimeTimeoutTask = DispatchWorkItem {
            self.trackpadTimedOut()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.abortTime, execute: self.abortTimeTimeoutTask!)
    }
    
    func trackpadTimedOut() {
        //double haptic for timedout
        self.haptic.perform(.generic, performanceTime: .now)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
            self.haptic.perform(.generic, performanceTime: .now)
        }
        WindowMover.snapOverlayWindow.hideWindow(animated: true)
        self.trackpadState = .aborted
        self.previousLocation = .NONE
        self.currentLocation = .NONE
    }
    //if user start swiping (w/out resting finger on trackspad) this function may not be called
    func onTrackpadScrollGestureMayBegin() {
        self.trackpadState = .may_move
        
        let appFrame = AppDelegate.focusedWindow?.frame.value
        WindowMover.snapOverlayWindow.setFrameCustom(rect: appFrame!, animate: false)
        WindowMover.snapOverlayWindow.alphaValue = 0
        WindowMover.snapOverlayWindow.makeKey()
        if let bw = GestureWindowManager.shared.getBackmostGestureWindow() {
            WindowMover.snapOverlayWindow.order(.below, relativeTo: bw.windowNumber)
        }
        
        // trackpad modifier timer for when user starts by resting two fingers on trackpad
        // normal function moves window between screens
        // keyboard modified function moves window in thirds
        self.modifierTimeTimeoutTask?.cancel()
        self.modifierTimeTimeoutTask = DispatchWorkItem {
            if self.modifierFlags.contains(.command) {
                self.currentLocation = .THIRD_MIDDLE
                self.modifierSelectionLocation = .THIRD_MIDDLE
                WindowMover.snapOverlayWindow.alphaValue = 1
                WindowMover.snapOverlayWindow.setFrameCustom(rect: getSnapLocationToScreen(location: self.currentLocation, screen: self.swindler.mainScreen!), animate: true)
            } else {
                self.trackpadState = .modifier
                self.currentLocation = .NONE
            }
            self.haptic.perform(.generic, performanceTime: .now)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.modifierTime, execute: self.modifierTimeTimeoutTask!)
        
        self.abortTimeTimeoutTask?.cancel()
        self.abortTimeTimeoutTask = DispatchWorkItem {
            self.trackpadTimedOut()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.abortTime, execute: self.abortTimeTimeoutTask!)
    }
    
    func onTrackpadScrollGestureBegan() {
        
        switch self.trackpadState {
        case .idle:
            //if overlay has not been shown yet, show it
            let appFrame = AppDelegate.focusedWindow?.frame
            WindowMover.snapOverlayWindow.setFrameCustom(rect: appFrame!.value, animate: false)
            WindowMover.snapOverlayWindow.alphaValue = 0
            WindowMover.snapOverlayWindow.makeKey()
            if let bw = GestureWindowManager.shared.getBackmostGestureWindow() {
                WindowMover.snapOverlayWindow.order(.below, relativeTo: bw.windowNumber)
            }
            break
        case .may_move:
            //overlay already showed
            break
        default:
            break
        }
        
        if self.modifierFlags.contains(.command) {
            WindowMover.snapOverlayWindow.alphaValue = 1
        }
        
    }
    
    func onTrackpadScrollGestureEnded() {
        //finger up automatically makes it idle
        trackpadState = .idle
        
        //remove timers
        modifierTimeTimeoutTask?.cancel()
        modifierTimeTimeoutTask = nil
        abortTimeTimeoutTask?.cancel()
        abortTimeTimeoutTask = nil
        
        //if modifier seletion was being used, snap to it
        if modifierSelectionLocation != .NONE {
            currentLocation = modifierSelectionLocation
            previousLocation = modifierSelectionLocation
        }
        if previousLocation != .NONE && currentLocation != .NONE {
            //move window
            let snap = (currentLocation == .NONE) ? previousLocation : currentLocation
            let _ = AppDelegate.focusedWindow?.frame.set(getSnapLocationToScreen(location: snap, screen: swindler.mainScreen!))
        }
        //hide overlay
        WindowMover.snapOverlayWindow.hideWindow(animated: true)
        previousLocation = .NONE
        currentLocation = .NONE
        modifierSelectionLocation = .NONE
    }
    
    func setModifierFlags(_ flags:[NSEvent.ModifierFlags]) {
        // only set to none if changed
        if !(self.modifierFlags.contains(.command) == flags.contains(.command)) {
            self.currentLocation = .NONE
            self.modifierSelectionLocation = .NONE
        }
            
        self.modifierFlags = flags
    }
    
    func stop() {
        previousLocation = .NONE
        currentLocation = .NONE
        modifierSelectionLocation = .NONE
        WindowMover.snapOverlayWindow.hideWindow(animated: false)
    }
    
}
