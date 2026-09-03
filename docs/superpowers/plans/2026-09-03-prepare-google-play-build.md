# Prepare Google Play Build Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an opencode command that automatically bumps the Flutter build number, runs tests, builds the Android App Bundle, and reports the upload path.

**Architecture:** Keep this as a single opencode command file rather than a larger agent workflow. The command will delegate the actual work to the build agent, but the routine itself stays fixed: bump version, test, bundle, summarize.

**Tech Stack:** opencode command markdown, Flutter, Dart, `pubspec.yaml`

## Global Constraints

- The build number in `pubspec.yaml` is the Android `versionCode`.
- The command must bump the build number automatically.
- The command must run `flutter test` before `flutter build appbundle`.
- The command must report `build/app/outputs/bundle/release/app-release.aab`.

---

### Task 1: Add the Google Play build command

**Files:**
- Create: `.opencode/command/prepare-google-play-build.md`

**Interfaces:**
- Consumes: `pubspec.yaml`, `flutter test`, `flutter build appbundle`
- Produces: a reusable command named `prepare google play build`

- [ ] **Step 1: Write the command file**

```markdown
---
description: Prepare a Google Play release build for the Flutter app.
agent: build
---

Prepare a Google Play build for this Flutter app.

Do this in order:

1. Read `pubspec.yaml` and bump the Flutter build number by 1.
2. Keep the version name unchanged.
3. Run `flutter test`.
4. Run `flutter build appbundle`.
5. Report the resulting AAB path: `build/app/outputs/bundle/release/app-release.aab`.
6. Remind me to upload the new AAB to Google Play closed testing.

If any step fails, stop immediately and report the failure clearly.
```

- [ ] **Step 2: Verify the command file exists and is readable**

Run: `git diff -- .opencode/command/prepare-google-play-build.md`

Expected: the new command file is present with the fixed routine text.

- [ ] **Step 3: Commit**

```bash
git add .opencode/command/prepare-google-play-build.md docs/superpowers/specs/2026-09-03-prepare-google-play-build-design.md docs/superpowers/plans/2026-09-03-prepare-google-play-build.md
git commit -m "feat: add google play build command"
```
