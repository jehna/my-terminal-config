---
name: commit-push
description: "ALWAYS use when creating a new branch, commit or push"
---

When your work is good to go, let's work towards creating a pull request to Github.

1. Create a descriptive branch (if you're not on a feature branch already)
    * If you don't know, ask for the Linear ticket number
    * A good name is `$VERB/$WHAT_THIS_IS_ABOUT-$LINEARTICKET`
2. Create atomic commits
    * Each commit MUST contain a single logical increment / feature
    * Each commit MUST pass the fast local checks: linters, formatters, type checks and the individual tests that cover the change (use e.g. `git stash --keep-index && <run linters and formatters> && git commit && git stash pop` to verify, no need to do everything as one-liner)
    * Slow test suites (full e2e and the like) MUST NOT be run locally before committing. Push, let CI run them, and react to what CI reports
    * Commit title MUST start specifically with one of: `Add`, `Change`, `Remove` or `Fix` without `:`
    * Commit title MUST be max 50 characters. Use `echo "Add title that describes WHAT here" | wc -c` to ensure. Iterate until <= 50 chars.
    * Commit SHOULD include a descriptive commit body message that explains _WHY_
3. Rebase to keep the history perfect
    * The commit history of a feature branch MUST read as a story of how the feature would have been built in the perfect world
    * Rebase often to amend relevant changes to commits they belong to
