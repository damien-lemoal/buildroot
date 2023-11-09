#

# Resize the terminal to match the serial console size
resize > /dev/null

# Some convenient aliases
alias cls='clear'
alias ll='ls -aFl --color=auto'
alias off='poweroff'

alias ltssm='devmem 0xfe150300'
alias lspcivvv='lspci -vvv -s 0000:01:00.0'
