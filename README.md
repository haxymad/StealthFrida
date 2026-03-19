# 🚀 StealthFrida

> Custom-built **stealth version of Frida** designed to evade detection and enhance dynamic analysis.

---

## 🧠 Overview

**StealthFrida** is a modified build of Frida with multiple anti-detection patches applied at the core level.
It is tailored for **reverse engineering and security research** where standard Frida is easily detected.

---

## ⚡ Features

* 🔌 **Custom Port**
  Default Frida port (`27042`) changed to `44444`

* 🕵️ **Agent Renaming**
  `frida-agent` → `sys-lib-*` (bypass signature-based detection)

* 🔄 **RPC Rename**
  `frida:rpc` → `sys:io`

* 🧵 **Thread Name Masking**
  Removed common Frida thread identifiers

* 🧬 **Core String Modifications**
  Eliminates common detection fingerprints
  
* **Glib and Gio Patched** *

---

## 📁 Repository Structure

```
StealthFrida/
├── build.sh
├── frida/
├── frida-server
├── frida-*.whl
└── README.md
```

---

## 🛠️ Build Instructions

```bash
# Clone repo
git clone https://github.com/haxymad/StealthFrida.git
cd StealthFrida

# Run build script
chmod +x build.sh
./build.sh
```

---

**1.Find frida-python "frida-17.8.2-cp37-abi3-linux_x86_64.whl" and install it** 
---
**2.find frida-server and push it to android **
## 📱 Usage

### ▶️ Start Frida Server on Device

```bash
adb push frida-server /data/local/tmp/
adb shell chmod +x /data/local/tmp/frida-server
adb shell /data/local/tmp/frida-server &
```

---

### 🔗 Connect from PC

```bash
frida -H 127.0.0.1:44444 -U -n <target_app>
```

---


## ⚠️ Disclaimer

This project is intended for:

* Educational purposes
* Security research
* Ethical testing

❌ Do not use for unauthorized activities.

---

## 🧑‍💻 Author

**haxymad**
🔗 https://github.com/haxymad

---

## ⭐ Support

If you find this useful:

* ⭐ Star the repo
* 🍴 Fork it
* 🧠 Contribute ideas

---

## 🔥 Future Plans

* More Inject and Gadget 
* Auto-build pipeline
* Dynamic stealth injection techniques

---

> “Stay invisible. Instrument everything.” 👁️‍🗨️
