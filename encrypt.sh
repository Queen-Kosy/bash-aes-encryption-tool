#!/usr/bin/env bash
# encrypt_aes_cbc.sh
# Encrypt JSON data using AES-128-CBC with PKCS#7 padding (CryptoJS-compatible)
#
# Usage:
#   ./encrypt_aes_cbc.sh -p '{"username":"admin","password":"123"}' -k "<key_string>" -v "<iv_string>"
#   echo '{"username":"admin"}' | ./encrypt_aes_cbc.sh -k "<key>" -v "<iv>"

set -euo pipefail

PLAINTEXT=""
KEY_STR=""
IV_STR=""
OUTFILE="/dev/stdout"

usage() {
  cat <<EOF
Usage: $0 -p <json_plaintext> -k <key_string> -v <iv_string> [-o <outfile>]

Examples:
  $0 -p '{"user":"test"}' -k "mysecretkey12345" -v "myivvector123456"
  echo '{"user":"test"}' | $0 -k "mysecretkey12345" -v "myivvector123456"

EOF
  exit 1
}

while getopts "p:k:v:o:h" opt; do
  case "$opt" in
    p) PLAINTEXT="$OPTARG" ;;
    k) KEY_STR="$OPTARG" ;;
    v) IV_STR="$OPTARG" ;;
    o) OUTFILE="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# If plaintext not passed via -p, try read from stdin
if [[ -z "$PLAINTEXT" ]]; then
  if ! tty -s; then
    PLAINTEXT="$(cat <&0)"
  fi
fi

if [[ -z "$PLAINTEXT" || -z "$KEY_STR" || -z "$IV_STR" ]]; then
  echo "Error: plaintext, key and iv are required."
  usage
fi

# Convert key and iv to hex (UTF-8)
keyhex="$(printf '%s' "$KEY_STR" | xxd -p | tr -d '\n')"
ivhex="$(printf '%s' "$IV_STR" | xxd -p | tr -d '\n')"

# Warn if lengths are unexpected
if [[ ${#keyhex} -ne 32 ]]; then
  echo "Warning: key length is ${#keyhex} hex chars (${#keyhex}/2 bytes). Expected 32 hex chars (16 bytes) for AES-128."
fi
if [[ ${#ivhex} -ne 32 ]]; then
  echo "Warning: iv length is ${#ivhex} hex chars (${#ivhex}/2 bytes). Expected 32 hex chars (16 bytes)."
fi

# Encrypt with OpenSSL AES-128-CBC PKCS#7
# -nosalt to match CryptoJS.format.Hex output
# output in binary first, then convert to hex
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
plaintext_file="$tmpdir/plain.txt"
cipher_file="$tmpdir/cipher.bin"

printf '%s' "$PLAINTEXT" > "$plaintext_file"

openssl enc -aes-128-cbc -e -in "$plaintext_file" -K "$keyhex" -iv "$ivhex" -nosalt -out "$cipher_file"

# Convert binary to hex string
xxd -p "$cipher_file" | tr -d '\n' > "$OUTFILE"

echo ""
