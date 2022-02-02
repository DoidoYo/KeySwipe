//
//  KeyboardListener.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/24/22.
//

import Foundation
import Cocoa

protocol KeyboardListenerDelegate: AnyObject {
//    func onActivationStarted()
//    func onActivationCompleted()
//    func onActivationAborted()
//    func onKeyDownWhileActivated(pressedKeys: Set<UInt16>)
    
    func onTrigger()
    func onModifiers(flags _: [NSEvent.ModifierFlags])
    func onTriggerEnded()
}

private enum ActivationState: String {
    case idle
    case active
}

class KeyboardListener {
    
    weak var delegate: KeyboardListenerDelegate?
    
    private var globalModifierKeyMonitor: Any?
    private var localModifierKeyMonitor: Any?
    
//    var activationKeys = NSEvent.ModifierFlags(arrayLiteral: [.option])
    var activationKeys:[NSEvent.ModifierFlags] = [.option]
    var modifierKeys:[NSEvent.ModifierFlags] = [.command]
    
    private var state = ActivationState.idle
    
    init() {
        self.globalModifierKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { (event) in
            self.onModifierKeyEvent(event)
        }
        self.localModifierKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (event) in
            self.onModifierKeyEvent(event)
            return event
        }
    }
    
    func setDelegate(_ delegate: KeyboardListenerDelegate?) {
        self.delegate = delegate
    }
    
    private func onModifierKeyEvent(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
//        Logger.shared.log("Modifier key event", [
//            "state": self.state.rawValue,
//            "flags": humanReadableModifierFlags(flags),
//        ])
        
        if flags.contains(NSEvent.ModifierFlags(rawValue: getModMasks(self.activationKeys)))  {
            var modifiers = [NSEvent.ModifierFlags]()
            if flags.contains(.command) {
                modifiers.append(NSEvent.ModifierFlags.command)
            }
            handleActivationKey(modifiers)
        } else {
            handleOtherModifierKeyCombinations()
        }
    }
    
    private func handleActivationKey(_ mod:[NSEvent.ModifierFlags]) {
        switch self.state {
        case .idle:
            self.delegate?.onTrigger()
            self.delegate?.onModifiers(flags: mod)
            self.state = .active
            break
        case .active:
            self.delegate?.onModifiers(flags: mod)
            break
        }
        
    }
    
    private func handleOtherModifierKeyCombinations() {
        switch self.state {
        case .idle:
            // NOOP
            break
        case .active:
            // Go back to idle state w/ aborted event
            self.state = .idle
            self.delegate?.onTriggerEnded()
        }
    }
    
    func getModMasks(_ d:[NSEvent.ModifierFlags]) -> UInt {
        var all:UInt=0
        for i in d {
            all = all | i.rawValue
        }
        return all
    }
    
    deinit {
        NSEvent.removeMonitor(self.localModifierKeyMonitor as Any)
        NSEvent.removeMonitor(self.globalModifierKeyMonitor as Any)
    }
}

fileprivate func humanReadableModifierFlags(_ flags: NSEvent.ModifierFlags) -> String {
    var keys: [String] = []
    if flags.contains(.capsLock) { keys.append("capsLock") }
    if flags.contains(.shift) { keys.append("shift") }
    if flags.contains(.control) { keys.append("control") }
    if flags.contains(.option) { keys.append("option") }
    if flags.contains(.command) { keys.append("command") }
    if flags.contains(.numericPad) { keys.append("numericPad") }
    if flags.contains(.help) { keys.append("help") }
    return keys.joined(separator: " ")
}
