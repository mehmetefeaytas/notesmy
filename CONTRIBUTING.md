# Contributing to NotesMy

Thank you for your interest in contributing to **NotesMy**! We welcome community contributions, bug reports, and feature suggestions to make NotesMy the most refined, privacy-first, on-device notes experience on macOS.

---

## 🔒 Release & Deployment Policy (Strictly Maintainer-Only)

> [!IMPORTANT]
> **Releases, GitHub Releases, DMG distributions, and Homebrew Tap updates are strictly restricted to the project owner and maintainer ([@mehmetefeaytas](https://github.com/mehmetefeaytas)).**

- **No automated or external releases:** External contributors, pull requests, and forks cannot trigger release pipelines or publish versioned binaries.
- **Workflow Security:** The release workflow (`.github/workflows/release.yml`) is protected with repository-level and actor-level guards (`github.actor == 'mehmetefeaytas'`).
- **Tag & Tap Authorization:** Only the maintainer holds the Apple Developer credentials, code signing certificates, and Homebrew tap write tokens (`TAP_GITHUB_TOKEN`).
- **Release Schedule:** Contributions merged into `main` are bundled into official semantic releases (`vX.Y.Z`) exclusively by the maintainer following testing on Apple Silicon and Intel hardware.

---

## 📋 Development Workflow

To ensure code stability, cleanliness, and universal macOS binary compatibility, please follow these standardized steps:

### 1. Fork & Clone
```bash
# 1. Fork repository on GitHub
# 2. Clone your personal fork
git clone https://github.com/<your-username>/notesmy.git
cd notesmy

# 3. Add upstream remote
git remote add upstream https://github.com/mehmetefeaytas/notesmy.git
git fetch upstream
```

### 2. Branch Naming Conventions
All branches must follow standardized prefixes:
- `feature/<short-description>` — New features or UX enhancements (e.g. `feature/audio-waveform`)
- `fix/<short-description>` — Bug fixes, crash resolutions (e.g. `fix/archive-selection-crash`)
- `docs/<short-description>` — Documentation or localization updates (e.g. `docs/tr-readme-update`)
- `refactor/<short-description>` — Code cleanup without behavior changes (e.g. `refactor/window-manager`)
- `perf/<short-description>` — Performance optimizations (e.g. `perf/debounce-save`)

```bash
git checkout -b feature/audio-waveform
```

### 3. Commit Message Standards (Conventional Commits)
We strictly enforce [Conventional Commits](https://www.conventionalcommits.org/):

Format: `<type>(<scope>): <subject>`

Allowed types:
- `feat`: A new user-facing feature
- `fix`: A bug fix or crash resolution
- `docs`: Documentation or translations
- `style`: Formatting, whitespace (no code change)
- `refactor`: Restructuring code without changing behavior
- `perf`: Performance improvement
- `test`: Adding or fixing unit tests
- `chore`: Maintenance, dependencies, SPM updates

*Examples:*
- `feat(editor): add interactive color picker popover`
- `fix(audio): validate CoreAudio sample rate before installing tap`
- `docs(i18n): update Japanese localization strings`

---

## 🧪 Pre-Submission Checklist

Before opening a Pull Request, run the following commands locally to verify:

```bash
# 1. Swift compile check (debug build)
swift build

# 2. Universal release build test (ARM64 + x86_64)
swift build -c release --arch arm64 --arch x86_64

# 3. Run all unit tests
swift test
```

### Code Guidelines:
1. **Swift 6 & Concurrency:**
   - Adhere to Swift 6 concurrency rules.
   - Annotate UI services with `@MainActor`.
   - Never use force-unwraps (`!`) in UI views or data decoding paths.
2. **Zero Telemetry & 100% Privacy:**
   - Do NOT introduce external analytical trackers, remote logging, or unauthenticated network requests.
   - All AI features must use Apple Intelligence / NaturalLanguage / Vision on-device frameworks.
3. **Multilingual Architecture:**
   - Any new user-facing text must be added to `LocalizationKey` in `LocalizationService.swift` and translated across all 12 supported languages.
4. **macOS Human Interface Guidelines (HIG):**
   - Ensure clean contrast on all light and dark note themes (Amber, Coral, Mint, Sky, Lavender, Slate).
   - Toolbars and footers must be balanced and responsive to window resizing.

---

## 🚀 Submitting a Pull Request (PR)

1. **Rebase against `upstream/main`:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. **Push to your fork:**
   ```bash
   git push origin feature/audio-waveform
   ```
3. **Open Pull Request on GitHub:**
   - Fill in the PR description template clearly explaining:
     - **What was changed?**
     - **Why was it changed?**
     - **How was it tested?**
   - Attach screenshots or screen recordings (GIF/MP4) for any UI/UX changes.
   - Wait for CI checks (`🧪 CI — Build & Test`) to pass.
   - The maintainer will review, provide feedback, and merge via squash-and-merge.

---

## 💬 Questions & Community

- **Bug Reports:** Open an issue with reproduction steps and macOS version.
- **Feature Requests:** Open a discussion or feature request issue.
- **Security Inquiries:** Contact [@mehmetefeaytas](https://github.com/mehmetefeaytas) directly.
