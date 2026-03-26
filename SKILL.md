---
name: xfg-zsxq-skills
version: 2.2.0
description: "知识星球自动化技能。支持发帖、回帖、浏览帖子、检查通知、自动回帖、自动发帖。自动读取 ~/.xfg-zsxq/groups.json 配置。支持定时任务自动检查通知和被圈提醒。回复功能使用浏览器自动化（Playwright MCP）。触发词：'知识星球'、'发帖'、'回帖'、'zsxq'、'检查通知'、'浏览帖子'、'回复帖子'、'自动回帖'、'设置定时任务'。"
author: xiaofuge
license: MIT
triggers:
  - "知识星球"
  - "发帖"
  - "回帖"
  - "zsxq"
  - "发布到星球"
  - "检查通知"
  - "浏览帖子"
  - "回复帖子"
  - "自动回帖"
  - "设置定时任务"
  - "被圈提醒"
  - "星球动态"
  - "圈人"
  - "通知"
metadata:
  openclaw:
    emoji: "📝"
---

# 知识星球自动化技能

支持发帖、回帖、浏览帖子、检查通知、自动回帖等完整功能。

## ⚡ 自动配置（推荐）

配置文件位置：`~/.xfg-zsxq/groups.json`

**首次配置（只需一次）：**

```bash
cd /Users/fuzhengwei/Documents/project/xfg-zsxq-skills/scripts
node zsxq.js config add --url "https://wx.zsxq.com/group/星球ID" --cookie "你的cookie"
```

## 📝 快速发帖

```bash
cd /Users/fuzhengwei/Documents/project/xfg-zsxq-skills/scripts

# 简单发帖
node zsxq.js post --text "今天分享一个设计模式..."

# 带图片
node zsxq.js post --text "内容" --images "/path/a.jpg,b.png"

# 从文件读取
node zsxq.js post --file "/tmp/post.txt"
```

## 📖 浏览帖子

```bash
# 查看最新帖子
curl -X GET "https://api.zsxq.com/v2/groups/{group_id}/topics?count=10" \
  -H "cookie: $COOKIE"
```

## 💬 回复帖子（浏览器自动化）

回复功能使用浏览器自动化，需要 OpenClaw 的 Playwright MCP 支持：

1. 确保浏览器已启动：`browser start`
2. 打开星球页面：`browser open "https://wx.zsxq.com/group/{group_id}"`
3. 定位到帖子，点击"评论"按钮
4. 在输入框输入内容
5. 点击"评论"按钮发送

**或者使用脚本自动化：**

```bash
cd /Users/fuzhengwei/Documents/project/xfg-zsxq-skills/scripts
node zsxq-auto-reply.js --topic-id <帖子ID> --text "回复内容"
```

## 👤 圈人回帖

在回复内容中使用 `@用户` 格式，浏览器会自动识别：

```
@KungFu_Sta* 欢迎！🎉 我是糊糊-小龙虾，OpenClaw AI 助手！
```

## 🔔 检查通知

```bash
cd /Users/fuzhengwei/Documents/project/xfg-zsxq-skills/scripts
node zsxq-auto-check.js
```

---

# 🤖 自动化功能

## 自动检查通知脚本

使用 `scripts/zsxq-auto-check.js` 脚本：

```bash
node zsxq-auto-check.js --scope all --count 30
```

**功能**：
- 检查新帖子、评论、被圈提醒
- 格式化输出通知列表
- 支持过滤 `--scope related`（与我相关）

## 自动回复脚本

使用 `scripts/zsxq-auto-reply.js` 脚本（浏览器自动化）：

```bash
# 回复指定帖子
node zsxq-auto-reply.js --topic-id 22811424285551840 --text "欢迎！"

# 回复并圈人
node zsxq-auto-reply.js --topic-id <ID> --text "@用户名 内容" --mention 用户ID
```

## 设置定时任务

当用户说"设置定时任务"、"开启自动检查"时，创建 cron 任务：

```bash
# 使用 cron 工具创建每30分钟检查一次的任务
openclaw cron add --name "知识星球通知检查" --every 1800000 --target isolated --message "检查通知..."
```

---

# 📁 API 接口速查

| 功能 | 接口 | 方法 | 状态 |
|------|------|------|------|
| 发帖 | `/v2/groups/{group_id}/topics` | POST | ✅ 正常 |
| 浏览帖子 | `/v2/groups/{group_id}/topics` | GET | ✅ 正常 |
| 回复帖子 | `/v2/topics/{topic_id}/comments` | POST | ⚠️ API限制 |
| 获取动态 | `/v2/dynamics?scope=all` | GET | ✅ 正常 |
| 获取相关动态 | `/v2/dynamics?scope=related` | GET | ✅ 正常 |

> ⚠️ **注意**：回复帖子的 API (`/v2/topics/{topic_id}/comments` POST) 返回"数据待初始化"错误。建议使用浏览器自动化方式回复。

---

# 🔧 签名算法

知识星球 API 需要签名验证：

```
x-timestamp = Unix时间戳（秒）
x-signature = SHA1(x-timestamp + MD5(request_body))
x-request-id = UUID
x-version = 2.89.0
```

---

# 🔐 Cookie 配置

确保 Cookie 包含以下关键字段：

```json
{
  "default": "星球名称",
  "groups": {
    "星球名称": {
      "groupId": "星球ID",
      "cookie": "sajssdk_2015_cross_new_user=1; zsxq_access_token=xxx; sensorsdata2015jssdkcross=xxx; abtest_env=product",
      "url": "https://wx.zsxq.com/group/星球ID"
    }
  }
}
```

---

# 🛠️ 浏览器自动化回复流程

当 API 回复不可用时，使用浏览器自动化：

1. **启动浏览器**
   ```javascript
   browser action=start
   ```

2. **打开星球页面**
   ```javascript
   exec command="open 'https://wx.zsxq.com/group/星球ID'"
   ```

3. **获取页面快照找到评论按钮**
   ```javascript
   browser action=snapshot target=host refs=aria
   ```

4. **点击评论按钮**
   ```javascript
   browser action=act target=host ref=e1262 kind=click
   ```

5. **输入回复内容**
   ```javascript
   browser action=act target=host ref=e1971 kind=type text="回复内容"
   ```

6. **点击发送按钮**
   ```javascript
   browser action=act target=host ref=e1976 kind=click
   ```

---

# 参考

- 知识星球网页版：https://wx.zsxq.com
- 配置文件：`~/.xfg-zsxq/groups.json`
- 脚本目录：`/Users/fuzhengwei/Documents/project/xfg-zsxq-skills/scripts`
