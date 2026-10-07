#!/usr/bin/env bash
# Tests for src/check-standard.sh. Run: bash tests/check-standard.test.sh
#
# Each test builds a throwaway git repository that follows the standard, breaks one rule,
# then checks the exit code and the message. Works with macOS bash 3.2 and Linux bash 5.

ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
CHECK="$ROOT/src/check-standard.sh"
BLOCK="$ROOT/src/agents-block.md"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
unset GITHUB_ACTIONS STANDARD_PR_TITLE STANDARD_BRANCH
# Keep the developer's own git config (global ignores, hooks, signing) out of the tests.
export HOME="$TMP/home" XDG_CONFIG_HOME="$TMP/home/.config" GIT_CONFIG_NOSYSTEM=1
mkdir -p "$HOME"
pass=0
fail=0

git_q() { git -c core.hooksPath=/dev/null -c commit.gpgsign=false "$@"; }

# A clean repository that follows the standard. The current directory moves into it.
new_repo() {
  local dir
  dir=$(mktemp -d "$TMP/repo.XXXXXX")
  cd "$dir" || exit 1
  git init -q -b main
  git config user.email test@example.com
  git config user.name test
  printf '# test\n' > README.md
  { printf '# test\n\n'; cat "$BLOCK"; } > AGENTS.md
  printf '@AGENTS.md\n' > CLAUDE.md
  printf '# Decisions\n' > DECISIONS.md
  printf '.env\n.env.*\n!.env.example\n' > .gitignore
  mkdir -p src tests docs scripts .github/scripts
  cp "$CHECK" .github/scripts/check-standard.sh
  touch src/.gitkeep tests/.gitkeep docs/.gitkeep scripts/.gitkeep
  git add -A
  git_q commit -qm init
}

# Runs the check with the given arguments; records its output and exit code.
run() { out=$(bash "$CHECK" "$@" 2>&1); status=$?; }

# Runs the repo's own copy in --hook mode with a Claude Code Write payload for path $1.
run_hook() {
  local payload
  payload=$(jq -n --arg p "$1" --arg c "$PWD" \
    '{tool_name: "Write", tool_input: {file_path: $p, content: "x"}, cwd: $c}')
  out=$(printf '%s' "$payload" | bash .github/scripts/check-standard.sh --hook 2>&1)
  status=$?
}

ok() { pass=$((pass + 1)); printf 'ok    %s\n' "$1"; }
not_ok() {
  fail=$((fail + 1))
  printf 'FAIL  %s\n      %s\n' "$1" "$2"
  printf '%s\n' "$out" | sed 's/^/      | /'
}

# expect NAME STATUS [TEXT]: the last run exited with STATUS and its output contains TEXT.
expect() {
  if [ "$status" -ne "$2" ]; then not_ok "$1" "exit $status, expected $2"; return; fi
  if [ -n "${3:-}" ] && ! printf '%s' "$out" | grep -qF -- "$3"; then
    not_ok "$1" "output lacks: $3"; return
  fi
  ok "$1"
}

# expect_clean NAME: the last run exited 0 with no errors and no warnings.
expect_clean() {
  if [ "$status" -ne 0 ]; then not_ok "$1" "exit $status, expected 0"; return; fi
  if printf '%s' "$out" | grep -qiE '^(error|warning)'; then not_ok "$1" "unexpected findings"; return; fi
  ok "$1"
}

echo "== whole repository =="
new_repo; run; expect_clean "clean repository passes"
cd "$TMP"; run; expect "outside a git repository fails" 1 "git repository"

new_repo; rm README.md; run; expect "missing README.md fails" 1 "README.md"
new_repo; printf '# no import\n' > CLAUDE.md; run; expect "CLAUDE.md without @AGENTS.md fails" 1 "@AGENTS.md"
new_repo; printf '# test\n' > AGENTS.md; run; expect "AGENTS.md without the standard block fails" 1 "standard block"
new_repo; printf 'node_modules/\n' > .gitignore; run; expect ".gitignore that does not ignore .env fails" 1 ".env"

echo "== names =="
new_repo; touch "docs/my notes.md"; run; expect "space in a name fails" 1 "docs/my notes.md"
new_repo; mkdir "Casino "; touch "Casino /plan.md"; run; expect "trailing space in a folder name fails" 1 "Casino "
new_repo; touch "docs/tähtipolku.md"; run; expect "non-ASCII name fails" 1 "docs/t"
new_repo; touch "src/tähti.py"; run; expect "non-ASCII name inside src fails" 1 "src/t"
new_repo; touch "src/a&b.ts"; run; expect "symbol in a name fails" 1 "src/a&b.ts"
new_repo; touch My-Notes.md; run; expect "uppercase top-level name fails" 1 "My-Notes.md"
new_repo; mkdir -p docs/Specs; touch docs/Specs/plan.md; run; expect "uppercase folder in docs fails" 1 "docs/Specs/plan.md"
new_repo; touch docs/plan_v2.md; run; expect "underscore in docs fails" 1 "docs/plan_v2.md"
new_repo; touch Dockerfile LICENSE docs/README.md; run; expect_clean "conventional uppercase names pass"
new_repo
mkdir -p "src/app/[slug]" "src/app/(marketing)" "src/app/@modal" src/adlete3d/body src/components
touch "src/app/[slug]/page.tsx" "src/app/(marketing)/page.tsx" "src/app/@modal/default.tsx" \
  src/adlete3d/body/__init__.py src/components/Button.tsx
run; expect_clean "framework names inside src pass"
new_repo; mkdir -p "src/routes/{-\$locale}"
touch 'src/routes/$username.tsx' 'src/routes/{-$locale}/index.tsx' src/routes/__root.tsx
run; expect_clean "TanStack Router names inside src pass"
new_repo; blob=$(git hash-object -w /dev/null)
git update-index --add --cacheinfo "100644,$blob,src/Assets/a.png"
git update-index --add --cacheinfo "100644,$blob,src/assets/b.png"
run; expect "names differing only by letter case fail" 1 "src/Assets"

echo "== media, size, secrets =="
new_repo; touch docs/demo.mp4; run; expect "video fails" 1 "docs/demo.mp4"
new_repo; touch docs/deck.pdf; run; expect "PDF fails" 1 "docs/deck.pdf"
new_repo; touch scripts/backup.zip; run; expect "archive fails" 1 "scripts/backup.zip"
new_repo; touch logo.png; run; expect "image at the top level fails" 1 "logo.png"
new_repo; mkdir -p public; touch public/icon-192.png docs/architecture.png; run; expect_clean "images in public and docs pass"
new_repo; head -c 6000000 /dev/zero > src/model.bin; run; expect "file over 5 MB fails" 1 "src/model.bin"
new_repo; head -c 5000000 /dev/zero > src/small.wasm; run; expect_clean "file under 5 MB passes"
new_repo; echo 'KEY=1' > .env; git add -f .env; run; expect "committed .env fails" 1 ".env"
new_repo; echo 'KEY=' > .env.example; run; expect_clean ".env.example passes"
new_repo; touch src/server.pem; run; expect "key file fails" 1 "src/server.pem"
new_repo; touch .DS_Store; run; expect ".DS_Store fails" 1 ".DS_Store"

echo "== warnings =="
new_repo; mkdir tasks; touch tasks/todo.md; run; expect "unknown top-level folder warns but passes" 0 "tasks/"
new_repo; touch notes.md; run; expect "loose top-level document warns but passes" 0 "notes.md"

echo "== exceptions =="
new_repo; touch docs/contract.pdf
printf 'docs/contract.pdf  # signed contract, required for the audit\n' > .github/standard-exceptions
run; expect_clean "listed exception passes"
new_repo; touch docs/contract.pdf; printf 'docs/contract.pdf\n' > .github/standard-exceptions
run; expect "exception without a reason fails" 1 "reason"
new_repo; mkdir tasks; touch tasks/todo.md
printf '# Folders a tool needs at the root\ntasks  # the task runner reads it from the root\n' > .github/standard-exceptions
run; expect_clean "excepted top-level folder passes"

echo "== drift from the canonical copies =="
new_repo; run --canonical "$ROOT/src"; expect_clean "copies matching the canonical ones pass"
new_repo; sed -i.bak 's/Never commit to main directly/Commit anywhere/' AGENTS.md && rm AGENTS.md.bak
run --canonical "$ROOT/src"; expect "outdated AGENTS.md block warns but passes" 0 "out of date"
new_repo; echo '# changed' >> .github/scripts/check-standard.sh
run --canonical "$ROOT/src"; expect "outdated script copy warns but passes" 0 "check-standard.sh"

echo "== pull request title and branch =="
new_repo; export STANDARD_PR_TITLE='feat(api): add athlete height endpoint' STANDARD_BRANCH='feat/height'
run; unset STANDARD_PR_TITLE STANDARD_BRANCH; expect_clean "conventional title and branch pass"
new_repo; export STANDARD_PR_TITLE='Update stuff'
run; unset STANDARD_PR_TITLE; expect "non-conventional PR title fails" 1 "Conventional Commits"
new_repo; export STANDARD_BRANCH='my-branch'
run; unset STANDARD_BRANCH; expect "unprefixed branch warns but passes" 0 "my-branch"
new_repo; export STANDARD_BRANCH='claude/brave-turing'
run; unset STANDARD_BRANCH; expect_clean "Claude Code branch passes"

echo "== CI output =="
new_repo; touch "docs/my notes.md"; git add -A; export GITHUB_ACTIONS=true
run; unset GITHUB_ACTIONS; expect "CI output uses GitHub annotations" 1 "::error file=docs/my notes.md::"

echo "== staged files (git pre-commit hook) =="
new_repo; touch "docs/my notes.md"; git add -A; run --staged; expect "new bad name blocks the commit" 1 "docs/my notes.md"
new_repo; touch docs/plan.md; git add -A; run --staged; expect_clean "new good name passes"
new_repo; touch "docs/old notes.md"; git add -A; git_q commit -qm legacy
echo change >> "docs/old notes.md"; git add -A; run --staged; expect_clean "editing a legacy file does not block the commit"
new_repo; head -c 6000000 /dev/zero > src/model.bin; git add -A; run --staged; expect "file over 5 MB blocks the commit" 1 "src/model.bin"
new_repo; mkdir tasks; touch tasks/todo.md; git add -A; run --staged; expect "new unknown top-level folder warns but passes" 0 "tasks/"
dir=$(mktemp -d "$TMP/empty.XXXXXX"); cd "$dir"; git init -q -b main; touch "Bad Name.md"; git add -A
run --staged; expect "first commit of an empty repository is checked" 1 "Bad Name.md"

echo "== Claude Code hook =="
new_repo; run_hook "$PWD/My File.md"; expect "blocks a new file with a space" 2 "My File.md"
new_repo; run_hook "$PWD/docs/athlete-model.md"; expect_clean "allows a good new file"
new_repo; run_hook "$PWD/docs/new folder/plan.md"; expect "blocks a new folder with a space" 2 "new folder"
new_repo; run_hook "$PWD/docs/tähti.md"; expect "blocks a non-ASCII name" 2 "docs/t"
new_repo; run_hook "$PWD/docs/demo.mp4"; expect "blocks a video" 2 "docs/demo.mp4"
new_repo; mkdir -p src/assets; touch src/assets/a.png; git add -A; git_q commit -qm assets
run_hook "$PWD/src/Assets/b.png"; expect "blocks a name that clashes by letter case" 2 "assets"
new_repo; touch "docs/old notes.md"; run_hook "$PWD/docs/old notes.md"; expect_clean "allows editing an existing file"
new_repo; run_hook "$TMP/elsewhere/My File.md"; expect_clean "ignores files outside the repository"
new_repo; run_hook "$PWD/.env"; expect_clean "ignores gitignored files"
new_repo; run_hook "$PWD/tasks/todo.md"; expect_clean "does not block on warnings"
new_repo; out=$(printf 'not json' | bash .github/scripts/check-standard.sh --hook 2>&1); status=$?
expect "lets malformed input through" 0

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
