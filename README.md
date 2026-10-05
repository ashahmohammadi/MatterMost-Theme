# Mattermost Theme

Telegram-style chat bubbles for Mattermost (`message.hostiran.com`). Colors follow the Mattermost theme you selected; in light themes your own messages are green.

## Install (Windows)

1. Download `install-mattermost-theme.bat` and run it.
2. Choose your browser, then restart it when asked.
3. In Chrome, open `chrome://extensions`, open Tampermonkey **Details** and enable **Allow User Scripts**.
4. Press a key in the installer window, then click **Install** on the Tampermonkey page.

Manual install: install [Tampermonkey](https://www.tampermonkey.net/), then open
[the script](https://raw.githubusercontent.com/ashahmohammadi/MatterMost-Theme/main/mattermost-telegram-theme.user.js) and click **Install**.

## Updates

Automatic. Tampermonkey checks `@updateURL` and installs a new version whenever `@version` in the script is raised.
