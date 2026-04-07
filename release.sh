#!/bin/bash

# Avbryt skriptet direkt om något kommando misslyckas
set -e

echo "🚀 Startar release-processen..."

# 1. Kontrollera vilken branch vi står på
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️ Varning: Du är inte på main/master-branchen (nuvarande: $CURRENT_BRANCH)."
    read -p "Vill du fortsätta ändå? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 2. Kontrollera att arbetsytan är ren (inga o-committade ändringar)
if ! git diff-index --quiet HEAD; then
    echo "❌ Fel: Du har o-committade ändringar. Vänligen gör en commit eller stash:a dem först."
    exit 1
fi

# 3. Hämta de senaste ändringarna från servern
echo "⬇️ Hämtar senaste ändringarna från remote ($CURRENT_BRANCH)..."
git pull origin "$CURRENT_BRANCH"

# 4. Be användaren om ett nytt versionsnummer
echo ""
echo "De 5 senaste taggarna:"
git tag --sort=-creatordate | head -n 5
echo ""
read -p "🏷️ Ange det nya versionsnumret (t.ex. v1.0.0): " VERSION

if [ -z "$VERSION" ]; then
    echo "❌ Fel: Versionen kan inte vara tom."
    exit 1
fi

# 5. Skapa en Git-tagg
echo "Skapar taggen $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

# 6. Pusha till remote
echo "⬆️ Pusher branch och tagg till remote..."
git push origin "$CURRENT_BRANCH"
git push origin "$VERSION"
echo "✅ Release $VERSION är nu skapad och pushad!"