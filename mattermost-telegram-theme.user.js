// ==UserScript==
// @name         HostIran Mattermost Telegram Theme
// @namespace    http://tampermonkey.net/
// @version      10.2
// @author       A.Shahmohammadi
// @match        https://message.hostiran.com/*
// @updateURL    https://raw.githubusercontent.com/ashahmohammadi/MatterMost-Theme/main/mattermost-telegram-theme.user.js
// @downloadURL  https://raw.githubusercontent.com/ashahmohammadi/MatterMost-Theme/main/mattermost-telegram-theme.user.js
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function () {
    'use strict';

    // Colors come from the Mattermost theme the user selected
    // (--center-channel-*, --button-bg, --link-color), so light, dark and
    // custom themes all work without any mode detection.
    const telegramCSS = `
    @import url('https://cdn.jsdelivr.net/gh/rastikerdar/vazirmatn@v33.003/Vazirmatn-font-face.css');

    *, body, input, textarea, button, span, div, p {
        font-family: 'Vazirmatn', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
    }

    .post {
        display: flex !important;
        flex-direction: row !important;
        width: 100% !important;
        max-width: 100% !important;
        padding: 2px 20px !important;
        margin: 1px 0 !important;
        background: transparent !important;
        border: none !important;
        box-sizing: border-box !important;
    }

    .post:hover {
        background: transparent !important;
    }

    /* ---------- incoming (left) ---------- */
    .post[data-tg="other"] {
        justify-content: flex-start !important;
    }

    .post[data-tg="other"] .post__content {
        display: flex !important;
        flex-direction: row !important;
        align-items: flex-end !important;
        max-width: 68% !important;
        width: fit-content !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin: 0 auto 0 0 !important;
    }

    .post[data-tg="other"] .post__img {
        width: 32px !important;
        min-width: 32px !important;
        margin-right: 7px !important;
        margin-left: 0 !important;
        margin-bottom: 2px !important;
        padding: 0 !important;
    }

    .post[data-tg="other"] .post__img .Avatar,
    .post[data-tg="other"] .post__img img {
        width: 32px !important;
        height: 32px !important;
        border-radius: 50% !important;
    }

    .post[data-tg="other"] .post__content > div:not(.post__img) {
        border-radius: 14px 14px 14px 4px !important;
        padding: 6px 11px !important;
        width: fit-content !important;
        min-width: 100px !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        background-color: rgba(var(--center-channel-color-rgb), 0.08) !important;
        color: var(--center-channel-color) !important;
        border: 1px solid rgba(var(--center-channel-color-rgb), 0.08) !important;
    }

    .post[data-tg="other"] .post__header .user-popover {
        color: var(--link-color) !important;
        font-weight: 600 !important;
        font-size: 12px !important;
    }

    /* ---------- outgoing (right) ---------- */
    .post[data-tg="self"] {
        justify-content: flex-end !important;
    }

    .post[data-tg="self"] .post__content {
        display: flex !important;
        flex-direction: row-reverse !important;
        align-items: flex-end !important;
        max-width: 68% !important;
        width: fit-content !important;
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
        margin: 0 0 0 auto !important;
    }

    .post[data-tg="self"] .post__img {
        display: none !important;
    }

    .post[data-tg="self"] .post__content > div:not(.post__img) {
        border-radius: 14px 14px 4px 14px !important;
        padding: 6px 11px !important;
        width: fit-content !important;
        min-width: 95px !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        background-color: rgba(var(--button-bg-rgb), 0.30) !important;
        color: var(--center-channel-color) !important;
        border: 1px solid rgba(var(--button-bg-rgb), 0.45) !important;
    }

    /* light themes: green outgoing bubbles like Telegram */
    html[data-tg-mode="light"] .post[data-tg="self"] .post__content > div:not(.post__img) {
        background-color: #d9f7b9 !important;
        border: 1px solid #bfe39c !important;
        color: #10200c !important;
    }

    html[data-tg-mode="light"] .post[data-tg="self"] .post-message__text {
        color: #10200c !important;
    }

    html[data-tg-mode="light"] .post[data-tg="self"] .post__time,
    html[data-tg-mode="light"] .post[data-tg="self"] .time {
        color: #4f7d3a !important;
    }

    .post[data-tg="self"] .post__header .col__name {
        display: none !important;
    }

    /* ---------- text ---------- */
    .post-message__text {
        font-size: 13px !important;
        line-height: 1.55 !important;
        text-align: start !important;
        unicode-bidi: plaintext !important;
        padding: 1px 0 !important;
        margin: 0 !important;
        word-break: break-word !important;
        color: var(--center-channel-color) !important;
    }

    .post-message__text code, pre {
        direction: ltr !important;
        text-align: left !important;
        border-radius: 5px !important;
        font-size: 12px !important;
    }

    .post .post__header {
        display: flex !important;
        align-items: center !important;
        justify-content: space-between !important;
        margin-bottom: 2px !important;
        padding: 0 !important;
    }

    .post__time, .post .time {
        font-size: 10.5px !important;
        margin-left: 6px !important;
        text-decoration: none !important;
        color: rgba(var(--center-channel-color-rgb), 0.56) !important;
    }

    .post-message__text a:not(.mention-link) {
        color: var(--link-color) !important;
        text-decoration: underline !important;
        font-weight: 600 !important;
    }

    .post[data-tg="other"] .mention-link,
    .post[data-tg="self"] .mention-link {
        color: var(--link-color) !important;
        background: rgba(var(--button-bg-rgb), 0.18) !important;
        border: 1px solid rgba(var(--button-bg-rgb), 0.30) !important;
        padding: 1px 5px !important;
        border-radius: 5px !important;
        font-weight: 600 !important;
    }

    /* ---------- reactions / files ---------- */
    .post-reaction-list,
    .post-reaction,
    .Reaction {
        background: rgba(128, 128, 128, 0.12) !important;
        border-radius: 10px !important;
        border: 1px solid rgba(128, 128, 128, 0.2) !important;
        padding: 1px 6px !important;
        margin-top: 3px !important;
    }

    .file-attachment,
    .post-image__column,
    .attachment__content {
        border-radius: 10px !important;
        overflow: hidden !important;
        max-width: 100% !important;
        margin-top: 5px !important;
    }

    /* ---------- date separator ---------- */
    .date-separator {
        display: flex !important;
        justify-content: center !important;
        margin: 12px 0 !important;
    }

    .date-separator .separator__text,
    .date-separator___box {
        background: rgba(128, 128, 128, 0.18) !important;
        color: inherit !important;
        border-radius: 14px !important;
        padding: 3px 12px !important;
        font-size: 11px !important;
        font-weight: 500 !important;
        backdrop-filter: blur(5px) !important;
        border: 1px solid rgba(128, 128, 128, 0.2) !important;
    }

    .date-separator .separator__hr {
        display: none !important;
    }

    /* ---------- input ---------- */
    .post-create__container {
        padding: 6px 20px !important;
        background: transparent !important;
        border: none !important;
    }

    .post-create-body {
        border-radius: 18px !important;
        padding: 6px 14px !important;
        box-shadow: 0 1px 6px rgba(0, 0, 0, 0.08) !important;
    }

    #post_textbox {
        background: transparent !important;
        color: inherit !important;
        font-size: 13px !important;
        line-height: 1.55 !important;
        border: none !important;
    }

    .SidebarChannel.active,
    .SidebarLink.active {
        border-radius: 8px !important;
    }

    ::-webkit-scrollbar {
        width: 5px !important;
    }
    ::-webkit-scrollbar-thumb {
        background: rgba(128, 128, 128, 0.25) !important;
        border-radius: 4px !important;
    }
    `;

    const styleEl = document.createElement('style');
    styleEl.appendChild(document.createTextNode(telegramCSS));
    document.documentElement.appendChild(styleEl);

    // ---------- who am I (exact name match, never substring) ----------
    const myNames = new Set();
    const addName = (n) => { if (n && n.trim()) myNames.add(n.trim().toLowerCase()); };

    function loadMe() {
        fetch('/api/v4/users/me', { credentials: 'same-origin', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then((r) => (r.ok ? r.json() : null))
            .then((u) => {
                if (!u) return;
                addName(u.username);
                addName(u.nickname);
                addName(u.first_name);
                addName(u.last_name);
                addName(`${u.first_name} ${u.last_name}`);
                schedule();
            })
            .catch(() => { /* .current--user still classifies own posts */ });
    }

    // ---------- classify posts in DOM order ----------
    // Consecutive posts from one sender have no header, so they inherit the
    // side of the post before them. A data attribute is used instead of a
    // class because React rewrites `class` on every hover and would wipe it.
    function updateThemeMode() {
        const cs = getComputedStyle(document.body);
        const m = cs.getPropertyValue('--center-channel-bg-rgb').match(/\d+/g) ||
                  cs.backgroundColor.match(/\d+/g);
        if (!m || m.length < 3) return;
        const lum = (m[0] * 299 + m[1] * 587 + m[2] * 114) / 1000;
        const mode = lum < 140 ? 'dark' : 'light';
        const root = document.documentElement;
        if (root.dataset.tgMode !== mode) root.dataset.tgMode = mode;
    }

    function classifyAll() {
        updateThemeMode();
        let side = 'other';
        document.querySelectorAll('.post').forEach((post) => {
            const authorEl = post.querySelector('.post__header .user-popover, .post__header .col__name');
            const author = authorEl ? authorEl.textContent.trim().toLowerCase() : '';

            if (post.classList.contains('current--user')) side = 'self';
            else if (author) side = myNames.has(author) ? 'self' : 'other';

            if (post.dataset.tg !== side) post.dataset.tg = side;
        });
    }

    // One pass per frame at most, so new posts are styled before first paint.
    let pending = false;
    function schedule() {
        if (pending) return;
        pending = true;
        requestAnimationFrame(() => {
            pending = false;
            classifyAll();
        });
    }

    new MutationObserver(schedule).observe(document.body, { childList: true, subtree: true });
    loadMe();
    schedule();
})();
