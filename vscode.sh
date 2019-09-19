#!/bin/sh

if command -v code >/dev/null; then

  # from `code --list-extensions`
  modules="
dbaeumer.vscode-eslint
eamodio.gitlens
esbenp.prettier-vscode
gaearon.subliminal
vscodevim.vim
"
	for module in $modules; do
		code --install-extension "$module" || true
	done
fi
