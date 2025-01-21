# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
GOOGLE_APPLICATION_CREDENTIALS="/etc/weighty-fabric-265417-5871dfe15bb3.json"
PATH=$PATH:$HOME/bin

export PATH GOOGLE_APPLICATION_CREDENTIALS

/root/close_ssd.sh
