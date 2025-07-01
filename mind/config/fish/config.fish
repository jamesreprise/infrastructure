if status is-interactive
    # Interactive-only goes here
    fish_default_key_bindings

    # Show full directory path
    set -U fish_prompt_pwd_dir_length 0

    # Git prompt
    set -g __fish_git_prompt_showcolorhints true
    set -g __fish_git_prompt_showdirtystate true
    set -g __fish_git_prompt_showuntrackedfiles true

    # FZF fish bindings
    fzf --fish | source

    # Aliases
    alias vi "nvim"
    alias vim "nvim"
    alias nano "ls"
end

# Disable welcome message
set fish_greeting

# Add homebrew to PATH
fish_add_path /opt/homebrew/bin

# GPG signing for git
set -x GPG_TTY (tty)

set PATH "/usr/bin:$PATH"
