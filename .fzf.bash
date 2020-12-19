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
export FZF_DEFAULT_COMMAND='ag -U -l --path-to-ignore ~/.ignore'
