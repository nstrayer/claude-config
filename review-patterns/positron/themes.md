# Positron Review Themes

16 recurring themes derived from 354 real reviewer comments across 207 merged PRs (~39% of all review feedback). Only flag lines added or modified in the diff. Cite `file:line` for every finding. See `utilities.md` for the canonical utility lookup table and `reviewer-voice.md` for phrasing.

## Severity model

- **Error**: reviewer will block (missing error handling in prod services, missing upstream markers)
- **Warning**: reviewer will comment (console.log, missing localization, dead code)
- **Info**: reviewer may mention (observable @description, symmetric keybindings)

## Mechanical

**7. Missing localization.** User-facing strings not wrapped in `nls.localize()`: literals in `title:`, `description:`, `placeholder:`, `label:` props; strings passed to `showInformationMessage`/`showWarningMessage`/`showErrorMessage`; raw ARIA labels. Skip log messages, comments, test files, localize ID strings, internal constants. Also: display strings in `package.json` that belong in `package.nls.json`.

**9. Wrong logging.** `console.log/warn/error/info` in non-test TypeScript (use injected `ILogService`); Python `print()` for diagnostics (use `logging.getLogger(__name__)`). Skip `test/` and non-Positron extensions. Question suspect levels (high-frequency output belongs at trace).

**13. Copyright header.** New Positron files need `Copyright (C) <year> Posit Software, PBC` with the current year. Only check files with Positron markers or in positron contrib paths.

**16. Dead code and unlinked TODOs.** 3+ consecutive lines of commented-out code; `TODO` without an issue link (`#NNNN` or URL). Skip TODOs with issue references and JSDoc `@todo` with explanation.

## Reuse

**1. Use existing utilities.** Added code that reimplements an established helper (see `utilities.md`): manual className concatenation instead of `positronClassNames()`; `new Emitter()` + manual fire/dispose where `observableSignal()`/`observableValue()` fits; config read once instead of `observableConfigValue()`; manual computation from observables instead of `derived()`; `new DisposableStore()` without `this._register()`. Grep to confirm the utility exists and how nearby code uses it before flagging.

**8. Code duplication.** New CSS that duplicates existing positron contrib styles; new utility functions that reimplement `src/vs/base/` or positron browser utilities; prompt/agent files repeating content from another prompt file.

**11. Observable/reactive patterns.** Observables missing `/** @description name */`; emitter+listener chains where `observableSignal()` or `derived()` composition is cleaner. Code that reads a config value at init without subscribing to changes (`onDidChangeConfiguration` or `observableConfigValue`).

## Architecture

**2. Architecture and design.** Module-scope `const` state that belongs on a class; new Positron features in upstream files not guarded by a `positron.` feature flag; functions over 60 lines in added code. (Info -- judgment required.)

**3. Code organization.** New commands missing from `contributes.commands` in `package.json`; context keys defined far from the feature using them; `export` on symbols imported from only one file.

**10. Keybinding `when` clauses.** Keybindings without a `when` clause (at minimum negate `editorTextFocus` or scope to the right focus); raw `KeyCode.KeyA`-`KeyZ` without `KeyMod` (non-QWERTY unsafe); asymmetric bindings (if `Ctrl+Shift+Up` is registered, check for its mirror).

**12. Upstream compatibility.** Changes to upstream VS Code files (outside positron contrib paths, not added in this branch) must be wrapped in `// --- Start Positron ---` / `// --- End Positron ---` markers (Error). No wholesale reformatting of upstream code -- whitespace-only changes outside markers create merge conflicts. Types copied from upstream should be imported from their `common/` source instead.

## Quality

**4. Test coverage and quality.** `waitForTimeout` in tests (flaky -- use condition-based waiting); assertions that only check `toBeDefined()`/`not.toBeNull()`/`toHaveLength(>0)`; test files outside standard locations (`test/e2e/` for e2e, co-located `.test.ts` for unit); test names that repeat the function name without describing the scenario.

**5. AI-generated code smell.** Multi-line JSDoc on every private method (3+ consecutive); prompt files over 500 lines without section structure; `catch (e) {}` with empty body.

**6. Error handling and edge cases.** `await` in service methods without enclosing try/catch (especially `executeCommand`, network, file ops); loading/pending UI without a timeout escape; nested try/catch where the inner block cannot throw; mixed promise chains and async/await in one function.

**14. React hooks.** `useEffect` adding listeners/subscriptions without cleanup; dependency arrays referencing service instances (stale across renders); `useState` for values never rendered (use `useRef`); `useRef` for values that should re-render (use `useState`); async work in `useEffect` without cancellation.

**15. Accessibility.** `onClick` on non-button elements without `onKeyDown` + `tabIndex={0}` or `role="button"`; interactive elements without `aria-label`/`aria-labelledby`; ARIA attributes reflecting state (aria-checked, aria-expanded) bound to static values instead of the state variable; redundant roles inside wrappers that already provide them; selection UIs built from plain divs instead of radio/listbox semantics; ARIA label literals not localized.

## What NOT to flag

- Code not modified in this branch; untouched upstream code
- Test-only patterns where the "violation" is appropriate in test context
- Deliberate deviations with explanatory comments
