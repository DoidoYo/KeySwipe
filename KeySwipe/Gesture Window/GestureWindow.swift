//
//  GestureWindow.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import AppKit

protocol GestureWindowDelegate: AnyObject {
    func onTrackpadScrollGesture(delta: (vector:CGVector, timestamp: Double, direction:SwipeDirection))
    func onTrackpadScrollGestureBegan()
    func onTrackpadScrollGestureEnded()
    func onTrackpadScrollGestureMayBegin()
    func onMouseMoveGesture(position: CGPoint)
    func onMagnifyGesture(factor: (width: CGFloat, height: CGFloat))
}

enum SwipeDirection {
    case UP
    case DOWN
    case RIGHT
    case LEFT
    case DIAGONAL
}

class GestureWindow: NSWindow {
    
    weak var delegate_: GestureWindowDelegate?
    
    private var trackpadScrollDeltaHistory = [(vector: CGVector, timestamp: TimeInterval)]()
    
    private var trackingArea:NSTrackingArea?
    
    private let VECTOR_UP_RIGHT = CGVector(dx: 1, dy: 1).normalized()
    private let VECTOR_UP_LEFT = CGVector(dx: -1, dy: 1).normalized()
    private let VECTOR_DOWN_RIGHT = CGVector(dx: 1, dy: -1).normalized()
    private let VECTOR_DOWN_LEFT = CGVector(dx: -1, dy: -1).normalized()
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.trackingArea = NSTrackingArea(rect: NSRect.zero, options: [.activeAlways,.mouseMoved], owner: self, userInfo: nil)
        self.contentView?.addTrackingArea(trackingArea!)
    }
    
    func setFrameAndTA(rect: NSRect) {
        self.setFrame(rect, display: true, animate: false)
        
        if self.trackingArea != nil {
            self.contentView?.removeTrackingArea(trackingArea!)
        }
        
        self.trackingArea = NSTrackingArea(rect: NSRect(origin: CGPoint.zero, size: CGSize(width: rect.width, height: rect.height)), options: [.activeAlways,.mouseMoved], owner: self, userInfo: nil)
        self.contentView?.addTrackingArea(self.trackingArea!)
    }
    
    
    
    func setDelegate(_ delegate: GestureWindowDelegate?) {
        self.delegate_ = delegate
    }
    
    
    
    override func mouseDown(with event: NSEvent) {
//        print(event)
    }
    override func rightMouseDown(with event: NSEvent) {
//        print(event)
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override func scrollWheel(with event: NSEvent) {
        // Check if scroll is triggered from mouse wheel
        // https://stackoverflow.com/a/13981577
        if event.phase == NSEvent.Phase.init(rawValue: 0) &&
            event.momentumPhase == NSEvent.Phase.init(rawValue: 0) {
            return
        }
        //trackpad gesture
        if event.phase == NSEvent.Phase.mayBegin { //two fingers down, but not moving
            self.delegate_?.onTrackpadScrollGestureMayBegin()
        }else if event.phase == NSEvent.Phase.began { //two fingers started moving
            self.delegate_?.onTrackpadScrollGestureBegan()
            
            self.trackpadScrollDeltaHistory = []
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
            
            self.delegate_?.onTrackpadScrollGesture(delta: delta)
        } else if (event.phase == NSEvent.Phase.ended || event.phase == NSEvent.Phase.cancelled) {
            // Call the delegate method
            self.delegate_?.onTrackpadScrollGestureEnded()
            self.trackpadScrollDeltaHistory = []
            
        }
    }
    
    override func touchesMoved(with event: NSEvent) {
//        print("Touch Moved")
    }
    
    override func touchesBegan(with event: NSEvent) {
//        print("Touch Began")
    }
    
    override func mouseMoved(with event: NSEvent) {
        let mouseX = NSEvent.mouseLocation.x
        let mouseY = NSEvent.mouseLocation.y // bottom-left origined
        self.delegate_?.onMouseMoveGesture(position: CGPoint(x: mouseX, y: mouseY))
    }
    
    func clear() {
        self.trackpadScrollDeltaHistory = []
    }
    
}
