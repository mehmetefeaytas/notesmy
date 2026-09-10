import SwiftUI
import AppKit

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

                // Screen Capture System Audio Warning if Online Mode
                if (selectedMode == .online || selectedMode == .systemOnly) && !meetingService.hasSystemAudioPermission {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(isTR ? "Ekran / Sistem Sesi İzni Gerekiyor" : "Screen & System Audio Permission Required")
                                .font(.system(size: 13, weight: .bold))
                            Text(isTR
                                 ? "Zoom, Teams ve Google Meet'teki karşı tarafın sesini doğrudan yakalayabilmek için macOS Ekran Kaydı izni verin. İzin verilmezse toplantı yalnızca mikrofonunuz üzerinden kaydedilir."
                                 : "To capture voices from Zoom, Teams and Google Meet participants, please grant macOS Screen Recording permission. Otherwise, recording falls back to microphone.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(isTR ? "İzin Ver" : "Grant Access") {
                            _ = meetingService.requestScreenCapturePermission()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.1))
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
                HStack(spacing: 12) {
                    // Pause / Resume
                    Button {
                        if meetingService.isPaused {
                            meetingService.resumeMeeting()
                        } else {
                            meetingService.pauseMeeting()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: meetingService.isPaused ? "play.fill" : "pause.fill")
                            Text(meetingService.isPaused ? (isTR ? "Devam Et" : "Resume") : (isTR ? "Duraklat" : "Pause"))
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    // Finish & Synthesize with AI
                    Button {
                        finishRecording()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                            Text(isTR ? "Bitir & EA ile Analiz Et" : "Finish & AI Synthesize")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    // Cancel
                    Button {
                        meetingService.cancelMeeting()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(isTR ? "İptal Et" : "Cancel")
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

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

    // MARK: - 4. Post-Meeting Synthesis & Results View
    private var resultsView: some View {
        VStack(spacing: 0) {
            // Summary Header & Stats
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(lastMetadata?.title ?? (isTR ? "Toplantı Raporu" : "Meeting Report"))
                        .font(.system(size: 16, weight: .bold))
                    HStack(spacing: 8) {
                        Label(lastMetadata?.formattedDuration ?? "00:00", systemImage: "clock")
                        Label("\(lastTranscript.count) \(isTR ? "konuşma dökümü" : "transcript lines")", systemImage: "bubble.left.and.bubble.right")
                        if let att = lastMetadata?.attendees, !att.isEmpty {
                            Label("\(att.count) \(isTR ? "katılımcı" : "attendees")", systemImage: "person.2")
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                }

                Spacer()

                // Primary Save & Export Buttons
                HStack(spacing: 10) {
                    // Copy to clipboard
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(generatedContent, forType: .string)
                        showToast(isTR ? "Panoya kopyalandı!" : "Copied to clipboard!")
                    } label: {
                        Label(isTR ? "Kopyala" : "Copy", systemImage: "doc.on.doc")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.bordered)

                    // Export PDF / RTF
                    Menu {
                        Button(isTR ? "PDF Olarak Kaydet..." : "Export as PDF...") {
                            exportDirect(asPDF: true)
                        }
                        Button(isTR ? "RTF Olarak Kaydet..." : "Export as RTF...") {
                            exportDirect(asPDF: false)
                        }
                    } label: {
                        Label(isTR ? "Dışa Aktar" : "Export", systemImage: "square.and.arrow.up")
                            .font(.system(size: 12, weight: .semibold))
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
                        .font(.system(size: 12, weight: .bold))
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
                    }
                    .buttonStyle(.bordered)
                    .help(isTR ? "Yeni Toplantı Başlat" : "Start New Meeting")
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Template Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MeetingTemplate.allCases) { tpl in
                        Button {
                            self.selectedTemplate = tpl
                            regenerateTemplateContent()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: tpl.icon)
                                    .font(.system(size: 12))
                                Text(tpl.title(isTurkish: isTR))
                                    .font(.system(size: 12, weight: selectedTemplate == tpl ? .bold : .medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
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
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
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
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.3))

            Divider()

            // Note Content (Preview or Raw Edit)
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

    // MARK: - Bubble Component for Live Transcript
    private func transcriptBubble(entry: MeetingTranscriptEntry) -> some View {
        let isYou = (entry.speaker == .you)
        let bubbleColor = isYou ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1)
        let strokeColor = isYou ? Color.blue.opacity(0.3) : Color.purple.opacity(0.3)

        return HStack(alignment: .top, spacing: 8) {
            Image(systemName: entry.speaker.icon)
                .font(.system(size: 13))
                .foregroundColor(isYou ? .blue : .purple)
                .frame(width: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.speaker.shortLabel(isTurkish: isTR))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isYou ? .blue : .purple)
                    Text(entry.formattedTime)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text(entry.text)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(bubbleColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(strokeColor, lineWidth: 1)
            )

            Spacer()
        }
    }

    // MARK: - Actions & Helpers
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
                showToast(isTR ? "Kayıt başlatılamadı. Lütfen izinleri kontrol edin." : "Failed to start. Check permissions.")
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

    private func resetToNewMeeting() {
        self.showResults = false
        self.lastMetadata = nil
        self.lastTranscript = []
        self.lastUserNotes = ""
        self.generatedContent = ""
        self.meetingTitleInput = ""
        self.attendees = []
        self.savedNote = nil
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
