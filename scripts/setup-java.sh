#!/usr/bin/env bash
# Ensures a JDK 21 is available for building the Echo Technology mod.
# Idempotent: run it at the start of every session, because the v0 sandbox VM can be
# recreated between sessions, which wipes system packages and the ~/.gradle cache.
set -euo pipefail

has_jdk21() {
  command -v javac >/dev/null 2>&1 && javac -version 2>&1 | grep -qE 'javac 21(\.|$)'
}

if has_jdk21; then
  echo "[setup-java] $(javac -version 2>&1) already installed"
  exit 0
fi

if command -v dnf >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  echo "[setup-java] Installing Amazon Corretto 21 with dnf..."
  sudo dnf install -y -q java-21-amazon-corretto-devel
  javac -version
  exit 0
fi

# Fallback for environments without root access: portable Eclipse Temurin 21.
case "$(uname -m)" in
  x86_64) arch=x64 ;;
  aarch64 | arm64) arch=aarch64 ;;
  *) echo "[setup-java] Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
target="$HOME/.jdks/temurin-21"
if [ ! -x "$target/bin/javac" ]; then
  echo "[setup-java] Downloading Eclipse Temurin 21 ($arch)..."
  mkdir -p "$target"
  curl -fsSL "https://api.adoptium.net/v3/binary/latest/21/ga/linux/$arch/jdk/hotspot/normal/eclipse" \
    | tar -xz -C "$target" --strip-components=1
fi
"$target/bin/javac" -version
echo "[setup-java] Portable JDK at $target (scripts/build-mod.sh picks it up automatically)."
