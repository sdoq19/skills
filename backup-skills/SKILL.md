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

### Step 3: Update README.md (CRITICAL)

**MANDATORY**: Check if any new skills were added and update README.md accordingly:

1. List all skill directories in the backup repo
2. Compare with README.md categories
3. If new skills exist that are not in README.md:
   - Add them to the appropriate category table
   - Or create a new category if needed
   - Include skill name and description

**README.md Structure:**
- Quick backup section (already exists)
- Skills classification section with tables
- Repository info section

### Step 4: Create Atomic Commits

Follow git-master skill principles:
- Group related skills together
- Create separate commits for different categories
- Use clear, descriptive commit messages
- **Include README.md update as a separate commit if it was modified**

Example commit groups:
1. New skills added (grouped by category)
2. README.md update (if skills were added)
3. Updated skills (if existing skills changed)

### Step 5: Push to GitHub

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
4. **Verify README.md is up to date** (all skills listed in correct categories)
5. Report summary to user including:
   - New skills added
   - README.md updated (if applicable)
   - Total skills count

## README.md Maintenance Rules

When new skills are added, MUST update README.md:

1. **Check all skill directories** - List all directories in `/e/java/workspace_own/skills/`
2. **Match with README categories** - Ensure each skill appears in a category table
3. **Add missing skills** - Insert new rows in appropriate category tables
4. **Create new categories** if needed for skills that don't fit existing ones
5. **Update skill count** if totals are mentioned

**Categories in README:**
- 📄 文档处理类 (docx, pptx, xlsx, pdf)
- 📝 Obsidian 专属类 (obsidian-markdown, obsidian-bases, json-canvas)
- 🛠️ Skill 管理类 (skill-creator, skill-manager, etc. + backup-skills)
- 💻 开发工作流类 (Superpowers skills)
- 🔧 开发工具类
- 💰 投资工具类

## Repository Info

- **Local path**: `E:\java\workspace_own\skills`
- **GitHub URL**: https://github.com/sdoq19/skills
- **Remote**: origin/main
