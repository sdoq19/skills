---
name: skill-evolution-manager
description: 专门用于在对话结束时，根据用户反馈和对话内容总结优化并迭代现有 Skills 的核心工具。它通过吸取对话中的"精华"（如成功的解决方案、失败的教训、特定的代码规范）来持续演进 Skills 库。
license: MIT
# EXTENDED METADATA
github_url: https://github.com/KKKKhazix/Khazix-Skills
github_hash: fe15fea6cf7ac216027d11c2c64e87b462cc0427
version: 1.0.0
created_at: 2026-01-23
entry_point: scripts/merge_evolution.py
dependencies: []
---

# Skill Evolution Manager

这是整个 AI 技能系统的“进化中枢”。它不仅负责优化单个 Skill，还负责跨 Skill 的经验复盘和沉淀。

## 核心职责

1.  **复盘诊断 (Session Review)**：在对话结束时，分析所有被调用的 Skill 的表现。
2.  **经验提取 (Experience Extraction)**：将非结构化的用户反馈转化为结构化的 JSON 数据（`evolution.json`）。
3.  **智能缝合 (Smart Stitching)**：将沉淀的经验自动写入 `SKILL.md`，确保持久化且不被版本更新覆盖。

## 使用场景

**Trigger**: 
- `/evolve` 或 `/自更新`
- "复盘一下刚才的对话"
- "我觉得刚才那个工具不太好用，记录一下"
- "把这个经验保存到 Skill 里"
- "自更新"

**说明**: `/evolve` 和 `/自更新` 是等价的触发方式，都用于在对话结束后复盘并优化 Skills。

## 工作流 (The Evolution Workflow)

### 0. 自更新触发 (Self-Update Trigger)

当用户使用 `/自更新` 时，执行以下 4 步逻辑：

1. **搜索最近使用的 Skill**
   - 扫描当前对话历史，识别本次会话中调用了哪些 Skills
   - 按调用时间排序，找出最近使用的 Skill（通常是最后一个被调用的）

2. **对比使用过程，识别优化点**
   - 分析用户与该 Skill 的交互过程
   - 找出：
     - 用户明确表达的不满意（"这个不对"、"太慢了"、"格式错了"）
     - 用户明确的满意（"很好"、"这正是我想要的"）
     - 隐式反馈（重复修改、多次尝试才成功）
   - 对比 Skill 当前指导 vs 实际最佳实践

3. **定位对应位置**
   - 检查该 Skill 的 `SKILL.md` 结构
   - 确定优化建议应该写入哪个章节（如 `## When to Use`、`## Workflow`、`## Best Practices`）

4. **智能更新**
   - 生成结构化经验数据（JSON 格式）
   - 调用 `merge_evolution.py` 保存到 `evolution.json`
   - 调用 `smart_stitch.py` 将经验缝合到 `SKILL.md` 的 `## User-Learned Best Practices & Constraints` 章节

### 1. 经验复盘 (Review & Extract)
当用户触发复盘时，Agent 必须执行：
1.  **扫描上下文**：找出用户不满意的点（报错、风格不对、参数错误）或满意的点（特定 Prompt 效果好）。
2.  **定位 Skill**：确定是哪个 Skill 需要进化（例如 `yt-dlp` 或 `baoyu-comic`）。
3.  **生成 JSON**：在内存中构建如下 JSON 结构：
    ```json
    {
      "preferences": ["用户希望下载默认静音"],
      "fixes": ["Windows 下 ffmpeg 路径需转义"],
      "custom_prompts": "在执行前总是先打印预估耗时"
    }
    ```

### 2. 经验持久化 (Persist)
Agent 调用 `scripts/merge_evolution.py`，将上述 JSON 增量写入目标 Skill 的 `evolution.json` 文件中。
- **命令**: `python scripts/merge_evolution.py <skill_path> <json_string>`

### 3. 文档缝合 (Stitch)
Agent 调用 `scripts/smart_stitch.py`，将 `evolution.json` 的内容转化为 Markdown 并追加到 `SKILL.md` 末尾。
- **命令**: `python scripts/smart_stitch.py <skill_path>`

### 4. 跨版本对齐 (Align)
当 `skill-manager` 更新了某个 Skill 后，Agent 应主动运行 `smart_stitch.py`，将之前保存的经验“重新缝合”到新版文档中。

## 核心脚本

- `scripts/merge_evolution.py`: **增量合并工具**。负责读取旧 JSON，去重合并新 List，保存。
- `scripts/smart_stitch.py`: **文档生成工具**。负责读取 JSON，在 `SKILL.md` 末尾生成或更新 `## User-Learned Best Practices & Constraints` 章节。
- `scripts/align_all.py`: **全量对齐工具**。一键遍历所有 Skill 文件夹，将存在的 `evolution.json` 经验重新缝合回对应的 `SKILL.md`。常用于 `skill-manager` 批量更新后的经验还原。

## 最佳实践

- **不要直接修改 SKILL.md 的正文**：除非是明显的拼写错误。所有的经验修正应通过 `evolution.json` 通道进行，这样可以保证在 Skill 升级时经验不丢失。
- **多 Skill 协同**：如果一次对话涉及多个 Skill，请依次为每个 Skill 执行上述流程。
