<!-- buildexlabs-standard:start (copy of src/agents-block.md in BuildexLabsAI/.github; edit it there, not here) -->
## BuildexLabsAI repository standard

Every repository in the BuildexLabsAI organization follows these rules. The full version, with
the reasons, is CONTRIBUTING.md in the BuildexLabsAI/.github repository.

- **Layout.** The top level holds README.md, AGENTS.md, CLAUDE.md, DECISIONS.md, .gitignore,
  src/, tests/, docs/, scripts/, tool config files, and folders a tool requires at the root
  (such as public/ or supabase/). All code lives in src/. Inside src/ the framework's own
  convention wins: src/app/ for Next.js, src/<package>/ for Python.
- **Names.** Lowercase kebab-case (`athlete-model.md`) for the repository, the top level and
  everything in docs/. Everywhere: no spaces, no non-ASCII characters, and no two names that
  differ only by letter case. Inside src/, tests/ and scripts/, follow the language's own
  convention (`snake_case.py`, `Button.tsx`).
- **Never commit** secrets (.env files, keys, tokens), video, audio, PDF, Office documents,
  design source files, archives, or any file over 5 MB. Media lives outside git; link to it
  from README.md. Small assets the app ships (icons, fonts, wasm) belong in src/ or public/.
- **Exceptions** go in `.github/standard-exceptions`, one path per line with its reason:
  `docs/contract.pdf  # signed contract, required for the audit`.
- **Branches.** Never commit to main directly. Name branches `feat/…`, `fix/…`, `docs/…`,
  `chore/…`, `refactor/…` or `test/…`. Agent tools' own prefixes (`claude/…`, `codex/…`) are
  accepted.
- **Commits and pull request titles** follow Conventional Commits:
  `feat(api): add athlete height endpoint`. Pull requests are squash-merged, so the title
  becomes the commit on main.
- **Decisions** that the code and git log cannot show go in DECISIONS.md, one dated line each.
- **Check before you push:** `bash .github/scripts/check-standard.sh`. CI runs the same check
  on every pull request.
<!-- buildexlabs-standard:end -->
