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

# dmesg tail
alias dmesgt='dmesg -wH'

# For local aliases
[ -f '.aliases.local' ] && source '.aliases.local'