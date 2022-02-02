//
//  GestureWindowManager.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import Cocoa

class GestureWindowManager {
    static let shared = GestureWindowManager()
    
    private var all = [GestureWindow]()
    private var avaliable = [GestureWindow]()
    
    func forEach(_ predicate: (GestureWindow) -> ()) {
        self.all.forEach { (item) in
            predicate(item)
        }
    }
    
    private func create() -> GestureWindow {
        // Create gesture overlay window
        let gestureWindow = GestureWindow(contentRect: CGRect(x: 0, y: 0, width: 0, height: 0), styleMask: [NSWindow.StyleMask.borderless], backing: NSWindow.BackingStoreType.buffered, defer: true)
        
        gestureWindow.level = .popUpMenu
        gestureWindow.isOpaque = false
        
        gestureWindow.ignoresMouseEvents = false
        gestureWindow.acceptsMouseMovedEvents = true
        
//        gestureWindow.contentView!.allowedTouchTypes = [.indirect]
        
        gestureWindow.backgroundColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.0)
        
        self.all.append(gestureWindow)
        
        return gestureWindow
    }
    
    func acquire() -> GestureWindow {
        if self.avaliable.isEmpty {
            return self.create()
        }
        
        return self.avaliable.removeLast()
    }
    
    func getBackmostGestureWindow() -> GestureWindow? {
        return self.all.min { g1, g2 in
            return g1.orderedIndex > g2.orderedIndex
        }
    }
    
    func release(_ item: GestureWindow) {
        // Remove gestureWindow's delegate, just in case
        item.setDelegate(nil)
        
        self.avaliable.append(item)
    }
}
