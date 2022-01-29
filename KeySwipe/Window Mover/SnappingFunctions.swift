//
//  SnappingFunctions.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/25/22.
//

import Foundation
import Swindler

func moveWindowToScreen(allScreens: [Screen], window_ window: Window, direction: SwipeDirection) -> Bool {
    
    let mult = CGRect(x: (window.frame.value.minX - (window.screen?.applicationFrame.minX)!)/(window.screen?.applicationFrame.width)!, y: (window.frame.value.minY - (window.screen?.applicationFrame.minY)!)/(window.screen?.applicationFrame.height)!, width: window.frame.value.width/(window.screen?.applicationFrame.width)!, height: window.frame.value.height/(window.screen?.applicationFrame.height)!)

    switch direction {
    case .UP:
        break //TODO
    case .DOWN:
        break //TODO
    case .RIGHT:
        if let i = allScreens.indices.filter({allScreens[$0].frame.minX > (window.screen?.frame.minX)!}).min() {
            let mScreen = allScreens[i]
            let rect = CGRect(x: mScreen.applicationFrame.minX + (mult.minX * mScreen.applicationFrame.width), y: mScreen.applicationFrame.minY + (mult.minY * mScreen.applicationFrame.height), width: mult.width * mScreen.applicationFrame.width, height: mult.height * mScreen.applicationFrame.height)
            let _ = window.frame.set(rect)
            return true
            
        }
        break
    case .LEFT:
        if let i = allScreens.indices.filter({ allScreens[$0].frame.minX < (window.screen?.frame.minX)! }).max() {
            let mScreen = allScreens[i]
            let rect = CGRect(x: mScreen.applicationFrame.minX + (mult.minX * mScreen.applicationFrame.width), y: mScreen.applicationFrame.minY + (mult.minY * mScreen.applicationFrame.height), width: mult.width * mScreen.applicationFrame.width, height: mult.height * mScreen.applicationFrame.height)
            let _ = window.frame.set(rect)
            return true
            
        }
        break
    case .DIAGONAL:
        break
    }
    return false
}

func getSnapLocationToScreen(location: SnapLocation, screen: Screen) -> CGRect {
    let frame = screen.applicationFrame
    switch location {
    case .FULLSCREEEN:
        return screen.applicationFrame
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
