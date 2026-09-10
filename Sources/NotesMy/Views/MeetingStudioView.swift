import SwiftUI
import AppKit
import AVFoundation

public struct MeetingStudioView: View {
    @ObservedObject var meetingService = MeetingRecordingService.shared
    @ObservedObject var loc = LocalizationService.shared

    // Form inputs
    @State private var meetingTitleInput: String = ""
    @State private var selectedMode: MeetingMode = .online
    @State private var attendees: [String] = []
    @State private var newAttendeeText: String = ""
    @State private var selectedLanguage: AppLanguage = .turkish

    // Post-Meeting results state
    @State private var showResults: Bool = false
    @State private var lastMetadata: MeetingMetadata?
    @State private var lastTranscript: [MeetingTranscriptEntry] = []
    @State private var lastUserNotes: String = ""
    @State private var selectedTemplate: MeetingTemplate = .executiveSummary
    @State private var generatedContent: String = ""
    @State private var isGeneratingAI: Bool = false
    @State private var previewMode: Int = 0 // 0: Preview, 1: Raw Markdown Editor
    @State private var toastMessage: String?
    @State private var savedNote: NoteItem?

    // Results view modes (0: AI Summary & Notes, 1: Speaker Transcript & Audio, 2: Split View)
    @State private var resultViewMode: Int = 0
    @State private var transcriptSearchQuery: String = ""
    @State private var selectedSpeakerFilter: String? = nil

    // Audio Playback Player (Meetily Plus)
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isAudioPlaying: Bool = false
    @State private var audioPlaybackTime: TimeInterval = 0
    @State private var audioTotalDuration: TimeInterval = 0
    @State private var audioPlaybackRate: Float = 1.0
    @State private var playbackTimer: Timer?
    @State private var activePlaybackEntryId: UUID?

    // Speaker Renaming & Turn Splitting State
    @State private var speakerToRename: MeetingSpeaker?
    @State private var renameSpeakerInput: String = ""
    @State private var showRenameSpeakerSheet: Bool = false

    @State private var splittingEntry: MeetingTranscriptEntry?
    @State private var splitCharPosition: Int = 0
    @State private var splitNewSpeaker: MeetingSpeaker = .roomSpeaker(2)
    @State private var showSplitSheet: Bool = false

    public init() {}

    private var isTR: Bool { loc.language == .turkish }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerBar

            Divider()

            // Main Content Area
            if showResults {
                resultsView
            } else if meetingService.isRecording {
                activeRecordingView
            } else {
                setupConfigurationView
            }
        }
        .frame(minWidth: 840, minHeight: 620)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(alignment: .bottom) {
            if let msg = toastMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(msg)
                        .font(.system(size: 13, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Material.regular)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showResults)
        .animation(.easeInOut(duration: 0.25), value: meetingService.isRecording)
        .onAppear {
            self.selectedLanguage = loc.language
            meetingService.checkExistingPermissions()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            meetingService.checkExistingPermissions()
        }
        .sheet(isPresented: $showRenameSpeakerSheet) {
            renameSpeakerSheet
        }
        .sheet(isPresented: $showSplitSheet) {
            splitUtteranceSheet
        }
    }

    // MARK: - 1. Header Bar
    private var headerBar: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(meetingService.isRecording ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: meetingService.isRecording ? "waveform.circle.fill" : "person.2.wave.2.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(meetingService.isRecording ? .red : .blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(isTR ? "NotesMy Toplantı Stüdyosu & EA Zekası" : "NotesMy Meeting Studio & AI")
                    .font(.system(size: 15, weight: .bold))
                Text(meetingService.isRecording
                     ? (isTR ? "Toplantı canlı kaydediliyor ve transkribe ediliyor..." : "Live meeting recording & transcribing...")
                     : (showResults
                        ? (isTR ? "Toplantı tamamlandı · EA ile analiz edildi" : "Meeting complete · Synthesized with AI")
                        : (isTR ? "Online (Zoom/Teams/Meet) ve yüz yüze toplantı asistanı" : "Online (Zoom/Teams/Meet) & in-person meeting assistant")))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if meetingService.isRecording {
                // Live Elapsed Timer
                HStack(spacing: 6) {
                    Circle()
                        .fill(meetingService.isPaused ? Color.orange : Color.red)
                        .frame(width: 8, height: 8)
                    Text(meetingService.formattedDuration)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(meetingService.isPaused ? .orange : .red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            Button {
                MeetingStudioWindowManager.shared.close()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help(isTR ? "Kapat" : "Close")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Material.bar)
    }

    // MARK: - 2. Setup Configuration View (Before Recording Starts)
    private var setupConfigurationView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Meeting Title
                VStack(alignment: .leading, spacing: 8) {
                    Text(isTR ? "Toplantı Başlığı" : "Meeting Title")
                        .font(.system(size: 13, weight: .bold))
                    TextField(isTR ? "Örn: Q4 Ürün Yol Haritası ve Sprint Planlama" : "e.g. Q4 Product Roadmap & Sprint Planning", text: $meetingTitleInput)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                }

                // Meeting Mode Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text(isTR ? "Kayıt Modu ve Ses Kaynağı" : "Capture Mode & Audio Source")
                        .font(.system(size: 13, weight: .bold))

                    HStack(spacing: 12) {
                        ForEach(MeetingMode.allCases) { mode in
                            Button {
                                self.selectedMode = mode
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: mode.icon)
                                            .font(.system(size: 15))
                                            .foregroundColor(selectedMode == mode ? .white : .blue)
                                        Spacer()
                                        if selectedMode == mode {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    }

                                    Text(mode.title(isTurkish: isTR))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(selectedMode == mode ? .white : .primary)
                                        .multilineTextAlignment(.leading)

                                    Text(mode.subtitle(isTurkish: isTR))
                                        .font(.system(size: 11))
                                        .foregroundColor(selectedMode == mode ? .white.opacity(0.85) : .secondary)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .background(selectedMode == mode ? Color.blue : Color(NSColor.controlBackgroundColor))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedMode == mode ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Microphone Permission Warning if needed
                if selectedMode != .systemOnly && !meetingService.hasMicPermission {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.slash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(isTR ? "Mikrofon İzni Gerekli" : "Microphone Permission Required")
                                .font(.system(size: 13, weight: .bold))
                            Text(isTR
                                 ? "Konuşmalarınızı kaydetmek ve transkript çıkarmak için Sistem Ayarları'ndan mikrofon izni vermeniz gerekir."
                                 : "Microphone access is required to record your voice and generate transcripts.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Button(isTR ? "Ayarları Aç" : "Open Settings") {
                                meetingService.openMicrophoneSettings()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)

                            Button(isTR ? "Denetle" : "Recheck") {
                                meetingService.checkExistingPermissions()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(8)
                }

                // Screen Capture System Audio Warning if Online Mode
                if (selectedMode == .online || selectedMode == .systemOnly) && !meetingService.hasSystemAudioPermission {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(isTR ? "Online Toplantı Ses Yakalama (Zoom & Teams)" : "Online Meeting Audio Capture (Zoom & Teams)")
                                .font(.system(size: 13, weight: .bold))
                            Text(isTR
                                 ? "Zoom/Teams karşı taraf sesini doğrudan sistemden yakalamak için Ekran Kaydı izni gerekir. Ayarlardan izin verdiyseniz geçerli olması için uygulamayı yeniden başlatın. İzin olmadan da mikrofonunuz üzerinden toplantı kaydedilebilir."
                                 : "Screen Recording is required to capture remote voices directly from Zoom/Teams. If already allowed in Settings, restart the app to apply. You can also record via microphone without it.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Button(isTR ? "Ayarları Aç" : "Open Settings") {
                                meetingService.openScreenCaptureSettings()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)

                            Button(isTR ? "Yeniden Başlat" : "Restart App") {
                                meetingService.restartApp()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)

                            Button(isTR ? "Denetle" : "Recheck") {
                                meetingService.checkExistingPermissions()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(8)
                }

                // Attendees & Language row
                HStack(alignment: .top, spacing: 24) {
                    // Attendees
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isTR ? "Katılımcılar" : "Attendees")
                            .font(.system(size: 13, weight: .bold))

                        HStack {
                            TextField(isTR ? "Katılımcı adı ekle (Örn: Mehmet)..." : "Add attendee name...", text: $newAttendeeText)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addAttendee()
                                }

                            Button(isTR ? "Ekle" : "Add") {
                                addAttendee()
                            }
                            .buttonStyle(.bordered)
                            .disabled(newAttendeeText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }

                        // Chips
                        if !attendees.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(attendees, id: \.self) { att in
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 10))
                                        Text(att)
                                            .font(.system(size: 12))
                                        Button {
                                            attendees.removeAll { $0 == att }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 9, weight: .bold))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Speech Language
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isTR ? "Konuşma Dili (Transkripsiyon)" : "Speech Recognition Language")
                            .font(.system(size: 13, weight: .bold))

                        Picker("", selection: $selectedLanguage) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text("\(lang.flag) \(lang.displayName)").tag(lang)
                            }
                        }
                        .labelsHidden()

                        Text(isTR ? "Apple on-device nöral konuşma tanıma modeli kullanılır." : "Uses Apple's on-device neural speech recognition.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 260)
                }

                Spacer(minLength: 20)

                // Start Button
                HStack {
                    Spacer()
                    Button {
                        startRecording()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "record.circle")
                                .font(.system(size: 17, weight: .bold))
                            Text(isTR ? "Toplantıyı Başlat & Dinle" : "Start Meeting & Listen")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: .red.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.top, 10)
            }
            .padding(24)
        }
    }

    // MARK: - 3. Active Recording View
    private var activeRecordingView: some View {
        VStack(spacing: 0) {
            // Live Status & Dual VU Meter Toolbar
            HStack(spacing: 20) {
                // Meeting Title & Mode
                VStack(alignment: .leading, spacing: 2) {
                    Text(meetingService.meetingTitle)
                        .font(.system(size: 15, weight: .bold))
                    Text(meetingService.selectedMode.title(isTurkish: isTR))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Divider().frame(height: 32)

                // Dual VU Meters
                HStack(spacing: 20) {
                    // Microphone VU Meter (You)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                            Text(isTR ? "Sen (Mikrofon)" : "You (Mic)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        HStack(spacing: 2) {
                            ForEach(0..<12) { idx in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Float(idx) / 12.0 < meetingService.micLevel ? Color.blue : Color.gray.opacity(0.25))
                                    .frame(width: 4, height: 12)
                            }
                        }
                    }

                    // System Audio VU Meter (Zoom / Teams)
                    if meetingService.selectedMode == .online || meetingService.selectedMode == .systemOnly {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.wave.2.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.purple)
                                Text(isTR ? "Toplantı (Ekran / Hoparlör)" : "Meeting (System)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            HStack(spacing: 2) {
                                ForEach(0..<12) { idx in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Float(idx) / 12.0 < meetingService.systemLevel ? Color.purple : Color.gray.opacity(0.25))
                                        .frame(width: 4, height: 12)
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Recording Controls
                HStack(spacing: 16) {
                    // Pause / Resume
                    Button {
                        if meetingService.isPaused {
                            meetingService.resumeMeeting()
                        } else {
                            meetingService.pauseMeeting()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: meetingService.isPaused ? "play.fill" : "pause.fill")
                            Text(meetingService.isPaused ? (isTR ? "Devam Et" : "Resume") : (isTR ? "Duraklat" : "Pause"))
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    // Finish & Synthesize with AI
                    Button {
                        finishRecording()
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "sparkles")
                            Text(isTR ? "Bitir & EA ile Analiz Et" : "Finish & AI Synthesize")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    // Cancel
                    Button {
                        meetingService.cancelMeeting()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color.secondary.opacity(0.08))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .help(isTR ? "İptal Et" : "Cancel")
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if let notice = meetingService.recordingNotice {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 13))
                    Text(notice)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: { meetingService.recordingNotice = nil }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 7)
                .background(Color.blue.opacity(0.08))

                Divider()
            }

            // Split View: Left: Live Transcript Timeline, Right: Live Scratchpad
            HSplitView {
                // Left: Live Transcript
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Label(isTR ? "Canlı Konuşma Transkripti" : "Live Speech Transcript", systemImage: "text.bubble.fill")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text("\(meetingService.transcriptEntries.count) \(isTR ? "cümle" : "utterances")")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

                    Divider()

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 10) {
                                if meetingService.transcriptEntries.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "waveform.and.magnifyingglass")
                                            .font(.system(size: 30))
                                            .foregroundColor(.secondary.opacity(0.5))
                                        Text(isTR ? "Konuşmalar dinleniyor... Biri konuştuğunda burada gerçek zamanlı görünecek." : "Listening... Transcriptions will appear here as participants speak.")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 200)
                                    .padding(.top, 40)
                                } else {
                                    ForEach(meetingService.transcriptEntries) { entry in
                                        transcriptBubble(entry: entry)
                                            .id(entry.id)
                                    }
                                }
                            }
                            .padding(14)
                        }
                        .onChange(of: meetingService.transcriptEntries.count) { _ in
                            if let last = meetingService.transcriptEntries.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .frame(minWidth: 420)

                // Right: User Live Notes Scratchpad
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Label(isTR ? "Toplantı Notlarım (Karalamalar)" : "In-Meeting Scratchpad", systemImage: "square.and.pencil")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text(isTR ? "💡 EA Özetine Eklenir" : "💡 Synced with AI Summary")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

                    Divider()

                    TextEditor(text: $meetingService.userNotes)
                        .font(.system(size: 13))
                        .padding(10)
                        .background(Color(NSColor.textBackgroundColor))
                }
                .frame(minWidth: 280)
            }
        }
    }

    // MARK: - 4. Post-Meeting Synthesis & Results View (Meetily Plus)
    private var resultsView: some View {
        VStack(spacing: 0) {
            // Results Top Bar: Title, Stats, Mode Selector & Actions
            resultsHeaderBar

            Divider()

            // Optional Audio Player Bar
            if lastMetadata?.audioFileURL != nil && (resultViewMode == 1 || resultViewMode == 2) {
                audioPlayerBar
                Divider()
            }

            // Main Content Area based on View Mode
            if resultViewMode == 0 {
                // Mode 0: AI Summary & Notes
                aiSummaryView
            } else if resultViewMode == 1 {
                // Mode 1: Speaker Transcript & Synced Audio Player
                interactiveTranscriptView
            } else {
                // Mode 2: Split View (Side by Side)
                HSplitView {
                    interactiveTranscriptView
                        .frame(minWidth: 380)

                    aiSummaryView
                        .frame(minWidth: 380)
                }
            }
        }
    }

    // MARK: - Results Header Bar
    private var resultsHeaderBar: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(lastMetadata?.title ?? (isTR ? "Toplantı Raporu" : "Meeting Report"))
                    .font(.system(size: 15, weight: .bold))
                HStack(spacing: 8) {
                    Label(lastMetadata?.formattedDuration ?? "00:00", systemImage: "clock")
                    Label("\(lastTranscript.count) \(isTR ? "konuşma" : "turns")", systemImage: "bubble.left.and.bubble.right")
                    if let att = lastMetadata?.attendees, !att.isEmpty {
                        Label("\(att.count) \(isTR ? "katılımcı" : "attendees")", systemImage: "person.2")
                    }
                }
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            }

            Spacer()

            // View Mode Picker
            Picker("", selection: $resultViewMode) {
                Label(isTR ? "EA Özeti" : "AI Summary", systemImage: "doc.plaintext.fill").tag(0)
                Label(isTR ? "Konuşmacılar & Ses" : "Speakers & Audio", systemImage: "person.wave.2.fill").tag(1)
                Label(isTR ? "Yan Yana" : "Split", systemImage: "rectangle.split.2x1.fill").tag(2)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 320)

            Spacer()

            // Primary Save & Export Buttons
            HStack(spacing: 10) {
                // Copy
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(generatedContent, forType: .string)
                    showToast(isTR ? "Panoya kopyalandı!" : "Copied to clipboard!")
                } label: {
                    Label(isTR ? "Kopyala" : "Copy", systemImage: "doc.on.doc")
                        .font(.system(size: 12.5, weight: .semibold))
                        .padding(.vertical, 2)
                }
                .buttonStyle(.bordered)

                // Export Menu
                Menu {
                    Button(isTR ? "PDF Olarak Kaydet..." : "Export as PDF...") {
                        exportDirect(asPDF: true)
                    }
                    Button(isTR ? "RTF Olarak Kaydet..." : "Export as RTF...") {
                        exportDirect(asPDF: false)
                    }
                    Button(isTR ? "Markdown (.md) Olarak Kaydet..." : "Export as Markdown (.md)...") {
                        exportAsMarkdown()
                    }
                    Divider()
                    Button(isTR ? "Altyazı (WebVTT - .vtt) Olarak Dışa Aktar..." : "Export Subtitles (WebVTT - .vtt)...") {
                        exportAsWebVTT()
                    }
                    Button(isTR ? "Altyazı (SubRip - .srt) Olarak Dışa Aktar..." : "Export Subtitles (SubRip - .srt)...") {
                        exportAsSRT()
                    }
                    if let audioURL = lastMetadata?.audioFileURL {
                        Divider()
                        Button(isTR ? "Ses Dosyasını Kaydet (.caf)..." : "Export Audio File (.caf)...") {
                            exportAudioFile(audioURL: audioURL)
                        }
                    }
                } label: {
                    Label(isTR ? "Dışa Aktar" : "Export", systemImage: "square.and.arrow.up")
                        .font(.system(size: 12.5, weight: .semibold))
                        .padding(.vertical, 2)
                }
                .menuStyle(.borderedButton)

                // Save as Note
                Button {
                    saveAsNote()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text(savedNote != nil ? (isTR ? "Notu Aç" : "Open Note") : (isTR ? "Not Olarak Kaydet" : "Save as Note"))
                    }
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(7)
                }
                .buttonStyle(.plain)

                // New Meeting
                Button {
                    resetToNewMeeting()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12))
                        .padding(.vertical, 2)
                }
                .buttonStyle(.bordered)
                .help(isTR ? "Yeni Toplantı Başlat" : "Start New Meeting")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - AI Summary View
    private var aiSummaryView: some View {
        VStack(spacing: 0) {
            // Template Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MeetingTemplate.allCases) { tpl in
                        Button {
                            self.selectedTemplate = tpl
                            regenerateTemplateContent()
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: tpl.icon)
                                    .font(.system(size: 13))
                                Text(tpl.title(isTurkish: isTR))
                                    .font(.system(size: 12.5, weight: selectedTemplate == tpl ? .bold : .medium))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedTemplate == tpl ? Color.blue.opacity(0.15) : Color.clear)
                            .foregroundColor(selectedTemplate == tpl ? .blue : .primary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTemplate == tpl ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
            }
            .background(Material.bar)

            Divider()

            // Preview vs Editor Toggle Subheader
            HStack {
                Picker("", selection: $previewMode) {
                    Text(isTR ? "Görsel Önizleme" : "Rich Preview").tag(0)
                    Text(isTR ? "Markdown Düzenle" : "Edit Markdown").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 220)

                Spacer()

                if selectedTemplate == .followUpEmail {
                    Button {
                        let emailOnly = MeetingAIService.shared.generateMeetingNote(
                            metadata: lastMetadata ?? MeetingMetadata(title: "", duration: 0, mode: .online),
                            transcriptEntries: lastTranscript,
                            userNotes: lastUserNotes,
                            template: .followUpEmail,
                            isTurkish: isTR
                        )
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(emailOnly, forType: .string)
                        showToast(isTR ? "Takip e-postası kopyalandı!" : "Follow-up email copied!")
                    } label: {
                        Label(isTR ? "E-posta Taslağını Kopyala" : "Copy Email Draft", systemImage: "envelope.badge")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.3))

            Divider()

            // Note Content
            if previewMode == 0 {
                MarkdownRendererView(markdown: generatedContent, localColor: .sky)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.textBackgroundColor))
            } else {
                TextEditor(text: $generatedContent)
                    .font(.system(size: 13, design: .monospaced))
                    .padding(14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.textBackgroundColor))
            }
        }
    }

    // MARK: - Synchronized Audio Player Bar (Meetily Plus)
    private var audioPlayerBar: some View {
        HStack(spacing: 12) {
            Button {
                toggleAudioPlayback()
            } label: {
                Image(systemName: isAudioPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .help(isAudioPlaying ? (isTR ? "Duraklat" : "Pause") : (isTR ? "Oynat" : "Play"))

            Text(formatTime(audioPlaybackTime))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            Slider(
                value: Binding(
                    get: { audioPlaybackTime },
                    set: { newTime in
                        seekAudio(to: newTime)
                    }
                ),
                in: 0...max(1.0, audioTotalDuration)
            )

            Text(formatTime(audioTotalDuration))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)

            // Playback Rate
            Menu {
                Button("1.0x") { setPlaybackRate(1.0) }
                Button("1.25x") { setPlaybackRate(1.25) }
                Button("1.5x") { setPlaybackRate(1.5) }
                Button("2.0x") { setPlaybackRate(2.0) }
            } label: {
                Text(String(format: "%.2gx", audioPlaybackRate))
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.12))
                    .cornerRadius(6)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.04))
    }

    // MARK: - Interactive Transcript View (Meetily Plus)
    private var interactiveTranscriptView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search Bar & Filter Chips & AI Disentangle
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        TextField(isTR ? "Dökümde ara..." : "Search transcript...", text: $transcriptSearchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                        if !transcriptSearchQuery.isEmpty {
                            Button {
                                transcriptSearchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )

                    Spacer()

                    // AI Disentangle Button
                    Button {
                        disentangleWithAI()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                            Text(isTR ? "EA ile Konuşmacıları Ayrıştır" : "Disentangle with AI")
                        }
                        .font(.system(size: 11.5, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.purple.opacity(0.12))
                        .foregroundColor(.purple)
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .help(isTR ? "Birbirine karışan cümleleri EA ile tespit edip konuşmacılarına göre ayırır." : "Uses AI to detect dialogue turns and separate mixed speech.")
                }

                // Speaker Filter Chips
                let uniqueSpeakers = Array(Set(lastTranscript.map { $0.speaker })).sorted { $0.shortLabel(isTurkish: isTR) < $1.shortLabel(isTurkish: isTR) }
                if uniqueSpeakers.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            Button {
                                selectedSpeakerFilter = nil
                            } label: {
                                Text(isTR ? "Tüm Konuşmacılar" : "All Speakers")
                                    .font(.system(size: 11, weight: selectedSpeakerFilter == nil ? .bold : .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(selectedSpeakerFilter == nil ? Color.blue : Color.secondary.opacity(0.12))
                                    .foregroundColor(selectedSpeakerFilter == nil ? .white : .primary)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)

                            ForEach(uniqueSpeakers, id: \.self) { spk in
                                let spkLabel = spk.shortLabel(isTurkish: isTR)
                                let isSelected = (selectedSpeakerFilter == spk.rawIdentifier)
                                let colors = speakerBadgeColors(colorIndex: spk.colorIndex)

                                Button {
                                    if isSelected {
                                        selectedSpeakerFilter = nil
                                    } else {
                                        selectedSpeakerFilter = spk.rawIdentifier
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(colors.fg)
                                            .frame(width: 6, height: 6)
                                        Text(spkLabel)
                                    }
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(isSelected ? colors.fg : colors.bg)
                                    .foregroundColor(isSelected ? .white : colors.fg)
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.6))

            Divider()

            // Transcript Entries
            let filteredEntries = lastTranscript.filter { entry in
                if let filter = selectedSpeakerFilter, entry.speaker.rawIdentifier != filter {
                    return false
                }
                if !transcriptSearchQuery.isEmpty {
                    return entry.text.localizedCaseInsensitiveContains(transcriptSearchQuery)
                }
                return true
            }

            if filteredEntries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(isTR ? "Eşleşen konuşma kaydı bulunamadı." : "No matching transcript entries found.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredEntries) { entry in
                                transcriptBubble(entry: entry, isInteractive: true)
                                    .id(entry.id)
                            }
                        }
                        .padding(14)
                    }
                    .onChange(of: activePlaybackEntryId) { newId in
                        if let id = newId {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                proxy.scrollTo(id, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }

    // MARK: - Bubble Component for Live Transcript & Interactive Review
    private func transcriptBubble(entry: MeetingTranscriptEntry, isInteractive: Bool = false) -> some View {
        let colors = speakerBadgeColors(colorIndex: entry.speaker.colorIndex)
        let isPlayingThis = (activePlaybackEntryId == entry.id)

        return HStack(alignment: .top, spacing: 10) {
            // Speaker Badge
            if isInteractive {
                Menu {
                    Button {
                        self.speakerToRename = entry.speaker
                        self.renameSpeakerInput = entry.speaker.displayName(isTurkish: isTR)
                        self.showRenameSpeakerSheet = true
                    } label: {
                        Label(isTR ? "Konuşmacıyı Yeniden Adlandır..." : "Rename Speaker...", systemImage: "pencil")
                    }

                    if let attendees = lastMetadata?.attendees, !attendees.isEmpty {
                        Menu(isTR ? "Katılımcı Olarak Ata" : "Assign to Attendee") {
                            ForEach(attendees, id: \.self) { att in
                                Button(att) {
                                    renameSpeakerInResults(from: entry.speaker, to: att)
                                }
                            }
                        }
                    }

                    Divider()

                    Button {
                        self.splittingEntry = entry
                        self.splitCharPosition = entry.text.count / 2
                        self.showSplitSheet = true
                    } label: {
                        Label(isTR ? "Bu Cümleyi Böl (Ayrıştır)..." : "Split Utterance...", systemImage: "arrow.triangle.branch")
                    }

                    Button {
                        seekAudio(to: entry.timestamp)
                    } label: {
                        Label(isTR ? "Bu Noktadan Dinle" : "Play from Here", systemImage: "play.fill")
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: entry.speaker.icon)
                            .font(.system(size: 11))
                        Text(entry.speaker.shortLabel(isTurkish: isTR))
                            .font(.system(size: 11, weight: .bold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .bold))
                            .opacity(0.6)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colors.bg)
                    .foregroundColor(colors.fg)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(colors.stroke, lineWidth: 1)
                    )
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            } else {
                HStack(spacing: 4) {
                    Image(systemName: entry.speaker.icon)
                        .font(.system(size: 11))
                    Text(entry.speaker.shortLabel(isTurkish: isTR))
                        .font(.system(size: 11, weight: .bold))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(colors.bg)
                .foregroundColor(colors.fg)
                .cornerRadius(6)
                .fixedSize()
            }

            // Bubble Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Button {
                        if isInteractive {
                            seekAudio(to: entry.timestamp)
                        }
                    } label: {
                        HStack(spacing: 3) {
                            if isPlayingThis && isAudioPlaying {
                                Image(systemName: "waveform")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            Text(entry.formattedTime)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(isPlayingThis ? .blue : .secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    if entry.duration > 0 {
                        Text("• \(String(format: "%.1fs", entry.duration))")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary.opacity(0.8))
                    }

                    Spacer()

                    if isInteractive {
                        Button {
                            seekAudio(to: entry.timestamp)
                        } label: {
                            Image(systemName: isPlayingThis && isAudioPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(entry.text)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isPlayingThis ? Color.blue.opacity(0.12) : colors.bg.opacity(0.5))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isPlayingThis ? Color.blue : colors.stroke.opacity(0.6), lineWidth: isPlayingThis ? 2 : 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if isInteractive {
                    seekAudio(to: entry.timestamp)
                }
            }
        }
    }

    // MARK: - Speaker Badge Colors Helper
    private func speakerBadgeColors(colorIndex: Int) -> (bg: Color, fg: Color, stroke: Color) {
        switch colorIndex {
        case 0:
            return (Color.blue.opacity(0.12), Color.blue, Color.blue.opacity(0.4))
        case 1:
            return (Color.purple.opacity(0.12), Color.purple, Color.purple.opacity(0.4))
        case 2:
            return (Color.green.opacity(0.14), Color.green, Color.green.opacity(0.4))
        case 3:
            return (Color.orange.opacity(0.14), Color.orange, Color.orange.opacity(0.4))
        case 4:
            return (Color.pink.opacity(0.14), Color.pink, Color.pink.opacity(0.4))
        case 5:
            return (Color.cyan.opacity(0.14), Color.cyan, Color.cyan.opacity(0.4))
        case 6:
            return (Color.indigo.opacity(0.14), Color.indigo, Color.indigo.opacity(0.4))
        default:
            return (Color.teal.opacity(0.14), Color.teal, Color.teal.opacity(0.4))
        }
    }

    // MARK: - Sheets: Rename Speaker & Split Turn
    private var renameSpeakerSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(isTR ? "Konuşmacıyı Yeniden Adlandır" : "Rename Speaker")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Button {
                    showRenameSpeakerSheet = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Text(isTR
                 ? "Bu konuşmacının toplantı dökümündeki ve tutanağındaki adını güncelleyin:"
                 : "Update the displayed name for this speaker across the entire meeting minutes:")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            TextField(isTR ? "Örn: Ahmet Bey, Ayşe Hanım, Müşteri Temsilcisi..." : "e.g. John Doe, Sarah, Client Representative...", text: $renameSpeakerInput)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))

            if let att = lastMetadata?.attendees, !att.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(isTR ? "Kayıtlı Katılımcılardan Seç:" : "Quick Select from Attendees:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(att, id: \.self) { a in
                            Button(a) {
                                renameSpeakerInput = a
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
            }

            HStack {
                Spacer()
                Button(isTR ? "İptal" : "Cancel") {
                    showRenameSpeakerSheet = false
                }
                .buttonStyle(.bordered)

                Button(isTR ? "Tüm Dökümde Güncelle" : "Update All Occurrences") {
                    if let target = speakerToRename {
                        renameSpeakerInResults(from: target, to: renameSpeakerInput)
                    }
                    showRenameSpeakerSheet = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(renameSpeakerInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 420)
    }

    private var splitUtteranceSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(isTR ? "Cümleyi İki Konuşmacıya Böl" : "Split Utterance Between Speakers")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Button {
                    showSplitSheet = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            if let entry = splittingEntry {
                Text(isTR
                     ? "Eğer iki kişi arka arkaya konuştuysa ve tek cümle olduysa buradan bölün:"
                     : "If two people spoke consecutively and were captured in one block, split them here:")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    Text(isTR ? "Mevcut Metin:" : "Original Utterance:")
                        .font(.system(size: 11, weight: .semibold))
                    Text(entry.text)
                        .font(.system(size: 12))
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.08))
                        .cornerRadius(8)
                }

                // Pick second speaker
                VStack(alignment: .leading, spacing: 6) {
                    Text(isTR ? "İkinci Konuşmacı Kim?" : "Who is the Second Speaker?")
                        .font(.system(size: 11, weight: .semibold))

                    Picker("", selection: $splitNewSpeaker) {
                        Text(isTR ? "Sen (Mikrofon)" : "You").tag(MeetingSpeaker.you)
                        Text(isTR ? "Katılımcılar (Ekran)" : "Remote").tag(MeetingSpeaker.remote)
                        ForEach(1...5, id: \.self) { idx in
                            Text(isTR ? "Konuşmacı \(idx)" : "Speaker \(idx)").tag(MeetingSpeaker.roomSpeaker(idx))
                        }
                        if let att = lastMetadata?.attendees {
                            ForEach(att, id: \.self) { name in
                                Text(name).tag(MeetingSpeaker.custom(name))
                            }
                        }
                    }
                    .labelsHidden()
                }

                HStack {
                    Spacer()
                    Button(isTR ? "İptal" : "Cancel") {
                        showSplitSheet = false
                    }
                    .buttonStyle(.bordered)

                    Button(isTR ? "Cümleyi Ortadan Böl" : "Split Utterance") {
                        let text = entry.text
                        let half = max(1, text.count / 2)
                        _ = SpeakerDiarizationService.shared.splitTranscriptEntry(
                            entryId: entry.id,
                            splitCharIndex: half,
                            newSpeaker: splitNewSpeaker,
                            transcript: &lastTranscript
                        )
                        regenerateTemplateContent()
                        showSplitSheet = false
                        showToast(isTR ? "Cümle iki konuşmacıya bölündü!" : "Utterance split!")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(20)
        .frame(width: 440)
    }

    // MARK: - Actions & Audio Playback Helpers
    private func setupAudioPlayerIfNeeded() {
        guard audioPlayer == nil, let url = lastMetadata?.audioFileURL else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.enableRate = true
            player.rate = audioPlaybackRate
            player.prepareToPlay()
            self.audioPlayer = player
            self.audioTotalDuration = player.duration
        } catch {
            print("Failed to initialize AVAudioPlayer: \(error)")
        }
    }

    private func toggleAudioPlayback() {
        setupAudioPlayerIfNeeded()
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isAudioPlaying = false
            playbackTimer?.invalidate()
            playbackTimer = nil
        } else {
            player.rate = audioPlaybackRate
            player.play()
            isAudioPlaying = true
            startPlaybackTimer()
        }
    }

    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            Task { @MainActor in
                guard let player = self.audioPlayer else { return }
                self.audioPlaybackTime = player.currentTime
                if !player.isPlaying {
                    self.isAudioPlaying = false
                    self.playbackTimer?.invalidate()
                    self.playbackTimer = nil
                }
                self.updateActivePlaybackEntry()
            }
        }
    }

    private func updateActivePlaybackEntry() {
        let t = audioPlaybackTime
        if let entry = lastTranscript.first(where: { t >= $0.timestamp && t < ($0.timestamp + max(1.5, $0.duration)) }) {
            self.activePlaybackEntryId = entry.id
        } else {
            self.activePlaybackEntryId = nil
        }
    }

    private func seekAudio(to timestamp: TimeInterval) {
        setupAudioPlayerIfNeeded()
        guard let player = audioPlayer else { return }
        player.currentTime = timestamp
        self.audioPlaybackTime = timestamp
        updateActivePlaybackEntry()
        if !player.isPlaying {
            player.rate = audioPlaybackRate
            player.play()
            isAudioPlaying = true
            startPlaybackTimer()
        }
    }

    private func setPlaybackRate(_ rate: Float) {
        audioPlaybackRate = rate
        audioPlayer?.rate = rate
    }

    private func cleanupAudioPlayer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        isAudioPlaying = false
        audioPlaybackTime = 0
        activePlaybackEntryId = nil
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let mins = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func renameSpeakerInResults(from target: MeetingSpeaker, to newName: String) {
        SpeakerDiarizationService.shared.renameSpeakerInTranscript(
            targetSpeaker: target,
            newName: newName,
            transcript: &lastTranscript
        )
        meetingService.renameSpeaker(target: target, newName: newName)
        regenerateTemplateContent()
        showToast(isTR ? "\(newName) olarak güncellendi!" : "Renamed to \(newName)!")
    }

    private func disentangleWithAI() {
        let disentangled = MeetingAIService.shared.disentangleSpeakersWithAI(
            transcript: lastTranscript,
            attendees: lastMetadata?.attendees ?? [],
            mode: lastMetadata?.mode ?? .online
        )
        self.lastTranscript = disentangled
        regenerateTemplateContent()
        showToast(isTR ? "Konuşmacılar EA ile başarıyla ayrıştırıldı!" : "Speakers disentangled with AI!")
    }

    private func addAttendee() {
        let clean = newAttendeeText.trimmingCharacters(in: .whitespaces)
        if !clean.isEmpty && !attendees.contains(clean) {
            attendees.append(clean)
            newAttendeeText = ""
        }
    }

    private func startRecording() {
        Task {
            let success = await meetingService.startMeeting(
                title: meetingTitleInput,
                mode: selectedMode,
                attendees: attendees,
                language: selectedLanguage
            )
            if !success {
                showToast(isTR ? "Kayıt başlatılamadı. Lütfen mikrofon iznini kontrol edin." : "Failed to start. Check microphone permission.")
            }
        }
    }

    private func finishRecording() {
        let (metadata, transcript, _, userNotes) = meetingService.stopMeeting()
        self.lastMetadata = metadata
        self.lastTranscript = transcript
        self.lastUserNotes = userNotes
        self.showResults = true
        self.savedNote = nil

        setupAudioPlayerIfNeeded()
        regenerateTemplateContent()
    }

    private func regenerateTemplateContent() {
        guard let meta = lastMetadata else { return }
        self.generatedContent = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: lastTranscript,
            userNotes: lastUserNotes,
            template: selectedTemplate,
            isTurkish: isTR
        )
    }

    private func saveAsNote() {
        if let existing = savedNote {
            NoteWindowManager.shared.openNote(id: existing.id)
            return
        }

        guard let meta = lastMetadata else { return }

        let title = meta.title.isEmpty ? (isTR ? "Toplantı Notu" : "Meeting Note") : meta.title
        var tags = ["meeting", meta.mode.rawValue]
        if isTR { tags.append("toplantı") }

        var note = NoteStore.shared.createNote(
            title: title,
            body: generatedContent,
            color: .sky,
            category: isTR ? "Toplantı" : "Work"
        )
        note.tags = tags

        if let audioURL = meta.audioFileURL {
            note.attachments.append(NoteAttachment(
                fileName: audioURL.lastPathComponent,
                relativePath: audioURL.lastPathComponent,
                mimeType: "audio/caf"
            ))
        }

        NoteStore.shared.updateNote(note)
        self.savedNote = note

        showToast(isTR ? "Not kaydedildi ve kütüphaneye eklendi!" : "Saved as note!")
        NoteWindowManager.shared.openNote(id: note.id)
    }

    private func exportDirect(asPDF: Bool) {
        guard let meta = lastMetadata else { return }
        let dummy = NoteItem(
            title: meta.title,
            body: generatedContent,
            color: .sky,
            category: "Meeting"
        )

        if asPDF {
            ExportService.shared.promptSaveNoteAsPDF(note: dummy)
        } else {
            ExportService.shared.promptSaveNoteAsRTF(note: dummy)
        }
    }

    private func exportAsMarkdown() {
        let title = lastMetadata?.title ?? "Meeting"
        promptSaveTextFile(filename: "\(title).md", content: generatedContent)
    }

    private func exportAsWebVTT() {
        let title = lastMetadata?.title ?? "Meeting_Transcript"
        let content = MeetingExportFormat.toWebVTT(entries: lastTranscript, isTurkish: isTR)
        promptSaveTextFile(filename: "\(title).vtt", content: content)
    }

    private func exportAsSRT() {
        let title = lastMetadata?.title ?? "Meeting_Transcript"
        let content = MeetingExportFormat.toSRT(entries: lastTranscript, isTurkish: isTR)
        promptSaveTextFile(filename: "\(title).srt", content: content)
    }

    private func exportAudioFile(audioURL: URL) {
        let title = lastMetadata?.title ?? "Meeting_Audio"
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "\(title).caf"
        if panel.runModal() == .OK, let target = panel.url {
            try? FileManager.default.copyItem(at: audioURL, to: target)
            showToast(isTR ? "Ses dosyası dışa aktarıldı!" : "Audio exported!")
        }
    }

    private func promptSaveTextFile(filename: String, content: String) {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = filename
        if panel.runModal() == .OK, let target = panel.url {
            try? content.write(to: target, atomically: true, encoding: .utf8)
            showToast(isTR ? "Dosya kaydedildi!" : "File saved!")
        }
    }

    private func resetToNewMeeting() {
        cleanupAudioPlayer()
        self.showResults = false
        self.lastMetadata = nil
        self.lastTranscript = []
        self.lastUserNotes = ""
        self.generatedContent = ""
        self.meetingTitleInput = ""
        self.attendees = []
        self.savedNote = nil
        self.transcriptSearchQuery = ""
        self.selectedSpeakerFilter = nil
    }

    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}

// MARK: - FlowLayout for Attendees Tag Chips
private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            height = max(height, currentY + rowHeight)
        }

        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
