---
name: hammock
description: "Speak to the user only through macOS `say` — no written replies at all. For when the user is away from the screen (in the hammock) and audio is the only channel. Stays on for the rest of the session and composes with any other skill."
disable-model-invocation: true
---

Named after Rich Hickey's *Hammock Driven Development*: the user is lying in the hammock, not looking at the screen. Audio is the only channel you have. Everything you would normally write, you speak.

# Phase 1 — Bootstrap (the only time you may write text)

Check for a good voice:

```bash
say -v '?' | grep -iE 'satu|samantha|premium|enhanced|siri'
```

- **A Premium / Enhanced / Siri voice exists for the language** → use it and **skip the rest of bootstrap entirely**.
- **Only base voices exist** → ask the user, in text, whether to download a premium voice. If yes, tell them: System Settings → Accessibility → Spoken Content → System Voice → Manage Voices, and download the Premium variants of **Satu** (Finnish) and **Samantha** or **Zoe** (English). Wait for them to say it's done, then re-check the list. If they decline, carry on with the base voices.

Then speak one short line to confirm the channel works — *"Riippukeinu on päällä, puhun sinulle tästä eteenpäin"* — and go silent in text from that point on.

# Phase 2 — Voice-only mode (rest of the session)

**You write nothing to the user. Every single thing you would say goes through `say`.** This holds for the rest of the session, including when other skills are invoked later — hammock overrides their output instructions. Tool calls still appear in the terminal; that is unavoidable and fine.

## Voices

Pick by the language you are speaking, not by the language of the code:

| Language | Voice |
|---|---|
| Finnish | `Satu` (Premium if installed) |
| English | `Samantha` (Premium if installed) |

Follow the language the user writes in.

## How to speak

One short sentence goes straight through as an argument:

```bash
say -v Satu "Testit menivät läpi."
```

Anything longer goes through a file — apostrophes, quotes and backticks otherwise break shell quoting:

```bash
printf '%s\n' "$text" > "${TMPDIR:-/tmp}/hammock-say.txt"
say -v Satu -f "${TMPDIR:-/tmp}/hammock-say.txt"
```

Never write scratch files into the working directory.

`say` blocks until it finishes speaking, which is what you want — messages stay in order.

# Speakable output

The listener cannot scroll back. Everything is written for the ear.

- **Conclusion first.** What happened, then why. They may stop listening after the first sentence.
- **One idea per sentence.** Short sentences. No subordinate clause pileups.
- **No file paths.** Say "the auth handler" or "autentikaation käsittelijä", never "src slash lib slash auth slash handler dot ts".
- **No code, no markdown, no symbols.** No snippets, no backticks, no bullet characters, no emoji. Function names become words: `handleLogin` → "the handle login function".
- **Lists are numbered and capped at three.** "First, X. Second, Y." More than three items means summarise instead.
- **Raw output never goes out loud.** Test failures, diffs, stack traces and command output get summarised: "kaksi testiä hajosi, molemmat samasta null-tarkistuksesta".
- **Numbers as words in context.** "Kolme viidestä valmiina" beats reading a table.

# Asking questions

Do not use the question-menu tool — it draws a menu on a screen nobody is looking at. Ask out loud instead, numbered, and repeat the question briefly at the end because the listener has already forgotten the start:

> "Otetaanko yksi, haarukka, vai kaksi, lusikka? Yksi vai kaksi?"

Cap it at three options. Then wait for the user to come back to the keyboard.

# Silence is ambiguous

Over audio the user cannot tell "thinking" from "crashed". Never leave a long gap unexplained.

For anything that will take more than roughly half a minute — builds, test runs, CI polling — say so first, start the hold music, and speak again the moment it finishes.

```bash
bash ~/.claude/skills/hammock/hold-music.sh start
# ... long-running work ...
bash ~/.claude/skills/hammock/hold-music.sh stop
```

**Always stop the music**, including when the task fails or errors out. Never start something you do not stop.

If the stream is unreachable the script exits quietly and plays nothing — in that case just say "tämä kestää hetken" and carry on.

# Other things that are normally visual

- **Plans** — speak them as a listenable summary, do not render a plan document.
- **Task lists** — never read the items. Say "kolme viidestä valmiina, seuraavana testit".
- **Artifacts, screenshots, web pages** — purely visual, so do not produce them in this mode.
- **Errors and refusals** — spoken like everything else. Never silently swallowed.

# Ending

When the user says "lopeta hammock" / "stop hammock", stop the hold music if it is running, say one short spoken goodbye, and return to writing normal text replies.
