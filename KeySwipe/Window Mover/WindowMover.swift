//
//  WindowMover.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/27/22.
//

import Foundation
import Cocoa
import AXSwift

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
    
    case MINIMIZE
    
    case NONE
    
    case THIRD_MIDDLE
    case THIRD_LEFT
    case THIRD_RIGHT
    case THIRD_MIDDLE_RIGHT
    case THIRD_MIDDLE_LEFT
}

class WindowMover {
    private let haptic = NSHapticFeedbackManager.defaultPerformer
    
    private var previousLocation:SnapLocation = .NONE
    private var currentLocation:SnapLocation = .NONE
    private var modifierSelectionLocation:SnapLocation = .NONE
    private var trackpadState = TrackpadState.idle
    
    private var modifierFlags = NSEvent.ModifierFlags()
    private static let activatingModifier:NSEvent.ModifierFlags = .function
    private static let smallGridModifier:NSEvent.ModifierFlags = .shift
    private var modifierTimeTimeoutTask: DispatchWorkItem?
    private var modifierTime = 0.2
    private var abortTimeTimeoutTask: DispatchWorkItem?
    private var abortTime = 1.0
    
    private var lastLoc = NSEvent.mouseLocation
    private var overTop = false
    private var update = false
    
    private let VECTOR_UP_RIGHT = CGVector(dx: 1, dy: 1).normalized()
    private let VECTOR_UP_LEFT = CGVector(dx: -1, dy: 1).normalized()
    private let VECTOR_DOWN_RIGHT = CGVector(dx: 1, dy: -1).normalized()
    private let VECTOR_DOWN_LEFT = CGVector(dx: -1, dy: -1).normalized()
    
    private var hitWindow:UIElement?
    private var windowToMove:UIElement?
    private var windowToMoveFrame:NSRect?
    private var windowToMoveScreen:NSRect?
    
    private static var snapOverlayWindow:SnapOverlayWindow = SnapOverlayWindow(contentRect: NSRect(x: 0, y: 0, width: 0, height: 0))
    
    func scrollWheelEvent(event:NSEvent) {
        //dont respond to momentum scrolling
        if event.momentumPhase != NSEvent.Phase(rawValue: 0) { return }

        //update hit if mouse position changed or update flag is set
        if lastLoc != NSEvent.mouseLocation || update {
            let maxY = NSScreen.screens.map({$0.frame.height}).max()!
            
            let nPos = NSEvent.mouseLocation
            lastLoc = nPos
            let sPos = NSPoint(x: nPos.x, y: maxY - nPos.y)
            
            var clickedElement:AXUIElement? = nil
            if AXError.success == AXUIElementCopyElementAtPosition(AXUIElementCreateSystemWide(), Float(sPos.x), Float(sPos.y), &clickedElement) {
                
                let element = AXSwift.UIElement(clickedElement!)
                overTop = isTop(element: element)
                //get associated window //returns focused window if modifier is pressed, else it uses window that the cursor is over its titlebar

                self.windowToMove = self.modifierFlags.contains(WindowMover.activatingModifier) ? getMainWindow() : (overTop ? getParentWindow(element: element) : nil)
                
                if self.windowToMove != nil {
                    self.windowToMoveFrame = try? self.windowToMove?.getMultipleAttributes(.frame)[.frame] as? NSRect
                    self.windowToMoveScreen = getAppScreen(window: getScreen(window: self.windowToMoveFrame!)!.frame)
                }

                update = false
            } else {
                print("Error getting UIelement from cursor position")
                overTop = false
                update = true //could not find UIelement
            }
        }
        
        //ignore if modifier key is NOT pressed and mouse NOT over topbar
//        if overTop == false && modifierFlags.contains(WindowMover.activatingModifier) == false { return }
        //state can only change if window is selected
        if self.windowToMove == nil { return }

        // Check if scroll is triggered from mouse wheel
        // https://stackoverflow.com/a/13981577
        if event.phase == NSEvent.Phase.init(rawValue: 0) &&
            event.momentumPhase == NSEvent.Phase.init(rawValue: 0) {
            return
        }
        //trackpad gesture
        if event.phase == NSEvent.Phase.mayBegin { //two fingers down, but not moving
            self.onTrackpadScrollGestureMayBegin()
        }else if event.phase == NSEvent.Phase.began { //two fingers started moving
            self.onTrackpadScrollGestureBegan()
            
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
            
            self.onTrackpadScrollGesture(delta: delta)
        } else if (event.phase == NSEvent.Phase.ended || event.phase == NSEvent.Phase.cancelled) {
            // Call the delegate method
            self.onTrackpadScrollGestureEnded()
        }
    }
    
    func getMainWindow() -> UIElement? {
        if let application = NSWorkspace.shared.frontmostApplication {
            let uiApp = AXSwift.Application(application)!
            if let appFocus = try? uiApp.windows()?.first{
                if isMinimized(element: appFocus) == true { return nil }
                
                if let main = try? appFocus.getMultipleAttributes(.main)[.main] as? Bool {
                    if main == false { return nil }
                }
            }
            return try? uiApp.windows()?.first
        }
        return nil
    }
    
    func getParentWindow(element:UIElement) -> UIElement? {
        if let parent = try? element.getMultipleAttributes(.topLevelUIElement)[.topLevelUIElement] as? UIElement {
            if let label = try? parent.getMultipleAttributes(.labelValue)[.labelValue] as? String {
//                print(label)
            }
            return parent
        }
        return nil
    }
    
    func isMinimized(element: UIElement) -> Bool? {
        if let minimized = try? element.getMultipleAttributes(.minimized)[.minimized] as? Bool {
            if minimized { return true } else {return false}
        } else {
            return nil
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
        if trackpadState == .aborted { return }
        if delta.vector.length() < UserPreferences.shared.trackpadDeadzone { return }
        
        //minimize window on swipe down
        if currentLocation == .NONE && delta.direction == .DOWN {
            try? self.windowToMove?.setAttribute(.minimized, value: true)
            self.trackpadTimedOut(haptic: false)
            return
        }
        
        //user held first, then moved
        if trackpadState == .modifier && previousLocation == .NONE {
            //move it with same ratio
            if self.windowToMove != nil {
                if moveWindowToScreen(window: self.windowToMove!, direction: delta.direction) {
                    self.trackpadState = .aborted
                }
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
        if modifierFlags.contains(WindowMover.smallGridModifier) {
            if currentLocation == .NONE {
                currentLocation = get3x3SnapLocation(currentLocation: currentLocation, swipeDirection: delta.direction)
            } else {
                let newloc = get3x3SnapLocation(currentLocation: currentLocation, swipeDirection: delta.direction)
                if newloc != modifierSelectionLocation {
            
                    WindowMover.snapOverlayWindow.setFrameCustom(rect: getSnapLocationToScreen(location: newloc, screen: self.windowToMoveScreen!.toCocoaCoord()), animate: true)
                }
                modifierSelectionLocation = newloc
            }
        } else {
            let newloc = get2x2SnapLocation(currentLocation: currentLocation, swipeDirection: delta.direction)
            if newloc != currentLocation {
//                print("Moving in screen: \(self.windowToMoveScreen!.toCocoaCoord())")
                WindowMover.snapOverlayWindow.setFrameCustom(rect: getSnapLocationToScreen(location: newloc, screen: self.windowToMoveScreen!.toCocoaCoord()), animate: true)
            }
            currentLocation = newloc
        }
        
        //modifier timer and timeout timer
        self.modifierTimeTimeoutTask?.cancel()
        self.modifierTimeTimeoutTask = DispatchWorkItem {
            if self.modifierFlags.contains(WindowMover.smallGridModifier) {
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
            self.trackpadTimedOut(haptic: true)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.abortTime, execute: self.abortTimeTimeoutTask!)
    }
    
    func trackpadTimedOut(haptic: Bool = false) {
        //double haptic for timedout
        if haptic {
            self.haptic.perform(.generic, performanceTime: .now)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                self.haptic.perform(.generic, performanceTime: .now)
            }
        }
        WindowMover.snapOverlayWindow.hideWindow(animated: true)
        self.trackpadState = .aborted
        self.previousLocation = .NONE
        self.currentLocation = .NONE
    }
    //if user start swiping (w/out resting finger on trackspad) this function may not be called
    func onTrackpadScrollGestureMayBegin() {
        //prevent movement if window is minimized
        if self.windowToMove == nil {
            self.trackpadTimedOut(haptic: false)
            return
        }
        
        self.trackpadState = .may_move
        
        let appFrame = try? self.windowToMove?.getMultipleAttributes(.frame)[.frame] as? NSRect
        WindowMover.snapOverlayWindow.setFrameCustom(rect: appFrame!.toCocoaCoord(), animate: false)
        WindowMover.snapOverlayWindow.alphaValue = 0
        WindowMover.snapOverlayWindow.makeKeyAndOrderFront(WindowMover.snapOverlayWindow)
        
        // trackpad modifier timer for when user starts by resting two fingers on trackpad
        // normal function moves window between screens
        // keyboard modified function moves window in thirds
        self.modifierTimeTimeoutTask?.cancel()
        self.modifierTimeTimeoutTask = DispatchWorkItem {
            if self.modifierFlags.contains(WindowMover.smallGridModifier) {
                self.currentLocation = .THIRD_MIDDLE
                self.modifierSelectionLocation = .THIRD_MIDDLE
                WindowMover.snapOverlayWindow.alphaValue = 1
                WindowMover.snapOverlayWindow.setFrameCustom(rect: getSnapLocationToScreen(location: self.currentLocation, screen: self.windowToMoveScreen!.toCocoaCoord()), animate: true)
            } else {
                self.trackpadState = .modifier
                self.currentLocation = .NONE
            }
            self.haptic.perform(.generic, performanceTime: .now)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.modifierTime, execute: self.modifierTimeTimeoutTask!)
        
        self.abortTimeTimeoutTask?.cancel()
        self.abortTimeTimeoutTask = DispatchWorkItem {
            self.trackpadTimedOut(haptic: true)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.abortTime, execute: self.abortTimeTimeoutTask!)
    }
    //aways called on any swipe or two finger move
    func onTrackpadScrollGestureBegan() {
        //prevent movement if window is minimized
        if self.windowToMove == nil {
            self.trackpadTimedOut(haptic: false)
            return
        }
        
        switch self.trackpadState {
        case .idle:
            //if overlay has not been shown yet, show it
            let appFrame = try? self.windowToMove?.getMultipleAttributes(.frame)[.frame] as? NSRect
            WindowMover.snapOverlayWindow.setFrameCustom(rect: appFrame!.toCocoaCoord(), animate: false)
            WindowMover.snapOverlayWindow.alphaValue = 0
            WindowMover.snapOverlayWindow.makeKeyAndOrderFront(WindowMover.snapOverlayWindow)
            break
        case .may_move:
            //overlay already showed
            break
        default:
            break
        }
        
        if self.modifierFlags.contains(WindowMover.smallGridModifier) {
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
        if previousLocation != .NONE && currentLocation != .NONE && self.windowToMove != nil {
            //move window
            let snap = (currentLocation == .NONE) ? previousLocation : currentLocation
            let setRect = getSnapLocationToScreen(location: snap, screen: self.windowToMoveScreen!.toCocoaCoord())
            let _ = try? self.windowToMove!.setAttribute(.position, value: setRect.toSystemCoord().origin)
            let _ = try? self.windowToMove!.setAttribute(.size, value: setRect.toSystemCoord().size)
            //update hit since user may have changed window focus without moving mouse
            self.update = true
        }
        //hide overlay
        WindowMover.snapOverlayWindow.hideWindow(animated: true)
        previousLocation = .NONE
        currentLocation = .NONE
        modifierSelectionLocation = .NONE
    }
    
    func setModifierFlags(_ flags:NSEvent.ModifierFlags) {
        // only set to none if changed
        if !(self.modifierFlags.contains(WindowMover.smallGridModifier) && flags.contains(WindowMover.smallGridModifier)) {
            self.currentLocation = .NONE
            self.modifierSelectionLocation = .NONE
            update = true
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
