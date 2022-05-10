# My zsh config.
#  ______ _____  _   _
# |___  //  ___|| | | |
#    / / \ `--. | |_| |
#   / /   `--. \|  _  |
# ./ /___/\__/ /| | | |
# \_____/\____/ \_| |_/

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH:$HOME/.local/bin

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="lambda"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=28

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

### Homebrew ###
# FIXME: should be macOS only
if [[ "$OSTYPE" == "darwin"* ]]; then

  if [ -d "/opt/homebrew" ]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  fi

  # Homebrew on Intel Mac
  if [ -d "/usr/local/Homebrew" ]; then
    export HOMEBREW_PREFIX="/usr/local/Homebrew"
  fi

  eval $($HOMEBREW_PREFIX/bin/brew shellenv)

  if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

    autoload -Uz compinit
    compinit
  fi

  export LD_LIBRARY_PATH=$HOMEBREW_PREFIX/lib:$LD_LIBRARY_PATH
fi

### export ###
export TERM="xterm-256color"                      # getting proper colors
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export MANPATH="/usr/local/man:$MANPATH"
export MANPAGER="sh -c 'col -bx | bat -l man -p'" # "bat" as manpager
export EDITOR="emacsclient -t -a ''"
export ALTERNATEEDITOR="vi"

### alias ###
alias less=bat
alias grep=rg
alias emax="emacsclient -t -a ''"
alias doom="$HOME/.emacs.d/bin/doom"
alias config="git --git-dir=$HOME/dotfiles --work-tree=$HOME" # bare git repo alias for dotfiles
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash' # the terminal rickroll
alias tb="nc termbin.com 9999" # termbin, https://termbin.com/

if [ ! -z $(command -v prettyping) ]; then
  alias ping=prettyping # prettyping
fi

if [ ! -z $(command -v ncdu) ]; then
  alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules" # ncdu
fi

### extra 'sauce' ###
[ -f $HOME/.cargo/env ] && source "$HOME/.cargo/env" # Rust (Cargo)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # fzf
[ ! -z $(command -v zoxide) ] && eval "$(zoxide init zsh)" # a smarter cd command, https://github.com/ajeetdsouza/zoxide
[ ! -z $(command -v starship) ] && eval "$(starship init zsh)" # corss-shell prompt, https://starship.rs/

### CHANGE TITLE OF TERMINALS ###
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|alacritty|st|konsole*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
        ;;
  screen*)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

### Function extract for common file formats ###
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
 else
    for n in "$@"
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.cbr|*.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.cbz|*.epub|*.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *.cpio)      cpio -id < ./"$n"  ;;
            *.cba|*.ace)      unace x ./"$n"      ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
fi
}

IFS=$SAVEIFS

# navigation
up () {
  local d=""
  local limit="$1"

  # Default to limit of 1
  if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
    limit=1
  fi

  for ((i=1;i<=limit;i++)); do
    d="../$d"
  done

  # perform cd. Show error if cd fails
  if ! cd "$d"; then
    echo "Couldn't go up $limit dirs.";
  fi
}

### ll -> exa ###
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'

### adding flags ###
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias lynx='lynx -cfg=~/.lynx/lynx.cfg -lss=~/.lynx/lynx.lss -vikeys'
alias vifm='./.config/vifm/scripts/vifmrun'
alias ncmpcpp='ncmpcpp ncmpcpp_directory=$HOME/.config/ncmpcpp/'
alias mocp='mocp -M "$XDG_CONFIG_HOME"/moc -O MOCDir="$XDG_CONFIG_HOME"/moc'

### ps ###
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

### gpg encryption ###
# verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
# receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

### youtube-dl ###
alias yta-aac="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format aac "
alias yta-best="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format best "
alias yta-flac="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format flac "
alias yta-m4a="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format m4a "
alias yta-mp3="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format mp3 "
alias yta-opus="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format opus "
alias yta-vorbis="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format vorbis "
alias yta-wav="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format wav "
alias ytv-best="youtube-dl -o '%(title)s.%(ext)s' --external-downloader aria2c -f bestvideo+bestaudio "

### Common Lisp ###
export LISP=$HOME/lisp
alias alisp-repl="rlwrap $LISP/linuxamd64.64/alisp -L $HOME/quicklisp/setup.lisp"
alias alisp-smp-repl="rlwrap $LISP/linuxamd64.64smp/alisp -L $HOME/quicklisp/setup.lisp"
alias mlisp-repl="rlwrap $LISP/linuxamd64.64/mlisp -L $HOME/quicklisp/setup.lisp"
alias mlisp-smp-repl="rlwrap $LISP/linuxamd64.64smp/mlisp -L $HOME/quicklisp/setup.lisp"
alias sbcl-repl="rlwrap $LISP/sbcl/bin/sbcl --noinform --load $HOME/quicklisp/setup.lisp --eval '(require :sb-aclrepl)'"
alias ccl-repl="rlwrap $LISP/ccl/lx86cl64 --load $HOME/quicklisp/setup.lisp"
alias ecl-repl="rlwrap $LISP/ecl/bin/ecl --load $HOME/quicklisp/setup.lisp"

### load .profile if it exists ###
[ -f $HOME/.profile ] && source $HOME/.profile

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
