# Mattermost Theme

Telegram-style chat bubbles for Mattermost (`message.hostiran.com`). Colors follow the Mattermost theme you selected; in light themes your own messages are green.

## Install (Windows)

1. Download `install-mattermost-theme.bat` and run it.
2. Choose your browser, then restart it when asked.
3. In Chrome, open `chrome://extensions`, open Tampermonkey **Details** and enable **Allow User Scripts**.
4. Press a key in the installer window, then click **Install** on the Tampermonkey page.

Manual install: install [Tampermonkey](https://www.tampermonkey.net/), then open
[the script](https://raw.githubusercontent.com/ashahmohammadi/MatterMost-Theme/main/mattermost-telegram-theme.user.js) and click **Install**.

## Mattermost Desktop app (Windows)

Browser userscripts do not run in the desktop app, so use `mattermost-desktop-theme.bat` instead:

1. Download `mattermost-desktop-theme.bat` and double-click it, then press Enter.
2. It creates a **Mattermost (Theme)** shortcut on the Desktop and restarts Mattermost with the theme.
3. Start Mattermost from that shortcut from now on.

It starts the app with a local debug port (`127.0.0.1:9339`, this PC only) and injects the same theme from this repo each time. Nothing inside the Mattermost install folder is modified, so app updates do not break it. If something fails, see `%LOCALAPPDATA%\MattermostTheme\log.txt`.

## Updates

Browser: automatic. Tampermonkey checks `@updateURL` and installs a new version whenever `@version` in the script is raised.

Desktop app: the launcher downloads the latest script on every start and re-checks every 30 minutes; reload the window (Ctrl+R) to see a new version immediately.
