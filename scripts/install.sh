echo 'Restoring dotfiles...'

dir="$HOME/workspace/personal"
mkdir -p $dir && cd $dir
git clone https://github.com/rpidanny/dotfiles.git
cd dotfiles
# TODO: create symlink-dorfiles.sh
sh symlink-dotfiles.sh