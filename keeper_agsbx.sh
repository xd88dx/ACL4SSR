#!/bin/bash

check_type="${1:-all}"
log_file="$(pwd)/log_agsbx.log"

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') $*" | tee -a "$log_file"
}

run_res() {
  echo >"$log_file"
  log "$1"

  output=$(bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh) res 2>&1)
  echo "$output" >>"$log_file"

  if echo "$output" | grep -q "未安装"; then
    log "检测到未安装状态，执行部署脚本..."
    "$(pwd)/deploy_agsbx.sh" >>"$log_file" 2>&1
  fi
}

# 校验参数
if [[ ! "$check_type" =~ ^(sb|all|keep)$ ]]; then
  log "无效参数: $check_type，只支持 sb、all、keep"
  exit 1
fi

# 每日重启
[[ "$check_type" == "keep" ]] && run_res "每日重启" && exit 0

# 进程检测
sb_exists=1
xray_exists=1
tunnel_exists=1

[[ "$check_type" =~ ^(sb|all)$ ]] && ps aux | grep -q "[a]gsbx/sing" && sb_exists=0
[[ "$check_type" == "all" ]] && ps aux | grep -q "[a]gsbx/xray" && xray_exists=0
[[ "$check_type" == "all" ]] && ps aux | grep -q "[a]gsbx/cloud" && tunnel_exists=0

case "$check_type" in
sb)
  [[ $sb_exists -eq 0 ]] && echo "singbox 正在运行, 退出..." && exit 0
  ;;
all)
  [[ $sb_exists -eq 0 && $xray_exists -eq 0 && $tunnel_exists -eq 0 ]] && echo "agsbx 正在运行, 退出..." && exit 0
  ;;
esac

# 持久保活
run_res "进程检测失败, 开始重启..."
