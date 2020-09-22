# My Terminal configurations

> So I don't need to feel poor when I get a new computer

Generally this is just contents of my `~/.config/` folder. It contains
configurations for different tools I use frequently.

## Installing

To use my configurations on your machine, just clone the repository to your home
folder:

```shell
git clone git@github.com:jehna/my-terminal-config.git ~/.config
```

This creates a folder called `.config/` to your home folder.

See app-specific installation instructions below:

### Installing bash

To install the bash config, add the following line to your own `~/.bash_profile`
file:

```
source ~/.config/bash/main.bash
```

This installs the common bash startup scripts from the `bash/` folder.

### Installing brew packages

After installing `brew` to your machine you can use the following command to
install all global packages:

```
brew bundle --file=~/.config/brew/Brewfile
```

This takes all the dependencies from the Brewfile and installs them on your
machine locally

#### Updating Homebrew list of packages

When you install a new Homebrew package (run `brew install ...`), you should
update your global package list by running:

```
brew bundle dump -f --file=~/.config/brew/Brewfile
```

This updates your local list of installed Homebrew packages

### Installing VSCode configurations

The configuraitons need to be linked from their original place to use the
configs from this repo:

```
rm ~/Library/Application\ Support/Code/User/settings.json
rm ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.config/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.config/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
```

#### Installing VSCode plugins

This repository also has a "vscode packages file", wihch you can use to track
the installed plugins for VSCode. You can install all packages by running:

```
code --list-extensions | comm -13 - ~/.config/vscode/extensions.list | xargs -I {} code --install-extension {} # Adds new extensions
code --list-extensions | comm -23 - ~/.config/vscode/extensions.list | xargs -I {} code --uninstall-extension {} # Removes old extensions
```

#### Updating plugin list

Keeping the plugin list up to date requires manual work (like with Homebrew),
and you can update the extension list by running:

```
code --list-extensions > ~/.config/vscode/extensions.list
```

## Adding new files

If you fork this repo and add new configurations, make sure that you don't
commit any tokens or hashes that cannot be released to public.

Many programs use the folder as the place to save their configurations, and
those can include items that should not be disclosed to the public.

## Features

Currently includes my git config with aliases to:
* `git lg` = [Better Git log](https://coderwall.com/p/euwpig/a-better-git-log)
* `git dif` = Git diff by one character (normal diff is by line)
* `git grep-blame` = Same as git grep, but shows blame for each line
* `git show-dropped-stashes` = Dropped a stash by accident? You can recover it
  with this command.

## Contributing

This is pimarily menat to be my personal configuration stash, but I'm always
open to add good configs. If you have any suggestions, just pop a pull request
and I'll take a look.

## Licensing

This repository is licensed under MIT license.
