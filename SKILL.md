---
name: xfg-zsxq
description: "知识星球自动发帖技能。当你需要向小傅哥的知识星球发布内容时使用，支持发布文字、图片、文件等类型的帖子。触发词：'知识星球'、'发帖'、'发星球'、'zsxq'、'发布到星球'、'发文章到星球'。需要配置 cookie 和签名参数。"
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

## ⚠️ 使用前配置

使用本技能前，需要配置以下参数：

### 1. Cookie 配置

从浏览器开发者工具中获取 `zsxq_access_token`：

1. 登录知识星球网页版：https://wx.zsxq.com
2. 打开浏览器开发者工具（F12）
3. 切换到 Application/Storage -> Cookies
4. 找到 `zsxq_access_token` 值

### 2. 签名生成

知识星球 API 需要 `x-signature` 和 `x-timestamp` 签名，可通过浏览器开发者工具获取：

1. 在知识星球发布一条测试帖子
2. 在 Network 中查看请求头
3. 复制 `x-signature` 和 `x-timestamp` 值

> 注意：签名有时效性，过期后需要重新获取

## Quick Reference

| 功能 | 参考文档 |
|------|---------|
| API 接口说明 | [references/api.md](references/api.md) |
| 发帖脚本使用 | [references/usage.md](references/usage.md) |
| 签名生成方法 | [references/signature.md](references/signature.md) |
| 常见问题 | [references/faq.md](references/faq.md) |

## 发帖脚本

### 快速发帖

```bash
# 使用脚本发帖
bash scripts/post.sh \
  --token "YOUR_ACCESS_TOKEN" \
  --text "今天分享一个设计模式..." \
  --images "/path/to/image1.jpg,/path/to/image2.jpg"
```

### 参数说明

| 参数 | 说明 | 必填 |
|------|------|------|
| `--token` | zsxq_access_token | 是 |
| `--text` | 帖子内容 | 是 |
| `--images` | 图片路径，多个用逗号分隔 | 否 |
| `--files` | 文件路径，多个用逗号分隔 | 否 |
| `--group` | 星球ID，默认 48885154455258 | 否 |

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
  --token "85034009-ACAB-4F23-A200-0FD488D2D520_D625BA7FD9CBBDFA" \
  --text "大家好，今天分享一个设计模式的应用案例..."
```

### 发布带图片

```bash
bash scripts/post.sh \
  --token "YOUR_TOKEN" \
  --text "项目架构图如下：" \
  --images "/Users/xxx/Desktop/arch.png"
```

### 发布代码片段

```bash
bash scripts/post.sh \
  --token "YOUR_TOKEN" \
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

## 注意事项

1. **签名时效性**：`x-signature` 和 `x-timestamp` 有过期时间，失效后需重新获取
2. **频率限制**：避免短时间内大量发帖，可能触发风控
3. **内容合规**：确保发布内容符合星球规定
4. **Token 安全**：不要将 access_token 提交到代码仓库

## 参考链接

- 知识星球网页版：https://wx.zsxq.com
- 小傅哥星球：https://t.zsxq.com/xxxxx