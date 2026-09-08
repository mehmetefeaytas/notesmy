# 🇧🇷 NotesMy — Segundo Cérebro com IA & Notas Autoadesivas para macOS

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">Notas fluidas fixadas na borda da tela & Gestão de conhecimento pessoal no macOS</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
  <a href="README_fr.md">🇫🇷 Français</a> · 
  <a href="README_es.md">🇪🇸 Español</a> · 
  <strong>[🇧🇷 Português](README_pt.md)</strong> · 
  <a href="README_it.md">🇮🇹 Italiano</a> · 
  <a href="README_ru.md">🇷🇺 Русский</a> · 
  <a href="README_ja.md">🇯🇵 日本語</a> · 
  <a href="README_ko.md">🇰🇷 한국어</a> · 
  <a href="README_ar.md">🇸🇦 العربية</a> · 
  <a href="README_zh.md">🇨🇳 中文</a>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=for-the-badge&color=8B5CF6" alt="Release" /></a>
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20Dispon%C3%ADvel-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/Arquitetura-Universal%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Universal Binary" />
  <img src="https://img.shields.io/badge/Privacidade-100%25%20No--Dispositivo-success?style=for-the-badge" alt="Privacidade" />
  <img src="https://img.shields.io/badge/Licen%C3%A7a-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 Demonstração Cinematográfica

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy Demonstração em vídeo" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>Gravação de tela em alta definição: Deslize fluido a partir da borda da tela, captura veloz de notas, quadro interativo e OCR imediato de imagens. (<a href="../assets/demo.mp4">Baixar MP4 em 60fps</a>)</em>
</p>

---

## ⚡ O que é o NotesMy?

**NotesMy** é um aplicativo nativo para macOS criado para unir a agilidade de blocos autoadesivos de tela (*Unclutter*, *SideNotes*) com o poder analítico de bases de conhecimento interligadas (*Obsidian*, *Apple Notes*).

Construído 100% em **Swift 6, SwiftUI e AppKit**, o NotesMy opera de maneira discreta na barra de menus e desliza suavemente para dentro da tela quando você aproxima o cursor da borda ou aciona um atalho.

### ✨ Principais Recursos

- 🪟 **Gaveta de Borda (Edge Deck):** Aproxime o ponteiro da borda para exibir seus cartões de notas ativas em um leque dinâmico.
- 🔄 **Atualizações Automáticas Integradas:** Verificação direta de versões do GitHub nos Ajustes, visualizador de notas de atualização, barra de progresso do DMG e atualização em 1 clique.
- ⌨️ **Navegação com Teclas de Seta:** Deslize rapidamente por categorias e filtros usando as setas do teclado (`←` / `→`) e botões de rolagem.
- 🗑️ **Exclusão Rápida e Limpeza de Notas Inativas:** Exclua com um clique diretamente no cartão; detecção e arquivamento de notas não editadas há mais de 30 dias.
- ⚙️ **Fechamento Seguro de Janelas:** O botão vermelho dos Ajustes nunca encerra a aplicação; confirmação dupla antes de reiniciar os dados.
- 🧠 **Grafo de Conhecimento com Física & IA:** Simulação Coulomb-Hooke, similaridade conceitual Jaccard, links bidirecionais `[[WikiLinks]]` e conexões contínuas em cores vibrantes ao selecionar nós.
- 🔍 **OCR de Tela e Visão Computacional:** Selecione qualquer área do monitor para extrair texto para a área de transferência ou direto para uma nota.
- 🎙️ **Transcrição de Voz no Dispositivo:** Reconhecimento de fala em tempo real para 12 idiomas com zero latência e total privacidade.
- 📌 **Quadro Livre (Sticky Board):** Organize notas como cartões coloridos em um mural de cortiça expansível, com zoom e movimentação livre.
- 🎨 **Paletas Pastel Minimalistas:** 6 tons suaves projetados para o design do macOS, formatação Markdown completa, listas de verificação e realce de código.
- 🛡️ **Zero Telemetria e 100% Offline:** Sem dependência de servidores em nuvem ou perfis de usuário. Todos os recursos operam localmente no seu Mac.

---

## 🍺 Instalação via Homebrew

A forma mais recomendada para instalar e atualizar no macOS:

```bash
# 1. Adicionar o repositório
brew tap mehmetefeaytas/tap

# 2. Instalar o NotesMy
brew install --cask notesmy
```

### Atualização
```bash
brew upgrade --cask notesmy
```

### Download Manual (DMG)
Prefere instalar via DMG? Obtenha o instalador Universal mais recente na página de [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest).

> **Aviso do Gatekeeper (Primeira Execução):** Como o NotesMy é distribuído como código aberto independente, o macOS pode exibir uma mensagem de desenvolvedor não verificado. Clique com o botão direito em `NotesMy.app` em `/Applications` e selecione **Abrir**, ou execute no Terminal:
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 Capturas da Aplicação

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🕸️ Grafo de Conhecimento IA & Vínculos Brilhantes</h3>
      <img src="../assets/preview-graph.png" alt="NotesMy Grafo de Conhecimento" width="100%" />
    </td>
  </tr>
</table>

---

## 💎 Tabela Completa de Recursos

| Camada | Recurso | Status | Tecnologia |
| :--- | :--- | :---: | :--- |
| **V1 — Básico** | Notas de texto e listas de tarefas em temas pastel | ✅ | SwiftUI TextEditor nativo |
| **V1 — Básico** | Gaveta lateral ancorada à borda da tela | ✅ | AppKit NSPanel flutuante |
| **V1 — Básico** | Tags, categorias, fixação e notas favoritas | ✅ | Armazenamento JSON local |
| **V1 — Básico** | Navegação por teclado (`←` / `→`) entre categorias | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — Básico** | Exclusão rápida diretamente no cartão | ✅ | Manipulador de ações Swift |
| **V1 — Básico** | Histórico da área de transferência com captura auto | ✅ | NSPasteboard Monitor |
| **V1 — Básico** | Seletor interativo de cores e janelas redimensionáveis | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — Turbinado** | Notas de voz em 12 idiomas (Fala para texto) | ✅ | Apple SFSpeechRecognizer |
| **V2 — Turbinado** | Reconhecimento de texto OCR por recorte de tela | ✅ | Apple Vision + screencapture |
| **V2 — Turbinado** | Mural livre de notas (Sticky Board) | ✅ | Canvas SwiftUI com arrastar e soltar |
| **V2 — Turbinado** | Arquivamento automático de notas inativas (>30 dias) | ✅ | Motor temporal de inatividade |
| **V2 — Turbinado** | Detecção de datas e lembretes por linguagem natural | ✅ | NSDataDetector + UserNotifications |
| **V2 — Turbinado** | Busca semântica vetorial por conceitos | ✅ | Embeddings Apple NaturalLanguage |
| **V3 — Conectado** | Atualizações automáticas e verificação de versões | ✅ | GitHub REST API + URLSession |
| **V3 — Conectado** | Web Clipper para captura e resumo de links | ✅ | WebKit + URLSession |
| **V3 — Conectado** | Exportação de eventos de calendário (.ics) em 1 clique | ✅ | Gerador RFC 5545 |
| **V3 — Conectado** | Exportação para Apple Notes e Lembretes | ✅ | NSSharingService + EventKit |
| **V3 — Conectado** | Sincronização segura CloudKit e backup local | ✅ | Contêiner Apple CloudKit |
| **V3 — Conectado** | Histórico de versões e restauração temporal | ✅ | Snapshots incrementais |
| **V4 — Segundo Cérebro** | Grafo de conhecimento com física Coulomb-Hooke | ✅ | Simulação matemática + Canvas |
| **V4 — Segundo Cérebro** | Linhas contínuas e brilhantes na seleção de nós | ✅ | Traçados vetoriais SwiftUI |
| **V4 — Segundo Cérebro** | Links bidirecionais `[[WikiLinks]]` com backlinks | ✅ | Analisador Regex de links |
| **V4 — Segundo Cérebro** | Chat com IA sobre o banco de dados de notas | ✅ | Arquitetura RAG no próprio Mac |
| **V4 — Segundo Cérebro** | Extração inteligente de planos diários e tarefas | ✅ | Extração NLP de tarefas |
| **V4 — Segundo Cérebro** | Organização e formatação de pensamentos soltos | ✅ | Motor Apple Intelligence NLP |

---

## 🌍 Idiomas Suportados (12 Idiomas)

O NotesMy detecta automaticamente o idioma do macOS e oferece suporte total de interface e reconhecimento de voz para:

| Bandeira | Idioma | Bandeira | Idioma | Bandeira | Idioma |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (Brasil) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ Atalhos Globais de Teclado

Configure qualquer combinação em **Ajustes → Atalhos**:

| Atalho Padrão | Ação | Descrição |
| :--- | :--- | :--- |
| `⌥⌘N` | **Nova Nota** | Cria instantaneamente uma nota flutuante na tela |
| `⌥⌘V` | **Captura Rápida** | Converte o texto da área de transferência em nota |
| `⌥⌘L` | **Todas as Notas** | Abre a janela principal com busca semântica |
| `⌥⌘B` | **Quadro de Notas** | Abre o mural livre de cortiça |
| `⌥⌘A` | **Arquivo** | Exibe as notas arquivadas |
| `⌃⌥⌘H` | **Alternar Gaveta** | Exibe ou oculta a gaveta lateral |
| `Esc` | **Fechar Nota** | Fecha a janela de edição ativa |

---

## 📈 Histórico de Estrelas

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 Colaboradores

Contribuições, sugestões de novos recursos e correções de erros são muito bem-vindas!

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="Colaboradores" />
</a>

Consulte o arquivo [CONTRIBUTING.md](../CONTRIBUTING.md) para diretrizes de desenvolvimento e testes.

---

## 💖 Patrocínio e Apoio

Se o NotesMy agrega valor ao seu fluxo de trabalho diário no Mac, apoie o desenvolvimento:

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Apoiar-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
</p>

---

## 📬 Contato e Comunicação

Fique à vontade para entrar em contato:

- 📧 **E-mail:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ Privacidade e Arquitetura

- **Sem conexões de rede:** O NotesMy opera 100% offline. Sem envio de dados analíticos ou telemetria.
- **Arquivos Locais:** Todas as suas notas são salvas em `~/Library/Application Support/NotesMy/notes.json`.
- **Sincronização CloudKit:** Quando ativada, conecta-se apenas ao contêiner privado do seu próprio iCloud.

---

## 📄 Licença

O NotesMy é licenciado sob a **Apache License 2.0**. Consulte o arquivo [LICENSE](../LICENSE) para mais informações.

Desenvolvido com ❤️ por **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
