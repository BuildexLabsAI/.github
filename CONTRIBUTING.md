# Contributing to BuildexLabsAI repositories

These rules apply to every repository in the BuildexLabsAI organization, whoever writes the
code: a person, Claude Code, Codex or another agent. Agents read the same rules from the
BuildexLabsAI block in each repository's AGENTS.md.

## Repository layout

```
<repo-name>/                     lowercase kebab-case, e.g. adlete-3d
├── README.md                    what it is, how to run it, who owns it
├── AGENTS.md                    instructions for AI agents: commands + the org rules block
├── CLAUDE.md                    one line, @AGENTS.md (+ notes only Claude Code needs)
├── DECISIONS.md                 one dated line per decision
├── .gitignore
├── src/                         all code; the framework decides what goes inside
├── tests/                       tests (or next to the code, if the framework expects that)
├── docs/                        specs, plans, docs/history/
├── scripts/                     helper scripts
├── public/, supabase/ …         only folders a tool requires at the root, plus config files
├── .claude/settings.json        Claude Code hook
└── .github/                     CODEOWNERS, workflows, hooks, the check, exceptions
```

- All code lives in `src/`. Inside it, the framework's convention wins: `src/app/` for
  Next.js, `src/` for Vite, `src/<package>/` for Python.
- Tests go in `tests/`, unless the framework expects them next to the code.
- Folders a tool insists on at the root (`public/`, `supabase/`) and tool config files
  (`package.json`, `pyproject.toml`) sit at the top level. Any other folder there is a warning.
- What the organization manages lives in `.github/` and `.claude/`. Do not edit
  `.github/scripts/check-standard.sh` by hand: it is a copy.

## Names

- Repository names, the top level and everything in `docs/` use lowercase kebab-case:
  `athlete-model.md`, `2026-10-06-capture-plan.md`.
- Everywhere: no spaces, no non-ASCII characters (ä, ö), and no two names that differ only by
  letter case (`Assets` and `assets`). Each of these breaks something on macOS, Windows or in
  scripts.
- Inside `src/`, `tests/` and `scripts/`, follow the language: `snake_case.py`, `Button.tsx`,
  and framework route names such as `[slug]`, `(group)` or `$username`.
- Conventional upper-case files keep their names: README.md, AGENTS.md, CLAUDE.md,
  DECISIONS.md, LICENSE, Dockerfile, Makefile.

## What never goes into git

- **Secrets:** `.env` files, keys, certificates, tokens. Commit `.env.example` with placeholder
  values instead. If a secret is pushed, rotate it first: deleting the file does not remove it
  from git history.

**Allowed:** video, audio, PDF, Office files, design source files (Photoshop, Figma, Blender)
and archives, up to GitHub's limit. The check allows these file types and has no size limit.
Top-level images are rejected: app images go in `src/` or `public/`, other images in `docs/`.

**GitHub's limit:** GitHub blocks files larger than 100 MiB. Git warns above 50 MiB.

Small files the app ships (icons, fonts, wasm) belong in `src/` or `public/`. Each repository's
README.md has a "Media and large files" section saying where its media lives.

## Exceptions

When a file really has to break a rule, list it in `.github/standard-exceptions` with the
reason. The reason is required, and the pull request shows it to the reviewer.

```
prisma  # Prisma reads its schema from a folder at the root
```

## Branches, commits and pull requests

1. Never commit to `main` directly. Create a branch: `feat/athlete-height`,
   `fix/upload-timeout`, or `docs/`, `chore/`, `refactor/`, `test/`. Branches that Claude Code
   (`claude/…`) or Codex (`codex/…`) create are fine.
2. Commit messages follow [Conventional Commits](https://www.conventionalcommits.org):
   `type(scope): summary`, e.g. `feat(api): add athlete height endpoint`. Types: feat, fix,
   docs, chore, refactor, test, perf, ci, build.
3. Open a pull request with a title in the same format. The template asks what changed, why,
   and how it was tested.
4. The `standard` check runs on every pull request. Fix what it reports.
5. Pull requests are squash-merged: the whole pull request becomes one commit on main, and its
   title becomes the commit message.

## Decisions

A choice that the code and the git log cannot show, such as why this library and not that
one, goes into DECISIONS.md the day it is made, as one dated line.

## README

Every README.md is written with the
[readme-generator](https://github.com/b1rdmania/readme-generator) skill for Claude Code:

```bash
git clone https://github.com/b1rdmania/readme-generator ~/.claude/skills/readme-generator
```

1. **Sections.** The skill picks the sections for the project type: a Claude Code skill, a CLI
   tool, a package, a script collection or another kind of repository. Every README also keeps
   the five sections of the repo-template README: Run it locally, Deploy, Media and large files,
   First-time setup and Owner. The last four close the README in that order. Write "Not
   deployed." or "None." rather than drop one. A section the project needs beyond these, such as
   how to test or release it, stays.
2. **Every command runs first.** The skill does not run the README's commands. Run each command
   before it goes into the README and keep only the ones that work.
3. **Independent review.** Before the README reaches main, Codex reviews it at high reasoning
   effort against the code: every command, path, number and claim. Fix what blocks and review
   again until nothing blocking is left.

## New repositories

1. Create the repository from
   [BuildexLabsAI/repo-template](https://github.com/BuildexLabsAI/repo-template) with
   "Use this template". Give it a kebab-case name.
2. Apply the merge settings, because a template does not copy them:
   ```bash
   gh api -X PATCH repos/BuildexLabsAI/<name> -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false -F delete_branch_on_merge=true -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
   ```
3. Write README.md as [README](#readme) says, and fill in AGENTS.md: the commands and the
   sanity check.
4. In every clone, once: `git config core.hooksPath .github/hooks`

## The check

| Where | When | What happens |
|---|---|---|
| Claude Code hook | Claude creates a file | A name that breaks the rules is blocked |
| git pre-commit hook | `git commit` | A commit with a bad new name is blocked |
| CI (`standard`) | Every pull request and push to main | The whole repository, the pull request title and a secret scan; problems show as a red X |

Run it yourself with `bash .github/scripts/check-standard.sh`. What is enforced on the
organization's current plan, and what changes with GitHub Team:
[docs/enforcement.md](https://github.com/BuildexLabsAI/.github/blob/main/docs/enforcement.md).
