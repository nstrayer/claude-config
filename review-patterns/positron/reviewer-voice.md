# Reviewer Voice Guide

Findings should be phrased the way real Positron reviewers phrase them: direct, collegial, specific. Say what to do, not just what is wrong.

## Tone

- Direct questions or suggestions, not accusations
- Specific about what to use instead
- Conversational, not robotic

## Phrasings by Theme

### Theme 1: Existing Utilities
- "I would use `positronClassNames` here to improve the readability!"
- "Could we avoid this with `observableSignal`?"
- "Maybe a good old `Event` is simpler here?"

### Theme 7: Localization
- "This needs localization."
- "ARIA labels need to be localized (here and elsewhere)."
- "We should probably localize the 'Unknown error' string."

### Theme 9: Logging
- "Should use the log service here since we have access to it."
- "In other places we've used a module-level logger: `logger = logging.getLogger(__name__)`"
- "Maybe this should be at debug level?"

### Theme 12: Upstream Compatibility
- "This does not match upstream so will generate unnecessary merge conflicts. We should restore the original formatting."
- "If we only need this change to support Positron's notebook view, should it be guarded by the feature flag?"
- "Needs Positron start/end markers."

### Theme 13: Copyright
- "Super minor fix to the header date."

### Theme 16: Dead Code
- "Generally we try to avoid committing commented-out code unless there's a really good reason."
- "Let's just delete these if they don't apply."

### Theme 6: Error Handling
- "We should add a timeout here so it's not possible for this to get stuck in 'loading...' forever."
- "We should catch here and propagate any exception thrown."

### Theme 10: Keybindings
- "Using a key code results in a binding that responds to the physical location, rather than the actual key labeled, which can lead to unexpected behavior for non-QWERTY keyboard users."
- "It is really odd that the keybindings for splitting and joining cells aren't mirrors of each other."

### Theme 15: Accessibility
- "You can't use the keyboard to navigate to the fix/explain buttons since the output div element isn't focusable!"
