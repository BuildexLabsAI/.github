# Enforcement

What stops a change that breaks the standard, on GitHub Free (the organization's plan today) and
on GitHub Team.

| Layer | What it does | GitHub Free | GitHub Team |
|---|---|---|---|
| AGENTS.md and CLAUDE.md | Tell every AI agent the rules | Instruction only | Instruction only |
| Claude Code hook | Stops Claude from creating a badly named file | Blocks (Claude Code only) | Same |
| git pre-commit hook | Stops a commit with a bad new name, media or a file over 5 MB | Blocks, once switched on in the clone | Same |
| CI check `standard / check` | Checks the whole repository, the pull request title and secrets | Red X; merging still works | Blocks the merge |
| Merge settings | Squash merge only; branches deleted after merge | Works | Works |
| Repository creation | Only owners create repositories, so each one starts from the template | Works | Works |
| Ruleset `main-protection` | No direct pushes to main; pull request, passing check and owner review required | Not available for private repositories | One command |
| CODEOWNERS | Asks the owner for a review automatically | Inactive in private repositories | Works |

## The gap on GitHub Free

Anyone with write access can push straight to `main` of a private repository, and nothing stops
it: GitHub Free has no branch protection or rulesets for private repositories. The CI check still
runs on the push and shows a red X afterwards.

## Switching on hard enforcement (GitHub Team)

1. Upgrade the organization to GitHub Team.
2. From a clone of this repository, with an owner's token that has the `admin:org` scope
   (`gh auth refresh -h github.com -s admin:org`):
   ```bash
   gh api -X POST orgs/BuildexLabsAI/rulesets --input docs/ruleset-main.json
   ```
3. Verify: open a test pull request in any repository with a badly named file. The merge button
   must stay blocked until the check passes and an owner approves.

[ruleset-main.json](ruleset-main.json) applies to the default branch of every repository:

- No deleting the branch and no force pushes.
- Changes only through pull requests, merged by squash.
- One approving review from a code owner; a new push dismisses earlier approvals.
- The `standard / check` check must pass. New repositories and branches can still be created.

Organization admins can bypass it **through a pull request only**. The owner can merge their own
pull request without waiting for a second reviewer, but cannot push straight to main either.

## Settings that work on Free

Each needs an owner and is applied once.

- Per repository, the merge settings:
  ```bash
  gh api -X PATCH repos/BuildexLabsAI/<name> -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false -F delete_branch_on_merge=true -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
  ```
- For the organization: Settings → Member privileges → Repository creation, with both boxes
  cleared, so that only owners create repositories.
