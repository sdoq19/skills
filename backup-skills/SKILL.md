---
name: backup-skills
description: Use when user says "帮我备份 skills" or asks to backup Claude skills to GitHub. Automatically copies all skills from local Claude directory to the backup repository and pushes to GitHub.
---

# Backup Skills to GitHub

## Overview

This skill automates the backup process of all Claude skills to a GitHub repository.

## When to Use

- User says: "帮我备份 skills"
- User says: "备份 skills"
- User asks to backup skills to GitHub
- User wants to sync skills to the backup repo

## Backup Process

### Step 1: Copy Skills

Copy all skills from local Claude directory to backup repository:

```bash
cp -r /c/Users/sdoq1/.claude/skills/* /e/java/workspace_own/skills/
```

### Step 2: Check for Changes

Check git status to see what changed:

```bash
cd /e/java/workspace_own/skills
git status
```

### Step 3: Create Atomic Commits

Follow git-master skill principles:
- Group related skills together
- Create separate commits for different categories
- Use clear, descriptive commit messages

Example commit groups:
1. New skills added
2. Updated skills
3. README updates (if needed)

### Step 4: Push to GitHub

```bash
git push origin main
```

## Commit Message Format

Use format: `Backup skills: [description]`

Examples:
- `Backup skills: add new obsidian skills`
- `Backup skills: update superpowers workflow`
- `Backup skills: sync all local changes`

## Verification

After backup:
1. Verify working directory is clean
2. Check commit history
3. Confirm push to GitHub succeeded
4. Report summary to user

## Repository Info

- **Local path**: `E:\java\workspace_own\skills`
- **GitHub URL**: https://github.com/sdoq19/skills
- **Remote**: origin/main
