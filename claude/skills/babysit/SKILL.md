---
name: babysit
description: "Babysit a pull request after opening one"
---

# Ensure there's a PR

If there's not a pull request yet, create one.
* Use `.github/pull_request_template.md` if available
* Don't include attribution

After opening a pull request, start a `/loop` to poll for:
* Any comments to said pull request
* Failing CI

# In case of a comment

If there's a comment, you have a couple of options:

  1. If the change is straigtforward and undertandable:
      * Implement the fix
      * Use `git add <file> && git squash <hash> && git push --force-with-lease`
      * Reply to the comment and mark as resolved
  2. If the change needs human attention, ask the user for feedback
  3. Special case: In case it was Greptile making the comments, after addressing all comments by Greptile, trigger re-review from Greptile via commenting the word `@greptileai` to the PR as a new PR level comment

# In case of CI failure

  1. If the failed test seems flaky, retry the test run
  2. If there are any real errors caught by the CI:
      * Implement the fix
      * Use `git add <file> && git squash <hash> && git push --force-with-lease`

# All good?

If CI is green, no more comments, and there's at least one approval, prompt the user to press merge on the PR with the pull request URL
