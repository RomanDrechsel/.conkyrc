#!/bin/bash
dir="$(pwd;)";

echo "$dir"

mkdir -p ~/.fonts
cp "$dir/fonts"/*.*tf ~/.fonts
fc-cache -f ~/.fonts

#background image location
bg_placeholder="--lua_load"
if [ -n "$bg_placeholder" ]; then
    # replace background image location
    sed -i "/$bg_placeholder/c\    lua_load = '$dir/lua/conky.lua', $bg_placeholder" "$dir/.conkyrc"
fi

#symlink
ln -sf "$dir/.conkyrc" ~/.conkyrc
