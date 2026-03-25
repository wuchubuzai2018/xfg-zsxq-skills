# xfg-zsxq-skills

知识星球自动发帖技能包，支持向小傅哥的知识星球发布文字、图片等内容。

## 功能特性

- ✅ 发布纯文字帖子
- ✅ 支持 Markdown 格式
- ✅ 支持代码块
- ✅ **Token 自动保存和读取**
- ✅ **Token 过期自动提醒**
- 🔄 图片上传（待完善）

## 快速开始

### 1. 首次使用（配置 Token）

1. 登录 https://wx.zsxq.com
2. 按 `F12` 打开开发者工具 → Application → Cookies
3. 找到 `zsxq_access_token`，复制值
4. 运行脚本并提供 token：

```bash
bash scripts/post.sh \
  --token "YOUR_ACCESS_TOKEN" \
  --text "Hello 知识星球！"
```

Token 会自动保存到 `~/.xfg-zsxq/config`

### 2. 后续使用（自动读取 Token）

```bash
bash scripts/post.sh --text "今天分享一个设计模式..."
```

### 3. Token 过期处理

如果提示 "Token 已过期"：
1. 重新登录 https://wx.zsxq.com
2. 获取新的 `zsxq_access_token`
3. 运行脚本并提供新的 `--token`，会自动更新本地配置

## 文档

| 文档 | 说明 |
|------|------|
| [SKILL.md](SKILL.md) | 技能主文档 |
| [references/api.md](references/api.md) | API 接口文档 |
| [references/usage.md](references/usage.md) | 使用指南 |
| [references/signature.md](references/signature.md) | 签名获取方法 |
| [references/faq.md](references/faq.md) | 常见问题 |
| [references/token-config.md](references/token-config.md) | Token 配置说明 |

## 触发词

- "知识星球"
- "发帖"
- "发星球"
- "zsxq"
- "发布到星球"

## Token 管理

- **自动保存**：首次提供的 token 自动保存到 `~/.xfg-zsxq/config`
- **自动读取**：后续使用自动读取本地配置
- **过期提醒**：Token 过期时自动提示用户更新
- **安全存储**：配置文件权限 600，仅所有者可读写

## 注意事项

1. **Token 安全**：不要将 access_token 提交到代码仓库
2. **签名时效性**：`x-signature` 和 `x-timestamp` 有过期时间
3. **频率限制**：避免短时间内大量发帖

## 参考

- 知识星球网页版：https://wx.zsxq.com
- 小傅哥星球：https://t.zsxq.com/xxxxx

## License

MIT