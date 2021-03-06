# also see ./.profile

# * Todos
# TODO look at python plugins
# - https://github.com/davidparsson/zsh-pyenv-lazy or just --no-rehash
# - https://github.com/darvid/zsh-poetry
# - https://github.com/iboyperson/zsh-pipenv
# - https://github.com/shosca/zsh-pew
# - https://github.com/AnonGuy/yapipenv.zsh
# - https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv
# TODO nix plugins: https://github.com/chisui/zsh-nix-shell
# TODO just use https://github.com/softmoth/zsh-vim-mode ?
# TODO other init performance improvements
# TODO shellcheck; zsh-lint; can remove a lot of quoting of parameter expansions
# TODO ranger or deer keybinding
# TODO recentf as C-f; locate keybinding
# TODO cursor flickers with instant prompt

# * Sources
# Some settings or stuff got/found out about from here:
# https://wiki.archlinux.org/index.php/Zsh
# http://zsh.sourceforge.net/Doc/Release/Zsh-Modules.html
# https://github.com/Adalan/dotfiles/blob/master/zsh/setopt.zsh#L33
# http://www.bash2zsh.com/zsh_refcard/refcard.pdf
# http://stackoverflow.com/questions/171563/whats-in-your-zshrc
# https://github.com/Adalan/dotfiles/blob/master/zsh/functions.zsh
# https://wiki.gentoo.org/wiki/Zsh/HOWTO#
# https://github.com/phallus/arch-files/blob/master/config/.zshrc

# * Begin Profiling
if [[ -n $NOCT_PROFILE_ZSH ]]; then
	zmodload zsh/zprof
elif [[ -n $NOCT_TIME_ZSH ]]; then
	# https://github.com/zdharma/pm-perf-test
	typeset -F4 SECONDS=0
fi

# * Instant Prompt
# show cached prompt while real prompt is loading
NOCT_INSTANT_PROMPT=true
if $NOCT_INSTANT_PROMPT && \
		[[ -r ~/.cache/p10k-instant-prompt-${(%):-%n}.zsh ]]; then
	source ~/.cache/p10k-instant-prompt-${(%):-%n}.zsh
fi

# * Plugins
if [[ ! -f ~/.zplugin/bin/zplugin.zsh ]]; then
	echo "Installing zplugin..."
	git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin
fi

# NOTE zplugin load isn't apparently much of an issue when using wait/turbo
# mode, but I haven't needed reporting so far
# NOTE currently doing compinit at 0c; nothing seems to need to be loaded after
# compinit (even autopair)
if [[ -f ~/.zplugin/bin/zplugin.zsh ]]; then
	source ~/.zplugin/bin/zplugin.zsh

	# ** Theme/Appearance
	# more configuration in later section
	zplugin ice depth=1
	zplugin light "romkatv/powerlevel10k"

	# load after history-substring-search
	zplugin ice wait"0b" lucid atload'_zsh_autosuggest_start'
	zplugin light "zsh-users/zsh-autosuggestions"
	ZSH_AUTOSUGGEST_USE_ASYNC=true

	# compinit before loading; load after autosuggestions
	zplugin ice wait"0c" lucid \
			atinit"ZPLGM[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
	zplugin light "zdharma/fast-syntax-highlighting"

	# ** Zle Enhancements
	# needs to start before fast syntax highlighting and autosuggestions
	zplugin ice wait lucid
	zplugin light "zsh-users/zsh-history-substring-search"

	# says it needs to be loaded after compinit but works fine with this config
	zplugin ice wait lucid
	zplugin load "hlissner/zsh-autopair"

	# clipboard
	zplugin ice wait lucid
	zplugin light "kutsan/zsh-system-clipboard"

	# ** Completion
	# oh-my-zsh's completion setup (e.g. colors, case sensitivity, etc.)
	zplugin ice wait lucid
	zplugin snippet "OMZ::lib/completion.zsh"

	zplugin ice wait lucid
	zplugin light "zsh-users/zsh-completions"

	# completions for yarn run (mainly)
	zplugin ice wait lucid atclone"./zplug.zsh"
	zplugin light "g-plane/zsh-yarn-autocompletions"

	zplugin light "spwhitt/nix-zsh-completions"

	# provides tab completion for various commands and keybindings
	zplugin ice wait lucid multisrc"shell/*.zsh"
	zplugin light "junegunn/fzf"

	zplugin ice wait lucid
	zplugin light "wookayin/fzf-fasd"

	# directory selection with fuzzy search; nice complement to fasd
	zplugin ice wait lucid
	zplugin light "b4b4r07/enhancd"
	ENHANCD_FILTER=fzf
	# fzf selection with cd <Tab>
	ENHANCD_COMPLETION_BEHAVIOR=list

	# ** Commands/Other
	# prettier ls; nice if only had zshrc and no ranger or exa
	# zplugin ice wait lucid
	# zplugin light "supercrabtree/k"

	if ! hash exa 2> /dev/null; then
		zplugin ice wait lucid from"gh-r" as"program" mv"exa* -> exa"
		zplugin light "ogham/exa"
	fi

	zplugin ice wait lucid \
			atload"AUTO_NOTIFY_IGNORE+=(emacs mpgo mpv ranger rn vim vimus)"
	zplugin light "MichaelAquilina/zsh-auto-notify"

	# let you know you could have used an alias
	zplugin ice wait lucid
	zplugin light "MichaelAquilina/zsh-you-should-use"

	# ** Interesting but not useful for me at the moment
	# Tarrasch/zsh-autoenv
	# https://github.com/zpm-zsh/autoenv
	# hchbaw/auto-fu.zsh
	# https://github.com/joepvd/zsh-hints
	# https://github.com/hchbaw/zce.zsh
	# https://github.com/willghatch/zsh-snippets
	# maybe use at some point
	# https://github.com/bric3/nice-exit-code
	# https://github.com/Tarrasch/zsh-functional
fi

# * Appearance
# ** Pywal
if [[ -f ~/.cache/wal/sequences ]]; then
	(cat ~/.cache/wal/sequences &)
fi

# ** Less Colors
# colored less manpages
# similar to things like colored-man; don't remember where found this
export LESS_TERMCAP_mb=$'\E[01;31m'             # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'             # begin bold
export LESS_TERMCAP_me=$'\E[0m'                 # end mode
export LESS_TERMCAP_se=$'\E[0m'                 # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'          # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'                 # end underline
export LESS_TERMCAP_us=$'\E[01;32m'             # begin underline

# ** Cursor
if [[ -z $INSIDE_EMACS ]] ;then
	# use block cursor for normal mode only
	# using wincent/terminus in init.vim for switching
	zle-keymap-select() {
		if [[ $KEYMAP == vicmd ]]; then
			echo -ne '\e[1 q'
		else
			echo -ne '\e[5 q'
		fi
	}
	zle -N zle-keymap-select

	# start with line cursor
	zle-line-init() {
		echo -ne '\e[5 q'
	}
	zle -N zle-line-init
fi

# * Options
# http://linux.die.net/man/1/zshoptions ($ man zshoptions)
# rc_expand_param is interesting

# ** General
# 10 second wait then prompt if use rm with *
setopt RM_STAR_WAIT
# prompt if removing more than 3 files; don't delete anything from ~/.config/safe-rm
# I generally use trash-cli instead of rm
if hash safe-rm 2> /dev/null; then
	alias rm='safe-rm -I'
fi

# show nonzero exit codes
setopt print_exit_value

# allow comments with #
setopt interactive_comments

# no beeps
setopt no_beep

# default
# http://zsh.sourceforge.net/Doc/Release/Redirection.html#Multios
# setopt multios

# ** Correction
# spell check commands and offer correction (pdw > pwd)
setopt correct
# don't spell check arguments
unsetopt correct_all

# ** Completion
# http://askql.wordpress.com/2011/01/11/zsh-writing-own-completion/
# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

# show completion menu when number of options is at least 2
zstyle ':completion:*' menu select=2

# by unsetting, substitute alias before completion (so as if typed it out)
unsetopt complete_aliases

# when completing from the middle of a word, move the cursor to the end of the
# word; haven't noticed staying in middle of word even when unset; confusion
unsetopt always_to_end

# do not autoselect the first completion entry
unsetopt menu_complete

# show completion menu on successive tab press (menu_complete overrides)
setopt auto_menu

# default; lists choiches on ambiguous completion; won't go to first item
# (except with wildcard and glob_complete)
setopt auto_list

# will show name for directory if you have it set; ex if have DS=~/Desktop (ex
# with '%~' in prompt sequence), it will show DS instead of desktop if you cd
# into it
setopt auto_name_dirs

# default; will put / instead of space when autocomplete for param (ex ~D(tab)
# puts ~D/)
setopt auto_param_slash

# allow completion from within a word/phrase
# ex: completes to Desktop/ from Dktop with cursor before k)
setopt complete_in_word

# ** Globbing
# treat #, ~, and ^ as part of patterns for filename generation; ex ^ negates
# following pattern (ls -d ^*.c)
# ls *.png~Selection_005.png now will exclude that file frome results
# http://www.refining-linux.org/archives/37/ZSH-Gem-2-Extended-globbing-and-expansion/
# http://zsh.sourceforge.net/Doc/Release/Expansion.html
# http://www.linuxjournal.com/content/bash-extended-globbing
# probably will never use
setopt extended_glob

# if unset and do something like ls D* it will add anything that matches that to
# the line (ex ls Desktop/ Downloads/); with it set, will act like
# menu_complete; uses pattern matching; can use wih complete_in_word
setopt glob_complete

# ** Cd/Pushd Options
# http://zsh.sourceforge.net/Intro/intro_6.html
DIRSTACKSIZE=8

# if type the dir, will cd to it
setopt auto_cd

# http://zsh.sourceforge.net/Intro/intro_16.html
# if a var is a directory, can cd to it
setopt cdable_vars

# This makes cd=pushd (also have auto cd)
setopt auto_pushd

# blank pushd goes to home; default already I think
setopt pushd_to_home

# swap meaning of cd -num and cd +; dirs -v then cd -num of directory you want
# to switch to
setopt pushd_minus

# don't push multiple copies of the same directory onto the directory stack
setopt pushd_ignore_dups

# no pushd messages
setopt pushd_silent

# ** History
# lots of it
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# don't add to history when first character on the line is a space
# good for dangerous commands don't want to accidentally run (e.g. dd)
setopt hist_ignore_space

# remove extra blanks from each command added to history
setopt hist_reduce_blanks

# don't execute, just expand history and reload line
setopt hist_verify

# allow multiple terminal sessions to all append to one zsh command history
# instead of replacing the file; default
setopt append_history

# save timestamp of command and duration; begginingtime:elapsedseconds
setopt extended_history

# don't wait until shell exits to add commands to history
setopt inc_append_history

# imports new commands from history file (i.e. commands run in other zsh
# intsances) and appends typed commands to history (no need to set
# inc_append_history with this on)
setopt share_history

# don't store consecutive duplicates
setopt hist_ignore_dups

# when trimming history, lose oldest duplicates first
setopt hist_expire_dups_first

# * Keybindings
bindkey -v

# for "leader" keybindings
bindkey -a -r t

# ** Normal (vicmd)/Visual Mode
# -a is short for -M vicmd
# http://zshwiki.org/home/zle/vi-mode
# enable vi mode on commmand line; no visual
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
# for bash there is https://github.com/ardagnir/athame
# alternatively run shell in neovim or emacs

# enable surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround
#  quote text objects
autoload -U select-quoted

# bracket text objects
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
	for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
		bindkey -M $m $c select-bracketed
	done
done

# delay to enter normal mode normal mode
# https://coderwall.com/p/h63etq
# https://github.com/pda/dotzsh/blob/master/keyboard.zsh#L10
# unfortunately needs to be higher for surround keybindings to work
# https://github.com/softmoth/zsh-vim-mode/issues/13
KEYTIMEOUT=30

# add missing vim hotkeys
bindkey -a u undo
bindkey -a U redo
# swap
bindkey -a a vi-add-eol
bindkey -a A vi-add-next

# Colemak
# https://github.com/bunnyfly/dotfiles/blob/master/zshrc
bindkey -a h backward-char
# bindkey -a i forward-char
bindkey -a n history-substring-search-down
bindkey -a e history-substring-search-up
# bindkey -a "s" vi-insert
# bindkey -a "S" vi-insert-bol
bindkey -a k vi-repeat-search
bindkey -a K vi-rev-repeat-search
bindkey -a j vi-forward-word-end
bindkey -a E vi-forward-blank-word-end

# home and end
bindkey -a "^[[1~" beginning-of-line
bindkey -a "^[[4~" end-of-line

# http://zshwiki.org./home/zle/bindkeys#why_isn_t_control-r_working_anymore
bindkey -M vicmd 't?' history-incremental-pattern-search-backward

# ** Insert Mode
# bind UP and DOWN arrow keys (on caps or thumbkey)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# fix home, end, etc. keys (with vim mode)
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[5~" beginning-of-history
bindkey "^[[6~" end-of-history
bindkey "^[[3~" delete-char
bindkey "^[[2~" quoted-insert
# can also do with zkbd and "${key[Home]}" stuff

# https://superuser.com/questions/476532/how-can-i-make-zshs-vi-mode-behave-more-like-bashs-vi-mode/533685#533685
# allow deleting before insertion
bindkey '^?' backward-delete-char
bindkey "^W" backward-kill-word
bindkey "¸" backward-kill-word

# ** Clipboard
# using https://github.com/kutsan/zsh-system-clipboard
bindkey '^y' zsh-system-clipboard-vicmd-vi-put-before

# escaped paste
escape-paste-clipboard() {
	RBUFFER=$(printf '%q' "$(xsel -ob </dev/null)")$RBUFFER
}
zle -N escape-paste-clipboard
bindkey -a tp escape-paste-clipboard

# ** External Interaction
# for tmux copy mode
enter-copy-mode() {
	tmux copy-mode
}
zle -N enter-copy-mode
bindkey -a v enter-copy-mode

# enter ranger
ctrl-d() {
	xdotool key control+d
}
zle -N ctrl-d
bindkey -a tr ctrl-d

# ** Automatically Expand Global Aliases
# automatically expanding global aliases
# http://blog.patshead.com/2011/07/automatically-expanding-zsh-global-aliases-as-you-type.html?r=related
globalias() {
	if [[ $LBUFFER =~ ' [a-Z0-9]+$' ]]; then
		zle _expand_alias
		zle expand-word
	fi
	zle self-insert
}

zle -N globalias

# bindkey " " globalias
# bindkey "^ " magic-space           # control-space to bypass completion
# bindkey -M isearch " " magic-space # normal space during searches

# * Aliases/Functions
# ** Private
# aliases/functions with user info
if [[ -f ~/.zsh/.private_zshrc ]]; then
	source ~/.zsh/.private_zshrc
fi

# ** Navigation
# Programs like fasd and shell fuzzy finders like FZF and percol are awesome. I
# don't end up using them much though since they aren't as useful with a
# editor-based inside the editor (though fzf is nice with z and in ranger, and
# counsel-fzf is sometimes useful)

# order of preference:
# 1. quickmark for dir/file if exists (fastest but requires memorization)
# 2. (maybe fuzzy) search for recent/most visited/locate/find
# 3. f<keys> auto-enter navigation in file manager (e.g. deer and blscd) or tab
#    completion

# *** FASD
# have a (any), s (show), z (cd), etc.
eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install)"
alias z='fasd_cd -d'

# *** FZF
# http://owen.cymru/fzf-ripgrep-navigate-with-bash-faster-than-ever-before/
FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git"'
# not using FZF_TMUX, but fzf and enhancd completions uses this variable
FZF_TMUX_HEIGHT="90%"

# using git ls-tree can be faster in large repos according to fzf README
# only shows tracked files though
# export FZF_DEFAULT_COMMAND='
# (git ls-tree -r --name-only HEAD ||
# ag -l -g "") 2> /dev/null'

# using FZF completion script (see plugins section) for the following:
# $ cd ** # dirs
# $ kill -9 # processes
# $ other_command ** # files
# etc.
# keybindings:
# - C-t for files/directories
# - C-r for history
# - M-c to cd into directory

# idea suggested by gotbletu
fzf-locate() {
	local selected
	selected=$(locate "${1:-*}" | fzf -e)
	if [[ -d $selected ]]; then
		cd "$selected"
	else
		rifle "$selected"
	fi
}

fl() {
	fzf-locate "$PWD"/*
}

# ** Backup & Mounting
if [[ -f ~/.zsh/borg_backup.zsh ]]; then
	source ~/.zsh/borg_backup.zsh
fi

alias mountefi='sudo mount /dev/disk/by-label/SYSTEM /boot/efi'
alias mountesp='mountefi'
alias umountefi='sudo umount /dev/disk/by-label/SYSTEM'
alias umountesp='umountefi'

# ** Startup and Shutdown
# TODO is this overkill or at all necessary?
poweroff() {
	pkill -x mpd
	pkill emacs
	# emacsclient -t --eval "(let (kill-emacs-hook) (kill-emacs))"
	# maybe this is overly paranoid, but it seems like a good idea
	udiskie-umount --all || return 1
	if command -v tmsu &> /dev/null; then
		tmsu unmount -a || return 1
	fi
	if [[ $1 == reboot ]]; then
		systemctl reboot
	else
		systemctl poweroff
	fi
}

alias reboot='poweroff reboot'

# ** Symlinking Dotfiles With Stow
if [[ -f ~/.zsh/stow_functions.sh ]]; then
	source ~/.zsh/stow_functions.sh
fi

# ** Package Management
# *** Pacman/AUR
# make new mirror list
rldmirrors() {
	sudo reflector --verbose -l 200 --sort rate --save /etc/pacman.d/mirrorlist
}

# view packages:
# pacgraph -f /tmp/pacgraph
# inkscape /tmp/pacgraph

sysupd() {
	mountesp
	PACMAN=yay pacnanny -Syu
	mkinitcpio --allpresets
	# distro=$(lsb_release -is)
	# if [[ $distro == Arch ]]; then
	# fi
	# # else if nix
	# # sudo nixos-rebuild switch --upgrade
}

alias pacss='pacman -Ss'
alias pacs='sudo powerpill -S'
alias pacq='pacman -Q'
alias pacqm='pacman -Qm'

# will keep 3 most recent versions and remove all versions of uninstalled
# e.g. -rk2 to keep 2 most recent
alias cleanpaccache='paccache -rk2 && paccache -ruk0'
# remove packages installed as dependencies but not needed anymore
# pacman -Rs $(pacman -Qqdt)

alias aur='yay -S'
alias yays='yay -S'
alias aurs='yay -Ss'
alias yayss='yay -Ss'

# ** Reloading things
alias rld='echo "Reloading .zshrc" && source ~/.zshrc'

# xrdb -query -all
alias rldxres='xrdb -load ~/.Xresources'

alias rldless='lesskey ~/.lesskey'

# update font caches
alias rldfonts='fc-cache -vf'
# add pretty much any font in ~/.fonts; don't remember where stole from
fonts() {
	mkfontdir ~/.fonts
	mkfontscale ~/.fonts
	xset +fp ~/.fonts
	xset fp rehash
	fc-cache
	fc-cache -fv
}
# xfontsel to find long -*-* font names
# xft names; fc-list (-vv)

# set hardware clock to system time
alias fixhwclock='sudo hwclock --systohc'

alias rldsxhkd='pkill -USR1 -x sxhkd'

alias rldpolybar='pkill -USR1 -x polybar'

# manually reload udev rules
alias -g rldudev='udevadm control --reload-rules'

# TODO potential problem when sxhkd freezes
alias keyupall='DISPLAY=:0 xdotool keyup control shift alt super'

# ** System Information
alias cpuinfo='less /proc/cpuinfo'

# check drive mount options
mountopts() {
	grep -i "$1" /proc/mounts
}
# e.g.
# $ mountopts sdb1
# $ mountopts discard

alias lsb='lsblk -o name,size,label'

# ** Group Stuff
# add current user to group
alias gadd="sudo gpasswd -a $USER"

# list what groups current user is in
alias groupslist="groups $USER"

# ** General/Random
unalias run-help
autoload -Uz run-help
alias help='run-help'

alias e="$EDITOR"

alias stop_emacs='emacsclient --eval "(let (kill-emacs-hook) (kill-emacs))"'

# b is for bang!
b() {
	sudo "$(fc -ln -1)"
}

def(){
	echo "$1" | festival --tts &
	sdcv "$1"
	sdcv "$1" | ${PAGER:-less}
}

# generate gpl3 license
alias gpl3='harvey gpl-3.0 > LICENSE'

# blank screen
alias screenoff='xset dpms force off'

# for opening in already open gvim session
alias gvir='gvim --remote'

# telnet/fun
alias starwars='telnet towel.blinkenlights.nl'
alias fun='telnet sdf.org'
alias hack='hexdump -c /dev/urandom'

# other program aliases
alias pg='pgrep -l'
alias stl='sudo systemctl'
# use spacemacs config (not symlinking to home with stow)
alias spacemacs="env HOME=$HOME/spacemacs emacs"
alias testemacs="env HOME=$HOME/test-emacs emacs"

alias checkclass='xprop | grep WM_CLASS'

# ** Directory Stuff
# have cut down on the number of aliases here since I don't use most of them
# (just use actual file manager instead)

take() {
	mkdir -p "$1" && cd "$1"
}

# copy working directory to clipboard
alias cpwd='pwd | tr -d "\n" | xsel -ib'

# *** ls Stuff
# https://github.com/supercrabtree/k
# nice if don't have exa installed but much slower
alias kls='k -ah'

# https://github.com/ogham/exa
alias els='exa --all --long --group'

alias l='ls -alh'

# http://jeff.robbins.ws/reference/my-zshrc-file
# these require zsh
# files & directories modified in last day
alias ltd='ls *(m0)'
# files (no directories) modified in last day
alias lt='ls *(.m0)'
# list three newest
alias lnew='ls *(.om[1,3])'
# most recent subdir
alias lsrdir='ls -d *(/om[1])'

# *** cd Stuff
# custom cds
alias home='cd ~/'
alias cdot='cd ~/dotfiles'
# exit symlinks; http://alias.sh/exit-symlinks
xs() {
	cd "$(pwd -P)"
}

# *** Size Management
# baobab or something graphical is preferable, but these are nice in simple
# cases to check free space
alias fspace='df -h'
# colored disk usage; colour intelligently; sort; human readable sizes
alias diskspace='cdu -isdh'
# there's also ncdu.. but it doesn't support key rebinding
# dfc is also nice for whole filesystem
# number of files (not directories)
alias filecount='find . -type f | wc -l'

# *** Searching
alias rgs='rg --no-ignore --hidden --follow'
alias rsl='find . -name'

# ** Ranger
ranger-cd() {
	# from https://github.com/hut/ranger/blob/bdd6bf407ab22782f7ddb3a1dd24ffd9c3361a8d/examples/bash_automatic_cd.sh
	# with minor modifications
	# change the directory to the last visited one after ranger quits.
	# "-" to return to the original directory.
	local tempfile
	tempfile=/tmp/ranger/chosendir
	mkdir -p /tmp/ranger
	ranger --choosedir="$tempfile" "${@:-$(pwd)}"
	if [[ -f $tempfile ]] && \
		   [[ $(< $tempfile) != $(pwd | tr -d '\n') ]]; then
		# ranger will put full path in tempfile  (-- not needed)
		cd "$(< $tempfile)"
	fi
	rm -f "$tempfile"
}

rn() {
	if [[ ! -z $RANGER_LEVEL ]]; then
		# https://wiki.archlinux.org/index.php/Ranger
		# if a ranger session exists, restore it
		exit
	fi
	case $1 in
		dwn) ranger-cd ~/move ;;
		vim) ranger-cd ~/.vim ;;
		*)   ranger-cd ;;
	esac
}

# ** Media
# *** Music
# cd ripping
alias rip='abcde'

# could potentially use this instead of mpdcron
alias mpdstats='beet mpdstats'

# *** Connecting to External Displays
# **** Helpers
if [[ -f ~/bin/helpers/monitor.sh ]]; then
	source ~/bin/helpers/monitor.sh
fi

monitor_connect() ( # output_name right_of_primary? add_bspwm_desktop
	# exit if any command or any part of a pipe fails
	# using subshell so this only lasts for this function
	set -e -o pipefail
	name=$1
	right_of_primary=$2
	add_bspwm_desktop=$3
	primary=$(monitor_get_primary)

	# ensure disconnected (for when want to switch between mirroring and
	# separate desktop)
	monitor_disconnect "$name"

	if [[ -n $right_of_primary ]]; then
		xrandr --output "$name" --auto --right-of "$primary"
		# restore wallpaper (keep the wallpaper on the primary screen; make the
		# new monitor black instead of copying the wallpaper)
		setroot --restore
	else
		# mirror screen
		primary_geometry=$(monitor_get_dimensions "$primary")
		xrandr --output "$name" --auto --scale-from "$primary_geometry"
		# don't want any new desktops since just mirroring; bspc adds the
		# monitor and a desktop by default
		bspc monitor "$name" --remove
	fi

	# add new desktop/workspace for the monitor
	# TODO could potentially allow word splitting to add more than one desktop
	if [[ -n $add_bspwm_desktop ]]; then
		bspc monitor "$name" --reset-desktops "$add_bspwm_desktop"
	fi
)

monitor_disconnect() ( # output_name
	# exit if any command or any part of a pipe fails
	set -e -o pipefail
	name=$1
	xrandr --output "$name" --off
	if bspc query --monitors --names | grep --quiet "^${name}$"; then
		bspc monitor "$name" --remove
	fi
)

# **** VGA (old)
alias vgain='monitor_connect VGA1'
alias vgaout='monitor_connect VGA1 true X'
alias vgaout='monitor_disconnect VGA1'

# **** Thinkpad p50
# discrete is wonkier (e.g. compton doesn't work) and there doesn't seem to be a
# real advantage to using it (can just run X with graphics card on demand)
alias discrete="sudo cp ~/dotfiles/20-nvidia.conf /etc/X11/xorg.conf.d/"
alias hybrid="sudo rm /etc/X11/xorg.conf.d/20-nvidia.conf"

# discrete grapics in bios or hybrid and nvidia-xrun
alias nvadd='monitor_connect DP-1 true 十'
alias nvmirror='monitor_connect DP-1'
alias nvout='monitor_disconnect DP-1 true'

# **** Thinkpad p52
hdmiadd() {
	monitor_connect HDMI-0 true 十
	if [[ -n $1 ]]; then
		ponymix set-profile output:hdmi-stereo
	fi
}

hdmiout() {
	monitor_disconnect HDMI-0 true
	ponymix set-profile output:analog-stereo
}

# *** Play Video from Clipboard
mpgo() {
	mkdir -p /tmp/mpv
	if [[ -n $1 ]]; then
		clipboard=$1
	else
		clipboard=$(xsel -b)
	fi
	if [[ $clipboard == *youtube.com* ]]; then
		mpv --screenshot-template="./%tY.%tm.%td_%tH:%tM:%tS" "$clipboard"
	elif [[ $clipboard =~ ^http ]] || [[ -e $clipboard ]]; then
		echo "$clipboard" > /tmp/mpv/last_link
		# ytdl messes up direct links for some reason (slow)
		mpv --no-ytdl --screenshot-template="./%tY.%tm.%td_%tH:%tM:%tS" "$clipboard"
	elif [[ $clipboard =~ ^magnet ]]; then
		echo "$clipboard" > /tmp/mpv/last_link
		# --remove is broken
		peerflix --remove --mpv "$clipboard" -- --no-ytdl \
				 --screenshot-template="./%tY.%tm.%td_%tH:%tM:%tS" \
			; rm -rf /tmp/torrent-stream
	fi
}

mplast() {
	mpgo "$(< /tmp/mpv/last_link)"
}

# *** Record Audio
arec() { # filename
	# TODO move into own script
	# ffmpeg \
		# -f alsa -ac 2 -i hw:"$audio_card" -acodec libopus \
		# out.opus
	audio_card="0,0"
	ffmpeg -f alsa -ac 2 -i hw:"$audio_card" output.wav
}
# see ~/bin/srec for ffmpeg video recording

# ** Internet, VPN, Firewall, and Torrenting
# *** General
alias dl='aria2c -x 4'
# check ip; default gateway / router
alias gateip='ip route show'
# check what DNS servers have in conf and which one using
showdns() {
	cat /etc/resolv.conf \
		&& echo "\n--DIG OUTPUT:" \
		&& dig fsf.org | grep SERVER
}
alias checkdns='showdns'
# identify active network connections
# http://alias.sh/identify-and-search-active-network-connections
alias spy='lsof -i -P +c 0 +M'
# alias netlist='lsof -i -P | grep LISTEN'

# clean firefox profile
alias cleanff='profile-cleaner f'

# firewall
alias ufws='sudo ufw status verbose'
alias ufwd='sudo ufw delete'

# *** Network Management
# netctl (if no connman)
alias wifi='sudo wifi-menu'
alias nts='sudo netctl switch-to'
alias stopnetctl='sudo systemctl stop netctl'
alias startnetctl='sudo systemctl start netctl'
# connman
alias stopcon='sudo systemctl stop connman'
alias startcon='sudo systemctl start connman'

# sometimes
# necessary for reconnecting with spotty connection; doesn't always work
# https://bbs.archlinux.org/viewtopic.php?id=188825
# systemctl restart connman
rldcon() {
	sudo systemctl stop connman && sleep 3 && sudo systemctl start connman
}
alias conenwifi='connmanctl enable wifi'
alias conlist='connmanctl scan wifi && connmanctl services'
con() { # name
	local long_name
	long_name=$(conlist | awk "/$1/ {print \$3}")
	echo "$long_name"
	connmanctl connect "$long_name"
}

# mask to prevent from starting with tlp (still an issue?)
swcon() {
	sudo systemctl stop NetworkManager && sudo systemctl mask NetworkManager \
		&& sudo systemctl start connman && fixresolv
}

swnm() {
	sudo systemctl stop connman && sudo systemctl unmask NetworkManager \
		&& sudo systemctl start NetworkManager && fixresolv
}

# show active device
alias ipup="ip link show up | awk -F ':' '/state UP/ {print $2}'"

# *** DNS
# in case something goes wrong
backupresolv() {
	sudo chattr -i /etc/resolv.conf
	sudo cp ~/dotfiles/.root/etc/resolv.conf.backup /etc/resolv.conf
	sudo chattr +i /etc/resolv.conf
}

fixresolv() {
	sudo chattr -i /etc/resolv.conf
	echo -e "nameserver ::1
nameserver 127.0.0.1
options edns0 single-request-reopen" \
		| sudo tee /etc/resolv.conf
	sudo chattr +i /etc/resolv.conf
}

# if need to access captive portal for public wifi
# TODO what actually is default?
defaultresolv() {
	default_route=$(ip route | awk '/default/ {print $3}')
	sudo chattr -i /etc/resolv.conf
	echo -e "nameserver $default_route" \
		| sudo tee /etc/resolv.conf
	sudo chattr +i /etc/resolv.conf
}

# *** Torrents
alias starttr='sudo systemctl start transmission'
alias stoptr='sudo systemctl stop transmission'

# https://github.com/gotbletu/shownotes/blob/e6fe01c4567a4129558c3911a412cf5af4448cf9/transmission-cli.txt
# manually add a torrent file or magnent link
alias toa='transmission-remote -a'

# remove torrent; leaves data alone; give id (e.g. 1) or "all"
todd() {
	transmission-remote -t "$1" --remove
}

# remove completed torrents (but without a bunch of greps and xargs)
tord() {
	transmission-remote -l | \
		awk '/100%.*Done/ {system("transmission-remote -t "$1" -r")}'
}

# pause torrent
topp() {
	transmission-remote -t "$1" --stop
}

# pause all
alias stopto='transmission-remote -t all --stop'

# unpause
toup() {
	transmission-remote -t "$1" --start
}

# list
alias tol='transmission-remote -l'
# tell number of seeders
alias -g tons='transmission-show --scrape' # <torrent file>
alias tocs='tons'

# continuously show speed
toss() {
	while true; do
		clear
		transmission-remote -t "$1" -i | grep Speed
		sleep 1
	done
}

# ** Phone Syncing
# *** mtpfs and adbfs (currently unused)
ANDROID_MOUNT_DIR="$HOME/mnt/android"

alias adbrestart='adb kill-server ; adb start-server'

# mountand() {
# 	mkdir -p "$ANDROID_MOUNT_DIR" && jmtpfs "$MTP_MOUNT_DIR"
# }

# umountand() {
# 	fusermount -u "$ANDROID_MOUNT_DIR"
# }

mountand() {
	mkdir -p "$ANDROID_MOUNT_DIR" && adbfs "$ANDROID_MOUNT_DIR"
}

umountand() {
	fusermount -u "$ANDROID_MOUNT_DIR"
}

# http://www.arachnoid.com/android/SSHelper/index.html
# with ssh: I tried but it was much slower :( even with fast internets
# (sshdroid, sshelper, zshaolin, etc.)
# rsync -azvr --no-perms --no-times --size-only --progress --delete \
	# 	  --rsh="ssh -p 2222" /path root@hostip:/path

# see backup_rsync; --no-perms line is difference
android_rsync() {
	rsync --verbose --info=progress2 --human-readable --ignore-errors \
		  --recursive --links --hard-links \
		  --no-perms --no-times --no-group --no-owner --size-only \
		  --update --prune-empty-dirs \
		  --partial --whole-file --sparse "$@"
}

# seems beter with adbfs but still slow
syncandmus() {
	if ! mountpoint -q "$ANDROID_MOUNT_DIR"; then
		echo "Please mountand."
		return 1
	fi

	and_music_dir="$ANDROID_MOUNT_DIR$(adb_get_sd_card_dir)/Music"
	android_rsync --delete --copy-links ~/music-android/ "$and_music_dir"
	android_rsync ~/.mpd/playlists/ "$and_music_dir"
}

# *** adb-sync
adb_get_sd_card_dir() {
	# changing file system label (e.g. with exfatlabel) does not change the
	# android mountpoint; using this meh workaround to mark the sd card dir
	adb shell <<EOF
for i in /storage/*; do
	if [ -f "\$i"/is_external_sd ]; then
		echo "\$i"
		break
	fi
done
EOF
}

# intentionally not using --delete (do it manually)
# remember: trailing slashes are important on src dir
# trailing slash on dest dir results in dir// (but this doesn't matter)
# TODO adb-sync doesn't work with certain characters in filename:
# https://github.com/google/adb-sync/issues/34
syncphone() {
	if ! mountpoint -q ~/database; then
		echo "Please mountdatab."
		return 1
	fi

	mkdir -p ~/ag-sys/library/android || return 1
	mkdir -p ~/ag-sys/backup/{tachiyomi,to-clean} || return 1
	mkdir -p ~/database/move/phone/internal || return 1

	local internal external
	# /storage/emulated/0
	internal=/sdcard
	external=$(adb_get_sd_card_dir)

	if [[ -z "$external" ]]; then
		echo "Please ensure the sd card is mounted and has an 'is_external_sd'
file in it."
		return 1
	fi
	# Two Way
	adb-sync --two-way ~/wallpaper/phone/ "$internal"/Wallpaper/
	adb-sync --two-way ~/database/ringtones/ "$internal"/Ringtones/
	adb-sync --two-way ~/ag-sys/library/android/ "$external"/books
	adb-sync --two-way ~/database/meditations/ "$external"/meditations/
	adb-sync --copy-links --two-way ~/ag-sys/orgzly/ "$external"/orgzly/


	# One Way - To Phone
	# music
	adb-sync --copy-links ~/music-android/* "$external"/Music/
	# TODO check if this is actually used
	adb-sync ~/.mpd/playlists/ "$internal"/Playlists/

	adb-sync ~/ag-sys/life/back.pdf "$internal"/


	# One Way - To Computer
	# TODO exclude .thumbnails
	# photos
	adb-sync --reverse "$internal"/DCIM ~/database/move/phone/internal/
	adb-sync --reverse "$external"/DCIM ~/database/move/phone/internal/

	# videos (e.g. NewPipe)
	adb-sync --reverse "$internal"/Movies ~/database/move/phone/internal/
	adb-sync --reverse "$internal"/Pictures ~/database/move/phone/internal/
	adb-sync --reverse "$internal"/CamScanner ~/database/move/phone/internal/
	adb-sync --reverse "$internal"/OpenNoteScanner \
			 ~/database/move/phone/internal/

	# other downloads
	adb-sync --reverse "$internal"/Download ~/database/move/phone/internal/
	# downloaded photos
	adb-sync --reverse "$internal"/Clover ~/database/move/phone/internal/

	adb-sync --reverse "$internal"/Cytoid ~/database/move/phone/internal/

	adb-sync --reverse "$internal"/Signal ~/database/move/phone/internal/

	adb-sync --reverse "$internal"/Tachiyomi/backup/ ~/ag-sys/backup/tachiyomi/
	adb-sync --reverse "$internal"/Tachiyomi ~/database/move/phone/internal/

	# stats and preferences backup
	adb-sync --reverse "$internal"/gmmp ~/database/move/phone/internal

	# general location for other manual backups (e.g. k9, loop, dashchan, slide,
	# and moonreader)
	adb-sync --reverse "$internal"/backup ~/database/move/phone/internal/

	# sync back notes (now on sd card so restore for new phone is unnecessary)
	# can't use glob
	adb-sync --reverse "$external"/notes.txt ~/ag-sys/backup/to-clean/
	adb-sync --reverse "$external"/pots.txt ~/ag-sys/backup/to-clean/
}

# just for copying over all internal things
newphonerestore() {
	internal=/sdcard
	adb-sync ~/database/move/phone/internal/ "$internal"/
}

# ** Other Functions
if [[ -f ~/.config/ranger/ranger_functions ]]; then
	source ~/.config/ranger/ranger_functions
fi

# from omz; command usage statistics
zsh_stats() {
	fc -l 1 | \
		awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | \
		grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n20
}

# pipe into head; optionally specify line number
he() {
	if [[ $1 =~ ^[0-9]+$ ]]; then
		"${@:2}" | head -n "$1"
	else
		"$@" | head -n 15
	fi
}

# send stdout and stderr to /dev/null
qt() {
	"$@" &> /dev/null &
}

# save errors
qte() {
	"$@" 2> "${1}_error.log" &
}

# print all 256 colors
# https://wiki.archlinux.org/index.php/X_resources#Display_all_256_colors
colors() (
	x=$(tput op)
	y=$(printf %76s)
	for i in {0..256}; do
		o=00$i
		echo -e ${o:${#o}-3:3} $(tput setaf $i;tput setab $i)${y// /=}$x
	done
)

# * Kitty Fix
# should be able to read terminfo correctly
bindkey '\e[H'  beginning-of-line
bindkey '\e[F'  end-of-line
bindkey '\e[3~' delete-char

# * Local Config
if [[ -f ~/.zsh/local.zsh ]];then
	source ~/.zsh/local.zsh
fi

# * P10k Initialization
# based off Pure
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
POWERLEVEL9K_INSTANT_PROMPT=quiet

POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
	os_icon
	background_jobs
	dir                       # current directory
	vcs                       # git status
	anaconda
	context                   # user@host
	command_execution_time    # previous command duration
	newline                   # \n
	virtualenv                # python virtual environment
	prompt_char               # prompt symbol
)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(ranger)

# enable icons (e.g. for dir_writable)
unset POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION

# show number of jobs if >1
POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
# get rid of extra space after background jobs icon
POWERLEVEL9K_BACKGROUND_JOBS_ICON=

# show lock for dir section if not writable
POWERLEVEL9K_DIR_SHOW_WRITABLE=true

# enable default branch icon (based on POWERLEVEL9K_MODE)
unset POWERLEVEL9K_VCS_BRANCH_ICON

# typeset POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='➜'
# typeset POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='%%'
typeset POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='»'
typeset POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION=''

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.zshrc.
if $NOCT_INSTANT_PROMPT \
		&& (( ! ${+functions[p10k-instant-prompt-finalize]} )); then
	p10k-instant-prompt-finalize
fi

# * End Profiling
if [[ -n $NOCT_PROFILE_ZSH ]]; then
	zprof
elif [[ -n $NOCT_TIME_ZSH ]]; then
	print "[zshrc] loaded in ${(M)$(( SECONDS * 1000 ))#*.?} ms"
fi

# Local Variables:
# mode: sh
# End:
