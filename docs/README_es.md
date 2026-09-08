# 🇪🇸 NotesMy — Segundo Cerebro IA y Notas Adhesivas para macOS

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">Notas adhesivas ancladas al borde de pantalla & Gestión del conocimiento personal para macOS</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
  <a href="README_fr.md">🇫🇷 Français</a> · 
  <strong>[🇪🇸 Español](README_es.md)</strong> · 
  <a href="README_pt.md">🇧🇷 Português</a> · 
  <a href="README_it.md">🇮🇹 Italiano</a> · 
  <a href="README_ru.md">🇷🇺 Русский</a> · 
  <a href="README_ja.md">🇯🇵 日本語</a> · 
  <a href="README_ko.md">🇰🇷 한국어</a> · 
  <a href="README_ar.md">🇸🇦 العربية</a> · 
  <a href="README_zh.md">🇨🇳 中文</a>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=for-the-badge&color=8B5CF6" alt="Release" /></a>
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20Disponible-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/Arquitectura-Universal%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Binario Universal" />
  <img src="https://img.shields.io/badge/Privacidad-100%25%20En--Dispositivo-success?style=for-the-badge" alt="Privacidad" />
  <img src="https://img.shields.io/badge/Licencia-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 Demostración Cinematográfica

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy Demostración en vivo" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>Grabación de pantalla en alta definición: Despliegue suave desde el borde de la pantalla, captura veloz de notas, panel de corcho interactivo y extracción OCR instantánea. (<a href="../assets/demo.mp4">Descargar MP4 60fps</a>)</em>
</p>

---

## ⚡ ¿Qué es NotesMy?

**NotesMy** es una aplicación nativa para macOS diseñada para capturar notas adhesivas al instante y estructurar tu conocimiento personal. Une la inmediatez de los blocs rápidos (*SideNotes*, *Unclutter*) con el poder de las bases de conocimiento interconectadas (*Obsidian*, *Apple Notes*).

Desarrollada íntegramente en **Swift 6, SwiftUI y AppKit**, NotesMy descansa silenciosamente en tu barra de menús y se desliza con suavidad desde el borde de tu pantalla cada vez que lo necesites.

### ✨ Características Principales

- 🪟 **Bandeja de Borde (Edge Deck):** Acerca el cursor al lateral de la pantalla para desplegar tus notas en abanico interactivo.
- 🔄 **Actualizaciones Automáticas en la App:** Consulta directa de lanzamientos de GitHub desde Ajustes, visor de cambios, barra de progreso de descarga DMG y actualización en 1 clic.
- ⌨️ **Navegación con Teclas de Flecha:** Recorre tus etiquetas y categorías suavemente con las flechas (`←` / `→`) y botones de navegación rápida.
- 🗑️ **Borrado Rápido y Limpieza de Notas Inactivas:** Eliminación en un toque desde la propia tarjeta; detección automática y archivo de notas con más de 30 días sin modificar.
- ⚙️ **Cierre Seguro de Ventanas:** El botón rojo de Ajustes nunca cierra la aplicación; diálogo de confirmación en 2 fases antes de reiniciar datos.
- 🧠 **Grafo de Conocimiento IA con Física:** Simulación Coulomb-Hooke, similitud conceptual Jaccard, enlaces bidireccionales `[[WikiLinks]]` y trazos continuos de colores brillantes al seleccionar nodos.
- 🔍 **OCR de Pantalla e Inteligencia Visual:** Selecciona cualquier área de tu monitor para extraer texto al portapapeles o a tu nota al instante.
- 🎙️ **Notas de Voz en el Dispositivo:** Transcripción de audio en tiempo real para 12 idiomas sin latencia y con absoluta privacidad.
- 📌 **Tablero Libre (Sticky Board):** Organiza tus notas como tarjetas de colores en un lienzo infinito con zoom y desplazamiento libre.
- 🎨 **Paletas Pastel Minimalistas:** 6 tonos suaves calibrados para macOS, formato Markdown enriquecido, listas de tareas y resaltado de código.
- 🛡️ **Sin Telemetría y 100% Offline:** Sin cuentas en la nube ni rastreo. Todos los modelos de procesamiento corren en el hardware de tu Mac.

---

## 🍺 Instalación con Homebrew

La forma recomendada para instalar y actualizar NotesMy en macOS:

```bash
# 1. Agregar el repositorio
brew tap mehmetefeaytas/tap

# 2. Instalar NotesMy
brew install --cask notesmy
```

### Actualización
```bash
brew upgrade --cask notesmy
```

### Descarga Manual (DMG)
¿Prefieres un instalador DMG directo? Obtén el binario Universal más reciente en [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest).

> **Aviso de Gatekeeper (Primer inicio):** Al distribuirse en código abierto sin certificación comercial de pago, macOS puede solicitar confirmación al abrir. Haz clic derecho en `NotesMy.app` dentro de `/Applications` y selecciona **Abrir**, o ejecuta en la Terminal:
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 Capturas de la Aplicación

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🗂️ Todas las Notas y Búsqueda Semántica</h3>
      <img src="../assets/preview-allnotes.png" alt="Ventana principal de notas" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🪟 Bandeja Lateral de Borde</h3>
      <img src="../assets/preview-edge-deck.png" alt="NotesMy Edge Deck" width="100%" />
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3 align="center">📝 Editor de Notas Minimalista</h3>
      <img src="../assets/preview-note.png" alt="Editor de notas" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🎨 Icono Moderno en Pastel</h3>
      <img src="../assets/app_icon_1024.png" alt="Icono de NotesMy" width="60%" style="display: block; margin: 0 auto;" />
    </td>
  </tr>
</table>

---

## 💎 Matriz Completa de Capacidades

| Nivel | Capacidad | Estado | Tecnología |
| :--- | :--- | :---: | :--- |
| **V1 — Esencial** | Notas de texto y listas con temas pastel personalizados | ✅ | SwiftUI TextEditor nativo |
| **V1 — Esencial** | Bandeja de borde flotante y desplegable | ✅ | AppKit NSPanel flotante |
| **V1 — Esencial** | Etiquetas, categorías, chinchetas y favoritos | ✅ | Almacenamiento JSON local |
| **V1 — Esencial** | Navegación con teclado (`←` / `→`) entre categorías | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — Esencial** | Borrado rápido con un toque en la tarjeta | ✅ | Swift Action Handler |
| **V1 — Esencial** | Historial del portapapeles con autocaptura | ✅ | NSPasteboard Monitor |
| **V1 — Esencial** | Selector interactivo de color y ventanas ajustables | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — Avanzado** | Notas de voz multilingües (Voz a texto) | ✅ | Apple SFSpeechRecognizer |
| **V2 — Avanzado** | Extracción de texto OCR mediante recorte de pantalla | ✅ | Apple Vision + screencapture |
| **V2 — Avanzado** | Tablero interactivo de notas libres | ✅ | SwiftUI Canvas con arrastrar y soltar |
| **V2 — Avanzado** | Limpieza y archivo automático de notas (>30 días) | ✅ | Motor de inactividad de datos |
| **V2 — Avanzado** | Detección inteligente de fechas y recordatorios | ✅ | NSDataDetector + UserNotifications |
| **V2 — Avanzado** | Búsqueda semántica por conceptos vectoriales | ✅ | Apple NaturalLanguage Embeddings |
| **V3 — Conectado** | Actualizaciones integradas y comprobador de versiones | ✅ | GitHub REST API + URLSession |
| **V3 — Conectado** | Web Clipper para URLs con resumen automático | ✅ | WebKit + URLSession |
| **V3 — Conectado** | Exportación de calendario en un toque (.ics) | ✅ | Generador RFC 5545 |
| **V3 — Conectado** | Exportación a Apple Notas y Recordatorios | ✅ | NSSharingService + EventKit |
| **V3 — Conectado** | Sincronización privada con CloudKit y copia local | ✅ | Contenedor Apple CloudKit |
| **V3 — Conectado** | Historial de versiones y restauración en el tiempo | ✅ | Instantáneas incrementales |
| **V4 — Segundo Cerebro** | Grafo de conocimiento físico Coulomb-Hooke | ✅ | Simulación física + Canvas |
| **V4 — Segundo Cerebro** | Conexiones continuas de colores vivos en selección | ✅ | Trazos vectoriales SwiftUI |
| **V4 — Segundo Cerebro** | Enlaces bidireccionales `[[WikiLinks]]` con backlinks | ✅ | Analizador regex de enlaces |
| **V4 — Segundo Cerebro** | Chat con IA local sobre toda tu colección de notas | ✅ | Arquitectura RAG en el dispositivo |
| **V4 — Segundo Cerebro** | Plan del día inteligente y extracción de tareas | ✅ | Detección NLP de acciones |
| **V4 — Segundo Cerebro** | Organización de ideas y autoformato de texto | ✅ | Motor NLP Apple Intelligence |

---

## 🌍 Idiomas Disponibles (12 Idiomas)

NotesMy detecta automáticamente el idioma de tu sistema operativo e incluye traducción de interfaz y dictado para:

| Bandera | Idioma | Bandera | Idioma | Bandera | Idioma |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (Brasil) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ Atajos de Teclado Globales

Puedes personalizar cualquier atajo desde **Ajustes → Atajos**:

| Atajo por defecto | Acción | Detalle |
| :--- | :--- | :--- |
| `⌥⌘N` | **Nueva Nota** | Crea al instante una nota adhesiva flotante en pantalla |
| `⌥⌘V` | **Captura Rápida** | Transforma lo que tengas copiado en una nota nueva |
| `⌥⌘L` | **Todas las Notas** | Abre el panel central con motor de búsqueda semántica |
| `⌥⌘B` | **Tablero de Notas** | Abre la pizarra libre de corcho |
| `⌥⌘A` | **Archivo** | Muestra el listado de notas archivadas |
| `⌃⌥⌘H` | **Mostrar/Ocultar Bandeja** | Activa o desactiva la barra lateral del borde |
| `Esc` | **Cerrar Nota** | Cierra la ventana activa del bloc de notas |

---

## 📈 Historial de Estrellas

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 Colaboradores

¡Las contribuciones, propuestas de mejora y avisos de errores son bienvenidos!

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="Colaboradores" />
</a>

Revisa nuestra guía [CONTRIBUTING.md](../CONTRIBUTING.md) para conocer las pautas de estilo y pruebas.

---

## 💖 Patrocinio y Apoyo

Si NotesMy te ayuda en tu día a día en el Mac, considera apoyar el desarrollo:

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Apoyar-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
</p>

---

## 📬 Contacto y Comunidad

Para sugerencias, dudas y consultas profesionales:

- 📧 **Correo:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ Privacidad y Seguridad

- **Totalmente fuera de línea:** NotesMy no realiza peticiones a servidores externos. Cero analíticas, cero rastreo.
- **Almacenamiento Local Transparente:** Tus notas viven en tu Mac en `~/Library/Application Support/NotesMy/notes.json`.
- **Sincronización CloudKit:** La sincronización opcional opera exclusivamente a través de tu cuenta privada de iCloud.

---

## 📄 Licencia

NotesMy se distribuye bajo la licencia **Apache License 2.0**. Para más información, consulta el archivo [LICENSE](../LICENSE).

Creado con ❤️ por **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
