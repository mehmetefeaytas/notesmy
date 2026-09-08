import Foundation
import CloudKit
import Security

@MainActor
public final class CloudKitSyncService: ObservableObject {
    public static let shared = CloudKitSyncService()

    @Published public var isSyncing: Bool = false
    @Published public var lastSyncDate: Date? = nil
    @Published public var syncStatusMessage: String = "Local Storage"
    @Published public var isCloudKitAvailable: Bool = false

    private let containerIdentifier = "iCloud.app.notesmy.mac"

    public var isEntitled: Bool {
        guard let task = SecTaskCreateFromSelf(nil) else { return false }
        guard let value = SecTaskCopyValueForEntitlement(task, "com.apple.developer.icloud-container-identifiers" as CFString, nil) else {
            return false
        }
        if let array = value as? [String] {
            return array.contains(containerIdentifier)
        }
        return false
    }

    private var container: CKContainer? {
        guard isEntitled else { return nil }
        return CKContainer(identifier: containerIdentifier)
    }

    private init() {
        if isEntitled {
            checkAccountStatus()
        } else {
            isCloudKitAvailable = false
            syncStatusMessage = "Local Storage"
        }
    }

    public func checkAccountStatus() {
        guard isEntitled, let c = container else {
            isCloudKitAvailable = false
            syncStatusMessage = "Local Storage"
            return
        }

        c.accountStatus { [weak self] status, error in
            Task { @MainActor [weak self] in
                switch status {
                case .available:
                    self?.isCloudKitAvailable = true
                    self?.syncStatusMessage = "iCloud Active"
                case .noAccount:
                    self?.isCloudKitAvailable = false
                    self?.syncStatusMessage = "No iCloud Account"
                case .restricted:
                    self?.isCloudKitAvailable = false
                    self?.syncStatusMessage = "iCloud Restricted"
                case .couldNotDetermine:
                    self?.isCloudKitAvailable = false
                    self?.syncStatusMessage = "iCloud Status Unknown"
                case .temporarilyUnavailable:
                    self?.isCloudKitAvailable = false
                    self?.syncStatusMessage = "iCloud Temporarily Unavailable"
                @unknown default:
                    self?.isCloudKitAvailable = false
                }
            }
        }
    }

    public func syncNotes() async {
        guard isEntitled, isCloudKitAvailable, let c = container else {
            syncStatusMessage = "Local Storage"
            return
        }

        isSyncing = true
        syncStatusMessage = "Syncing with iCloud..."

        let privateDB = c.privateCloudDatabase
        let store = NoteStore.shared

        // Prepare records to upload from local store
        let localNotes = store.notes
        var recordsToSave: [CKRecord] = []

        for note in localNotes {
            let recordID = CKRecord.ID(recordName: note.id.uuidString)
            let record = CKRecord(recordType: "NoteItem", recordID: recordID)
            record["title"] = note.title as CKRecordValue
            record["body"] = note.body as CKRecordValue
            record["category"] = note.category as CKRecordValue
            record["color"] = note.color.rawValue as CKRecordValue
            record["updatedAt"] = note.updatedAt as CKRecordValue
            record["isPinned"] = (note.isPinned ? 1 : 0) as CKRecordValue
            record["isFavorite"] = (note.isFavorite ? 1 : 0) as CKRecordValue
            record["isArchived"] = (note.isArchived ? 1 : 0) as CKRecordValue
            recordsToSave.append(record)
        }

        let modifyOp = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        modifyOp.savePolicy = .changedKeys
        modifyOp.qualityOfService = .userInitiated

        modifyOp.modifyRecordsResultBlock = { [weak self] result in
            Task { @MainActor [weak self] in
                self?.isSyncing = false
                self?.lastSyncDate = Date()
                switch result {
                case .success:
                    self?.syncStatusMessage = "iCloud Synced (\(Date().formatted(date: .omitted, time: .shortened)))"
                case .failure(let err):
                    self?.syncStatusMessage = "Sync warning: \(err.localizedDescription)"
                }
            }
        }

        privateDB.add(modifyOp)
    }
}
