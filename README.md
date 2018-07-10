# Dotfiles

Stuffs that makes my life a bit easier...

## Installation

You can install this via the command-line with either `curl` or `wget`.

### via curl

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rpidanny/dotfiles/master/scripts/install.sh)"
```

### via wget

```shell
sh -c "$(wget https://raw.githubusercontent.com/rpidanny/dotfiles/master/scripts/install.sh -O -)"
```

## Customization

You can customize these dotfiles using `.local` files. These can be used to add custom commands or configure things that you don't want to commit to a public repo.

For example, to overwrite stuff in the `.zshrc` file, make a file called `.zshrc.local` and put your stuff in there.

When you make a new `.local` file, you'll have to restart the terminal.