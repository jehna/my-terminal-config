---
name: the-pihvi
description: "Design a brand-new feature properly before any code is written — identify the core ('the pihvi'), shape the architecture and a test strategy around it with the user one question at a time, and produce an approved design (optionally a plan.md)."
---

The premise: most features get coded shape-first and core-last — the hardest, most important thing ends up buried under glue. This skill flips that. Before any code exists, you find the one thing the feature really exists to do — **the pihvi** — and shape the entire architecture, the abstractions, the layering, and the tests to make *that* maximally elegant, readable, and testable. Everything else is supporting code that flows into place around it.

# Intake — understand what's being built

- **Check the current project state first** — relevant files, docs, recent commits. Enough to know where the feature attaches: which existing seams, conventions, and modules it will plug into.
- **Refine the intent one question at a time.** Focus on purpose, constraints, and success criteria. Prefer multiple-choice; one question per message; wait for the answer before the next. Don't batch.

Keep this phase short. Once you can state in a sentence what the feature does for the user and what its hard constraints are, move to the pihvi.

# Plan with the user — one small question at a time

Ask focused questions, **max ~300 characters each**, one at a time. Prefer multiple-choice when possible. Wait for the answer before the next. Don't batch. Use ASCII diagrams liberally — the user thinks visually here.

Cover at minimum (each of these is a real conversation with the user, not a checklist tick):

- **Identify the core ("the pihvi") — the single most important, usually hardest, thing this feature exists to do.** It is rarely the bulk of the code; in a "parse weird bank files and store them" feature the pihvi is the parsing logic, not the HTTP handlers or the DB writes. Find it at feature level: strip away the glue and ask "if everything else were trivial, what's the part that's genuinely hard to get right?" Once identified, the entire architecture, the chosen abstractions, the DSL, the layering — all of it gets shaped to make the pihvi maximally elegant, readable, and testable. Everything else is supporting code that flows into place around it. **Functional core / imperative shell** belongs here: it's the right tool to apply *at the pihvi*, not sprinkled across the whole feature. Design the pihvi to be pure — push side effects (I/O, network, clocks, randomness) out into the surrounding shell — so the hardest, most important thing is testable and easy to read; the surrounding code earns the right to be messier.

- **Colocation — "chairs and tables in the same room".** Things that change together belong physically close. Design the structure so a single conceptual change touches one place, not five. The failure mode to design *away from* up front: folder structures organized by technical role (`controllers/`, `models/`, `services/`) scatter a cohesive concept across the tree, so working on "cart" means opening three folders. Prefer domain folders (`cart/` containing controller, model, types, tests). Decide the feature's folder layout by *concept*, not by technical layer. Test: when you imagine changing one thing later, how many distant files would you have to touch? Minimize that number now, while it's free.

- **Abstraction levels.** A function should do work at one level of abstraction. Mixing levels — orchestration step right next to byte-fiddling inside the same function — forces the reader to constantly re-zoom and is the single biggest reason LLM-generated code feels unreadable. The classic tell is a long procedural function with comments like `// next we do X` separating chunks of wildly different levels — each such comment is begging to be a function call — but the deeper problem is bigger than comments. The fix: walk the code, identify level breaks (comments make them easy to spot, but you'll find more), and extract each chunk into a well-named function at the right level. Keep going until each function reads top-to-bottom at one level — orchestration, business logic, and I/O lives on their own levels. Result: many small, scannable, single-purpose functions. This pass also tends to produce good names for free, because a small function with one job is easy to name.

- **Domain modeling — can the language do the work?** Can richer types/classes/structs express the domain directly so invalid states become unrepresentable? Can a known abstraction (state machine, parser combinators, reducer, pipeline, etc.) carry the pihvi instead of procedural soup? Push toward a small DSL where it pays off — especially around the pihvi. Caveat: only borrow concepts that are easy to understand; importing exotic ones ("is this a monoid?") usually muddies the code.

- **Test strategy** — see below.

## Test strategy is a first-class topic

Spend real time here. The tests are designed alongside the architecture, not bolted on after.

**Invert the classic pyramid.** The only test that *really* matters is the end-to-end test, because it validates what the user actually experiences. Unit tests, taken alone, tell you almost nothing about whether the whole thing works together. So: basic use cases / happy paths get covered primarily by e2e tests, not unit tests. Unit tests cluster *near the pihvi* — closer to the pihvi means faster feedback loop and stricter coverage. Far from the pihvi, lean on e2e and don't bother unit-testing supporting glue.

**Test outcomes, not implementation.** A test should describe what the feature *does for the user*, not how it's wired internally. Implementation tests rot the moment you refactor. If a test would break because the code was reshaped without behavior changing, the test is wrong.

**Build a test DSL — apply the pihvi philosophy to the tests themselves.** Design a small testing DSL (scenario builder, page objects, fixtures, helpers — whatever fits) so every test case reads as just three things:

```
1. What the world looked like before
2. What happened
3. What the outcome was
```

That's the test case. Everything else — setup, teardown, factories, builders — is infrastructure whose only job is to make those three lines minimal, readable, and elegant. **The test case is the pihvi of the test.** Optimize the surrounding world so it shines. Anti-pattern: 100 lines of setup + random data + 20 scattered assertions. Goal: a named test, three lines, obviously correct.

**The DSL is unit #1 of the implementation order.** If the test plan calls for a scenario builder, page objects, or any test-side DSL, that infrastructure is itself a build unit and must appear in the implementation order *before* any production unit that ships tests using it. Every production unit writes its tests *through* the DSL; if a unit can't, the DSL is missing a primitive — add the primitive, don't write an ad hoc helper.

**Other things to nail down:**
- What test framework / runner is in play (or needs to be introduced)?
- Per implementation unit: what tests does it ship with? (No unit ships untested.)
- Test data / fixtures / mocking strategy.

# Present the design in sections

When you believe the design is good enough, **don't just dump it** — present it to the user in **200–300 word sections**, asking after each "does this look right so far?" Iterate per section. Be ready to go back and clarify when something doesn't fit. The four sections:

1. **Scope + intent + target architecture** (with diagrams)
2. **Module/file decomposition + seams** (colocation — domain folders, not technical layers)
3. **Per-unit implementation order** (test DSL is unit #1)
4. **Test strategy + test DSL** (inverted pyramid, outcome tests, the three-line shape, the DSL's own primitives)

Only after the user has signed off on every section is the design locked.

# After the design

Once locked, ask the user what they want to do next — don't assume:

- **Write the design to `plan.md`**?
- **Write `plan.md` and start implementing**?
- **Just implement now** without a separate doc (use task tracking)?

## Where the plan lives (if written)

```
<repo-root>/.claude/the-pihvi/<feature-slug>/plan.md
```

Add `.claude/the-pihvi/` to `.git/info/exclude` if not already excluded. `plan.md` mirrors the four approved sections.
