#!/bin/bash

# 知识星球发帖脚本
# 使用方法: bash post.sh --token "TOKEN" --text "内容" [--images "path1,path2"]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认配置
GROUP_ID="48885154455258"
API_URL="https://api.zsxq.com/v2/groups/${GROUP_ID}/topics"

# 参数解析
TOKEN=""
TEXT=""
IMAGES=""
FILES=""

# 显示帮助
show_help() {
    cat << EOF
知识星球发帖脚本

使用方法:
    bash post.sh --token "YOUR_TOKEN" --text "帖子内容" [选项]

必填参数:
    --token     zsxq_access_token (从浏览器 Cookie 获取)
    --text      帖子内容

可选参数:
    --images    图片路径，多个用逗号分隔
    --files     文件路径，多个用逗号分隔
    --group     星球ID (默认: 48885154455258)
    --help      显示帮助

示例:
    # 发布纯文字
    bash post.sh --token "xxx" --text "大家好"

    # 发布带图片
    bash post.sh --token "xxx" --text "看图" --images "/path/img.jpg"

    # 发布代码
    bash post.sh --token "xxx" --text '\`\`\`java\nSystem.out.println("Hello");\n\`\`\`'
EOF
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --token)
            TOKEN="$2"
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

# 验证必填参数
if [[ -z "$TOKEN" ]]; then
    echo -e "${RED}错误: 缺少 --token 参数${NC}"
    echo "请从浏览器 Cookie 中获取 zsxq_access_token"
    exit 1
fi

if [[ -z "$TEXT" ]]; then
    echo -e "${RED}错误: 缺少 --text 参数${NC}"
    exit 1
fi

# 生成请求ID
REQUEST_ID=$(uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || echo "$(date +%s)-$$")

# 获取签名（需要用户手动输入或从浏览器获取）
echo -e "${YELLOW}提示: 签名有时效性，请从浏览器开发者工具获取${NC}"
echo -n "请输入 x-signature: "
read -r SIGNATURE

echo -n "请输入 x-timestamp: "
read -r TIMESTAMP

if [[ -z "$SIGNATURE" || -z "$TIMESTAMP" ]]; then
    echo -e "${RED}错误: 签名和时间为必填项${NC}"
    echo "请在知识星球网页版发布一条帖子，从 Network 中复制 x-signature 和 x-timestamp"
    exit 1
fi

# 处理图片上传
IMAGE_IDS="[]"
if [[ -n "$IMAGES" ]]; then
    echo -e "${YELLOW}上传图片中...${NC}"
    # TODO: 实现图片上传逻辑
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
    echo "响应: $RESPONSE"
    
    if echo "$RESPONSE" | grep -q '401'; then
        echo -e "${RED}Token 已过期，请重新获取 zsxq_access_token${NC}"
    elif echo "$RESPONSE" | grep -q '429'; then
        echo -e "${RED}请求过于频繁，请稍后再试${NC}"
    fi
    exit 1
fi