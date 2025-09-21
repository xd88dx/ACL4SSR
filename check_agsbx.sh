#!/bin/bash

ps aux | grep "agsbx/sing" | grep -v grep >/dev/null
sing_exists=$?

ps aux | grep "agsbx/cloud" | grep -v grep >/dev/null
cloud_exists=$?

if [ $cloud_exists -eq 0 ] && [ $sing_exists -eq 0 ]; then
  echo "agsbx 正在运行, 退出..."
  exit 0
fi

echo "agsbx 进程检测失败, 开始重启..."
echo "$(date +'%Y-%m-%d %H:%M:%S') agsbx 进程检测失败, 开始重启..." >"$(pwd)/log_agsbx.log" 2>&1
$(pwd)/deploy_agsbx.sh >>"$(pwd)/log_agsbx.log" 2>&1
bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh) res >>"$(pwd)/log_agsbx.log" 2>&1
