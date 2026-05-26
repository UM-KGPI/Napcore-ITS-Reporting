# Contributing

This document defines the basic contribution workflow for this repository.

## Branching Rules

- Do not commit directly to `master` unless explicitly approved.
- Create a short-lived feature branch for each task.
- Use branch names like `feature/<topic>`, `fix/<topic>`, or `docs/<topic>`.

## Commit Rules

- Keep commits focused and atomic: one logical change per commit.
- Write clear commit messages in imperative form.
- Recommended format:
  - `<type>: <short summary>`
  - Examples: `docs: update dataset health diagram`, `fix: handle missing dataset endpoint`
- Use common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.
- Reference issue IDs in the commit body when available.

## Push Rules

- Push your branch regularly to avoid losing work.
- Never force-push shared branches unless the team has agreed.
- If force push is required on your own branch, prefer `--force-with-lease`.
- Ensure your branch is up to date with `master` before opening a PR.

## Pull Request Rules

- Open a PR for every change, including documentation updates.
- Keep PRs small and reviewable.
- PR title should summarize the change clearly.
- PR description should include:
  - What changed
  - Why it changed
  - How it was tested
  - Any follow-up tasks
- Link related issues or tickets.
- Add screenshots or diagram previews for UI/diagram changes when relevant.

## Merge Rules

- Merge only after at least one approval (or team-defined minimum).
- Required checks must pass before merge.
- Resolve all review comments or document why they are not applied.
- Preferred merge strategy: `Squash and merge` for clean history.
- Use `Rebase and merge` only when commit history is intentionally curated.
- Do not use merge commits unless specifically required by the team.

## Basic Quality Gate Before PR

- Run relevant tests and checks.
- Validate changed documentation links and diagram exports.
- Confirm no unrelated files are included.
- Confirm no secrets or credentials are committed.

## Communication

- Ask for clarification early when requirements are ambiguous.
- Highlight breaking changes clearly in the PR.
- If your change impacts architecture or API contracts, update docs in the same PR.
