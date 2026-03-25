---
name: xfg-zsxq
description: "知识星球自动发帖技能。当你需要向小傅哥的知识星球发布内容时使用，支持发布文字、图片、文件等类型的帖子。触发词：'知识星球'、'发帖'、'发星球'、'zsxq'、'发布到星球'、'发文章到星球'。首次使用需要提供 access_token，之后自动读取本地存储的 token，过期后提醒用户更新。"
author: xiaofuge
license: MIT
triggers:
  - "知识星球"
  - "发帖"
  - "发星球"
  - "zsxq"
  - "发布到星球"
  - "发文章到星球"
  - "发内容到星球"
metadata:
  openclaw:
    emoji: "📝"
---

# 知识星球发帖技能

自动向小傅哥的知识星球发布内容，支持文字、图片、文件等多种格式。

## ⚠️ Token 管理

### 首次使用

**首次使用时，必须提供 `access_token`**：

1. 登录知识星球网页版：https://wx.zsxq.com
2. 按 `F12` 打开开发者工具 → Application → Cookies
3. 找到 `zsxq_access_token`，复制值
4. 提供给技能，会自动保存到本地文件 `~/.xfg-zsxq/config`

### 后续使用

- **自动读取**：技能会自动从 `~/.xfg-zsxq/config` 读取已保存的 token
- **无需重复输入**：一次配置，多次使用

### Token 过期处理

如果提示 **"Token 已过期"**：
1. 重新登录 https://wx.zsxq.com
2. 获取新的 `zsxq_access_token`
3. 提供给技能更新本地配置

---

## Quick Reference

| 功能 | 参考文档 |
|------|---------|
| API 接口说明 | [references/api.md](references/api.md) |
| 发帖脚本使用 | [references/usage.md](references/usage.md) |
| 签名生成方法 | [references/signature.md](references/signature.md) |
| 常见问题 | [references/faq.md](references/faq.md) |
| Token 配置 | [references/token-config.md](references/token-config.md) |

## 发帖脚本

### 快速发帖

```bash
# 首次使用（需要提供 token）
bash scripts/post.sh \
  --text "今天分享一个设计模式..."

# 后续使用（自动读取本地 token）
bash scripts/post.sh \
  --text "今天分享一个设计模式..."

# 手动指定 token（覆盖本地配置）
bash scripts/post.sh \
  --token "YOUR_ACCESS_TOKEN" \
  --text "今天分享一个设计模式..."
```

### 参数说明

| 参数 | 说明 | 必填 |
|------|------|------|
| `--text` | 帖子内容 | 是 |
| `--token` | zsxq_access_token（首次使用或更新时提供） | 否（自动读取本地配置） |
| `--images` | 图片路径，多个用逗号分隔 | 否 |
| `--files` | 文件路径，多个用逗号分隔 | 否 |
| `--group` | 星球ID，默认 48885154455258 | 否 |

## Token 配置文件

本地配置文件位置：`~/.xfg-zsxq/config`

格式：
```
ZSXQ_ACCESS_TOKEN=your_token_here
ZSXQ_GROUP_ID=48885154455258
```

**安全提示**：
- 配置文件权限设置为 600（仅所有者可读写）
- 不要将配置文件提交到代码仓库
- 已添加到 `.gitignore`

## API 接口

### 发布帖子

**URL**: `POST https://api.zsxq.com/v2/groups/{group_id}/topics`

**Headers**:
```
content-type: application/json
x-request-id: {uuid}
x-signature: {signature}
x-timestamp: {timestamp}
x-version: 2.89.0
Cookie: zsxq_access_token={token}
```

**Body**:
```json
{
  "req_data": {
    "type": "topic",
    "text": "帖子内容",
    "image_ids": [],
    "file_ids": [],
    "mentioned_user_ids": []
  }
}
```

## 使用示例

### 发布纯文字

```bash
bash scripts/post.sh \
  --text "大家好，今天分享一个设计模式的应用案例..."
```

### 发布带图片

```bash
bash scripts/post.sh \
  --text "项目架构图如下：" \
  --images "/Users/xxx/Desktop/arch.png"
```

### 发布代码片段

```bash
bash scripts/post.sh \
  --text '```java
public class Singleton {
    private static Singleton instance;
    private Singleton() {}
    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}
```'
```

### 更新 Token

```bash
bash scripts/post.sh \
  --token "NEW_ACCESS_TOKEN" \
  --text "测试新 token"
```

## 注意事项

1. **Token 自动保存**：首次提供的 token 会自动保存到本地配置文件
2. **签名时效性**：`x-signature` 和 `x-timestamp` 有过期时间，失效后需重新获取
3. **频率限制**：避免短时间内大量发帖，可能触发风控
4. **内容合规**：确保发布内容符合星球规定
5. **Token 安全**：本地配置文件已设置权限保护，请勿手动分享

## 参考链接

- 知识星球网页版：https://wx.zsxq.com
- 小傅哥星球：https://t.zsxq.com/xxxxx