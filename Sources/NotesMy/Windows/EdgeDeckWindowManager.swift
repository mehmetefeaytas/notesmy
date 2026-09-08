import AppKit
import SwiftUI
import Combine

@MainActor
public final class EdgeDeckWindowManager: NSObject, NSWindowDelegate {
    public static let shared = EdgeDeckWindowManager()

    private var deckPanel: NSPanel?
    private var cancellables = Set<AnyCancellable>()
    private var globalMouseMonitor: Any?
    private var activeScreen: NSScreen?

    public override init() {
        super.init()
        setupDeckPanel()
        setupObservations()
        setupMultiDisplayMouseTracking()
    }

    public func showDeck() {
        deckPanel?.orderFront(nil)
    }

    public func hideDeck() {
        deckPanel?.orderOut(nil)
    }

    public func toggleVisibility() {
        if let panel = deckPanel, panel.isVisible {
            panel.orderOut(nil)
            NoteStore.shared.isDeckVisible = false
        } else {
            deckPanel?.orderFront(nil)
            NoteStore.shared.isDeckVisible = true
        }
    }

    private func setupDeckPanel() {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.delegate = self

        let deckView = EdgeDeckView(
            store: NoteStore.shared,
            onSelectNote: { [weak self] noteId in
                let targetScreen = self?.activeScreen ?? NSScreen.main
                NoteWindowManager.shared.openNote(id: noteId, on: targetScreen)
            },
            onNewNote: { [weak self] in
                let note = NoteStore.shared.createNote()
                let targetScreen = self?.activeScreen ?? NSScreen.main
                NoteWindowManager.shared.openNote(id: note.id, on: targetScreen)
            },
            onOpenAllNotes: {
                AllNotesWindowManager.shared.show()
            },
            onOpenArchive: {
                AllNotesWindowManager.shared.show(filter: .archived)
            },
            onQuickCapture: { [weak self] in
                if let note = ClipboardService.shared.captureToNewNote() {
                    let targetScreen = self?.activeScreen ?? NSScreen.main
                    NoteWindowManager.shared.openNote(id: note.id, on: targetScreen)
                }
            },
            onOpenSettings: {
                SettingsWindowManager.shared.show()
            }
        )

        let hostingView = NSHostingView(rootView: deckView)
        panel.contentView = hostingView

        self.deckPanel = panel
        self.activeScreen = NSScreen.main
        updatePanelFrame(isExpanded: false)
        panel.orderFront(nil)
    }

    private func setupObservations() {
        NoteStore.shared.$isDeckHovered
            .receive(on: RunLoop.main)
            .sink { [weak self] isHovered in
                self?.updatePanelFrame(isExpanded: isHovered)
            }
            .store(in: &cancellables)

        NoteStore.shared.$dockSide
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updatePanelFrame(isExpanded: NoteStore.shared.isDeckHovered)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleScreenReconfiguration()
            }
            .store(in: &cancellables)
    }

    // MARK: - Multi-Display Tracking
    private func setupMultiDisplayMouseTracking() {
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.checkMouseScreenTransition()
            }
        }
    }

    private func checkMouseScreenTransition() {
        let mouseLoc = NSEvent.mouseLocation
        guard let currentScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) else {
            return
        }

        if currentScreen != activeScreen && !NoteStore.shared.isDeckHovered {
            self.activeScreen = currentScreen
            updatePanelFrame(isExpanded: false)
        }
    }

    private func handleScreenReconfiguration() {
        let mouseLoc = NSEvent.mouseLocation
        self.activeScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) ?? NSScreen.main
        updatePanelFrame(isExpanded: NoteStore.shared.isDeckHovered)
    }

    public func updatePanelFrame(isExpanded: Bool) {
        guard let screen = activeScreen ?? NSScreen.main, let panel = deckPanel else { return }
        let screenFrame = screen.visibleFrame

        let width: CGFloat = isExpanded ? 275 : 18
        let height: CGFloat = isExpanded ? min(screenFrame.height * 0.85, 580) : 220

        var x: CGFloat = 0
        var y: CGFloat = screenFrame.midY - (height / 2)

        switch NoteStore.shared.dockSide {
        case .right:
            x = screenFrame.maxX - width
        case .left:
            x = screenFrame.minX
        case .bottom:
            x = screenFrame.midX - (width / 2)
            y = screenFrame.minY
        }

        let newFrame = NSRect(x: x, y: y, width: width, height: height)
        panel.setFrame(newFrame, display: true, animate: false)
    }
}
