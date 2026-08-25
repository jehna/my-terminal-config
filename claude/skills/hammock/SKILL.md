---
name: hammock
description: "Speak to the user only through text-to-speech — no written replies at all. For when the user is away from the screen (in the hammock) and audio is the only channel. Stays on for the rest of the session and composes with any other skill."
disable-model-invocation: true
---

Named after Rich Hickey's *Hammock Driven Development*: the user is lying in the hammock, not looking at the screen. Audio is the only channel you have. Everything you would normally write, you speak.

# Phase 1 — Bootstrap (the only time you may write text)

Everything you say goes through one script, which synthesises to a local file first and only then plays:

```bash
bash ~/.claude/skills/hammock/speak.sh fi "Tämä puhutaan ääneen."
```

It speaks with **Google Cloud Text-to-Speech, Chirp 3: HD**, authenticated with the user's `gcloud` login — no API key is stored anywhere. It needs `gcloud` (logged in, with a quota project that has the `texttospeech.googleapis.com` API enabled), `jq`, and a network connection. Synthesis is billed per character, so keep messages short — which the rules below demand anyway.

If Google is unavailable the script falls back to `edge-tts` and then to macOS `say`, per segment, without being asked. If nothing plays at all, say so **in text** and use `say -v Satu` directly for the session — the same rules below still apply, only the command changes.

Auth problems surface as an error from `gcloud`. Fixing them needs an interactive login, which you cannot run yourself — tell the user in text to run `gcloud auth login`.

Then speak one short line to confirm the channel works — *"Hammock on päällä, puhun sinulle tästä eteenpäin"* — and go silent in text from that point on.

# Phase 2 — Voice-only mode (rest of the session)

**You write nothing to the user. Every single thing you would say goes through `speak.sh`.** This holds for the rest of the session, including when other skills are invoked later — hammock overrides their output instructions. Tool calls still appear in the terminal; that is unavoidable and fine.

## Voices

Pick by the language you are speaking, not by the language of the code:

Pick by the language you are speaking, not by the language of the code. The voice is just a language tag:

| Language | Tag | Voice used |
|---|---|---|
| Finnish | `fi` | `fi-FI-Chirp3-HD-Leda` |
| English | `en` | `en-US-Chirp3-HD-Leda` |

Follow the language the user writes in. Both languages use Leda on purpose: Chirp 3 keeps the same speaker identity across locales, so a bilingual message sounds like one person switching languages rather than two people taking turns. The language itself is the cue, not a change of voice. Override with `HAMMOCK_VOICE_FI` / `HAMMOCK_VOICE_EN`; Chirp 3 has 30 named voices per locale.

**Never translate content that is genuinely English.** A PR comment, a commit message, an error string, a quoted sentence — those get spoken in English, in the English voice, even mid-Finnish. Split the message into one segment per language instead of forcing one voice through both; the Finnish voice reading English is unlistenable.

Pass the segments to one `speak.sh` call as voice/text pairs — they are all synthesised before anything plays, so the hold music covers the whole wait and the segments run back to back with no gap:

```bash
bash ~/.claude/skills/hammock/speak.sh \
  fi "Tämmöisen kommentin meinasin kirjoittaa." \
  en "Why do we need projectId here?" \
  fi "Olisiko tuo hyvä?"
```

Single English words that have settled into spoken Finnish — commit, branch, deploy — stay in the Finnish voice. Switch voices for whole phrases and sentences, not for terminology.

**English proper nouns stay English.** People, products, repos, services, branches, companies — never translated, never Finnicised: *Pricing Service*, ei "hinnoittelupalvelu"; *hammock*, ei "riippukeinu". Inflect them if the sentence needs it ("Pricing Servicessä"), and if the Finnish voice mangles the name badly, lift just the name into the English voice.

## How to speak

One short sentence goes straight through as an argument:

```bash
bash ~/.claude/skills/hammock/speak.sh fi "Testit menivät läpi."
```

Anything longer goes through a file — apostrophes, quotes and backticks otherwise break shell quoting. Prefix the path with `@`:

```bash
printf '%s\n' "$text" > "${TMPDIR:-/tmp}/hammock-say.txt"
bash ~/.claude/skills/hammock/speak.sh fi "@${TMPDIR:-/tmp}/hammock-say.txt"
```

Never write scratch files into the working directory.

The command blocks until it finishes speaking, which is what you want — messages stay in order. The speaking rate is fast on purpose; `HAMMOCK_RATE_GOOGLE` (0.25–2.0, default 1.6) changes it if the user asks for slower or faster.

# Speakable output

The listener cannot scroll back. Everything is written for the ear.

- **Small increments.** One chunk at a time, one question per message — never a whole phase or analysis in one breath.
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

Over audio the user cannot tell "thinking" from "crashed".

ALWAYS before doing anything else, start the hold music. **Do not stop it yourself before speaking** — `speak.sh` stops it for you, at the right moment:

```bash
bash ~/.claude/skills/hammock/hold-music.sh start
# ... long-running work ...
bash ~/.claude/skills/hammock/speak.sh fi "Testit menivät läpi."
```

The order inside `speak.sh` is: synthesise every segment to a local file, *then* stop the music, *then* play. That way the music covers the synthesis round trip too, and there is no silent gap between finishing the work and the voice starting.

Stop the music by hand only when you are not going to speak next — a failed task, an abort, the end of the session:

```bash
bash ~/.claude/skills/hammock/hold-music.sh stop
```

**The music always stops**, one way or the other. Never start something you do not stop.

If the stream is unreachable the script exits quietly and plays nothing — in that case just say "tämä kestää hetken" for longer tasks and carry on.

# Other things that are normally visual

- **Plans** — speak them as a listenable summary, do not render a plan document.
- **Task lists** — never read the items. Say "kolme viidestä valmiina, seuraavana testit".
- **Artifacts, screenshots, web pages** — purely visual, so do not produce them in this mode.
- **Errors and refusals** — spoken like everything else. Never silently swallowed.

# Ending

When the user says "lopeta hammock" / "stop hammock", say one short spoken goodbye (which stops the hold music if it is still running), and return to writing normal text replies.
