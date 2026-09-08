# 🇰🇷 NotesMy — macOS를 위한 AI 세컨드 브레인 & 화면 모서리 스티키 노트

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">화면 가장자리에서 부드럽게 펼쳐지는 스티키 노트 & 개인 지식 관리 도구</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
  <a href="README_fr.md">🇫🇷 Français</a> · 
  <a href="README_es.md">🇪🇸 Español</a> · 
  <a href="README_pt.md">🇧🇷 Português</a> · 
  <a href="README_it.md">🇮🇹 Italiano</a> · 
  <a href="README_ru.md">🇷🇺 Русский</a> · 
  <a href="README_ja.md">🇯🇵 日本語</a> · 
  <strong>[🇰🇷 한국어](README_ko.md)</strong> · 
  <a href="README_ar.md">🇸🇦 العربية</a> · 
  <a href="README_zh.md">🇨🇳 中文</a>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=for-the-badge&color=8B5CF6" alt="Release" /></a>
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20%EC%A7%80%EC%9B%90-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/%EC%95%84%ED%82%A4%ED%85%8D%EC%8primer-Universal%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Universal Binary" />
  <img src="https://img.shields.io/badge/%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4-100%25%20%EC%98%A8%EB%94%94%EB%B0%94%EC%9D%B4%EC%8A%A4-success?style=for-the-badge" alt="개인정보 보호" />
  <img src="https://img.shields.io/badge/%EB%9D%BC%EC%9D%B4%EC%84%A0%EC%8A%A4-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 시네마틱 라이브 데모

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy 라이브 데모" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>고화질 화면 녹화: 화면 모서리에서의 부드러운 슬라이딩, 빠른 메모 캡처, 무한 캔버스 보드 및 즉각적인 OCR 텍스트 추출. (<a href="../assets/demo.mp4">60fps MP4 다운로드</a>)</em>
</p>

---

## ⚡ NotesMy란 무엇인가요?

**NotesMy**는 화면 가장자리에서 바로 튀어나오는 스티키 노트(*Unclutter*, *SideNotes*)의 기동성과 지식 연결망을 형성하는 지식베이스(*Obsidian*, *Apple Notes*)의 강력함을 하나로 합친 네이티브 macOS 오픈소스 애플리케이션입니다.

**Swift 6, SwiftUI 및 AppKit**으로 100% 네이티브 개발되어 메뉴 막대에 가볍게 상주하며, 마우스를 화면 모서리에 가져가거나 단축키를 누르면 화면 안으로 부드럽게 미끄러져 들어옵니다.

### ✨ 핵심 하이라이트

- 🪟 **화면 모서리 덱 (Edge Deck):** 화면 가장자리에 커서를 올리면 부채꼴 모양 애니메이션으로 모든 활성 메모를 빠르게 탐색할 수 있습니다.
- 🔄 **앱 내 자동 업데이트 지원:** 설정에서 바로 GitHub Releases 최신 버전을 확인하고 변경 로그 보기, DMG 다운로드 진행률 및 1클릭 자동 업데이트를 지원합니다.
- ⌨️ **방향키 카테고리 탐색:** 키보드 좌우 방향키(`←` / `→`)와 클릭 버튼을 통해 카테고리와 필터를 부드럽게 가로 스크롤하며 전환할 수 있습니다.
- 🗑️ **빠른 삭제 및 장기 미사용 메모 정리:** 메모 카드에서 즉시 삭제할 수 있으며, 30일 이상 수정되지 않은 오래된 노트를 감지하여 일괄 보관하도록 제안합니다.
- ⚙️ **안전한 창 관리:** 설정 창의 빨간 닫기 버튼을 눌러도 앱 전체가 종료되지 않으며, 데이터 초기화 시 2단계 확인 창이 작동합니다.
- 🧠 **물리 엔진 기반 AI 지식 그래프:** 쿨롱-후크 물리 시뮬레이션, Jaccard 개념 유사도, 양방향 `[[WikiLinks]]` 및 노드 선택 시 화려하게 빛나는 실선 연결망을 제공합니다.
- 🔍 **화면 OCR & 비전 AI 텍스트 추출:** 화면의 원하는 영역을 십자선으로 드래그하여 이미지 속 글자를 클립보드나 메모로 즉시 추출합니다.
- 🎙️ **온디바이스 음성 기록:** Apple Silicon NPU 기반으로 12개 언어의 음성을 지연 시간과 프라이버시 침해 없이 즉각 텍스트로 변환합니다.
- 📌 **자유 배치 코르크보드 (Sticky Board):** 무한히 확장되는 보드 위에서 메모를 자유롭게 이동하고 확대/축소하며 배치할 수 있습니다.
- 🎨 **미니멀 파스텔 팔레트:** macOS에 맞춘 6가지 은은한 파스텔톤 컬러, 리치 마크다운, 체크리스트 및 코드 강조를 지원합니다.
- 🛡️ **노 텔레메트리 & 100% 오프라인:** 외부 서버 통신이 전혀 없으며 어떠한 추적도 하지 않습니다. 모든 AI 처리가 Mac 본체에서 안전하게 이뤄집니다.

---

## 🍺 Homebrew로 설치하기

macOS에서 간편하게 설치하고 항상 최신 상태를 유지하는 방법:

```bash
# 1. 커스텀 탭 저장소 등록
brew tap mehmetefeaytas/tap

# 2. NotesMy 설치
brew install --cask notesmy
```

### 업데이트
```bash
brew upgrade --cask notesmy
```

### 수동 설치 (DMG)
Universal DMG 파일을 직접 다운로드하려면 [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest) 페이지에서 최신 빌드를 받아보세요.

> **Gatekeeper 안내 (첫 실행 시):** 오픈소스로 독립 배포되는 앱 특성상 macOS에서 미확인 개발자 경고가 나타날 수 있습니다. `/Applications`의 `NotesMy.app`을 우클릭한 후 **열기**를 선택하거나 터미널에서 다음을 실행하세요:
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 실제 애플리케이션 미리보기

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🗂️ 모든 메모 & 시맨틱 검색</h3>
      <img src="../assets/preview-allnotes.png" alt="NotesMy 모든 메모 창" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🪟 화면 모서리 슬라이딩 덱</h3>
      <img src="../assets/preview-edge-deck.png" alt="NotesMy Edge Deck" width="100%" />
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3 align="center">📝 미니멀 메모 편집기</h3>
      <img src="../assets/preview-note.png" alt="메모 편집기" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🎨 파스텔 앱 아이콘</h3>
      <img src="../assets/app_icon_1024.png" alt="NotesMy 아이콘" width="60%" style="display: block; margin: 0 auto;" />
    </td>
  </tr>
</table>

---

## 💎 종합 기능 현황표

| 단계 | 기능명 | 지원 상태 | 핵심 기술 |
| :--- | :--- | :---: | :--- |
| **V1 — 기본 기능** | 파스텔 테마의 텍스트 & 체크리스트 메모 | ✅ | 네이티브 SwiftUI TextEditor |
| **V1 — 기본 기능** | 화면 모서리 고정 부채꼴 카드 덱 | ✅ | AppKit 플로팅 NSPanel |
| **V1 — 기본 기능** | 태그, 카테고리, 상단 고정 및 즐겨찾기 | ✅ | 로컬 JSON 저장소 |
| **V1 — 기본 기능** | 방향키(`←` / `→`) 카테고리 가로 탐색 | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — 기본 기능** | 카드 행에서 1클릭 빠른 메모 삭제 | ✅ | Swift Action Handler |
| **V1 — 기본 기능** | 클립보드 내역 자동 캡처 허브 | ✅ | NSPasteboard Monitor |
| **V1 — 기본 기능** | 대화형 컬러 피커 및 자유로운 크기 조절 | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — 확장 기능** | 12개 언어 음성 인식 (음성 텍스트 변환) | ✅ | Apple SFSpeechRecognizer |
| **V2 — 확장 기능** | 화면 영역 캡처 기반 비전 OCR 추출 | ✅ | Apple Vision + screencapture |
| **V2 — 확장 기능** | 자유 배치형 대화형 스티키 보드 (캔버스) | ✅ | 드래그 앤 드롭 지원 SwiftUI Canvas |
| **V2 — 확장 기능** | 30일 이상 미수정 휴면 메모 자동 정리 | ✅ | 타임스탬프 기반 인덱서 |
| **V2 — 확장 기능** | 자연어 기반 날짜 및 리마인더 자동 인식 | ✅ | NSDataDetector + UserNotifications |
| **V2 — 확장 기능** | 개념 벡터 임베딩 시맨틱 검색 | ✅ | Apple NaturalLanguage Embeddings |
| **V3 — 연결성** | 앱 내 업데이트 확인 & GitHub 릴리즈 연동 | ✅ | GitHub REST API + URLSession |
| **V3 — 연결성** | URL 웹 클리퍼 및 자동 본문 요약 | ✅ | WebKit + URLSession |
| **V3 — 연결성** | 1클릭 캘린더(.ics) 이벤트 내보내기 | ✅ | RFC 5545 캘린더 생성기 |
| **V3 — 연결성** | Apple 메모 및 미리 알림으로 내보내기 | ✅ | NSSharingService + EventKit |
| **V3 — 연결성** | 개인 CloudKit 데이터베이스 동기화 및 백업 | ✅ | Apple CloudKit 컨테이너 |
| **V3 — 연결성** | 메모 버전 기록 관리 및 타임머신 복원 | ✅ | 증분 스냅샷 보관 |
| **V4 — 세컨드 브레인** | 쿨롱-후크 물리 엔진 기반 AI 지식 그래프 | ✅ | 수학 물리 시뮬레이션 + Canvas |
| **V4 — 세컨드 브레인** | 노드 선택 시 선명하게 빛나는 실선 연결망 | ✅ | SwiftUI 벡터 그래픽 렌더링 |
| **V4 — 세컨드 브레인** | 양방향 `[[WikiLinks]]` 및 백링크 인덱싱 | ✅ | 정규식 링크 파서 |
| **V4 — 세컨드 브레인** | 전체 메모 데이터 기반 온디바이스 AI 챗 | ✅ | 로컬 RAG 아키텍처 |
| **V4 — 세컨드 브레인** | 일일 실행 계획 수립 및 할 일 자동 추출 | ✅ | 자연어 기반 태스크 추출 |
| **V4 — 세컨드 브레인** | 복잡한 생각 정리 및 텍스트 자동 서식화 | ✅ | Apple Intelligence NLP 엔진 |

---

## 🌍 지원 언어 안내 (총 12개 언어)

NotesMy는 macOS의 시스템 언어를 자동으로 감지하며 인터페이스 및 음성 인식을 완전하게 지원합니다:

| 국기 | 언어 | 국기 | 언어 | 국기 | 언어 |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (브라질) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ 글로벌 단축키 안내

모든 단축키는 **설정 → 단축키** 탭에서 사용자 맞춤형으로 변경할 수 있습니다:

| 기본 단축키 | 실행 동작 | 설명 |
| :--- | :--- | :--- |
| `⌥⌘N` | **새 메모** | 화면 위에 독립된 플로팅 스티키 노트를 생성합니다 |
| `⌥⌘V` | **빠른 캡처** | 클립보드에 복사된 내용을 즉시 새 메모로 만듭니다 |
| `⌥⌘L` | **모든 메모 & 검색** | 시맨틱 검색이 가능한 메인 관리 창을 엽니다 |
| `⌥⌘B` | **스티키 보드** | 무한 코르크보드 캔버스를 화면에 표시합니다 |
| `⌥⌘A` | **보관함** | 보관 처리된 메모 목록을 확인합니다 |
| `⌃⌥⌘H` | **덱 보이기/숨기기** | 화면 모서리 슬라이딩 덱을 토글합니다 |
| `Esc` | **메모 창 닫기** | 현재 활성화된 편집 창을 닫습니다 |

---

## 📈 스타 히스토리 (인기도 그래프)

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 기여자

새로운 아이디어 제안, 버그 리포트, 코드 기여는 언제나 환영합니다!

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="기여자" />
</a>

기여 가이드와 테스트 지침은 [CONTRIBUTING.md](../CONTRIBUTING.md) 문서를 참고해 주세요.

---

## 💖 후원 및 응원

NotesMy가 여러분의 Mac 작업 환경을 더 쾌적하게 만들어 드렸다면 후원이나 커피 한 잔을 선물해 주세요:

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-%ED%9B%84%EC%9B%90%ED%95%98%EA%B8%B0-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
  &nbsp;&nbsp;
  <a href="https://buymeacoffee.com/mehmetefeaytas"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-%EC%BB%A4%ED%94%BC%20%EC%84%A0%EB%AC%BC-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee" /></a>
</p>

---

## 📬 연락처 및 소통 창구

문의 사항, 협업 제안, 피드백은 언제든지 환영합니다:

- 📧 **이메일:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ 개인정보 보호 및 아키텍처

- **완전한 오프라인 작동:** NotesMy는 외부 서버와 통신하지 않습니다. 원격 분석이나 트래커가 없습니다.
- **투명한 로컬 파일 저장:** 모든 메모는 Mac의 `~/Library/Application Support/NotesMy/notes.json`에 안전하게 보관됩니다.
- **iCloud / CloudKit:** 동기화를 활성화하더라도 오직 사용자의 개인 iCloud 컨테이너를 통해서만 전송됩니다.

---

## 📄 라이선스

NotesMy는 **Apache License 2.0** 라이선스에 따라 자유롭게 사용할 수 있습니다. 세부 사항은 [LICENSE](../LICENSE) 파일을 참고하세요.

Developed with ❤️ by **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
