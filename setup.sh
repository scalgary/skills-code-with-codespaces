#!/bin/bash

# setup.sh - Script for setting up uv in GitHub Codespace
# Usage: chmod +x setup.sh && ./setup.sh


# setup.sh - Script simple pour uv
set -e

echo "🚀 Configuration uv..."

# Installer uv
pip install uv

# Créer pyproject.toml simple
cat > pyproject.toml << EOF
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.9"
dependencies = []

[tool.uv]
dev-dependencies = [
    "pytest",
    "black",
]
EOF

# Créer le lock file
uv lock

# Installer les dépendances
uv sync



echo "✅ Configuration terminée!"
echo ""
echo "Commandes disponibles:"
echo "• uv add <package>     - Ajouter une dépendance"
echo "• uv run <command>     - Exécuter une commande"
echo "• uv sync              - Synchroniser les dépendances"

source 