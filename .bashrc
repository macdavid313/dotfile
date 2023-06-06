# My bash config
# ______  ___   _____ _   _
# | ___ \/ _ \ /  ___| | | |
# | |_/ / /_\ \\ `--.| |_| |
# | ___ \  _  | `--. \  _  |
# | |_/ / | | |/\__/ / | | |
# \____/\_| |_/\____/\_| |_/

# Include more 'bin' paths
export PATH=$PATH:$HOME/bin:/usr/local/bin:$HOME/.local/bin

# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
  *) return ;;
esac

# Path to your oh-my-bash installation.
export OSH=$HOME/.oh-my-bash

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="font"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_OSH_DAYS=28

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
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $OSH/custom?
# OSH_CUSTOM=/path/to/new-custom-folder

# To disable the uses of "sudo" by oh-my-bash, please set "false" to
# this variable.  The default behavior for the empty value is "true".
OMB_USE_SUDO=true

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
# Custom completions may be added to ~/.oh-my-bash/custom/completions/
# Example format: completions=(ssh git bundler gem pip pip3)
# Add wisely, as too many completions slow down shell startup.
completions=(
  git
  composer
  ssh
)

# Which aliases would you like to load? (aliases can be found in ~/.oh-my-bash/aliases/*)
# Custom aliases may be added to ~/.oh-my-bash/custom/aliases/
# Example format: aliases=(vagrant composer git-avh)
# Add wisely, as too many aliases slow down shell startup.
# aliases=(
#   general
# )

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  bashmarks
)

# Which plugins would you like to conditionally load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format:
#  if [ "$DISPLAY" ] || [ "$SSH" ]; then
#      plugins+=(tmux-autoattach)
#  fi

source "$OSH"/oh-my-bash.sh

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

  export LD_LIBRARY_PATH=$HOMEBREW_PREFIX/lib:$LD_LIBRARY_PATH
fi

### export ###
export TERM="xterm-256color" # getting proper colors
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export MANPATH="/usr/local/man:$MANPATH"
export MANPAGER="sh -c 'col -bx | bat -l man -p'" # "bat" as manpager
export EDITOR="emacsclient -t -a ''"
export ALTERNATEEDITOR="vi"

### alias ###
if [ ! -z $(command -v less) ]; then
  alias less=bat
fi

if [ ! -z $(command -v rg) ]; then
  alias grep=rg
fi

alias emax="emacsclient -t -a ''"
alias doom="$HOME/.config/emacs/bin/doom"
alias config="git --git-dir=$HOME/dotfiles --work-tree=$HOME"                                       # bare git repo alias for dotfiles
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash' # the terminal rickroll
alias tb="nc termbin.com 9999"                                                                      # termbin, https://termbin.com/

if [ ! -z $(command -v prettyping) ]; then
  alias ping=prettyping # prettyping
fi

if [ ! -z $(command -v ncdu) ]; then
  alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules" # ncdu
fi

### extra 'sauce' ###
[ -f $HOME/.cargo/env ] && source "$HOME/.cargo/env"        # Rust (Cargo)
[ -f ~/.fzf.bash ] && source ~/.fzf.bash                    # fzf
[ ! -z $(command -v zoxide) ] && eval "$(zoxide init bash)" # a smarter cd command, https://github.com/ajeetdsouza/zoxide

### CHANGE TITLE OF TERMINALS ###
case ${TERM} in
  xterm* | rxvt* | Eterm* | aterm | kterm | gnome* | alacritty | st | konsole*)
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
    for n in "$@"; do
      if [ -f "$n" ]; then
        case "${n%,}" in
          *.cbt | *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar)
            tar xvf "$n"
            ;;
          *.lzma) unlzma ./"$n" ;;
          *.bz2) bunzip2 ./"$n" ;;
          *.cbr | *.rar) unrar x -ad ./"$n" ;;
          *.gz) gunzip ./"$n" ;;
          *.cbz | *.epub | *.zip) unzip ./"$n" ;;
          *.z) uncompress ./"$n" ;;
          *.7z | *.arj | *.cab | *.cb7 | *.chm | *.deb | *.dmg | *.iso | *.lzh | *.msi | *.pkg | *.rpm | *.udf | *.wim | *.xar)
            7z x ./"$n"
            ;;
          *.xz) unxz ./"$n" ;;
          *.exe) cabextract ./"$n" ;;
          *.cpio) cpio -id <./"$n" ;;
          *.cba | *.ace) unace x ./"$n" ;;
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
up() {
  local d=""
  local limit="$1"

  # Default to limit of 1
  if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
    limit=1
  fi

  for ((i = 1; i <= limit; i++)); do
    d="../$d"
  done

  # perform cd. Show error if cd fails
  if ! cd "$d"; then
    echo "Couldn't go up $limit dirs."
  fi
}

### ll -> exa ###
if [ ! -z $(command -v exa) ]; then
  alias ls='exa -al --color=always --group-directories-first' # my preferred listing
  alias la='exa -a --color=always --group-directories-first'  # all files and dirs
  alias ll='exa -l --color=always --group-directories-first'  # long format
  alias lt='exa -aT --color=always --group-directories-first' # tree listing
  alias l.='exa -a | egrep "^\."'
fi

### adding flags ###
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
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

### yt-dlp ###
alias yta-aac="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format aac "
alias yta-best="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format best "
alias yta-flac="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format flac "
alias yta-m4a="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format m4a "
alias yta-mp3="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format mp3 "
alias yta-opus="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format opus "
alias yta-vorbis="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format vorbis "
alias yta-wav="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c --extract-audio --audio-format wav "
alias ytv-best="yt-dlp -o '%(title)s.%(ext)s' --external-downloader aria2c -f bestvideo+bestaudio --merge-output-format mkv "

### Common Lisp ###
export LISP=$HOME/lisp
export QUICKLISP_HOME=$HOME/quicklisp

if [ -d $LISP/sbcl ]; then
  alias sbcl-repl="rlwrap $LISP/sbcl/bin/sbcl --noinform --load $QUICKLISP_HOME/setup.lisp --eval '(require :sb-aclrepl)'"
fi

if [ -d $LISP/ecl ]; then
  alias ecl-repl="rlwrap $LISP/ecl/bin/ecl --load $QUICKLISP_HOME/setup.lisp"
fi

for acltype in linuxamd64.64 macarm64.64 macosx86-64.64
do
  if [ -d $LISP/${acltype} ]; then
    export ACL_HOME=$LISP/${acltype}
    export ALISP=$ACL_HOME/alisp
    export MLISP=$ACL_HOME/mlisp
    alias alisp-repl="rlwrap $ALISP -L $QUICKLISP_HOME/setup.lisp"
    alias mlisp-repl="rlwrap $MLISP -L $QUICKLISP_HOME/setup.lisp"
  fi

  if [ -d $LISP/${acltype}smp ]; then
    export ACL_SMP_HOME=$LISP/${acltype}smp
    export ALISP_SMP=$ACL_SMP_HOME/alisp
    export MLISP_SMP=$ACL_SMP_HOME/mlisp
    alias alisp-smp-repl="rlwrap $ALISP_SMP -L $QUICKLISP_HOME/setup.lisp"
    alias mlisp-smp-repl="rlwrap $MLISP_SMP -L $QUICKLISP_HOME/setup.lisp"
  fi
done

### pyenv ###
if [ -d $HOME/.pyenv ]; then
  export PYENV_ROOT=$HOME/.pyenv
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

### pipx ###
if [ ! -z $(command -v pipx) ]; then
  eval "$(register-python-argcomplete pipx)"
fi

### Starship ###
[ ! -z $(command -v starship) ] && eval "$(starship init bash)" # corss-shell prompt, https://starship.rs/
