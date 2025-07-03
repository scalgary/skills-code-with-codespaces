#!/bin/bash
# setup.sh - Script for setting up uv + R in GitHub Codespace
# Usage: chmod +x setup.sh && ./setup.sh

set -e

echo "🚀 Configuration uv + R..."

# === CONFIGURATION PYTHON (uv) ===
echo "🐍 Configuration Python avec uv..."

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

# === CONFIGURATION R (renv) ===
echo "📊 Configuration R avec renv..."

# Vérifier si R est installé
if command -v R &> /dev/null; then
    echo "✅ R détecté"
    
    # Initialiser renv si pas déjà fait
    if [ ! -f "renv.lock" ]; then
        echo "🔧 Initialisation de renv..."
        Rscript -e "
        if (!require('renv', quietly = TRUE)) {
            install.packages('renv', repos = 'https://cloud.r-project.org/')
        }
        renv::init(bare = TRUE)
        "
        echo "✅ renv initialisé"
    else
        echo "✅ renv déjà configuré"
    fi
    
    # Installer packages R essentiels
    echo "📦 Installation des packages R..."
    Rscript -e "
    renv::install(c(
        'tidyverse',
        'ggplot2',
        'dplyr',
        'readr'
    ))
    renv::snapshot()
    "
    echo "✅ Packages R installés"
else
    echo "⚠️  R non détecté - installation des packages R ignorée"
fi

# === CONFIGURATION COMMUNE ===
echo "⚙️  Configuration finale..."

# Créer ou mettre à jour .gitignore
if [ -f ".gitignore" ]; then
    echo "📝 .gitignore existe déjà - ajout des entrées manquantes..."
    
    # Ajouter les entrées Python si elles n'existent pas
    if ! grep -q ".venv/" .gitignore; then
        echo "" >> .gitignore
        echo "# Python (ajouté par setup.sh)" >> .gitignore
        echo ".venv/" >> .gitignore
        echo "__pycache__/" >> .gitignore
        echo "*.pyc" >> .gitignore
        echo ".env" >> .gitignore
    fi
    
    # Ajouter les entrées R si elles n'existent pas et si R est disponible
    if command -v R &> /dev/null && ! grep -q ".Rproj.user/" .gitignore; then
        echo "" >> .gitignore
        echo "# R (ajouté par setup.sh)" >> .gitignore
        echo ".Rproj.user/" >> .gitignore
        echo ".Rhistory" >> .gitignore
        echo ".RData" >> .gitignore
        echo ".Ruserdata" >> .gitignore
        echo "renv/library/" >> .gitignore
        echo "renv/python/" >> .gitignore
        echo "renv/staging/" >> .gitignore
    fi
    
    echo "✅ .gitignore mis à jour"
else
    echo "📝 Création de .gitignore..."
    cat > .gitignore << EOF
# Python
.venv/
__pycache__/
*.pyc
.env

# R
.Rproj.user/
.Rhistory
.RData
.Ruserdata
renv/library/
renv/python/
renv/staging/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
EOF
    echo "✅ .gitignore créé"
fi

# Configurer auto-activation pour Python
echo '
# Auto-activation uv environment
if [ -f .venv/bin/activate ] && [ -z "$VIRTUAL_ENV" ]; then
    source .venv/bin/activate
    echo "🐍 uv environment activé"
fi

# Aliases utiles
alias py="uv run python"
alias uv-add="uv add"
alias uv-run="uv run"
alias uv-sync="uv sync"
' >> ~/.bashrc

echo "✅ Configuration terminée!"
echo ""
echo "🎯 Commandes disponibles:"
echo ""
echo "Python (uv):"
echo "• uv add <package>      - Ajouter une dépendance Python"
echo "• uv run <command>      - Exécuter une commande Python"
echo "• uv sync               - Synchroniser les dépendances"
echo "• py script.py          - Alias pour uv run python"
echo ""

if command -v R &> /dev/null; then
    echo "R (renv):"
    echo "• R                     - Lancer R"
    echo "• Rscript script.R      - Exécuter un script R"
    echo "• renv::install('pkg')  - Installer package R"
    echo "• renv::snapshot()      - Sauvegarder état R"
    echo ""
fi

echo "📝 Fichiers créés/mis à jour:"
echo "• pyproject.toml + uv.lock (Python)"
if [ -f "renv.lock" ]; then
    echo "• renv.lock (R)"
fi
if [ -f ".gitignore" ]; then
    echo "• .gitignore (mis à jour ou créé)"
fi

# Source bashrc pour activer les alias immédiatement
if [ -n "$BASH_VERSION" ]; then
    source ~/.bashrc 2>/dev/null || true
fi