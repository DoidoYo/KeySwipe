//
//  InputNotification.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 2/1/22.
//

import Foundation
import Signals

class InputNotfication {
    static let shared = InputNotfication()
    
    let onTrackpadScrollGesture = Signal<(vector:CGVector, timestamp: Double, direction:SwipeDirection)>()
    let onTrackpadScrollGestureBegan = Signal<Int>()
    let onTrackpadScrollGestureEnded = Signal<Int>()
    let onTrackpadScrollGestureMayBegin = Signal<Int>()
    
}
