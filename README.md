<div align="center">
  <img src="assets/logos/Pasted.svg" alt="Pasted Logo" width="128">
    <h1>Pasted</h1>
  <p><i>Pass Trigger; Emit Definition</i></p>
</div>
<p align="center">
  <a href="https://github.com/ekjaisal/Pasted/releases"><img height="20" alt="GitHub Release" src="https://img.shields.io/github/v/release/ekjaisal/Pasted?color=66023C&label=Release&labelColor=141414&style=flat-square&logo=github&logoColor=F5F3EF&logoWidth=11"></a>
  <a href="https://github.com/ekjaisal/Pasted/blob/main/LICENSE"><img height="20" alt="License: BSD-3-Clause" src="https://img.shields.io/badge/License-BSD_3--Clause-66023C?style=flat-square&labelColor=141414&logoColor=F5F3EF&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0iI0Y1RjNFRiI+PHBhdGggZD0iTTE0IDJINmMtMS4xIDAtMiAuOS0yIDJ2MTZjMCAxLjEuOSAyIDIgMmgxMmMxLjEgMCAyLS45IDItMlY4bC02LTZ6bTQgMThINlY0aDd2NWg1djExeiIvPjwvc3ZnPg=="></a>
  <a href="https://github.com/ekjaisal/Pasted/releases"><img height="20" alt="GitHub Downloads" src="https://img.shields.io/github/downloads/ekjaisal/Pasted/total?color=66023C&label=Downloads&labelColor=141414&style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0iI0Y1RjNFRiI+PHBhdGggZD0iTTEyIDIwbC03LTcgMS40MS0xLjQxTDExIDE2LjE3VjRoMnYxMi4xN2w0LjU5LTQuNThMMTkgMTNsLTcgN3oiLz48L3N2Zz4=&logoColor=F5F3EF"></a>
  <a href="https://github.com/ekjaisal/Pasted/stargazers"><img height="20" alt="GitHub Stars" src="https://img.shields.io/github/stars/ekjaisal/Pasted?color=66023C&style=flat-square&labelColor=141414&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0iI0Y1RjNFRiI+PHBhdGggZD0iTTEyIDJsMy4wOSA2LjI2TDIyIDkuMjdsLTUgNC44N2wxLjE4IDYuODhMMTIgMTcuNzdsLTYuMTggMy4yNUw3IDE0LjE0IDIgOS4yN2w2LjkxLTEuMDFMMTIgMnoiLz48L3N2Zz4=&logoColor=F5F3EF&label=Stars"></a>
</p>

Pasted is a swift, stubbornly lightweight, native text-substitution utility designed to work system-wide on Windows (see § [Limitations](#limitations)). It combines the convenience of text-substitution with a fully-featured graphical user interface for management, maintaining a minimal footprint on system resources while working offline to ensure privacy.

The application monitors keystrokes and substitutes trigger strings when matches are detected. It also includes a [Quick Search](#quick-search) dialog for searching triggers and inserting definitions with ease. Pasted thus helps save time by reducing look-ups for characters not readily available on the keyboard and by lessening repetitive typing of long text snippets.

## Features

The main interface has three sections: a Collections panel for organisation, a Triggers panel displaying details (including the last triggered timestamp), and a Definition Preview panel.

![Main Interface](assets/screenshots/main-interface.avif)

### Trigger Management

Triggers can be easily created and categorised into collections using the graphical user interface. It is highly recommended to prefix trigger sequences with a designated symbol (e.g. a semicolon `;`) to prevent accidental substitutions during regular typing.

![Edit Trigger](assets/screenshots/new-trigger.avif)

### Dynamic Content

Pasted supports dynamic date and time variables, allowing triggers to resolve to the current local time upon execution. The variables should be formatted by wrapping standard date/time tags in `${}` delimiters.

* `${yyyy-mm-dd}` → e.g. `2026-02-25`
* `${dd/mm/yyyy}` → e.g. `25/02/2026`
* `${hh:nn:ss AM/PM}` → e.g. `02:30:45 PM`
* `${dddd, dd mmmm yyyy}` → e.g. `Wednesday, 25 February 2026`

To output a literal tag without triggering dynamic resolution, prefix it with a backslash `(\${yyyy-mm-dd})`.

### Quick Search

It is not hard to forget triggers as collections grow bigger. Pasted, therefore, includes a global Quick Search dialog for swiftly finding forgotten triggers (by searching their name, trigger, or definition) and inserting them directly into the active text field. To call it from anywhere, press `Alt` + `;` (or `Ctrl` + `Alt` + `;`).

![Quick Search](assets/screenshots/quick-search.avif)

### Data Management

The application uses a local [SQLite3](https://sqlite.org) database for data storage. Users can back up the entire database or restore from a previous snapshot via the **Data** menu. Furthermore, triggers (full set or specific collections) can be imported and exported as JSON documents to facilitate seamless sharing across devices.

## Usage

1. Download the installer from the [Releases](https://github.com/ekjaisal/Pasted/releases/latest) page or from [https://pasted.jaisal.in](https://pasted.jaisal.in).

2. Install and launch the application.

   **Note:** Windows SmartScreen may flag the installer as an unrecognised application. Provided the installer is sourced from the locations specified in step 1, bypass the prompt by clicking **More info** → **Run anyway**. For added assurance, [verify](#verification) the `SHA256SUMS`.

3. Add or import triggers to get Pasted springing into action.

4. Toggle the start-up checkbox in the bottom-left corner to ‘Enabled on system start-up’ to ensure Pasted runs automatically when the system boots.

5. Close the application window. Pasted will minimise to the tray and work silently in the background.

6. Refer to the [user guide](UserGuide.txt) or navigate to **Help** → **User Guide** in the application menu for more details on usage.

## Verification

A PGP signed `SHA256SUMS` file is included with the release artifacts for verifying integrity.

**Fingerprint:** `C4A8 E4F9 1650 7DD9 49D4 5DF8 B4ED 8851 B020 2101`
**Key Server:** [keys.openpgp.org](https://keys.openpgp.org)

## Limitations

  * **Permissions:** If the target application is running with administrative privileges while Pasted is running as a standard user, the Windows User Account Control (UAC) may block the definitions from reaching the target.
  * **Third-Party Interference:** Aggressive clipboard managers, remote desktop protocols (RDP), or intensive security configurations may interfere with Pasted’s functionality.

## Building from Source

Pasted uses custom-compiled SQLite3, statically linked to the executable to make it fully standalone and self-contained. The steps to build the project from source are as follows:

### Build Prerequisites

* [Lazarus](https://www.lazarus-ide.org) IDE v4.4

* [Free Pascal Compiler](https://www.freepascal.org) v3.2.2 (included with Lazarus IDE v4.4)

* [WinLibs](https://winlibs.com) (or a similar [GCC](https://gcc.gnu.org)-based C compiler toolchain).

  **Note:** Add the binary directory (e.g. `C:\winlibs\mingw64\bin`) to the system’s PATH environment variable.

### Build Instructions

1. **Compile SQLite3**

   Open the terminal and navigate to the `vendor/sqlite3/` directory and execute the `build-sqlite3.bat` script to compile the SQLite3 amalgamation source to an optimised `sqlite3.o` object file.

   **Note:** This step uses GCC; therefore, it should be added to the PATH.

2. **Configure Library Paths in Lazarus**

   Open `Pasted.lpi` in the IDE. Navigate to **Project** → **Project Options** → **Compiler Options** → **Paths**. In the **Libraries (-Fl)** field, add the required C library paths. 

   Example for WinLibs:

     * `C:\winlibs\mingw64\lib\`
     * `C:\winlibs\mingw64\x86_64-w64-mingw32\lib\`
     * `C:\winlibs\mingw64\lib\gcc\x86_64-w64-mingw32\15.2.0\`

3. **Compile the Application**

   Build using **Run** → **Build** or `Shift` + `F9` in the Lazarus IDE.

## Acknowledgements

Pasted is built using the [Lazarus IDE](https://www.lazarus-ide.org) and the [Free Pascal Compiler](https://www.freepascal.org) and relies on third-party libraries and resources. Please see the [NOTICE](NOTICE) file for details. The project has benefited significantly from Google [Gemini 3.1 Pro](https://deepmind.google/models/model-cards/gemini-3-1-pro)’s assistance for ideation, code generation, and refactoring.

## License

The project is under the BSD 3-Clause License and is provided “as is”, without any warranties. Please see the [LICENSE](LICENSE) file for details.
