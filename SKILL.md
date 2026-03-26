---
name: xfg-zsxq-skills
version: 2.1.0
description: "知识星球自动化技能。支持发帖、回帖、浏览帖子、检查通知、自动回帖、自动发帖。自动读取 ~/.xfg-zsxq/groups.json 配置。支持定时任务自动检查通知和被圈提醒。触发词：'知识星球'、'发帖'、'回帖'、'zsxq'、'检查通知'、'浏览帖子'、'回帖'、'自动回帖'、'设置定时任务'。"
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
curl -X GET "https://api.zsxq.com/v2/hashtags/{hashtag_id}/topics?count=10" \
  -H "cookie: $COOKIE"

# 查看帖子评论
curl -X GET "https://api.zsxq.com/v2/topics/{topic_id}/comments" \
  -H "cookie: $COOKIE"
```

## 💬 回帖

```bash
# 回复帖子
curl -X POST "https://api.zsxq.com/v2/topics/{topic_id}/comments" \
  -H "content-type: application/json" \
  -H "cookie: $COOKIE" \
  -d '{"req_data":{"text":"我的回复内容","image_ids":[],"mentioned_user_ids":[]}}'
```

## 👤 圈人回帖

```bash
# 圈人回帖（提及用户）
curl -X POST "https://api.zsxq.com/v2/topics/{topic_id}/comments" \
  -H "content-type: application/json" \
  -H "cookie: $COOKIE" \
  -d '{"req_data":{"text":"<e type=\"mention\" uid=\"用户ID\" title=\"@用户名\" /> 回复内容","image_ids":[],"mentioned_user_ids":[用户ID]}}'
```

## 🔔 检查通知

```bash
# 获取动态（通知、被圈提醒）
curl -X GET "https://api.zsxq.com/v2/dynamics?scope=all&count=30" \
  -H "cookie: $COOKIE"
```

---

# 🤖 自动化功能

## 自动检查通知脚本

当需要自动检查通知时，使用 `scripts/zsxq-auto-check.js` 脚本：

```bash
# 检查最新动态
cd /Users/fuzhengwei/Documents/project/xfg-zsxq-skills/scripts
node zsxq-auto-check.js
```

**功能**：
- 检查新帖子、评论、被圈提醒
- 格式化输出通知列表
- 支持过滤只看 mentions（被圈）

## 设置定时任务

当用户说"设置定时任务"、"开启自动检查"、"启动通知监控"时，创建 cron 任务：

```javascript
// 每30分钟检查一次通知
{
  "name": "知识星球通知检查",
  "schedule": { "kind": "every", "everyMs": 1800000 },
  "payload": {
    "kind": "agentTurn",
    "message": "请执行知识星球通知检查：\n1. 运行 zsxq-auto-check.js 检查最新动态\n2. 如果有新的被圈提醒，整理后回复给我\n3. 如果有用户提问，可以考虑自动回帖帮助\n4. 检查完成后汇报结果"
  },
  "sessionTarget": "isolated",
  "enabled": true
}
```

---

# 📁 API 接口速查

| 功能 | 接口 | 方法 |
|------|------|------|
| 发帖 | `/v2/groups/{group_id}/topics` | POST |
| 浏览最新帖子 | `/v2/hashtags/{hashtag_id}/topics` | GET |
| 查看帖子评论 | `/v2/topics/{topic_id}/comments` | GET |
| 回复帖子 | `/v2/topics/{topic_id}/comments` | POST |
| 获取动态/通知 | `/v2/dynamics?scope=all` | GET |
| 获取相关动态 | `/v2/dynamics?scope=related` | GET |
| 获取星球信息 | `/v2/groups/{group_id}` | GET |

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

# 参考

- 知识星球网页版：https://wx.zsxq.com
- 配置文件：`~/.xfg-zsxq/groups.json`
- 脚本目录：`/Users/fuzhengwei/Documents/project/xfg-zsxq-skills/scripts`
