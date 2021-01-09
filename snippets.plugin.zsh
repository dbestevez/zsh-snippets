#!/usr/bin/env zsh

# ---
# Adds a snippet to the list.
#
# @param $1 The snippet shortcut.
# @param $2 The snippet value.
# ---
_zsh_snippets_add_snippet() {
    if [ -z $1 ] || [ -z $2 ]; then
        _zsh_snippets_help "Shortcut and/or snippet argument missing"
        return 1
    fi

    snippets[$1]="$2"
    _zsh_snippets_save
}

# ---
# Changes the jump mode to the provided mode.
#
# @param $1 The jump mode.
# ---
_zsh_snippets_change_jump_mode() {
    if [[ "$1" != "forward" ]] && [[ "$1" != "backward" ]]; then
        _zsh_snippets_help "Invalid jump mode (modes: forward/backward)"
        return 1
    fi

    jumpMode="$1"
    _zsh_snippets_save
}

# ---
# Changes the jump mode to the provided mode.
#
# @param $1 The jump mode.
# ---
_zsh_snippets_change_persistency() {
    if [ $1 != true ] && [ $1 != false ]; then
        _zsh_snippets_help "Invalid value (values: true/false)"
        return 1
    fi

    persistency=$1
    _zsh_snippets_save
}

# ---
# Deletes a snippet from the list.
#
# @param $1 The snippet shortcut.
# ---
_zsh_snippets_delete_snippet() {
    if [ -z $1 ]; then
        _zsh_snippets_help "Shortcut argument missing"
        return 1
    fi

    unset "snippets[$1]"
    _zsh_snippets_save
}

# ---
# Shows the shortcut extracted from the current left buffer.
# ---
_zsh_snippets_get_shortcut() {
    echo ${LBUFFER[(w)-1]}
}

# ---
# Shows the snippet for the provided shortcut.
#
# @param $1 The shortcut.
# ---
_zsh_snippets_get_snippet() {
    if [ -z $1 ]; then
        return 0
    fi

    echo ${snippets[$1]}
}

# ---
# Shows the list of snippets. If a shortcut is provided as parameter, filters
# the list and shows only the items that match or partially match the provided
# shortcut.
#
# @param $1 The shortcut to filter the list by.
# ---
_zsh_snippets_get_snippets() {
    local list=$(print -a -C 2 ${(kv)snippets})

    if [ ! -z $1 ]; then
        list=$(echo "$list" | grep "^$1")
    fi

    echo "$list"
}

# ---
# Shows the help message. If an error message is provided, shows the error
# message before the help.
#
# @param $1 The error message.
# ---
_zsh_snippets_help() {
    if [ ! -z $1 ]; then
        echo -e "\e[31;1mzsh_snippets: $1\033[0m"
    fi

    echo "Usage: zsh_snippets ACTION [SHORTCUT] [SNIPPET]"
    echo ""
    echo "   Manages persistent zsh snippets"
    echo ""
    echo "Actions:"
    echo "   add     SHORTCUT  SNIPPET Add a new snippet for the provided shortcut"
    echo "   delete  SHORTCUT          Delete the snippet for the provided shortcut"
    echo "   expand  SHORTCUT          Expand the shortcut"
    echo "   help                      Shows this help message"
    echo "   list   [SHORTCUT]         Shows the list of snippets matching the SHORTCUT"
    echo "   mode   [MODE]             Changes the jump mode (forward/backward)"
}

# ---
# Initializes the zsh-snippets plugin.
# ---
_zsh_snippets_init() {
    if [ ! -e "$SNIPPET_FILE" ]; then
        $(which touch) $SNIPPET_FILE
        $(which chmod) +x $SNIPPET_FILE

        persistency=true
        jumpMode="forward"
        typeset -g -A snippets
        _zsh_snippets_save
    fi

    source $SNIPPET_FILE
}

# ---
# Removes a placeholder and puts the cursor in position to replace it with
# the real value.
# ---
_zsh_snippets_jump() {
    local str=$BUFFER

    [[ "$str" =~ (${[a-zA-Z0-9]}) ]] || return 0

    if [ "$jumpMode" = "backward" ]; then
        left="${str%(#m)([$]\{[-a-zA-Z0-9]#\}*)}"
        right="${MATCH#([$]\{[a-zA-Z0-9]#\}*)}"
    else
        right="${str#(#m)(*[$]\{[-a-zA-Z0-9]#\})}"
        left="${MATCH%(*[$]\{[-a-zA-Z0-9]#\})}"
    fi

    BUFFER=$left$right
    CURSOR=${#left}
}

# ---
# Saves the zsh_snippets file.
# ---
_zsh_snippets_save() {
    echo "persistency=$persistency" > $SNIPPET_FILE
    echo "jumpMode=\"$jumpMode\"" >> $SNIPPET_FILE

    [ $persistency = false ] && return 0
    typeset -p snippets >> $SNIPPET_FILE
}

# ---
# Returns the version of the plugin.
# ---
_zsh_snippets_show_version() {
    echo $ZSH_SNIPPETS_VERSION
}

# ---
# Manages persistent zsh snippets.
# ---
zsh_snippets() {
    emulate -L zsh
    setopt extendedglob

    SNIPPET_FILE=~/.zsh_snippets

    _zsh_snippets_init

    local action=$1
    local shortcut=$2
    local snippet=$3

    if [ -z $action ]; then
        _zsh_snippets_help "Invalid action"
        return 1
    fi

    case $action in
        add)
            _zsh_snippets_add_snippet $shortcut $snippet
            ;;
        delete)
            _zsh_snippets_delete_snippet $shortcut
            ;;
        expand)
            _zsh_snippets_get_snippet $shortcut
            ;;
        help)
            _zsh_snippets_help
            ;;
        jump)
            _zsh_snippets_jump
            ;;
        list)
            _zsh_snippets_get_snippets $shortcut
            ;;
        mode)
            _zsh_snippets_change_jump_mode $shortcut
            ;;
        persistency)
            _zsh_snippets_change_persistency $shortcut
            ;;
        *)
            _zsh_snippets_help "Unrecognized action $action"
            ;;
    esac
}

# ---
# Expands a shortcut.
# ---
zsh-snippets-widget-expand() {
    local shortcut=$(_zsh_snippets_get_shortcut)
    local snippet=$(zsh_snippets expand $shortcut)

    LBUFFER=${LBUFFER%%$shortcut}
    LBUFFER+=$snippet

    zle -M ""
}

# ---
# Moves cursor between placeholders. Placeholders must be defined as ${} or
# ${alphanumeric}.
# ---
zsh-snippets-widget-jump() {
    zsh_snippets jump
}

# ---
# Shows the list of snippets.
# ---
zsh-snippets-widget-list() {
    zle -M "$(zsh_snippets list)"
}

# ---
# Shows the list of snippets filtered by the last word in the buffer.
# ---
zsh-snippets-widget-search() {
    local shortcut=$(_zsh_snippets_get_shortcut)

    zle -M "$(zsh_snippets list $shortcut)"
}

# Define widgets
zle -N zsh-snippets-widget-expand
zle -N zsh-snippets-widget-jump
zle -N zsh-snippets-widget-list
zle -N zsh-snippets-widget-search

# Add completion
fpath+="`dirname $0`"
