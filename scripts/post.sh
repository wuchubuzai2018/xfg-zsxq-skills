#!/bin/bash

# 知识星球发帖脚本
# 使用方法: bash post.sh --text "内容" [--token "TOKEN"]
# 首次使用需要提供 --token，之后自动读取 ~/.xfg-zsxq/config

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置文件路径
CONFIG_DIR="${HOME}/.xfg-zsxq"
CONFIG_FILE="${CONFIG_DIR}/config"

# 默认配置
GROUP_ID="48885154455258"
API_URL="https://api.zsxq.com/v2/groups/${GROUP_ID}/topics"

# 参数解析
TOKEN=""
TEXT=""
IMAGES=""
FILES=""
SAVE_TOKEN=false

# 显示帮助
show_help() {
    cat << EOF
知识星球发帖脚本

使用方法:
    bash post.sh --text "帖子内容" [选项]

必填参数:
    --text      帖子内容

可选参数:
    --token     zsxq_access_token (首次使用或更新时提供)
    --images    图片路径，多个用逗号分隔
    --files     文件路径，多个用逗号分隔
    --group     星球ID (默认: 48885154455258)
    --help      显示帮助

Token 管理:
    首次使用: 提供 --token 参数，会自动保存到 ~/.xfg-zsxq/config
    后续使用: 无需提供 --token，自动读取本地配置
    更新 Token: 提供新的 --token 参数，会覆盖本地配置

示例:
    # 首次使用（需要提供 token）
    bash post.sh --token "xxx" --text "大家好"

    # 后续使用（自动读取本地 token）
    bash post.sh --text "大家好"

    # 更新 token
    bash post.sh --token "new_token" --text "测试"

    # 发布带图片
    bash post.sh --text "看图" --images "/path/img.jpg"
EOF
}

# 加载本地配置
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        if [[ -n "$ZSXQ_ACCESS_TOKEN" ]]; then
            TOKEN="$ZSXQ_ACCESS_TOKEN"
            echo -e "${BLUE}✓ 已从本地配置读取 token${NC}"
        fi
        if [[ -n "$ZSXQ_GROUP_ID" ]]; then
            GROUP_ID="$ZSXQ_GROUP_ID"
            API_URL="https://api.zsxq.com/v2/groups/${GROUP_ID}/topics"
        fi
    fi
}

# 保存配置到本地
save_config() {
    if [[ "$SAVE_TOKEN" == true && -n "$TOKEN" ]]; then
        mkdir -p "$CONFIG_DIR"
        cat > "$CONFIG_FILE" << EOF
# 知识星球配置
# 生成时间: $(date)
ZSXQ_ACCESS_TOKEN=${TOKEN}
ZSXQ_GROUP_ID=${GROUP_ID}
EOF
        # 设置权限，仅所有者可读写
        chmod 600 "$CONFIG_FILE"
        echo -e "${GREEN}✓ Token 已保存到 ${CONFIG_FILE}${NC}"
        echo -e "${YELLOW}  配置文件权限已设置为 600（仅所有者可读写）${NC}"
    fi
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --token)
            TOKEN="$2"
            SAVE_TOKEN=true
            shift 2
            ;;
        --text)
            TEXT="$2"
            shift 2
            ;;
        --images)
            IMAGES="$2"
            shift 2
            ;;
        --files)
            FILES="$2"
            shift 2
            ;;
        --group)
            GROUP_ID="$2"
            API_URL="https://api.zsxq.com/v2/groups/${GROUP_ID}/topics"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 加载本地配置（如果用户没有提供 --token）
if [[ -z "$TOKEN" ]]; then
    load_config
fi

# 验证必填参数
if [[ -z "$TOKEN" ]]; then
    echo -e "${RED}错误: 未找到 access_token${NC}"
    echo ""
    echo "首次使用需要提供 --token 参数，例如："
    echo "  bash post.sh --token \"YOUR_TOKEN\" --text \"内容\""
    echo ""
    echo "获取 token 方法："
    echo "  1. 登录 https://wx.zsxq.com"
    echo "  2. 按 F12 打开开发者工具 → Application → Cookies"
    echo "  3. 复制 zsxq_access_token 的值"
    exit 1
fi

if [[ -z "$TEXT" ]]; then
    echo -e "${RED}错误: 缺少 --text 参数${NC}"
    exit 1
fi

# 保存 token 到本地配置
save_config

# 生成请求ID
REQUEST_ID=$(uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || echo "$(date +%s)-$$")

# 获取签名（需要用户手动输入或从浏览器获取）
echo ""
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}  签名获取步骤：${NC}"
echo -e "${YELLOW}  1. 打开 https://wx.zsxq.com${NC}"
echo -e "${YELLOW}  2. 按 F12 → Network 标签${NC}"
echo -e "${YELLOW}  3. 发布一条测试帖子${NC}"
echo -e "${YELLOW}  4. 复制请求头中的 x-signature 和 x-timestamp${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo ""

echo -n "请输入 x-signature: "
read -r SIGNATURE

echo -n "请输入 x-timestamp: "
read -r TIMESTAMP

if [[ -z "$SIGNATURE" || -z "$TIMESTAMP" ]]; then
    echo -e "${RED}错误: 签名和时间为必填项${NC}"
    exit 1
fi

# 处理图片上传
IMAGE_IDS="[]"
if [[ -n "$IMAGES" ]]; then
    echo -e "${YELLOW}上传图片中...${NC}"
    echo -e "${YELLOW}注意: 图片上传功能需要额外实现${NC}"
fi

# 构建请求体
# 转义特殊字符
TEXT_ESCAPED=$(echo "$TEXT" | sed 's/"/\\"/g' | sed 's/\n/\\n/g')

REQUEST_BODY=$(cat << EOF
{
  "req_data": {
    "type": "topic",
    "text": "${TEXT_ESCAPED}",
    "image_ids": ${IMAGE_IDS},
    "file_ids": [],
    "mentioned_user_ids": []
  }
}
EOF
)

echo ""
echo -e "${YELLOW}正在发帖...${NC}"

# 发送请求
RESPONSE=$(curl -s -X POST "${API_URL}" \
    -H "accept: application/json, text/plain, */*" \
    -H "accept-language: zh-CN,zh;q=0.9" \
    -H "content-type: application/json" \
    -H "origin: https://wx.zsxq.com" \
    -H "referer: https://wx.zsxq.com/" \
    -H "x-request-id: ${REQUEST_ID}" \
    -H "x-signature: ${SIGNATURE}" \
    -H "x-timestamp: ${TIMESTAMP}" \
    -H "x-version: 2.89.0" \
    -b "zsxq_access_token=${TOKEN}" \
    --data-raw "${REQUEST_BODY}" 2>&1)

# 检查响应
if echo "$RESPONSE" | grep -q '"succeeded":true'; then
    echo -e "${GREEN}✅ 发帖成功！${NC}"
    TOPIC_ID=$(echo "$RESPONSE" | grep -o '"topic_id":[0-9]*' | cut -d':' -f2)
    echo -e "${GREEN}帖子ID: ${TOPIC_ID}${NC}"
else
    echo -e "${RED}❌ 发帖失败${NC}"
    echo ""
    echo "响应: $RESPONSE"
    echo ""
    
    if echo "$RESPONSE" | grep -q '401'; then
        echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  Token 已过期或无效                            ║${NC}"
        echo -e "${RED}╠════════════════════════════════════════════════╣${NC}"
        echo -e "${RED}║  请重新获取 zsxq_access_token：               ║${NC}"
        echo -e "${RED}║  1. 访问 https://wx.zsxq.com                  ║${NC}"
        echo -e "${RED}║  2. 按 F12 → Application → Cookies            ║${NC}"
        echo -e "${RED}║  3. 复制新的 zsxq_access_token                ║${NC}"
        echo -e "${RED}║  4. 重新运行脚本并提供 --token 参数           ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "示例: bash post.sh --token \"NEW_TOKEN\" --text \"内容\""
    elif echo "$RESPONSE" | grep -q '429'; then
        echo -e "${RED}请求过于频繁，请稍后再试${NC}"
    fi
    exit 1
fi