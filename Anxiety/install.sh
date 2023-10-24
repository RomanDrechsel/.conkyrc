#!/bin/bash
pwd="$(dirname "$0")"

mkdir -p ~/.fonts
cp "$pwd/fonts"/*.*tf ~/.fonts
fc-cache -f ~/.fonts

#background image location
bg_placeholder="--lua_load"
if [ -n "$bg_placeholder" ]; then
    # replace background image location
    sed -i "s|$bg_placeholder|lua_load = '$pwd/conky.lua',|g" "$pwd/.conkyrc"
fi

#symlink
ln -sf "$pwd/.conkyrc" ~/.conkyrc