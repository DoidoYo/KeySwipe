//
//  SnapOverlayWindow.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/25/22.
//

import Foundation
import AppKit

class SnapOverlayWindow:NSWindow {
    
    private var hideWindowTask: DispatchWorkItem?
    
    convenience init(contentRect: NSRect) {
        self.init(contentRect: contentRect, styleMask: [NSWindow.StyleMask.borderless], backing: NSWindow.BackingStoreType.buffered, defer: true)
        
        self.level = .popUpMenu
        self.hasShadow = false
        self.isOpaque = false
        self.ignoresMouseEvents = true
        self.acceptsMouseMovedEvents = false
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.animationBehavior = .none
        
        self.backgroundColor = .clear
        
        
        let ve = NSVisualEffectView()
        ve.blendingMode = .behindWindow
        ve.material = .dark
        ve.alphaValue = 1
        ve.state = .active
        ve.wantsLayer = true
        ve.layer?.cornerRadius = 10
        contentView = ve

        contentView?.wantsLayer = true
        contentView?.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
    
    func setFrameCustom(rect: NSRect, animate: Bool) {
        hideWindowTask?.cancel()
        if self.frame == rect { return }
        if animate {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.08 // maybe make this configurable
                self.animator().setFrame(rect, display: true)
            }
        } else {
            self.setFrame(rect, display: false, animate: false)
        }
    }
    
    func hideWindow(animated: Bool) {
        if animated {
            hideWindowTask?.cancel()
            hideWindowTask = nil
            hideWindowTask = DispatchWorkItem {
                self.orderOut(self)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: hideWindowTask!)
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.4 // maybe make this configurable
                self.animator().alphaValue = 0
            } completionHandler: {
                
            }
        } else {
            self.orderOut(self)
        }
    }
    
}
