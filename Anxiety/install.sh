#!/bin/bash
pwd="$(dirname "$0")"

cp "$pwd/fonts"/*.*tf ~/.fonts
fc-cache -f ~/.fonts

#background image location
bg_placeholder="#{background}"
if [ -n "$bg_placeholder" ]; then
    # Ersetze den alten Pfad durch den neuen Pfad
    sed -i "s|$bg_placeholder|\${image $pwd/background.jpg -p 0,0}#|g" "$pwd/.conkyrc"
fi

#symlink
ln -s -f "$pwd/.conkyrc" ~/.conkyrc