# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# powerlevel10k 
zinit ice depth=1
zinit light romkatv/powerlevel10k

# # 快速目录跳转
zinit ice lucid wait='1'
zinit light skywind3000/z.lua

# fzf-tab
#[[ $(command -v fzf) ]] && zinit ice lucid pick"fzf-tab.zsh" && zinit light _local/fzf-tab
#zinit ice lucid wait='zpcompinit'
#init light Aloxaf/fzf-tab

# # 自动建议
zinit ice lucid wait atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# # 语法高亮
zinit ice lucid wait atinit='zpcompinit'
zinit light zdharma/fast-syntax-highlighting

## sudo
zinit ice lucid wait='1'
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh

# 补全
zinit ice lucid wait blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# #Load OMZ 
zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/theme-and-appearance.zsh


# vi-mode
zinit snippet OMZ::plugins/vi-mode/vi-mode.plugin.zsh

## 解压缩
zinit ice svn lucid wait='1' 
zinit snippet OMZ::plugins/extract

## git
zinit ice lucid wait='1' 
zinit snippet OMZ::plugins/git/git.plugin.zsh


# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

# Vi-Mode
function zle-keymap-select {
	if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
		echo -ne '\e[1 q'
	elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
		echo -ne '\e[5 q'
  fi
}

### commond hot 
zsh_stats () {
  fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n20
}

# Change ls colours
LS_COLORS="ow=01;36;40" && export LS_COLORS

# make cd use the ls colours
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
autoload -Uz compinit
compinit

### proxy config
getIp() {
    export winip=$(ip route | grep default | awk '{print $3}')
    export wslip=$(ip addr | grep eth0 | grep inet | awk -F 'inet |/20' '{print $2}')
    export PROXY_SOCKS5="socks5://${winip}:7891"
    export PROXY_HTTP="http://${winip}:7890"
}

ip_() {
    getIp
    #https --follow -b https://api.ip.sb/geoip/$1
    curl cip.cc
    echo "WIN ip: ${winip}"
    echo "WSL ip: ${wslip}"
}

proxy_git () {
	  git config --global http.https://github.com.proxy ${PROXY_HTTP}
	    if ! grep -qF "Host github.com" ~/.ssh/config ; then
	      echo "Host github.com" >> ~/.ssh/config
	      echo "  User git" >> ~/.ssh/config
	      echo "  ProxyCommand nc -X 5 -x ${PROXY_SOCKS5} %h %p" >> ~/.ssh/config
	    else
	      lino=$(($(awk '/Host github.com/{print NR}'  ~/.ssh/config)+2))
	      sed -i "${lino}c\  ProxyCommand nc -X 5 -x ${PROXY_SOCKS5} %h %p" ~/.ssh/config
	    fi
}

proxy () {
    getIp
    # pip can read http_proxy & https_proxy
    export http_proxy="${PROXY_HTTP}"
    export HTTP_PROXY="${PROXY_HTTP}"
    export https_proxy="${PROXY_HTTP}"
    export HTTPS_PROXY="${PROXY_HTTP}"
    export ftp_proxy="${PROXY_HTTP}"
    export FTP_PROXY="${PROXY_HTTP}"
    export rsync_proxy="${PROXY_HTTP}"
    export RSYNC_PROXY="${PROXY_HTTP}"
    export ALL_PROXY="${PROXY_SOCKS5}"
    export all_proxy="${PROXY_SOCKS5}"
    # proxy_git
    if [ ! $1 ]; then
        ip_
    fi
    echo "Acquire::http::Proxy \"${PROXY_HTTP}\";" | sudo tee /etc/apt/apt.conf.d/proxy.conf >/dev/null 2>&1
    echo "Acquire::https::Proxy \"${PROXY_HTTP}\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf >/dev/null 2>&1
}

unpro () {
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
    unset ftp_proxy
    unset FTP_PROXY
    unset rsync_proxy
    unset RSYNC_PROXY
    unset ALL_PROXY
    unset all_proxy
    #sudo rm /etc/apt/apt.conf.d/proxy.conf
    git config --global --unset http.https://github.com.proxy
    ip_
}

# path
export MYVIMRC=~/.vimrc

# alias config
alias ra='ranger'
alias ne='neofetch | lolcat'
alias x='extract'
alias vim='nvim'

alias l='exa -alh'
alias fmax='find ./ -type f -print0  | xargs -0  du -h | sort -nr | head -n10'
alias cat='bat'
alias grep='grep --color=auto'

eval $(thefuck --alias)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export TERM=xterm-256color
