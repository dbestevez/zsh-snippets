# zsh-snippets

- Add, update, list, search and delete snippets.
- Supports auto-completion.
- Supports placeholders in snippets with forward/backward jump modes.
- Supports persistent snippets.

![Usage](https://github.com/dbestevez/zsh-snippets/blob/master/images/usage_high.gif)

What makes this different from other zsh-snippets plugins? The answer is **persistency** and **placeholders**.

**Persistency**

The plugin can be configured to work with or without persistency. With persistency *enabled*, snippets will be saved to a file and will be shared between different shell sessions. With persistency *disabled*, snippets will only be available in the shell session where they were defined.

Snippets in shell were created to be something temporal because for persistent shortcuts to common actions you can use regular aliases. So why would anyone want a plugin for zsh snippets with persistency? Like many others, I keep my aliases in my dotfiles repository and I use those dotfiles in any system I need. Some of the aliases I need for work can contain sensible information so I wanted a different way to manage shortcuts to common actions that allowed me to keep my aliases clean.

**Placeholders**

This plugin supports snippets with placeholders. A placeholder is a string that represents a real value you should use when the command is executed. Placeholders must follow the format `${<name>}` where `<name>` can be any alphanumeric string.  It is also possible to define a placeholder without any name. These are valid placeholders:

```
${}
${1}
${host}
${name2}
```

Snippets must be quoted when using the `add` action. Do not forget to escape `$` if you use double quotes.

After snippet expansion, placeholders can replaced from left to right (forward mode) or from right to left (backward mode). The default mode is *forward*.

After expanding a shortcut the cursor appears at the end of the line so I personally prefer to replace placeholders from right to left.

## Installation

### Plugin manager

It is recommended to manage plugins like this with a plugin manager. There are many out there but the way to install plugins are quite similar. For example, to install the plugin with `zgen` add the following line to the list of plugins in your `.zshrc` or similar.

```
zgen "dbestevez/zsh-snippets"
```

Please, refer to the official documentation of your plugin manager to know how to install `zsh-snippets`

### Alias

It is recommended to add the following alias to your `.aliases`:

```
alias zsp="zsh_snippets"
```

### Bindings

Add the following bindings to your `.zshrc`

```
bindkey '^S^J' zsh-snippets-widget-list
bindkey '^S^L' zsh-snippets-widget-expand
bindkey '^S^K' zsh-snippets-widget-search
bindkey '^S^H' zsh-snippets-widget-jump
```

## Usage

Here you can find an example of how to use `zsh-snippets`. Note that:

- All commands and snippets are auto-completed by pressing `tab` key.
- In the following example, '!' means your current cursor in terminal.

```
# Add a 'mysql' snippet
$ zsp add mysql "mysql -h\${host} -u\${user} -p\${password}"

# List snippets or type binded key `^S^J`
$ zsp list

# Expand a snippet
$ mysql!

# It will be expanded into
$ mysql -h${host} -u${user} -p${password}

# Press `^S^H` to start replacing the placeholders (backward mode)
$ mysql -h${host} -u${user} -p!

# Press `^S^H` to start replacing the placeholders (forward mode)
$ mysql -h! -u${user} -p{password}

# Delete a snippet
zsp delete mysql
```

## Credits

Thanks to [willghatch](https://github.com/willghatch) for the [willghatch/zsh-snippets](https://github.com/willghatch/zsh-snippets) plugin, my first contact with zsh snippets.

Thanks to [1ambda](https://github.com/1ambda) for the [1ambda/zsh-snippets](https://github.com/1ambda/zsh-snippets) plugin, the original repository I forked.

Thanks to [verboze](https://github.com/verboze) for the [verboze/zsh-snippets](https://github.com/verboze/zsh-snippets) plugin, the repository where I take the idea for placeholders from.
