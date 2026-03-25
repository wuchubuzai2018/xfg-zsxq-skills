# xfg-zsxq-skills

知识星球自动发帖技能包，支持向小傅哥的知识星球发布文字、图片等内容。

## 功能特性

- ✅ 发布纯文字帖子
- ✅ 支持 Markdown 格式
- ✅ 支持代码块
- ✅ 命令行脚本快速发帖
- 🔄 图片上传（待完善）

## 快速开始

### 1. 获取 Access Token

1. 登录 https://wx.zsxq.com
2. 按 `F12` 打开开发者工具
3. 在 **Application** → **Cookies** 中找到 `zsxq_access_token`

### 2. 发帖

```bash
bash scripts/post.sh \
  --token "YOUR_ACCESS_TOKEN" \
  --text "Hello 知识星球！"
```

### 3. 输入签名

按提示输入从浏览器获取的 `x-signature` 和 `x-timestamp`

## 文档

| 文档 | 说明 |
|------|------|
| [SKILL.md](SKILL.md) | 技能主文档 |
| [references/api.md](references/api.md) | API 接口文档 |
| [references/usage.md](references/usage.md) | 使用指南 |
| [references/signature.md](references/signature.md) | 签名获取方法 |
| [references/faq.md](references/faq.md) | 常见问题 |

## 触发词

- "知识星球"
- "发帖"
- "发星球"
- "zsxq"
- "发布到星球"

## 注意事项

1. **签名时效性**：`x-signature` 和 `x-timestamp` 会过期，需定期更新
2. **频率限制**：避免短时间内大量发帖
3. **Token 安全**：不要将 access_token 提交到代码仓库

## 参考

- 知识星球网页版：https://wx.zsxq.com
- 小傅哥星球：https://t.zsxq.com/xxxxx

## License

MIT