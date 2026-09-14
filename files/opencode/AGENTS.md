# Local Rules

- Be terse. Prefer short answers over walls of text.

- Prefer the dedicated CLI tool for a task when one exists.

- Never write into `~/.config/`. All config edits happen inside this nix-config repo `$HOME/Repos/nix-config`.

- All projects live in `$HOME/Repos`.

- Don't add comments just to describe what code does. Only add comments that help the IDE or document a non-obvious decision.

- After editing anything that needs building, run the appropriate build command to verify.

- When a change involves a meaningful tradeoff, present the options and let the user decide.
