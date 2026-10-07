# BuildexLabsAI/.github

The BuildexLabsAI organization's shared defaults and its repository standard.

- **Defaults for every repository.** GitHub shows [CONTRIBUTING.md](CONTRIBUTING.md),
  [SECURITY.md](SECURITY.md) and the [pull request template](.github/pull_request_template.md)
  in every BuildexLabsAI repository that has none of its own. GitHub only reads these defaults
  from a public `.github` repository, so this one is public. Nothing secret belongs here.
- **The standard.** CONTRIBUTING.md is the full rulebook.
  [src/agents-block.md](src/agents-block.md) is the short version that every repository's
  AGENTS.md carries for AI agents.
- **The check.** [src/check-standard.sh](src/check-standard.sh) enforces the rules. Every
  repository runs it in three places: the Claude Code hook (when Claude creates a file), the git
  pre-commit hook, and CI through the shared workflow
  [.github/workflows/standard-check.yml](.github/workflows/standard-check.yml).
- **Enforcement.** [docs/enforcement.md](docs/enforcement.md) says what is enforced where, and
  how to switch on hard enforcement when the organization moves to GitHub Team.

New repositories start from [BuildexLabsAI/repo-template](https://github.com/BuildexLabsAI/repo-template).

## Changing the standard

1. Open a pull request here. Change the rule in `src/check-standard.sh` and add a test to
   `tests/check-standard.test.sh` that fails without the change. If agents need to know the
   rule, update `src/agents-block.md` and CONTRIBUTING.md in the same pull request.
2. After the merge, CI warns every repository whose copies are out of date. Update
   BuildexLabsAI/repo-template first: copy `src/check-standard.sh` to
   `.github/scripts/check-standard.sh` and the new block into AGENTS.md.

Run the tests with `bash tests/check-standard.test.sh`.
