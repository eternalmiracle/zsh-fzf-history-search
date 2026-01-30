fzf-history-search() {
  setopt localoptions extendedglob

  FC_ARGS="-l -n"
  history_cmd="fc ${=FC_ARGS} -1 0"
  history_cmd="$history_cmd | awk '!seen[\$0]++'"

  # fzfの引数に --expect=ctrl-j を追加
  # これにより、Enterならそのまま、Ctrl-jなら1行目に "ctrl-j" と出力されるようになります
  local fzf_args=(
    #+s +m -x -e
    --reverse
    --height 40%
    #--preview-window=hidden
    --expect=ctrl-j
  )

  local result
  if (( $#BUFFER )); then
    result=("${(f)$(eval $history_cmd | fzf "${fzf_args[@]}" -q "$BUFFER")}")
  else
    result=("${(f)$(eval $history_cmd | fzf "${fzf_args[@]}")}")
  fi

  # fzfがキャンセルされた（Escなど）場合は何もしない
  local ret=$?
  if [ -z "$result" ]; then
    zle reset-prompt
    return $ret
  fi

  # 1行目が押されたキー、2行目以降が選択された中身
  local key=$result[1]
  local candidate=$result[2]

  if [ -n "$candidate" ]; then
    BUFFER="$candidate"
    CURSOR=$#BUFFER

    # キーが空（Enter）の場合のみ即実行
    if [ -z "$key" ]; then
      zle accept-line
    else
      # カーソルを行末に移動させる
      zle end-of-line
    fi
  fi

  zle reset-prompt
  return $ret
}

zle -N fzf-history-search
bindkey '^r' fzf-history-search

