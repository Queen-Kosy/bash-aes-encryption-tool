# bash-aes-encryption-tool
A simple Bash-based AES encryption and decryption tool that demonstrates the core components of encryption logic using AES-128-CBC and PKCS7 padding. Ideal for beginners who want to understand how encryption works in practice.

 🔧 **Features**

* AES-128-CBC encryption and decryption
* PKCS#7 padding compatible with CryptoJS
* Outputs ciphertext in Hexadecimal format
* Beginner-friendly and easy to modify

---

## 📘 Usage

### 1️⃣ Clone the repository

```bash
git clone https://github.com/Queen-Kosy/bash-aes-encryption-tool.git
cd bash-aes-encryption-tool
```

### 2️⃣ Make the scripts executable

```bash
chmod +x encrypt.sh decrypt.sh
```

### 3️⃣ Run the scripts

**Encryption**

```bash
./encrypt_aes_cbc.sh -p '<insert your json plain text here>' -k "<insert your secret key here>" -v "<insert your initialization vector here>"
```

**Decryption**

```bash
./decrypt_aes_cbc.sh -c "<insert your cipher text here>" -k "<insert your secret key here>" -v "<insert your initialization vector here>"
```

---

> ⚠️ The key and IV must match the required length (16 bytes for AES-128).

---

 ⚠️ **Tool-Specific Disclaimer**

This tool is **designed specifically for AES encryption/decryption** using the following configuration:

* **Algorithm:** AES (Advanced Encryption Standard)
* **Key size:** 128-bit (16 bytes)
* **Mode:** CBC (Cipher Block Chaining)
* **Padding:** PKCS#7
* **Output format:** Hexadecimal

It may **not work** with:

* AES keys of different lengths (e.g., 192-bit, 256-bit)
* Other block cipher modes (e.g., ECB, GCM)
* Different padding schemes (e.g., ANSI X.923, ISO 10126)
* Non-hex output formats (e.g., Base64 unless modified)

This tool is intended **for educational and demonstration purposes only**. Using incompatible inputs may produce errors or incorrect results.

---

## 📚 Educational Purpose

This tool is for learning and experimentation do **not** use it in production with sensitive data.

---

## 🧠 Author

**Kosi Destiny**
💬 Exploring cryptography and cybersecurity through practical tools.
