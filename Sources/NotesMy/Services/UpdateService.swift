import Foundation
import AppKit
import Combine
import UserNotifications

public struct ReleaseAsset: Codable, Sendable, Equatable {
    public let name: String
    public let browserDownloadUrl: String
    public let size: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadUrl = "browser_download_url"
        case size
    }
}

public struct AppReleaseInfo: Codable, Sendable, Identifiable, Equatable {
    public let id: Int
    public let tagName: String
    public let name: String?
    public let body: String?
    public let htmlUrl: String
    public let publishedAt: String?
    public let assets: [ReleaseAsset]

    enum CodingKeys: String, CodingKey {
        case id
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case publishedAt = "published_at"
        case assets
    }

    public var version: String {
        tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))
    }

    public var displayTitle: String {
        if let name = name, !name.isEmpty {
            return name
        }
        return "NotesMy \(tagName)"
    }

    public var dmgDownloadURL: URL? {
        if let dmgAsset = assets.first(where: { $0.name.hasSuffix(".dmg") }) {
            return URL(string: dmgAsset.browserDownloadUrl)
        }
        if let zipAsset = assets.first(where: { $0.name.hasSuffix(".zip") }) {
            return URL(string: zipAsset.browserDownloadUrl)
        }
        return URL(string: htmlUrl)
    }
}

public enum UpdateState: Equatable {
    case idle
    case checking
    case upToDate(currentVersion: String)
    case updateAvailable(AppReleaseInfo)
    case downloading(progress: Double)
    case readyToInstall(dmgURL: URL, version: String)
    case error(message: String)
}

@MainActor
public final class UpdateService: NSObject, ObservableObject, URLSessionDownloadDelegate {
    public static let shared = UpdateService()

    private let repoOwner = "mehmetefeaytas"
    private let repoName = "notesmy"
    private let autoCheckKey = "NotesMyAutoUpdateCheckEnabled"
    private let lastCheckKey = "NotesMyLastUpdateCheckTimestamp"

    @Published public private(set) var state: UpdateState = .idle
    @Published public var autoCheckEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoCheckEnabled, forKey: autoCheckKey)
        }
    }
    @Published public private(set) var lastCheckDate: Date? {
        didSet {
            UserDefaults.standard.set(lastCheckDate, forKey: lastCheckKey)
        }
    }
    @Published public private(set) var downloadProgress: Double = 0.0

    private var downloadTask: URLSessionDownloadTask?
    private var downloadContinuation: CheckedContinuation<URL, Error>?
    private var activeReleaseToInstall: AppReleaseInfo?

    public var currentVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, !version.isEmpty {
            return version
        }
        return "1.6.2"
    }

    private override init() {
        if UserDefaults.standard.object(forKey: autoCheckKey) == nil {
            self.autoCheckEnabled = true
        } else {
            self.autoCheckEnabled = UserDefaults.standard.bool(forKey: autoCheckKey)
        }
        self.lastCheckDate = UserDefaults.standard.object(forKey: lastCheckKey) as? Date
        super.init()
    }

    // MARK: - Version Comparison Logic

    public nonisolated static func isVersion(_ v1: String, higherThan v2: String) -> Bool {
        let clean1 = v1.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))
        let clean2 = v2.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))

        let parts1 = clean1.split(separator: ".").compactMap { Int($0) }
        let parts2 = clean2.split(separator: ".").compactMap { Int($0) }

        let count = max(parts1.count, parts2.count)
        for i in 0..<count {
            let p1 = i < parts1.count ? parts1[i] : 0
            let p2 = i < parts2.count ? parts2[i] : 0
            if p1 > p2 { return true }
            if p1 < p2 { return false }
        }
        return false
    }

    // MARK: - Check For Updates

    public func checkForUpdates(isUserInitiated: Bool = true) async {
        state = .checking
        lastCheckDate = Date()

        let apiURLString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: apiURLString) else {
            state = .error(message: "Invalid update URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("NotesMy-macOS-Updater", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                state = .error(message: "Geçersiz sunucu yanıtı")
                return
            }

            if httpResponse.statusCode == 404 {
                // No releases published yet on GitHub repo
                state = .upToDate(currentVersion: currentVersion)
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                state = .error(message: "GitHub API Hatası: \(httpResponse.statusCode)")
                return
            }

            let release = try JSONDecoder().decode(AppReleaseInfo.self, from: data)

            if Self.isVersion(release.version, higherThan: currentVersion) {
                state = .updateAvailable(release)

                if !isUserInitiated {
                    notifyUpdateAvailable(release: release)
                }
            } else {
                state = .upToDate(currentVersion: currentVersion)
            }
        } catch {
            if isUserInitiated {
                state = .error(message: error.localizedDescription)
            } else {
                state = .idle
            }
        }
    }

    // MARK: - Download & Install

    public func downloadAndInstall(release: AppReleaseInfo) async {
        guard let downloadURL = release.dmgDownloadURL else {
            openReleasePage(release: release)
            return
        }

        state = .downloading(progress: 0.0)
        downloadProgress = 0.0
        activeReleaseToInstall = release

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        do {
            let tempDownloadedURL = try await withCheckedThrowingContinuation { continuation in
                self.downloadContinuation = continuation
                let task = session.downloadTask(with: downloadURL)
                self.downloadTask = task
                task.resume()
            }

            // Move to user's Downloads folder
            let fileManager = FileManager.default
            let downloadsDir = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
            let targetFileName = "NotesMy-\(release.version).dmg"
            let destinationURL = downloadsDir.appendingPathComponent(targetFileName)

            try? fileManager.removeItem(at: destinationURL)
            try fileManager.moveItem(at: tempDownloadedURL, to: destinationURL)

            state = .readyToInstall(dmgURL: destinationURL, version: release.version)

            // Open/Mount the DMG in macOS and reveal in Finder
            NSWorkspace.shared.open(destinationURL)
            NSWorkspace.shared.activateFileViewerSelecting([destinationURL])

        } catch {
            state = .error(message: "İndirme başarısız oldu: \(error.localizedDescription)")
        }
    }

    public func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        downloadContinuation?.resume(throwing: CancellationError())
        downloadContinuation = nil
        state = .idle
    }

    public func openReleasePage(release: AppReleaseInfo) {
        if let url = URL(string: release.htmlUrl) {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Notifications

    private func notifyUpdateAvailable(release: AppReleaseInfo) {
        let content = UNMutableNotificationContent()
        content.title = "🚀 NotesMy Güncellemesi Mevcut: v\(release.version)"
        content.body = "Yeni özellikler ve iyileştirmeler yayınlandı. Güncellemek için tıklayın."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "notesmy_update_\(release.version)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // MARK: - URLSessionDownloadDelegate

    public nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        Task { @MainActor in
            self.downloadProgress = progress
            self.state = .downloading(progress: progress)
        }
    }

    public nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // Copy to temporary cache location before system deletes it
        let tempDir = FileManager.default.temporaryDirectory
        let tempTarget = tempDir.appendingPathComponent("NotesMyDownload-\(UUID().uuidString).dmg")
        try? FileManager.default.copyItem(at: location, to: tempTarget)

        Task { @MainActor in
            self.downloadContinuation?.resume(returning: tempTarget)
            self.downloadContinuation = nil
        }
    }

    public nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error {
            Task { @MainActor in
                self.downloadContinuation?.resume(throwing: error)
                self.downloadContinuation = nil
            }
        }
    }
}
