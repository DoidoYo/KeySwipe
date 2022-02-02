//
//  SnappingFunctions.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/25/22.
//

import Foundation
import AppKit
import AXSwift
import SwiftUI

func moveWindowToScreen(window windowElement: UIElement, direction: SwipeDirection) -> Bool {
//    let allScreens = NSScreen.screens.map({$0.frame})
    
    let window:NSRect!
    if let x = try? windowElement.getMultipleAttributes(.frame)[.frame] as? NSRect {
        window = x
    } else {
        return false
    }
    
    let screen = getAppScreenFromSystem(window)
    //getAppScreen(window: getScreen(window: window)!.frame)
    
    let allScreens = NSScreen.screens.map({NSRect(origin: $0.frame.origin, size: CGSize(width: $0.frame.width, height: $0.frame.height - (NSApplication.shared.mainMenu?.menuBarHeight ?? 0)))})
    
    let mult = CGRect(x: (window.minX - (screen.minX))/(screen.width), y: (window.minY - (screen.minY))/(screen.height), width: window.width/(screen.width), height: window.height/(screen.height))

    switch direction {
    case .UP:
        break //TODO
    case .DOWN:
        break //TODO
    case .RIGHT:
        if let i = allScreens.indices.filter({allScreens[$0].minX > (window.minX)}).min() {
            let mScreen = allScreens[i]
            let rect = CGRect(x: mScreen.minX + (mult.minX * mScreen.width), y: mScreen.minY + (mult.minY * mScreen.height), width: mult.width * mScreen.width, height: mult.height * mScreen.height)

            let _ = try? windowElement.setAttribute(.position, value: rect.toSystemCoord().origin)
            let _ = try? windowElement.setAttribute(.size, value: rect.toSystemCoord().size)
            return true
        }
        break
    case .LEFT:
        if let i = allScreens.indices.filter({ allScreens[$0].maxX <= (window.minX)}).max() {
            let mScreen = allScreens[i]
            let rect = CGRect(x: mScreen.minX + (mult.minX * mScreen.width), y: mScreen.minY + (mult.minY * mScreen.height), width: mult.width * mScreen.width, height: mult.height * mScreen.height)

            let _ = try? windowElement.setAttribute(.position, value: rect.toSystemCoord().origin)
            let _ = try? windowElement.setAttribute(.size, value: rect.toSystemCoord().size)
            return true
        }
        break
    case .DIAGONAL:
        break
    }
    return false
}
// take in System coordinates
func getAppScreenFromSystem(_ appWindow:NSRect) ->NSRect {
    let menuHeight = (NSApplication.shared.mainMenu?.menuBarHeight ?? 0)
    let window = getCocoaScreen(appWindow)!.toSystemCoord()
    let rec = NSRect(origin: NSPoint(x: window.minX, y: window.minY + menuHeight), size: CGSize(width: window.width, height: window.height - menuHeight))
    return rec
}
//gives out cocoa coordinates
func getCocoaScreen(_ window:NSRect) -> NSRect? {
    
    let i = NSScreen.screens.map({ i -> Float in
        let ii = i.frame.intersection(window)
        return Float(ii.width * ii.height)
    })
    
    return NSScreen.screens[i.firstIndex(of: i.max()!)!].frame
}

extension NSRect {
    
    func toCocoaCoord() -> NSRect {
        let rect = self
        return NSRect(origin: CGPoint(x: rect.minX, y: NSScreen.screens.map({$0.frame.height}).max()! - (rect.minY + self.height)), size: rect.size)
    }
    func toSystemCoord() -> NSRect{
        let rect = self
        return NSRect(origin: CGPoint(x: rect.minX, y: NSScreen.screens.map({$0.frame.height}).max()! - (rect.minY + self.height)), size: rect.size)
    }
}

func getSnapLocationToScreen(location: SnapLocation, screen: NSRect) -> CGRect {
    let frame = screen
    switch location {
    case .FULLSCREEEN:
        return screen
    case .LEFT_HALF:
        return CGRect(x: frame.minX, y: frame.minY, width: frame.width/2, height: frame.height)
    case .RIGHT_HALF:
        return CGRect(x: frame.minX + (frame.width/2), y: frame.minY, width: frame.width/2, height: frame.height)
    case .TOP_LEFT:
        return CGRect(x: frame.minX, y: frame.minY + (frame.height/2), width: frame.width/2, height: frame.height/2)
    case .TOP_RIGHT:
        return CGRect(x: frame.minX + (frame.width/2), y: frame.minY + (frame.height/2), width: frame.width/2, height: frame.height/2)
    case .BOTTOM_LEFT:
        return CGRect(x: frame.minX, y: frame.minY, width: frame.width/2, height: frame.height/2)
    case .BOTTOM_RIGHT:
        return CGRect(x: frame.minX + (frame.width/2), y: frame.minY, width: frame.width/2, height: frame.height/2)
    case .NONE:
        break
    case .THIRD_MIDDLE:
        return CGRect(x: frame.minX + (frame.width/3), y: frame.minY, width: frame.width/3, height: frame.height)
    case .THIRD_LEFT:
        return CGRect(x: frame.minX, y: frame.minY, width: frame.width/3, height: frame.height)
    case .THIRD_RIGHT:
        return CGRect(x: frame.minX + (2*frame.width/3), y: frame.minY, width: frame.width/3, height: frame.height)
    case .THIRD_MIDDLE_RIGHT:
        return CGRect(x: frame.minX + (frame.width/3), y: frame.minY, width: 2*frame.width/3, height: frame.height)
    case .THIRD_MIDDLE_LEFT:
        return CGRect(x: frame.minX, y: frame.minY, width: 2*frame.width/3, height: frame.height)
        
    default:
        break
    }
    return CGRect(x: 0, y: 0, width: 0, height: 0)
}

// add -> Bool that says if it should lock selection. TODO
func get3x3SnapLocation(currentLocation: SnapLocation, swipeDirection: SwipeDirection) -> SnapLocation {
    switch currentLocation {
    case .NONE:
        switch swipeDirection {
        case .RIGHT:
            return .THIRD_RIGHT
        case .LEFT:
            return .THIRD_LEFT
        default:
            return .NONE
        }
    case .THIRD_MIDDLE:
        switch swipeDirection {
        case .RIGHT:
            return .THIRD_MIDDLE_RIGHT
        case .LEFT:
            return .THIRD_MIDDLE_LEFT
        default:
            break
        }
        break
    case .THIRD_LEFT:
        switch swipeDirection {
        case .RIGHT:
            return .THIRD_MIDDLE_LEFT
        default:
            break
        }
        break
    case .THIRD_RIGHT:
        switch swipeDirection {
        case .LEFT:
            return .THIRD_MIDDLE_RIGHT
        default:
            break
        }
        break
    case .THIRD_MIDDLE_RIGHT:
        switch swipeDirection {
        case .RIGHT:
            return .THIRD_RIGHT
        case .LEFT:
            return .THIRD_MIDDLE
        default:
            break
        }
        break
    case .THIRD_MIDDLE_LEFT:
        switch swipeDirection {
        case .RIGHT:
            return .THIRD_MIDDLE
        case .LEFT:
            return .THIRD_LEFT
        default:
            break
        }
        break
    default:
        break
    }
    
    return currentLocation
}

func get2x2SnapLocation(currentLocation: SnapLocation, swipeDirection: SwipeDirection) -> SnapLocation {
    
    //        if swipeDirection == SwipeDirection.DIAGONAL { return currentLocation }
    //modifier timer - short ; reset time - long
    // idea for top half. swipe up. if modifier timer is true make top half
    switch currentLocation {
    case .NONE:
        switch swipeDirection {
        case .UP:
            return .FULLSCREEEN
        case .DOWN:
            //TODO - still does nothing
            break
        case .RIGHT:
            return .RIGHT_HALF
        case .LEFT:
            return .LEFT_HALF
        case .DIAGONAL:
            break
//        default:
//            break
        }
    case .FULLSCREEEN:
        switch swipeDirection {
        case .UP:
            //Doesn't change
            break
        case .DOWN:
            break
        case .RIGHT:
            return .TOP_RIGHT
        case .LEFT:
            return .TOP_LEFT
        case .DIAGONAL:
            break
//        default:
//            break
        }
    case .LEFT_HALF:
        switch swipeDirection {
        case .UP:
            return .TOP_LEFT
        case .DOWN:
            return .BOTTOM_LEFT
        case .RIGHT:
            return .RIGHT_HALF
        case .LEFT:
            break
        case .DIAGONAL:
            break
//        default:
//            break
        }
    case .RIGHT_HALF:
        switch swipeDirection {
        case .UP:
            return .TOP_RIGHT
        case .DOWN:
            return .BOTTOM_RIGHT
        case .RIGHT:
            break
        case .LEFT:
            return .LEFT_HALF
        case .DIAGONAL:
            break
//        default:
//            break
        }
    case .TOP_LEFT:
        switch swipeDirection {
        case .UP:
            break
        case .DOWN:
            return .BOTTOM_LEFT
        case .RIGHT:
            return .TOP_RIGHT
        case .LEFT:
            break
        case .DIAGONAL:
            break
//        default:
//            break
        }
    case .TOP_RIGHT:
        switch swipeDirection {
        case .UP:
            break
        case .DOWN:
            return .BOTTOM_RIGHT
        case .RIGHT:
            break
        case .LEFT:
            return .TOP_LEFT
        case .DIAGONAL:
            break
//        default:
//            break
        }
    case .BOTTOM_LEFT:
        switch swipeDirection {
        case .UP:
            return .TOP_LEFT
        case .DOWN:
            break
        case .RIGHT:
            return .BOTTOM_RIGHT
        case .LEFT:
            break
        case .DIAGONAL:
            break
//        default:
//            break
        }
    case .BOTTOM_RIGHT:
        switch swipeDirection {
        case .UP:
            return .TOP_RIGHT
        case .DOWN:
            break
        case .RIGHT:
            break
        case .LEFT:
            return .BOTTOM_LEFT
        case .DIAGONAL:
            break
//        default:
//            break
        }
    default:
        break
    }
    
    return currentLocation
}
