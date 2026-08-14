# Local Rules

- Be terse. Prefer short answers over walls of text.

- Prefer the dedicated CLI tool for a task when one exists.

- Never write into `~/.config/`. All config edits happen inside this dotfiles repo `$HOME/Repos/dotfiles`.

- Never run `kubectl exec` or `kubectl run`. These commands are blocked and will fail.

- On NixOS, never run `home-manager`.

- All projects live in `$HOME/Repos`.

- Don't add comments just to describe what code does. Only add comments that help the IDE (e.g. hover docs, function explanations) or document a non-obvious decision.

- After editing anything that needs building, run the appropriate build command to verify.

- When a change involves a meaningful tradeoff (security vs convenience, manual vs automated, decoupling vs reuse, locking-in vs agnostic), present the options and let the user decide.
