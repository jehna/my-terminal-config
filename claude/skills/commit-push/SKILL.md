---
name: commit-push
description: "Commit + Push"
---

When your work is good to go, let's work towards creating a pull request to Github.

1. Create a descriptive branch (if you're not on a feature branch already)
    * If you don't know, ask for the Linear ticket number
    * A good name is `$VERB/$WHAT_THIS_IS_ABOUT-$LINEARTICKET`
2. Create atomic commits
    * Each commit MUST contain a single logical increment / feature
    * Each commit MUST pass linters and tests (use e.g. `git stash --keep-index && <run linters and formatters> && git commit && git stash pop` to verify, no need to do everything as one-liner)
    * Commit title MUST start specifically with one of: `Add`, `Change`, `Remove` or `Fix` without `:`
    * Commit title MUST be max 50 characters. Use `echo "Add title that describes WHAT here" | wc -c` to ensure. Iterate until <= 50 chars.
    * Commit SHOULD include a descriptive commit body message that explains _WHY_
