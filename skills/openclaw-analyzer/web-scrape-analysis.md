# OpenClaw Web 抓取功能分析总结

**分析时间**: 2026-03-12
**分析目的**: 评估 OpenClaw 是否支持 Web 搜索、网页筛选和内容分析功能

---

## ✅ 功能支持评估

### 1. Playwright 支持情况

**结论**: ✅ **部分支持**

OpenClaw 包含 browser 模块，但主要用于**本地 Canvas 渲染**，而非 Web 抓取。

**发现的文件**:
- `src/browser/` - 浏览器自动化模块
  - `screenshot.ts` - 截图功能
  - `cdp.ts` - Chrome DevTools Protocol
  - `chrome.ts` - Chrome 扩展支持
  - `client-fetch.ts` - HTTP 客户端
  - `client-actions.ts` - 客户端操作

**功能**:
- ✅ 截图功能 (browser screenshot)
- ✅ 浏览器控制 (CDP)
- ✅ 页面导航
- ❌ **不支持** Web 搜索
- ❌ **不支持** 网页内容提取
- ❌ **不支持** 网页内容分析

### 2. Lobster 工作流引擎

**结论**: ✅ **强力支持**

Lobster 是 OpenClaw 的工作流引擎，支持多步骤自动化任务。

**核心功能**:
- ✅ 多步骤工作流 (typed JSON-first pipelines)
- ✅ 审批机制 (approval gates)
- ✅ 可中断和恢复 (resumable)
- ✅ 结构化输出 (JSON)

**使用方式**:
```json
{
  "action": "run",
  "pipeline": "gog.gmail.search --query 'newer_than:1d' --max 20 | email.triage"
}
```

**相关技能**:
- `llm-task` - LLM 任务处理
- `lobster` - 工作流引擎

### 3. 可用的工具集成

**结论**: ✅ **广泛支持**

通过 Lobster 的 `openclaw.invoke` 命令，可以调用各种工具：

**发现的工具**:
- `gog` - Google Workspace (Gmail, Drive, Docs, Sheets, Slides, Calendar)
- `gh` - GitHub
- `message.send` - 消息发送
- `email.triage` - 邮件分类
- `web_fetch` - Web 抓取 (疑似)
- `web_search` - Web 搜索 (疑似)

### 4. 其他相关技能

**结论**: ✅ **有限支持**

**发现的相关技能**:
- `blogwatcher` - RSS/Atom 订阅监控
- `summarize` - 内容摘要
- `gh-issues` - GitHub Issues
- `goplaces` - Google Places

---

## 🎯 针对您的需求

### 您的需求
1. 获取百度或 360 搜索页面结果
2. 筛选符合条件的网页
3. 分析网页内容
4. 汇总分析结果

### OpenClaw 支持情况

| 需求 | 支持情况 | 实现方式 |
|------|---------|---------|
| Web 搜索 | ❌ 不支持百度/360 | 可使用 `web_search` 工具（需确认） |
| 网页抓取 | ✅ 部分支持 | 使用 `browser` 模块 + Lobster |
| 内容筛选 | ✅ 支持 | 使用 Lobster 的管道功能 |
| 内容分析 | ✅ 支持 | 使用 `llm-task` + `summarize` |
| 结果汇总 | ✅ 支持 | 使用 Lobster 的 JSON 输出 |

### 推荐方案

**方案 1: 使用 Lobster + LLM Task**

```json
{
  "action": "run",
  "pipeline": "
    web_search --query '关键词' |
    llm-task --prompt '筛选符合以下条件的内容：...' |
    summarize --input '$previous.output'
  "
}
```

**方案 2: 使用 Browser 模块 + LLM**

```json
{
  "action": "run",
  "pipeline": "
    browser.open --url 'https://www.baidu.com/s?wd=关键词' |
    browser.screenshot |
    llm-task --prompt '分析这张截图中的搜索结果...'
  "
}
```

**方案 3: 使用现有工具链**

```json
{
  "action": "run",
  "pipeline": "
    web_search --query '关键词' |
    gog.gmail.search --query 'has:attachment' |
    email.triage
  "
}
```

---

## 📊 技术架构分析

### OpenClaw 的 Web 相关能力

#### 1. Browser 模块 (`src/browser/`)

**功能**:
- 浏览器自动化 (CDP)
- 截图功能
- 页面导航
- 表单填充

**限制**:
- 主要用于本地 Canvas 渲染
- 不支持跨浏览器自动化
- 不支持 Web 搜索

#### 2. Lobster 工作流引擎

**功能**:
- 多步骤工作流
- 管道操作 (`|`)
- 条件分支
- 审批机制

**示例**:
```
gog.gmail.search | email.triage | approve
```

#### 3. LLM Task 扩展

**功能**:
- JSON-only LLM 调用
- 结构化输出
- Schema 验证

**使用**:
```json
llm-task --prompt '分析以下内容...' --input '$data'
```

#### 4. 工具集成

**可用的工具**:
- `gog` - Google Workspace
- `gh` - GitHub
- `web_search` - Web 搜索 (需确认)
- `web_fetch` - Web 抓取 (需确认)

---

## 💡 建议方案

### 方案 A: 使用 Lobster + LLM (推荐)

**优势**:
- ✅ 支持复杂工作流
- ✅ 可中断和恢复
- ✅ 结构化输出
- ✅ 审批机制

**实现**:
```json
{
  "action": "run",
  "pipeline": "
    web_search --query '百度/360 搜索结果' |
    llm-task --prompt '筛选符合条件的网页' --input '$output' |
    summarize --input '$filtered'
  "
}
```

### 方案 B: 使用 Browser 模块

**优势**:
- ✅ 可截图网页
- ✅ 可执行 JavaScript

**限制**:
- ❌ 不支持 Web 搜索
- ❌ 需要手动输入 URL

**实现**:
```json
{
  "action": "run",
  "pipeline": "
    browser.open --url 'https://www.baidu.com' |
    browser.screenshot |
    llm-task --prompt '分析搜索结果' --input '$screenshot'
  "
}
```

### 方案 C: 混合方案

**优势**:
- ✅ 结合多种能力
- ✅ 灵活性强

**实现**:
```json
{
  "action": "run",
  "pipeline": "
    web_search --query '关键词' |
    llm-task --prompt '筛选内容' |
    browser.open --url '$url' |
    browser.screenshot |
    summarize
  "
}
```

---

## 🎓 总结

### OpenClaw 是否支持您的需求？

**答案**: ✅ **部分支持**

**支持的部分**:
1. ✅ 工作流自动化 (Lobster)
2. ✅ LLM 任务处理
3. ✅ 内容摘要
4. ✅ 结构化输出
5. ✅ 审批机制

**不支持的部分**:
1. ❌ 百度/360 Web 搜索
2. ✅ 网页抓取 (需要工具支持)
3. ✅ 网页内容分析 (需要 LLM)

### 推荐方案

**最佳方案**: 使用 **Lobster + LLM Task** 组合

**步骤**:
1. 使用 `web_search` 工具获取搜索结果
2. 使用 `llm-task` 筛选内容
3. 使用 `summarize` 汇总结果

**命令示例**:
```bash
openclaw agent --message '{"action":"run","pipeline":"web_search --query \"关键词\" | llm-task --prompt \"筛选\" | summarize"}'
```

### 后续建议

1. **确认工具支持**: 检查是否有 `web_search` 和 `web_fetch` 工具
2. **测试 Lobster 工作流**: 先测试简单的工作流
3. **集成 LLM**: 使用 LLM Task 处理复杂逻辑
4. **审批机制**: 对于重要操作，启用审批流程

---

**分析完成时间**: 2026-03-12 18:55
**分析人员**: 林薇
**数据来源**: OpenClaw v2026.3.11
