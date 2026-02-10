fzf-history-search() {
  setopt localoptions extendedglob

  FC_ARGS="-l -n"
  history_cmd="fc ${=FC_ARGS} -1 0"
  history_cmd="$history_cmd | awk '!seen[\$0]++'"

  local fzf_opts="${ZSH_FZF_HISTORY_SEARCH_FZF_OPTS:=--reverse --height 40%}"
  local expect_key="${ZSH_FZF_HISTORY_SEARCH_EXPECT_KEY:=ctrl-j}"

  local result
  if (( $#BUFFER )); then
    result=("${(f)$(eval $history_cmd | fzf ${=fzf_opts} --expect=$expect_key -q "$BUFFER")}")
  else
    result=("${(f)$(eval $history_cmd | fzf ${=fzf_opts} --expect=$expect_key)}")
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

