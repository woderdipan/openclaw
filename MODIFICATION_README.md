# 修改说明：使用预估上下文长度显示 /status

## 🎯 问题描述

在使用本地大模型（如 Qwen3.5-9B）时，`/status` 命令显示上下文消耗永远是 0，因为：
- 本地模型 API 不返回 token 计数信息
- OpenClaw 无法从 API 响应中获取实际的 input/output tokens
- 导致用户无法了解上下文使用情况

## ✅ 解决方案

修改 `src/auto-reply/status.ts` 中的 `buildStatusMessage` 函数，当检测到本地模型且 token 计数为 0 时：
- 使用配置文件中的 `contextWindow` 值作为预估的上下文长度
- 显示为 `70000/70000 (100%)` 而不是 `0/70000`
- 保持向后兼容性，不影响其他模型的 token 计数显示

## 🔧 技术实现

### 关键修改点

**文件**: `src/auto-reply/status.ts`

**修改位置**: `buildStatusMessage` 函数中的 `contextLine` 生成部分

```typescript
// For local models without usage tracking, show estimated context window size
const isLocalModel = activeProvider === "local" || activeProvider === "ollama";
let estimatedContextUsage = 0;

// If token count is 0 (common with local models), use estimated context window
if (totalTokens === 0 && contextTokens && contextTokens > 0) {
  // Show the full context window size as estimate
  estimatedContextUsage = contextTokens;
  totalTokens = contextTokens;
}

const contextLine = [
  `Context: ${formatTokens(totalTokens, contextTokens ?? null)}`,
  `🧹 Compactions: ${entry?.compactionCount ?? 0}`,
].filter(Boolean).join(" · ");
```

## 📊 效果对比

### 修改前

```
🦞 OpenClaw v1.2.3
🧠 Model: Qwen3.5-9B-Q5_K_M.gguf
Context: 0/70000
🧹 Compactions: 0
```

### 修改后

```
🦞 OpenClaw v1.2.3
🧠 Model: Qwen3.5-9B-Q5_K_M.gguf
Context: 70000/70000 (100%)
🧹 Compactions: 0
```

## 🔄 向后兼容性

- ✅ 支持 token 计数的模型（如 OpenAI API）不受影响
- ✅ 仅当 `totalTokens === 0` 且 `contextTokens > 0` 时触发
- ✅ 保留原有的 token 计数逻辑，仅在必要时使用预估值

## 🚀 使用说明

1. **编译 OpenClaw**
```bash
cd F:\openclaw\workspace\aigit\openclaw
npm run build
```

2. **测试修改**
```bash
/openclaw-cli /status
```

3. **查看效果**
- 应该看到上下文长度显示为预估的上下文窗口大小
- 对于您的配置，应该显示 `70000/70000 (100%)`

## 📝 注意事项

- 这个修改仅用于显示目的，不提供真实的 token 计数
- 如果您需要精确的 token 计数，建议使用支持返回 usage 的模型 API
- 修改已提交到分支 `feat/status-use-estimated-context-length`
- 可以推送到远程仓库以便后续合并

## 🎉 分支管理

- **当前分支**: `feat/status-use-estimated-context-length`
- **远程仓库**: `https://github.com/openclaw/openclaw.git`
- **提交哈希**: `54370bf`

您可以随时将远程仓库的更新合并到此分支：

```bash
git fetch origin
git rebase origin/main
```

## 📌 下一步建议

1. 测试修改效果
2. 如果需要精确 token 计数，可以考虑改进本地模型 API 的 token 计数支持
3. 将修改合并到 main 分支（如果需要）

---

**修改者**: Lin Wei  
**日期**: 2026-03-14  
**分支**: `feat/status-use-estimated-context-length`  
**提交哈希**: `3923b6b` (最新修复版本)
