#!/bin/bash
sudo apt-get update
sudo apt-get install sl
echo "export PATH=\$PATH:/usr/games" >> ~/.bashrc

echo "🚀 Initialisation du Codespace..."



# Ajouter des alias utiles
echo "
# Alias pour uv
alias uv-install='uv pip install'
alias uv-compile='uv pip compile requirements.in'
alias uv-sync='uv pip sync requirements.txt'
alias uv-update='uv pip compile requirements.in && uv pip sync requirements.txt'
alias activate='source venv/bin/activate'

# Auto-activation de l'environnement virtuel
if [ -f venv/bin/activate ]; then
    source venv/bin/activate
fi
" >> ~/.bashrc

echo "✅ Codespace configuré avec succès!"