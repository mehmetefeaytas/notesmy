import Foundation
import AppKit
import Carbon

public final class HotKeyManager: @unchecked Sendable {
    public static let shared = HotKeyManager()

    public typealias HotKeyHandler = () -> Void
    private var hotKeys: [UInt32: HotKeyHandler] = [:]
    private var registeredRefs: [UInt32: EventHotKeyRef] = [:]
    private var eventHandlerRef: EventHandlerRef?
    private var nextHotKeyId: UInt32 = 1

    private init() {
        setupCarbonEventHandler()
    }

    public func unregisterAll() {
        for (_, ref) in registeredRefs {
            UnregisterEventHotKey(ref)
        }
        registeredRefs.removeAll()
        hotKeys.removeAll()
    }

    private func setupCarbonEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            if status == noErr {
                Task { @MainActor in
                    HotKeyManager.shared.handleHotKey(id: hotKeyID.id)
                }
            }
            return noErr
        }

        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, &eventHandlerRef)
    }

    @MainActor
    private func handleHotKey(id: UInt32) {
        if let handler = hotKeys[id] {
            handler()
        }
    }

    @discardableResult
    public func registerHotKey(keyCode: UInt32, modifiers: UInt32, handler: @escaping HotKeyHandler) -> UInt32? {
        let hotKeyId = nextHotKeyId
        nextHotKeyId += 1

        let hotKeyID = EventHotKeyID(signature: OSType(0x4E544D59), id: hotKeyId) // "NTMY"
        var hotKeyRef: EventHotKeyRef?

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr, let ref = hotKeyRef {
            hotKeys[hotKeyId] = handler
            registeredRefs[hotKeyId] = ref
            return hotKeyId
        } else {
            print("Failed to register hotkey with status: \(status)")
            return nil
        }
    }
}
