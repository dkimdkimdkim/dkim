### Add the following lines to the beginning of your .bash_profile or .bashrc:
#
#PERSONAL_GIT="${HOME}/git/dkim/"
#PERSONAL_BASHRC="bashrc"
#FULL_BASHRC_PATH="${PERSONAL_GIT}/${PERSONAL_BASHRC}"
#
#if [ -d "${FULL_BASHRC_PATH}" ]; then
#    source ${FULL_BASHRC_PATH}
#fi
###############################################################################

# Git branch in prompt.
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

parse_machine() {
    echo
    return
    local path=`pwd 2> /dev/null | grep 'Volume'`
    if [ -n $path ] ; then
        echo $path
    fi
}

export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\]\[\033[31m\]\$(parse_machine)\]\033[00m\] $ "

function spam () {
    while true; do curl -s "$@" > /dev/null ; done
}

alias ls="ls -CFG"

function rgrep() { grep -R "$@" . ; }

alias bashrc="vim ~/.bash_profile ; source ~/.bash_profile ; echo bash_profile reloaded"

export PATH="$PATH:~/bin"

bind '"\e[1;2C":forward-word'
bind '"\e[1;2D":backward-word'
