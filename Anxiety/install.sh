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
    sed -i "s|$bg_placeholder|lua_load = '$dir/conky.lua',|g" "$dir/.conkyrc"
fi

#symlink
ln -sf "$dir/.conkyrc" ~/.conkyrc
