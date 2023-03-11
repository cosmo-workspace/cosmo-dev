# Go
export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH

# home bin
mkdir -p $HOME/bin
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

# git verified commit
export GPG_TTY=$(tty)

# create-react-app@5 hot reload bug
export WDS_SOCKET_PORT=0

# .bashrc ==========================================
. ~/.bashrc
#===================================================

