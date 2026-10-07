# Decisions

Choices that neither the code nor the git log shows, newest first. One line each.

- 2026-10-07: This repository is public, because GitHub only reads organization-wide default files from a public `.github` repository.
- 2026-10-07: Hard enforcement waits for GitHub Team. GitHub Free has no rulesets or branch protection for private repositories, so the standard relies on agent instructions, local hooks and a CI check that warns; docs/enforcement.md holds the ruleset ready to switch on.
- 2026-10-07: All code lives in src/ whatever the framework (Next.js src/app/, Vite src/, Python src/<package>/), so the top level is identical in every repository.
- 2026-10-07: No per-repository CONTRIBUTING.md: this repository's copy is shown everywhere, and a second copy would drift.
- 2026-10-07: AGENTS.md holds the instructions and CLAUDE.md imports it with `@AGENTS.md`, so Claude Code, Codex and other agents read the same rules.
- 2026-10-07: One check script runs in three places (Claude Code hook, git pre-commit hook, CI) so the rules cannot disagree; each repository carries a copy for local runs, and CI warns when the copy is out of date.
- 2026-10-07: Pull requests are squash-merged and their titles follow Conventional Commits, so main has one readable commit per change.
- 2026-10-07: Secrets are scanned with the gitleaks binary from its GitHub release, pinned by checksum. GitHub's push protection needs a paid add-on for private repositories, and gitleaks-action needs a license key for organizations.
- 2026-10-07: Branches that agent tools create (claude/, codex/) are accepted, because Claude Code names its worktree branches that way.
- 2026-10-07: Folder and file names may contain the route symbols frameworks use ([slug], (group), @slot, $param, {-$optional}); UAE-SponSlot's TanStack Router routes need $.
