[user]
	name = rpidanny
	email = abhishekmaharjan1993@gmail.com
[push]
	default = upstream
[color]
	diff = auto
[alias]
	lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	cleanup = "!git branch --merged | grep  -v '\\*\\|master' | xargs -n 1 git branch -d"
[hub]
	protocol = https
[help]
	autocorrect = 1
[http]
	sslVerify = false
[filter "lfs"]
	clean = git-lfs clean %f
	smudge = git-lfs smudge %f
	required = true