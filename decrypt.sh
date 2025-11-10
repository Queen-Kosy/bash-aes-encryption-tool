#!/usr/bin/env bash
# decrypt_aes_cbc.sh
# Decrypt a hex-encoded AES-CBC ciphertext (CryptoJS AES.encrypt(...).toString(CryptoJS.format.Hex))
#
# Usage:
#   ./decrypt_aes_cbc.sh -c "<cipher_hex>" -k "<key_string>" -v "<iv_string>"
# Or:
#   echo "<cipher_hex>" | ./decrypt_aes_cbc.sh -k "<key_string>" -v "<iv_string>"
#
# Notes:
# - The script converts the provided key and iv from UTF-8 bytes to hex (the same
#   way CryptoJS uses tr.enc.Utf8.parse(...)).
# - OpenSSL expects key and iv in hex; decryption uses AES-128-CBC with PKCS#7 padding.
# - If your key/iv are not 16 bytes (128 bits) decryption may still work depending on how
#   the frontend constructed them, but it's best if they are exactly 16 bytes.
set -euo pipefail

CIPHER_HEX=""
KEY_STR=""
IV_STR=""
OUTFILE="/dev/stdout"

usage() {
  cat <<EOF
Usage: $0 -c <cipher_hex> -k <key_string> -v <iv_string> [-o <outfile>]

Examples:
  $0 -c "5f2a..." -k "mysecretkey12345" -v "myivvector123456"
  echo "5f2a..." | $0 -k "mysecretkey12345" -v "myivvector123456"

EOF
  exit 1
}

while getopts "c:k:v:o:h" opt; do
  case "$opt" in
    c) CIPHER_HEX="$OPTARG" ;;
    k) KEY_STR="$OPTARG" ;;
    v) IV_STR="$OPTARG" ;;
    o) OUTFILE="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# If cipher not passed via -c, try read from stdin
if [[ -z "$CIPHER_HEX" ]]; then
  if ! tty -s; then
    # read all stdin, strip whitespace/newlines
    CIPHER_HEX="$(tr -d ' \n\r\t' <&0 || true)"
  fi
fi

if [[ -z "$CIPHER_HEX" || -z "$KEY_STR" || -z "$IV_STR" ]]; then
  echo "Error: cipher hex, key and iv are required."
  usage
fi

# Convert key and iv (UTF-8 strings) to hex (lowercase). This matches CryptoJS Utf8.parse bytes.
keyhex="$(printf '%s' "$KEY_STR" | xxd -p | tr -d '\n')"
ivhex="$(printf '%s' "$IV_STR" | xxd -p | tr -d '\n')"

# Warn if lengths are unexpected (AES-128 expects 16 bytes -> 32 hex chars)
if [[ ${#keyhex} -ne 32 ]]; then
  echo "Warning: key length is ${#keyhex} hex chars (${#keyhex}/2 bytes). Expected 32 hex chars (16 bytes) for AES-128."
fi
if [[ ${#ivhex} -ne 32 ]]; then
  echo "Warning: iv length is ${#ivhex} hex chars (${#ivhex}/2 bytes). Expected 32 hex chars (16 bytes)."
fi

# Create temp files
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
cipherbin="$tmpdir/cipher.bin"

# Convert hex ciphertext to binary
if ! printf '%s' "$CIPHER_HEX" | xxd -r -p > "$cipherbin" 2>/dev/null; then
  echo "Error: invalid ciphertext hex."
  exit 2
fi

# Decrypt using openssl. Use -nosalt because CryptoJS hex output does not include OpenSSL salt header.
# OpenSSL's default padding is PKCS#7 which is compatible with CryptoJS.
if ! openssl enc -aes-128-cbc -d -in "$cipherbin" -K "$keyhex" -iv "$ivhex" -nosalt -out "$OUTFILE" 2>/dev/null; then
  echo "Decryption failed. Possible causes:"
  echo " - wrong key or iv"
  echo " - ciphertext not produced as raw AES-CBC hex (CryptoJS.format.Hex expected)"
  echo " - key/iv length mismatch"
  exit 3
fi

exit 0
