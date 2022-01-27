//
//  QuickPickerWindow.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/26/22.
//

import Foundation
import AppKit

class QuickPickerWindow:NSWindow {
    
    override init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: [NSWindow.StyleMask.borderless], backing: NSWindow.BackingStoreType.buffered, defer: true)
        
        self.level = .popUpMenu
        self.isOpaque = false
        
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
        
        self.contentView!.allowedTouchTypes = [.indirect]
        self.contentView!.wantsRestingTouches = true
        
        self.backgroundColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.0)
        

        
    }
    
}
