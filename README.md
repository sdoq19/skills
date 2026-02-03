# Claude Skills 备份仓库

本仓库用于备份本地 Claude Code 的 skills，防止意外丢失。

## 快速备份

告诉 Claude：**"帮我备份 skills"**

或者手动执行：
```bash
cd /e/java/workspace_own/skills
./backup.sh
```

---

## Skills 分类

### 📄 文档处理类

| Skill | 用途 |
|-------|------|
| **docx** | Word 文档创建、编辑和分析，支持修订、评论和格式保留 |
| **pptx** | PowerPoint 演示文稿创建、编辑和分析 |
| **xlsx** | Excel 电子表格创建、编辑、公式计算和数据分析 |
| **pdf** | PDF 工具包，支持表单填充、文本提取、合并拆分等 |

### 📝 Obsidian 专属类

| Skill | 用途 |
|-------|------|
| **obsidian-markdown** | 创建和编辑 Obsidian Flavored Markdown，支持 wikilink、callout 等 |
| **obsidian-bases** | 创建和编辑 Obsidian 数据库 (.base) 文件 |
| **json-canvas** | 创建和编辑 Obsidian Canvas 可视化文件 |

### 🛠️ Skill 管理类

| Skill | 用途 |
|-------|------|
| **skill-creator** | 创建新 skill 的指南和工具 |
| **skill-manager** | GitHub-based skills 生命周期管理器 |
| **skill-evolution-manager** | 根据对话反馈持续演进和优化现有 skills |
| **github-to-skills** | 自动将 GitHub 仓库转换为 Claude skill 的工具 |
| **template-skill** | 创建新 skill 的模板 |
| **backup-skills** | 自动化备份所有 skills 到 GitHub 仓库 |

### 💻 开发工作流类 (Superpowers)

| Skill | 用途 |
|-------|------|
| **brainstorming** | 编码前的设计思考和需求探索（Socratic 对话） |
| **writing-plans** | 创建详细的实现计划（每项任务 2-5 分钟） |
| **executing-plans** | 批量执行计划，带有人工检查点 |
| **subagent-driven-development** | 子代理驱动开发，快速迭代 |
| **test-driven-development** | 真正的 TDD（红-绿-重构循环） |
| **systematic-debugging** | 系统化调试（4 阶段根本原因分析） |
| **verification-before-completion** | 完成前的验证（必须有证据） |
| **requesting-code-review** | 请求代码审查前的检查清单 |
| **receiving-code-review** | 接收代码审查反馈（技术要求而非社交表演） |
| **using-git-worktrees** | 使用 Git 工作树进行并行开发 |
| **finishing-a-development-branch** | 完成开发分支（合并/PR/保留/丢弃决策） |
| **dispatching-parallel-agents** | 并行代理工作流 |
| **using-superpowers** | 技能系统使用指南 |
| **writing-skills** | 创建新技能的最佳实践 |

### 🔧 开发工具类

| Skill | 用途 |
|-------|------|
| **changelog-generator** | 从 Git 提交记录自动生成用户友好的变更日志 |
| **coding-standards-checker** | 甘草云 HIS 系统代码规范检查器，确保模块边界和架构合规 |

### 💰 投资工具类

| Skill | 用途 |
|-------|------|
| **duan-yongping-invest-skill** | 段永平风格投资备忘录生成器，基于好生意+好人+好价格评估 |

---

## 仓库信息

- **本地路径**: `E:\java\workspace_own\skills`
- **远程仓库**: https://github.com/sdoq19/skills
- **最后更新**: 2026-02-03
