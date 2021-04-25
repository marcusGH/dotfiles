# Setup fzf
# ---------
if [[ ! "$PATH" == */home/marcus/GitHub/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/marcus/GitHub/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/marcus/GitHub/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/marcus/GitHub/fzf/shell/key-bindings.bash"

# Use silver searcher
export FZF_DEFAULT_COMMAND='ag -U -l --hidden --path-to-ignore ~/.ignore'

# Use nord colour scheme for FZF
export FZF_DEFAULT_OPTS='
--color=fg:#d8dee9,bg:#2E3440,hl:#81a1c1
--color=fg+:#d8dee9,bg+:#3b4252,hl+:#81a1c1
--color=info:#eacb8a,prompt:#81a1c1,pointer:#81a1c1
--color=marker:#81a1c1,spinner:#81a1c1,header:#81a1c1'
