#!/bin/bash

check_type="${1:-all}"
log_file="$(pwd)/log_agsbx.log"

# 校验参数
if [[ ! "$check_type" =~ ^(sb|all)$ ]]; then
  log "无效参数: $check_type，只支持 sb、all"
  exit 1
fi

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') $*" | tee -a "$log_file"
}

# 进程检测
sing_exists=1
cloud_exists=1

[[ "$check_type" =~ ^(sb|all)$ ]] && ps aux | grep -q "[a]gsbx/sing" && sing_exists=0
[[ "$check_type" == "all" ]] && ps aux | grep -q "[a]gsbx/cloud" && cloud_exists=0

case "$check_type" in
sb)
  [[ $sing_exists -eq 0 ]] && log "singbox 正在运行, 退出..." && exit 0
  ;;
all)
  [[ $sing_exists -eq 0 && $cloud_exists -eq 0 ]] && log "agsbx 正在运行, 退出..." && exit 0
  ;;
esac

# 执行保活
echo >"$log_file"
log "进程检测失败, 开始重启..."

curl_output=$(bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh) res 2>&1)
echo "$curl_output" >>"$log_file"

if echo "$curl_output" | grep -q "未安装"; then
  log "检测到未安装状态，执行部署脚本..."
  "$(pwd)/deploy_agsbx.sh" >>"$log_file" 2>&1
fi
