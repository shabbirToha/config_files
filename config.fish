# ============================
#     General Configuration
# ============================

# Disable default fish greeting
set -g fish_greeting

# Starship prompt
if type -q starship
    starship init fish | source
end

# fzf integration
if type -q fzf
    fzf --fish | source
end

# Pager + autosuggestion style
set fish_pager_color_prefix cyan
set fish_color_autosuggestion brblue

# ============================
#     Aliases & Shortcuts
# ============================

# Directory listings (eza)
alias l='eza -lh  --icons=auto'
alias ls='eza -1   --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'

alias vc='code'
alias c='clear'
alias x='exit'

# Git aliases
alias gs='git status'
alias gc='git commit -m'
alias ga='git add'
alias gaa='git add .'
alias gl='git log --oneline'

# ============================
#     Abbreviations (abbr)
# ============================

# Handy directory jumps
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# mkdir with -p by default
abbr mkdir 'mkdir -p'

# ============================
#     Zoxide Integration
# ============================

# Initialize zoxide
if type -q zoxide
    zoxide init fish | source
end

# Replace cd with zoxide-powered cd
function cd
    if test (count $argv) -eq 0
        z
    else
        z $argv
    end
end

# fzf-powered interactive directory jump (zi)
if type -q fzf
    function zi
        set dir (zoxide query --interactive)
        if test -n "$dir"
            cd "$dir"
        end
    end
end

# Optional: Keybinding for fast interactive cd (Ctrl+o)
# if type -q fzf
#     bind \co 'zi'
# end

# ============================
#     File Opener (fzf + bat)
# ============================

if type -q fzf
    function fo
        # Fuzzy search file + preview with bat
        set file (fzf --preview "bat --color=always --style=plain --line-range=1:200 {}")
        if test -n "$file"
            if set -q EDITOR
                $EDITOR "$file"
            else
                nano "$file"
            end
        end
    end
end

# Optional: Keybinding (Ctrl+f) to trigger file opener
# bind \cf 'fo'

# ============================
#     zf — find + fzf + zoxide jump
# ============================

function zf
    # Prefer fd, fallback to find
    if type -q fd
        set target (fd --type d --hidden --exclude .git .)
    else
        set target (find . -type d 2> /dev/null)
    end

    if test (count $target) -eq 0
        echo "No directories found."
        return 1
    end

    # Pick directory using fzf
    set dir (printf '%s\n' $target | fzf --height 40% --reverse --prompt="Find dir > ")

    # If no selection, exit
    if test -z "$dir"
        return 0
    end

    # Normalize path (remove leading ./)
    set dir (string replace -r '^./' '' "$dir")

    # Jump using zoxide (updates ranking)
    if type -q zoxide
        zoxide add "$dir"
        z "$dir"
    else
        cd "$dir"
    end
end
