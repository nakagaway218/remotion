## Codex work instructions

- This repository contains the restored Remotion codebase plus the user's own project files.
- The current main user-owned tool area is `Mytool/`.
- Match the existing code structure, naming, and style when making changes.
- Check the current worktree state with `git status` before starting edits.
- Do not revert or overwrite uncommitted user changes unless the user explicitly asks.
- Keep changes focused and avoid broad refactors unless they are necessary for the task.
- After changes, run relevant tests, lint, type checks, or builds when practical.
- Do not run `git push` unless the user explicitly asks for it.
- Before committing, briefly explain what changed.
- Explain work and results in Japanese when talking with the user.
- When using technical terms, add short explanations where helpful for beginners.
- Use `AI_CONTEXT.md`, `DESIGN.md`, and `SKILL.md` as supporting project context when relevant.

## GitHub sync policy

- Before reflecting changes on GitHub, review the changed files and diff.
- Use short English commit messages that describe the change.
- Ask for user approval before pushing or creating a pull request.

## Setup commands

```bash
# Install dependencies (uses Bun)
bun install

# Build all packages
bunx turbo run make

# Run tests and linting
bunx turbo run lint test

# Clean build artifacts
bun run clean

# Build a specific package
bunx turbo run make --filter='<package-name>'
```

Use `bunx` (not `npx`) to run package binaries.

The current Remotion version can be found in `packages/core/src/version.ts`. The next version should increment the patch version by 1.

Pull request titles should be in the format `\`[package-name]\``: [commit-message]`. For example, "`@remotion/player`: Add new feature.

## Before committing

If committing your work:

1. Run `bun run build` from the root of the repo to verify all packages build successfully
2. Run `bun run stylecheck` to ensure CI passes
3. Include `bun.lock` when dependencies change

## Contributing

Read the full [contribution guide](/packages/docs/docs/contributing/index.mdx).

- [General information](/packages/docs/docs/contributing/index.mdx)
- [Implementing a new feature](/packages/docs/docs/contributing/feature.mdx)
- [Implementing a new option](/packages/docs/docs/contributing/option.mdx)

## Cloud Agents specific instructions

### Runtime

Bun v1.3.3 is the required package manager and test runner. It is installed at `~/.bun/bin/bun`. Ensure `~/.bun/bin` is on `PATH` (the update script handles this).

### Key services

- **Remotion Studio** (dev testbed): `cd packages/example && bun run dev` — starts at `http://localhost:3000`. This is the main dev UI for previewing video compositions.
- **Player testbed**: `cd packages/player-example && bun run dev` — for testing `@remotion/player` changes.
- **Docs site**: `cd packages/docs && bun run start` — Docusaurus dev server.

### Rendering test videos

From `packages/example`:
- `bunx remotion compositions` — list available compositions.
- `bunx remotion render <comp-id> --output ../../out/video.mp4` — render a video.
- `bunx remotion still <comp-id> --output ../../out/still.png` — render a still image.

### Known caveats

- `@remotion/lambda-go` lint requires Go >= 1.23.0. The VM ships Go 1.22.2, so that package's lint will fail. This is optional and doesn't affect core development.
- `@remotion/openai-whisper` tests require `OPENAI_API_KEY` env var. Without it, 1 test fails. This is expected and non-blocking.
- The Remotion Studio (`bun run dev` in `packages/example`) sometimes reports "Already running on port 3000" if a previous instance is still bound. Check with `curl http://localhost:3000` before assuming it failed.
- After `bun install`, always run `bun run build` before running tests or starting the Studio, as many packages depend on built artifacts from other packages.
- The `prepare` script in root `package.json` sets git hooks path to `.githooks`. The pre-commit hook runs `bun pre-commit.ts` for formatting.
