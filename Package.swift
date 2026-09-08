// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotesMy",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NotesMy", targets: ["NotesMy"])
    ],
    targets: [
        .executableTarget(
            name: "NotesMy",
            path: "Sources/NotesMy"
        ),
        .testTarget(
            name: "NotesMyTests",
            dependencies: ["NotesMy"],
            path: "Tests/NotesMyTests"
        )
    ]
)
