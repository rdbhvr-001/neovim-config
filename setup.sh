#!/bin/bash

# This is my minimal nvim config, that is efficient enough instead of having tons of plugins
# This script auto installs the nvim config
# Truely, I hate editing configs. So it is vibe coded for 100%.

CONFIG_DIR="$HOME/.config"
# Backup any old nvim configs if it existed
if [[ -d "$CONFIG_DIR/nvim" ]]; then
    echo "[Info] Backing up your nvim config to $CONFIG_DIR/nvim.old"
    mv -v ~/.config/nvim ~/.config/nvim.old
fi
echo ""
# Copy my config to the ~/.config/nvim
echo "[Info] Copying my nvim config to $CONFIG_DIR/nvim"
echo "[Tip] For restoring your old config : Follow the steps in your terminal."
echo "      [Step 1] rm -rf ~/.config/nvim"
echo "      [Step 2] mv ~/.config/nvim.old ~/.config/nvim"
echo ""
cp -rv ./nvim $CONFIG_DIR/nvim
echo "[+] Done, Enjoy nvim"



