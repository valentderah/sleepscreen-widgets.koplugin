English | [Русский](README.ru.md)

# Sleepscreen widgets

A [KOReader](https://github.com/koreader/koreader) plugin that replaces the default sleep screen with a configurable widget grid.

![Widget example](assets/screenshot-sleep-grid.png)

## Features

- **Widget types**
  - **Current book** — Title, author, and progress for the book you have open.
  - **Quote** — A random saved quote from the current book.
  - **Calendar** — Current date.
  - **Clock** — Both analog and digital.
  - **Template** — Free text with placeholders.
  - **Daily progress** — How much you read today.

## Configuring KOReader

1. Enable **Settings** → **Screen** → **Sleep screen** → **Sleep screen message** → **Add custom message to sleep screen**.
2. Open **Container and position** and choose **Banner**, not **Box**.

If any of this is missing, KOReader will show the normal sleep message instead of the grid.

## Configuring plugin

After the plugin is enabled in **Plugin management** you can find all settings for plugin in **Screen → Screensaver → Sleepscreen widgets**. You can rearrange the widgets in the grid, adjust the spacing between them and set the widgets refresh rate (default 10 minutes).

## Installation

1. Copy the plugin folder into KOReader’s `plugins` directory, for example:  
   `koreader/plugins/sleepscreenwidgets.koplugin/`
2. Restart KOReader and enable the plugin in the menu.
