//
//  AppkitTouchesView.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/29/22.
//

import Foundation
import SwiftUI
import AppKit

protocol AppKitTouchesViewDelegate: AnyObject {
    // Provides `.touching` touches only.
    func touchesView(_ view: AppKitTouchesView, didUpdateTouchingTouches touches: Set<NSTouch>)
}

class AppkitTouchesWindow:NSWindow, AppKitTouchesViewDelegate {
    
    convenience init(contentRect: NSRect) {
        self.init(contentRect: contentRect, styleMask: [.closable, .fullSizeContentView,.resizable,.titled], backing: NSWindow.BackingStoreType.buffered, defer: true)
        
        self.title = "TEST"
        self.isOpaque = false
        self.ignoresMouseEvents = false
        
        self.acceptsMouseMovedEvents = true
        
        contentView = AppKitTouchesView()
    }
    
    func touchesView(_ view: AppKitTouchesView, didUpdateTouchingTouches touches: Set<NSTouch>) {
        print(touches)
    }
    
//    override func touchesBegan(with event: NSEvent) {
//        print(event)
//    }
    
    
}

final class AppKitTouchesView: NSView, NSGestureRecognizerDelegate {
    weak var delegate: AppKitTouchesViewDelegate?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        // We're interested in `.indirect` touches only.
        allowedTouchTypes = [.indirect]
        // We'd like to receive resting touches as well.
        wantsRestingTouches = true
        
        
    }
    
    override func beginGesture(with event: NSEvent) {
        print(event)
    }
    
    
    override func endGesture(with event: NSEvent) {
        print(event)
    }
    
    override func swipe(with event: NSEvent) {
        print(event)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func handleTouches(with event: NSEvent) {
        // Get all `.touching` touches only (includes `.began`, `.moved` & `.stationary`).
        let touches = event.touches(matching: .touching, in: self)
        // Forward them via delegate.
        delegate?.touchesView(self, didUpdateTouchingTouches: touches)
    }

//    override func touchesBegan(with event: NSEvent) {
//        handleTouches(with: event)
//        print(event)
//    }
//
//    override func touchesEnded(with event: NSEvent) {
//        handleTouches(with: event)
//    }
//
//    override func touchesMoved(with event: NSEvent) {
//        handleTouches(with: event)
//        print(event)
//    }
//
//    override func touchesCancelled(with event: NSEvent) {
//        handleTouches(with: event)
//    }
}
