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

This creates a folder called `.config/` to your home folder. After this you need
to install the main bash file in your own `~/.bash_profile` file:

```
source ~/.config/bash/main.bash
```

This installs the common bash startup scripts from the `bash/` folder.

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
