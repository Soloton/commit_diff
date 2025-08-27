#!/usr/bin/bash
set -e

REPO_RAW="https://raw.githubusercontent.com/Soloton/commit_diff/master"
INSTALL_BIN="/usr/local/bin"
INSTALL_SHARE="/usr/local/share/commit_diff"

echo "Installing commit_diff..."

# create directory
sudo mkdir -p "$INSTALL_SHARE"

# download files
sudo curl -fsSL "$REPO_RAW/commit_diff.sh" -o "$INSTALL_SHARE/commit_diff.sh"
sudo curl -fsSL "$REPO_RAW/conventional_complex.tpl" -o "$INSTALL_SHARE/conventional_complex.tpl"

# permissions
sudo chmod +x "$INSTALL_SHARE/commit_diff.sh"

# symlink
if [ ! -L "$INSTALL_BIN/commit_diff" ]; then
  sudo ln -s "$INSTALL_SHARE/commit_diff.sh" "$INSTALL_BIN/commit_diff"
fi

echo "commit_diff installed successfully."
echo "Executable: $INSTALL_BIN/commit_diff"
echo "Templates:  $INSTALL_SHARE (you can add your own *.tpl files here)"

# check PATH
if ! command -v commit_diff >/dev/null 2>&1; then
  echo
  echo "WARNING: commit_diff is not in your PATH."
  echo "Add this line to your shell configuration (e.g. ~/.bashrc or ~/.zshrc):"
  echo "  export PATH=\$PATH:$INSTALL_BIN"
fi
