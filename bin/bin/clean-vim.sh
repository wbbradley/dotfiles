#!/bin/bash

echo "Cleaning Neovim state and cache..."
rm -rf ~/.local/{state,share}/nvim
rm -rf ~/.cache/nvim
