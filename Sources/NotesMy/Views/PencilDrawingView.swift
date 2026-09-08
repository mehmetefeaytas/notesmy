import SwiftUI
import AppKit

// PencilKit is iOS/iPadOS only. On macOS we use a native NSView-based
// freehand canvas that works with Apple Pencil via USB/Sidecar and mouse/trackpad.

public struct PencilDrawingView: View {
    @ObservedObject var store = NoteStore.shared
    public var noteId: UUID
    public var onSave: (URL) -> Void
    public var onDismiss: () -> Void

    @State private var drawingImage: NSImage? = nil
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 3.0

    public init(noteId: UUID, onSave: @escaping (URL) -> Void, onDismiss: @escaping () -> Void) {
        self.noteId = noteId
        self.onSave = onSave
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "pencil.tip.crop.circle")
                    .foregroundColor(.accentColor)
                Text("Freehand Sketch")
                    .font(.system(size: 13, weight: .bold))

                Spacer()

                // Color picker
                HStack(spacing: 6) {
                    ForEach([Color.black, .blue, .red, .green, .orange], id: \.self) { c in
                        Circle()
                            .fill(c)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle().stroke(selectedColor == c ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture { selectedColor = c }
                    }
                }

                // Line width
                Slider(value: $lineWidth, in: 1...12)
                    .frame(width: 70)

                Button("Clear") {
                    drawingImage = nil
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)

                Button("Save to Note") {
                    saveDrawing()
                }
                .font(.system(size: 11, weight: .semibold))
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    onDismiss()
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Drawing canvas
            DrawingCanvasView(image: $drawingImage, strokeColor: $selectedColor, lineWidth: $lineWidth)
                .background(Color.white)
        }
        .frame(width: 580, height: 420)
        .cornerRadius(10)
    }

    private func saveDrawing() {
        guard let img = drawingImage else { onDismiss(); return }
        guard let tiff = img.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            onDismiss(); return
        }

        let fileName = "Sketch_\(Date().timeIntervalSince1970).png"
        let outputURL = store.attachmentsDirectory.appendingPathComponent(fileName)
        try? pngData.write(to: outputURL)
        onSave(outputURL)
    }
}

// MARK: - AppKit Drawing Canvas

struct DrawingCanvasView: NSViewRepresentable {
    @Binding var image: NSImage?
    @Binding var strokeColor: Color
    @Binding var lineWidth: CGFloat

    func makeNSView(context: Context) -> CanvasNSView {
        let v = CanvasNSView()
        v.onImageChange = { self.image = $0 }
        return v
    }

    func updateNSView(_ nsView: CanvasNSView, context: Context) {
        nsView.strokeColor = NSColor(strokeColor)
        nsView.lineWidth = lineWidth
        if image == nil {
            nsView.clearCanvas()
        }
    }
}

class CanvasNSView: NSView {
    var strokeColor: NSColor = .black
    var lineWidth: CGFloat = 3.0
    var onImageChange: ((NSImage?) -> Void)?

    private var currentPath: NSBezierPath?
    private var layers: [CanvasStroke] = []

    struct CanvasStroke {
        var path: NSBezierPath
        var color: NSColor
    }

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.setFill()
        dirtyRect.fill()
        for stroke in layers {
            stroke.color.setStroke()
            stroke.path.stroke()
        }
        currentPath?.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        currentPath = NSBezierPath()
        currentPath?.lineCapStyle = .round
        currentPath?.lineJoinStyle = .round
        currentPath?.lineWidth = lineWidth
        currentPath?.move(to: point)
        strokeColor.setStroke()
        currentPath?.stroke()
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        currentPath?.line(to: point)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        if let path = currentPath {
            let stroke = CanvasStroke(path: path.copy() as! NSBezierPath, color: strokeColor)
            layers.append(stroke)
        }
        currentPath = nil
        exportImage()
    }

    func clearCanvas() {
        layers.removeAll()
        currentPath = nil
        needsDisplay = true
        onImageChange?(nil)
    }

    private func exportImage() {
        let img = NSImage(size: bounds.size)
        img.lockFocus()
        NSColor.white.setFill()
        bounds.fill()
        for stroke in layers {
            stroke.color.setStroke()
            stroke.path.stroke()
        }
        img.unlockFocus()
        onImageChange?(img)
    }
}
