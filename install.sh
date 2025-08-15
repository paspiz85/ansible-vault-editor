#!/bin/bash

COMMAND="/usr/bin/ansible-vault-editor"
sudo tee "$COMMAND" >/dev/null <<EOF
#!/bin/bash

if ! command -v ansible-vault &> /dev/null; then
  echo "Error: ansible is not installed" >&2
  exit 1
fi
if ! command -v gpg >/dev/null 2>&1; then
  echo "Error: gpg is not installed" >&2
  exit 1
fi

VAULTDIR="\$HOME/.ansible-vault"
mkdir -p "\$VAULTDIR"
chmod 700 "\$VAULTDIR"

usage() {
  cat <<USAGE
Usage:
  \$(basename "\$0") -c <keyname>        # save locally the encrypted vault key (input from stdin)
  \$(basename "\$0") -e <editor>         # save editor to use
  \$(basename "\$0") <keyname> <file>    # create or edit an ansible-vault file

USAGE
}

MODE=""
if [[ "\${1:-}" == -* ]]; then
  MODE="\${1:-}"
  shift
fi

KEYNAME="\${1:-}"
[[ -n "\$KEYNAME" ]] || { echo "Error: missing <keyname>" >&2; usage; exit 1; }
KEYFILE="\$VAULTDIR/\$KEYNAME.key.gpg"

if [ "\$MODE" == "-c" ]; then
  if [ -t 0 ]; then
    echo "Enter the Vault password (end with Ctrl-D):" >&2
    gpg -c --yes --cipher-algo AES256 -o "\$KEYFILE" -
  else
    TMP="\$(mktemp)"
    trap 'shred -u "\$TMP"' EXIT
    cat > "\$TMP"
    cat "\$TMP" | gpg -c --yes --cipher-algo AES256 -o "\$KEYFILE"
  fi
  chmod 600 "\$KEYFILE"
  exit 0
fi
if [ "\$MODE" == "-e" ]; then
  echo \$KEYNAME > "\$VAULTDIR/.editor"
  exit 0
fi
if [ -f "\$VAULTDIR/.editor" ]; then
  export EDITOR=\$(cat "\$VAULTDIR/.editor")
fi

[[ -f "\$KEYFILE" ]] || { echo "Error: key '\$KEYNAME' not found" >&2; exit 1; }

FILE="\${2:-}"
[[ -n "\$FILE" ]] || { echo "Error: missing <file>" >&2; usage; exit 1; }
if [ -f "\$FILE" ]; then
  ansible-vault edit --vault-id \$KEYNAME@<(gpg --quiet --decrypt \$KEYFILE) "\$FILE"
else
  ansible-vault create --vault-id \$KEYNAME@<(gpg --quiet --decrypt \$KEYFILE) "\$FILE"
fi
EOF
sudo chmod +x "$COMMAND"
