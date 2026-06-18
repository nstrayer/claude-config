# Positron Utilities Reference

Canonical list of utilities that new code should reuse. When an agent finds code that reimplements one of these, flag it.

## CSS

| Utility | Location | Use instead of |
|---------|----------|----------------|
| `positronClassNames(...)` | `src/vs/workbench/contrib/positron/browser/utilities/positronClassNames.ts` | Manual string concatenation for class names, template literals joining classes |

## Reactive / Observable

| Utility | Use when |
|---------|----------|
| `observableValue(owner, initialValue)` | Simple reactive state that notifies on change |
| `observableSignal(event)` | Converting a VS Code `Event` into an observable |
| `observableConfigValue(configService, key)` | Reactive config setting that updates when user changes it |
| `derived(reader => ...)` | Computing a value from other observables |
| `observableFromEvent(event, getValue)` | Creating an observable from an event + getter |

Every observable should have a `/** @description name */` annotation for reactive tracing.

## Lifecycle / Disposables

| Pattern | Use when |
|---------|----------|
| `this._register(disposable)` | Tying a disposable to a class instance lifetime |
| `const store = new DisposableStore()` | Managing a group of disposables together |
| `store.add(disposable)` | Adding to an existing store |

Never use `new DisposableStore()` without either `this._register(store)` or explicit cleanup -- it will leak.

## Logging

| Context | Correct pattern |
|---------|-----------------|
| TypeScript service | Inject `ILogService`, use `this._logService.info/warn/error/trace()` |
| TypeScript (no DI) | Use `@ILogService` decorator in constructor |
| Python module | `logger = logging.getLogger(__name__)` at module level |

Never use `console.log/warn/error` in production TypeScript. Never pass logger as a function argument in Python.

### Log Levels

| Level | Use for |
|-------|---------|
| `trace` | High-frequency diagnostic output, loop iterations |
| `info` | Significant operations (session start, feature activated) |
| `warn` | Recoverable issues (fallback used, deprecated path) |
| `error` | Failures that affect user (operation failed, exception caught) |

## Localization

```typescript
import * as nls from 'vs/nls';
const label = nls.localize('positron.featureName.label', "English text");
```

Every user-facing string -- button labels, error messages, placeholders, ARIA labels -- must use `nls.localize()`. The only exception is provisional text marked with a `// TODO` comment linking an issue.

## Upstream File Conventions

```typescript
// --- Start Positron ---
// your changes here
// --- End Positron ---
```

- Never reformat upstream code (whitespace, line breaks, import order)
- Only change lines that are semantically different from upstream
- If copying a type from upstream, import from `common/` or add a comment noting the source
