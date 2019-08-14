# SSH into aws EC2 instance
alias awslogin='ssh -i ~/Downloads/aws-ubuntu.pem ubuntu@ec2-52-207-235-38.compute-1.amazonaws.com'

# list files with size in descending order
alias sortfiles='du -sh * | sort -h'

# copy with progress
alias cp='rsync -ah --progress'

# heroku logs
alias herokulog='heroku logs --tail'

# apple display brightness
# alias bright='f() { sudo /home/abhishek/workspace/github/acdcontrol/acdcontrol /dev/usb/hiddev$1 $2}; f'

# git stuffs
alias gpom='git push origin master'
alias gpod='git push origin develop'
alias gpgm='git push gitlab master'
alias gpgd='git push gitlab develop'
alias gpbm='git push bitbucket master'
alias gpbd='git push bitbucket develop'
alias gcm='git checkout master'
alias gcd='git checkout develop'

# dmesg tail
alias dmesgt='dmesg -wH'

# arduino
alias arduino='/opt/arduino-1.8.9/arduino'

# For local aliases
[ -f '.aliases.local' ] && source '.aliases.local'
