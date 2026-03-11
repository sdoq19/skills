# Claude Skills 仓库

本仓库用于备份和管理本地 Claude Code 的 skills，防止意外丢失。

## 快速备份

告诉 Claude：**"帮我备份 skills"**

通过 `backup-skills` skill 自动执行：复制 skills → 更新 README → 提交 → 推送到 GitHub

---

## Skills 分类（共 36 个）

### 🔒 安全审计类（1个）- ⚠️ 最高优先级

| Skill | 用途 |
|-------|------|
| **security-review** | **[CRITICAL]** 所有 skills 执行的安全门控。必须在任何其他 skill 执行前通过。检测 OWASP Top 10、SQL 注入、XSS、CSRF、硬编码密钥、认证授权等安全问题 |

**⚠️ 重要：`security-review` 是所有 skill 执行前的强制安全检查。**

```
┌─────────────────────────────────────────────────────────────┐
│  SECURITY GATE CHECKLIST                                     │
│                                                              │
│  □ 秘密管理 - 无硬编码密钥                                   │
│  □ 输入验证 - 所有输入已校验                                 │
│  □ SQL 注入 - 参数化查询                                     │
│  □ XSS 防护 - 输出已净化                                     │
│  □ 认证授权 - 正确的访问控制                                 │
│  □ 速率限制 - API 端点保护                                   │
│  □ 错误处理 - 无敏感数据暴露                                 │
│                                                              │
│  全部通过才能继续执行                                        │
└─────────────────────────────────────────────────────────────┘
```

### 🤖 自主代理类（1个）

| Skill | 用途 |
|-------|------|
| **self-improving-agent** | **[推荐]** 自我改进代理系统。通过观察会话、提取模式、演化技能实现持续自主改进。支持本能(Instinct)学习、自动循环模式、项目隔离、置信度评分 |

### 📄 文档处理类（4个）

| Skill | 用途 |
|-------|------|
| **docx** | Word 文档创建、编辑和分析，支持修订、评论和格式保留 |
| **pptx** | PowerPoint 演示文稿创建、编辑和分析 |
| **xlsx** | Excel 电子表格创建、编辑、公式计算和数据分析 |
| **pdf** | PDF 工具包，支持表单填充、文本提取、合并拆分等 |

### 📝 Obsidian 专属类（3个）

| Skill | 用途 |
|-------|------|
| **obsidian-markdown** | 创建和编辑 Obsidian Flavored Markdown，支持 wikilink、callout 等 |
| **obsidian-bases** | 创建和编辑 Obsidian 数据库 (.base) 文件 |
| **json-canvas** | 创建和编辑 Obsidian Canvas 可视化文件 |

### 🛠️ Skill 管理类（10个）

| Skill | 用途 |
|-------|------|
| **skill-creator** | 创建新 skill 的官方指南和工具（Anthropic 官方） |
| **skill-manager** | GitHub-based skills 生命周期管理器，检查更新和版本控制 |
| **skill-evolution-manager** | 根据对话反馈持续演进和优化现有 skills |
| **github-to-skills** | 自动将 GitHub 仓库转换为 skill 包装器（含元数据追踪） |
| **skill-from-github** | 从 GitHub 高质量项目学习并创建 skill（学习方法论） |
| **skill-from-masters** | 从领域大师学习，包含方法论数据库和技能分类法（最全面） |
| **skill-from-notebook** | 从文档/示例/Jupyter notebooks 提取方法论创建 skill |
| **search-skill** | 从可信市场搜索和推荐 Claude Code skills |
| **template-skill** | 创建新 skill 的模板 |
| **backup-skills** | 自动化备份所有 skills 到 GitHub 仓库 |

### 💻 开发工作流类 - Superpowers（14个）

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

### 🔧 开发工具类（2个）

| Skill | 用途 |
|-------|------|
| **changelog-generator** | 从 Git 提交记录自动生成用户友好的变更日志 |
| **coding-standards-checker** | 甘草云 HIS 系统代码规范检查器，确保模块边界和架构合规 |

### 💰 投资工具类（1个）

| Skill | 用途 |
|-------|------|
| **duan-yongping-invest-skill** | 段永平风格投资备忘录生成器，基于好生意+好人+好价格评估 |

---

## Skill 管理类详解

Skill 管理类包含多个功能各异的工具，以下是选择指南：

| 需求 | 推荐 Skill |
|------|-----------|
| 创建新 skill | `skill-creator`（官方指南）或 `skill-from-masters`（大师方法论） |
| 从 GitHub 项目学习 | `skill-from-github`（学习方法）或 `github-to-skills`（包装工具） |
| 从文档/示例学习 | `skill-from-notebook` |
| 搜索现有 skills | `search-skill` |
| 管理/更新 skills | `skill-manager` |
| 持续改进 skills | `skill-evolution-manager` |
| 备份 skills | `backup-skills` |

---

## 新增 Skills 说明

### security-review（安全审计）

**位置**: `skills/security-review/`

**用途**: 作为所有 skills 执行前的安全门控，确保代码符合安全最佳实践。

**关键功能**:
- OWASP Top 10 漏洞检测
- 硬编码密钥扫描
- SQL 注入防护
- XSS/CSRF 防护
- 认证授权检查
- 敏感数据暴露检测

**严重级别与动作**:
| 严重级别 | 动作 |
|----------|------|
| **CRITICAL** | 立即阻止，要求修复 |
| **HIGH** | 阻止，警告用户，建议修复 |
| **MEDIUM** | 警告，允许执行但需确认 |
| **LOW** | 记录日志，建议改进 |

### self-improving-agent（自我改进代理）

**位置**: `skills/self-improving-agent/`

**用途**: 实现持续自主学习和改进，通过观察会话、提取模式、演化技能来不断增强代理能力。

**关键功能**:
- 100% 观察（通过 Hooks）
- 本能(Instinct)系统 - 原子化学习
- 置信度评分（0.3-0.9）
- 项目隔离 vs 全局学习
- 自动演化到 skills/commands/agents

**核心命令**:
- `/instinct-status` - 显示已学习的本能
- `/evolve` - 聚类本能到技能
- `/promote` - 推广项目本能到全局
- `/projects` - 列出所有项目

---

**最后更新**: 2026-03-11
