English | [Русский](README.ru.md)

# Awesome Sleepscreen

A [KOReader](https://github.com/koreader/koreader) plugin that replaces the default **sleep-screen banner** with a configurable **3×3 grid** of blocks—iOS-style rounded widget **cards**, optional **wake lock (PIN)**, and varied content (clocks, templates, quotes from the book, sleep stats).

## Features

- **3×3 grid** — Each cell can hold a vertical stack of blocks; each block has its own card with configurable corner radius, inner padding, and gap between cards.
- **Block types**
  - **Template** — Free text with KOReader-style placeholders (like the sleep-message editor).
  - **Sleep stats** — Default sleep text or a custom template.
  - **Quote** — A random saved quote from the current book.
  - **Digital clock** — Time formatted with `strftime`.
  - **Analog clock** — Analog dial with hands (tested on e-ink).
- **Near full-screen layout** — The grid uses the full screen area (over cover/wallpaper); outer containers have no fill, so the screensaver background shows between cards.
- **Optional PIN after wake** — Dimmed overlay and PIN entry. *The PIN is stored on the device in plain settings—this is not strong cryptography!*
- **Localization** — English and Russian.

## KOReader settings (must all match)

The plugin grid appears only when **all** of the following are true:

1. **Sleep screen message** is enabled.
2. Message container mode is **Banner**, not full-screen message only.
3. **Screensaver type** is cover, **random image**, **document cover**, or **disabled** (so the standard banner region remains).

## Installation

1. Copy the plugin folder into KOReader’s `plugins` directory, for example:  
   `koreader/plugins/awesome-sleepscreen.koplugin/`
2. Restart KOReader and enable the plugin in the menu.
