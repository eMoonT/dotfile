#!/bin/sh

#
# Clone or pull
#

ZINIT_HOME="${ZINIT_HOME:-$ZPLG_HOME}"
if [ -z "$ZINIT_HOME" ]; then
	    ZINIT_HOME="${ZDOTDIR:-$HOME}/.zinit"
fi

ZINIT_BIN_DIR_NAME="${ZINIT_BIN_DIR_NAME:-$ZPLG_BIN_DIR_NAME}"
if [ -z "$ZINIT_BIN_DIR_NAME" ]; then
	    ZINIT_BIN_DIR_NAME="bin"
fi

if ! test -d "$ZINIT_HOME"; then
	    mkdir "$ZINIT_HOME"
	        chmod g-w "$ZINIT_HOME"
		    chmod o-w "$ZINIT_HOME"
fi

if ! command -v git >/dev/null 2>&1; then
	    echo "▓▒░ Something went wrong: no git available, cannot proceed."
	        exit 1
fi

# Get the download-progress bar tool
if command -v curl >/dev/null 2>&1; then
	    mkdir -p /tmp/zinit
	        cd /tmp/zinit 
		    curl -fsSLO https://raw.githubusercontent.com/zdharma/zinit/master/git-process-output.zsh && \
			            chmod a+x /tmp/zinit/git-process-output.zsh
						elif command -v wget >/dev/null 2>&1; then
							    mkdir -p /tmp/zinit
							        cd /tmp/zinit 
								    wget -q https://raw.githubusercontent.com/zdharma/zinit/master/git-process-output.zsh && \
									            chmod a+x /tmp/zinit/git-process-output.zsh
						fi

						echo
						if test -d "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME/.git"; then
							    cd "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME"
							        echo "▓▒░ Updating DHARMA Initiative Plugin Manager at $ZINIT_HOME/$ZINIT_BIN_DIR_NAME"
								    git pull origin master
							    else
								        cd "$ZINIT_HOME"
									    echo "▓▒░ Installing DHARMA Initiative Plugin Manager at $ZINIT_HOME/$ZINIT_BIN_DIR_NAME"
									        { git clone --progress https://github.com/zdharma/zinit.git "$ZINIT_BIN_DIR_NAME" \
											        2>&1 | { /tmp/zinit/git-process-output.zsh || cat; } } 2>/dev/null
										    if [ -d "$ZINIT_BIN_DIR_NAME" ]; then
											            echo
												            echo "▓▒░ Zinit succesfully installed at $ZINIT_HOME/$ZINIT_BIN_DIR_NAME".
													            VERSION="$(command git -C "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME" describe --tags 2>/dev/null)" 
														            echo "▓▒░ Version: $VERSION"
															        else
																	        echo
																		        echo "▓▒░ Something went wrong, couldn't install Zinit at $ZINIT_HOME/$ZINIT_BIN_DIR_NAME"
																			    fi
										    fi

										    #
										    # Modify .zshrc
										    #
										    THE_ZDOTDIR="${ZDOTDIR:-$HOME}"
										    RCUPDATE=1
										    if egrep '(zinit|zplugin)\.zsh' "$THE_ZDOTDIR/.zshrc" >/dev/null 2>&1; then
											        echo "▓▒░ .zshrc already contains \`zinit …' commands – not making changes."
												    RCUPDATE=0
										    fi

										    if [ $RCUPDATE -eq 1 ]; then
											        echo "▓▒░ Updating $THE_ZDOTDIR/.zshrc (10 lines of code, at the bottom)"
												    ZINIT_HOME="$(echo $ZINIT_HOME | sed "s|$HOME|\$HOME|")"
												        command cat <<-EOF >> "$THE_ZDOTDIR/.zshrc"

### Added by Zinit's installer
if [[ ! -f $ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$ZINIT_HOME" && command chmod g-rwX "$ZINIT_HOME"
    command git clone https://github.com/zdharma/zinit "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME" && \\
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \\
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh"
autoload -Uz _zinit
(( \${+_comps} )) && _comps[zinit]=_zinit
EOF
    file="$(mktemp)"
        command cat <<-EOF >>"$file"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \\
    zinit-zsh/z-a-rust \\
    zinit-zsh/z-a-as-monitor \\
    zinit-zsh/z-a-patch-dl \\
    zinit-zsh/z-a-bin-gem-node

EOF
echo
echo "▓▒░ Would you like to add 4 useful plugins" \
	    "- the most useful annexes (Zinit extensions that add new" \
	        "functions-features to the plugin manager) to the zshrc as well?" \
		    "It will be the following snippet:"
    command cat "$file"
        echo -n "▓▒░ Enter y/n and press Return: "
	    read input
	        if [ "$input" = y ] || [ "$input" = Y ]; then
			        command cat "$file" >> "$THE_ZDOTDIR"/.zshrc
				        echo
					        echo "▓▒░ Done."
						        echo
							    else
								            echo
									            echo "▓▒░ Done (skipped the annexes chunk)."
										            echo
											        fi

												    command cat <<-EOF >> "$THE_ZDOTDIR/.zshrc"
### End of Zinit's installer chunk
EOF
		fi

		command cat <<-EOF

▓▒░ A quick intro to Zinit: below are all the available Zinit
▓▒░ ice-modifiers, grouped by their role by different colors): 
▓▒░
▓▒░ id-as'' as'' from'' wait'' trigger-load'' load'' unload'' 
;219m▓▒░ pick'' src'' multisrc'' pack'' param'' extract'' atclone''
▓▒░ atpull'' atload'' atinit'' make'' mv'' cp'' reset''
▓▒░ countdown'' ;160mcompile'' nocompile'' nocd'' if'' has'' 
▓▒░ cloneopts'' depth'' proto'' on-update-of'' subscribe''
▓▒░ bpick'' cloneonly'' service'' notify'' wrap-track''
▓▒░ bindmap'' atdelete'' ver'' 
 
▓▒░ No-value (flag-only) ices:
▓▒░ svn git silent lucid light-mode is-snippet blockf nocompletions
▓▒░ run-atpull reset-prompt trackbinds aliases sh bash ksh csh

For more information see:
- README section on the ice-modifiers:
    - https://github.com/zdharma/zinit#ice-modifiers,
- intro to Zinit at the Wiki:
    - https://zdharma.org/zinit/wiki/INTRODUCTION/,
- zinit-zsh GitHub account, which holds all the available Zinit annexes:
    - https://github.com/zinit-zsh/,
- For-Syntax article on the Wiki; it is less directly related to the ices, however, it explains how to use them conveniently:
    - https://zdharma.org/zinit/wiki/For-Syntax/.
EOF
