---
name: the-revikka
description: "Review a pull request (or a local branch) with the user — why, then approach, then code; once for the PR, then once per commit. The skill brings the reading and the structure, the user writes any comments. Uses `gh` for everything GitHub-side."
disable-model-invocation: true
---

**This skill does not review the pull request, and it does not comment on it. It helps a human do both.**

Your job is to bring the right information at the right time, to keep the review from dropping to line level before the why and the approach are understood, and to work out together with the user what is actually happening in this change. The judgement is theirs — and so are the comments. You never post one. When something looks wrong, you hand them the material and they write it in their own words.

The frame that drives everything: a PR exists because there was a **problem**. Every problem has several possible solutions. This branch is **one incarnation** of one of them.

That gives one loop, run twice — once over the whole PR, then once per commit.

Use `gh` for everything that touches GitHub.

# Ground rule — verify before you assert

Whenever a reading of yours leans on a fact — is this still used, is that actually faster, does that constraint still hold, does this function do what its name says — check it before you say it. Grep for the usages, open the other file, find the source. The whole value of this skill is that what you bring to the user is *true*; a confident wrong claim sends them off to write a comment that wastes the author's time and costs them credibility.

When you notice mid-review that you were wrong about something, say so plainly and move on.

# Phase 0 — What are we reviewing

If the user hasn't said, ask: a PR (number or URL), a branch, or the local working diff. `gh pr list` helps if they're looking for it.

Then check whether this review is already in progress — the user may have been here before and left comments of their own:

```bash
ME=$(gh api user --jq .login)
gh api repos/{owner}/{repo}/pulls/{N}/comments --jq ".[] | select(.user.login==\"$ME\") | {path, line, body}"
gh api repos/{owner}/{repo}/pulls/{N}/reviews  --jq ".[] | select(.user.login==\"$ME\") | {state, body}"
```

If their comments are already there, you're resuming. Say what has already been covered and where you're picking up. When resuming after the author pushed fixes, look only at what changed since their last comment — don't re-walk settled ground.

# The loop

Three steps, always in this order:

1. **Why** — why does this exist at all? What is missing or broken without it?
2. **The proposed solution** — how did the author decide to attack that why? Name it as **one option among several**, not as the only shape the change could have had.
3. **Code** — where the solution actually lives. Separate the **pihvi** — the one change that really delivers the why — from the supporting churn around it.

**Between every step there is a gate: do not move on until the user agrees with your reading.** Present what you think, attach your uncertainty, ask whether they read it the same way, and wait. This is the whole discipline of the skill — everything else is detail. If the user doesn't agree, that disagreement *is* the review, and it is worth more than anything you'd have found three steps later.

State uncertainty as uncertainty. "Uncertain whether the provisioned-but-never-installed case is in scope or deliberately out" is far more useful than a confident guess, because it tells the user exactly where to look.

# Round 1 — The PR

**No diff yet.**

**Why.** Dig for what this PR is actually trying to solve, in this order:

1. The PR description (`gh pr view N --json title,body,url,headRefName,commits`)
2. Linked tickets — if a Linear MCP tool is available, fetch the ticket. If not, say what's missing and ask the user to paste it or describe the problem.
3. Linked issues / referenced PRs
4. The code, last resort — sometimes the problem is only visible in what the change works around

Then present your reading:

> The problem looks like: sync silently stops reporting when a vessel's clock runs ahead. Uncertain whether the "provisioned but never installed" case is in scope or deliberately out.

If the description doesn't state the problem anywhere, that is itself worth raising — it usually deserves a comment of its own.

→ *gate*

**The proposed solution.** Work from the commit messages **as a narrative** — in a good PR they tell the story of how the author attacked the problem — and from the shape of the change: which files, modules and layers appear, what is new, what moved.

> The approach: extend `PricingSource` into a union and resolve at read time, rather than denormalising resale prices into the existing price table. That trades a lookup per read for not having a sync job.

This is the point to ask what other roads existed and why this one. And this is where a **structural disagreement** must surface — if the user thinks the whole approach is wrong, that belongs here, before anyone spends time on line-level notes.

→ *gate*

**Code.** At this level "code" is not the diff — that's Round 2. It's the *shape*: which layers were touched, what's genuinely new versus mechanically adjusted, and the one place where the approach is most visible — the type that got widened, the new module's entry point. Open that one place with the user. It's usually also the best anchor if they want to comment on the approach.

→ *gate*, then Round 2.

# Round 2 — Commit by commit

Walk the commits in order (`gh api repos/{owner}/{repo}/pulls/{N}/commits`, then `git show <sha>` locally — faster and more readable than the API).

**Always identify a commit by position, the first three characters of its hash, and its subject** — the position alone is useless to someone scrolling a GitHub commit list, and three characters are enough to find the right row:

> **Commit 5/12 · `a75…` · "Add resale price source"**

Then the same three steps, scoped to this one commit:

**Why.** What is missing or broken in the PR without this commit, and why did the author need a separate step here? A commit whose *why* you cannot state is either badly split, badly named, or doesn't belong in this PR — all three are worth raising.

> Why: resale prices live in another table, and the read path currently can't see them at all — nothing downstream can price a resale item until it can.
> Do you read the reason for this commit the same way?

→ *gate*

**The proposed solution.** How this commit chose to deliver that why, and what else it could have done instead. Often small enough to be one sentence — say it anyway, because it's what makes the next step readable.

→ *gate*

**Code.** Name the pihvi and separate it from the churn:

> Pihvi: `PricingSource` union widens → `resolvePrice()` picks the winner
> Supporting: 9 files of imports and type fixes
> Uncertain: is the `UnitPriceInput` change part of the pihvi or a consequence?
> Do you read the pihvi the same way?

If the pihvi doesn't answer the why — or answers more than it — that gap is worth raising.

→ *gate*, then open the pihvi and read it together, properly, line by line. **This is where the review time goes.** Afterwards skim the supporting changes; you're only looking for what isn't mechanical.

Then the next commit.

# When you disagree

A disagreement is worth stopping for in exactly two cases: **something should be done differently or you can't see why it is this way**, or **something is exceptionally good and deserves to be said out loud**. Anything merely done correctly gets nothing — silence is the default.

You don't write the comment and you don't post it. You hand the user the material:

- **the anchor** — file and line, the closest place that actually shows the thing
- **what you know** — the facts you verified, with what you checked
- **what's still open** — the part only the author can answer

If they want a comment, these are the things that make one land — offer them, don't lecture:

1. **Ask, don't accuse.** *"Why do we need `projectId` here?"*, not *"projectId is unnecessary"*. There is usually something you don't know, and the author knows their code better.
2. **Severity out loud.** *"A nitpick, but…"*, *"Could be either way 🤷"*, versus a genuine blocker. The reader should never have to guess how seriously to take it.
3. **A concrete alternative.** A ```suggestion``` block for a line or two, otherwise a small sketch. A complaint without an alternative is half a comment.
4. **Short** — one sentence, two at the most. The suggestion block doesn't count; the prose does.
5. **Praise is short and specific**: 👏, *"Clever!"*, 💎.

Inline beats top-level almost always: an inline comment is a thread the author can reply to and resolve. Even approach-level disagreement usually has a line that shows it.

# What to look for

In the code step of either round, these are worth actively hunting:

- `as` casts where a Zod parse or a branded type would do the work
- Types that should be **derived** from a schema or from generated DB types, to avoid drift
- Dead code — unused tables, migrations, imports, leftovers from an earlier iteration
- Naming that costs the reader a re-read (*"could we call this `useEffectOnce`?"*) — and often a better follow-up: could this construct go away entirely?
- Security, **calibrated**: client-provided data is never trusted (host headers, content types, IDs), but *"these are UUIDs, not a practical attack"* is an equally correct conclusion. Don't manufacture threats.
- Local/CI parity — running the tests locally should be as easy as in CI
- Test structure: page objects, scenario DSL, consistency with how the repo already tests

# Ending

When the user is done and nothing is left open, the only thing you do on their behalf is the approve, and only if they ask for it:

```bash
gh pr review N --approve --body '💎'
```

Just an emoji or two as the body — 💎, 👏🚢. Nothing to say means nothing to write. Anything more than that, including requesting changes, the user does themselves.

No summary. If they walked the loop with you, they already have it.

Tell them they can come back to this PR later — the skill will read their own comments off GitHub and look only at what changed since.

# Local review (no PR)

Same two rounds, on `git log main..HEAD`, `git show <sha>`, `git diff main...HEAD`. No `gh` calls, no files written, nothing posted anywhere.
