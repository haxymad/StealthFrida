#!/bin/bash

# --- 1. Automated Downloading & Setup ---
echo "[*] Cloning Frida repository..."
git clone https://github.com/frida/frida.git
cd frida
git submodule update --init --recursive

echo "[*] Setting up custom GLib subproject..."
git clone https://github.com/frida/glib.git subprojects/glib

# --- 2. Environment Configuration ---
export ANDROID_NDK_ROOT=/home/lost/Android/Sdk/android-ndk-r25c
PYTHON_SITE_PACKAGES="/home/lost/.local/lib/python3.12/site-packages/frida/core.py"

# --- 3. Port Patches (27042 -> 44444) ---
echo "[*] Patching Ports in Core and Python Subprojects..."
# Standard Core
sed -i 's/27042/44444/g' subprojects/frida-core/lib/base/socket.vala
sed -i 's/27042/44444/g' subprojects/frida-core/tests/test-host-session.vala

# Python Subproject's internal Core copy
sed -i 's/27042/44444/g' subprojects/frida-python/subprojects/frida-core/lib/base/socket.vala
sed -i 's/27042/44444/g' subprojects/frida-python/subprojects/frida-core/tests/test-host-session.vala

# --- 4. Thread Patches ---
echo "[*] Patching Thread Names..."
sed -i 's/"frida-gadget"/"SyscallGadget"/g' subprojects/frida-core/lib/gadget/gadget-glue.c
sed -i 's/"frida-main-loop"/"SyscallLoop"/g' subprojects/frida-core/src/frida-glue.c
sed -i 's/"gum-js-loop"/"SyscallJS"/g' subprojects/frida-gum/bindings/gumjs/gumscriptscheduler.c
sed -i 's/"gmain"/"SysMain"/g' subprojects/glib/glib/gmain.c
sed -i 's/"gdbus"/"SysBus"/g' subprojects/glib/gio/gdbusprivate.c
sed -i 's/"pool-frida"/"pool-sys"/g' subprojects/glib/glib/gthreadpool.c
sed -i 's/"pool-%s"/"sys-%s"/g' subprojects/glib/glib/gthreadpool.c
sed -i 's/"pool-spawner"/"sys-spawner"/g' subprojects/glib/glib/gthreadpool.c

# --- 5. Agent-Bypass ---
echo "[*] Patching Agent Library Names..."
sed -i 's/"frida-agent-arm.so"/"sys-lib-32.so"/g' subprojects/frida-core/src/linux/linux-host-session.vala
sed -i 's/"frida-agent-arm64.so"/"sys-lib-64.so"/g' subprojects/frida-core/src/linux/linux-host-session.vala
sed -i 's/name = "frida-agent-arm.so"/name = "sys-lib-32.so"/g' subprojects/frida-core/src/linux/linux-host-session.vala
sed -i 's/name = "frida-agent-arm64.so"/name = "sys-lib-64.so"/g' subprojects/frida-core/src/linux/linux-host-session.vala
sed -i 's/"frida-agent-<arch>.so"/"sys-lib-<arch>.so"/g' subprojects/frida-core/src/linux/linux-host-session.vala

# --- 6. frida:rpc Bypass ---
echo "[*] Patching RPC Protocol Strings..."
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-gum/bindings/gumjs/runtime/message-dispatcher.js
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-gum/bindings/gumjs/runtime/worker.js
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-core/lib/base/rpc.vala
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-python/frida/core.py
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-node/src/frida_bindgen/assets/customization_helpers.ts
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-core/src/barebone/script-runtime/message-dispatcher.ts
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-go/frida/script.go
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-swift/Frida/Script.swift
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-core/tests/test-agent.vala
sed -i 's/frida:rpc/sys:io/g' subprojects/frida-gum/tests/gumjs/script.c

# Patch host python site-packages if it exists
if [ -f "$PYTHON_SITE_PACKAGES" ]; then
    sed -i 's/frida:rpc/sys:io/g' "$PYTHON_SITE_PACKAGES"
    sed -i 's/27042/44444/g' "$PYTHON_SITE_PACKAGES"
fi

# --- 7. ScriptEngine and GIOLb Bypass ---
echo "[*] Patching ScriptEngine and GIO Domains..."
sed -i 's/"GLib-GIO"/"SysIO"/g' subprojects/glib/gio/meson.build
sed -i 's/"GLib-GIO"/"SysIO"/g' subprojects/glib/gio/tests/meson.build

sed -i 's/\bScriptEngine\b/SysLogic/g' subprojects/frida-core/lib/payload/script-engine.vala
sed -i 's/\bScriptEngine\b/SysLogic/g' subprojects/frida-core/lib/payload/base-agent-session.vala
sed -i 's/\bScriptEngine\b/SysLogic/g' subprojects/frida-core/lib/gadget/gadget.vala

#gdbusProxy fix
sed -i '/G_DEFINE_TYPE_WITH_CODE/i typedef GDBusProxy SysBusProxy;\ntypedef GDBusProxyClass SysBusProxyClass;\ntypedef GDBusProxyPrivate SysBusProxyPrivate;' subprojects/glib/gio/gdbusproxy.c
sed -i 's/G_DEFINE_TYPE_WITH_CODE (GDBusProxy, g_dbus_proxy/G_DEFINE_TYPE_WITH_CODE (SysBusProxy, g_dbus_proxy/g' subprojects/glib/gio/gdbusproxy.c
sed -i 's/G_ADD_PRIVATE (GDBusProxy)/G_ADD_PRIVATE (SysBusProxy)/g' subprojects/glib/gio/gdbusproxy.c
sed -i 's/"GDBusProxy"/"SysBusProxy"/g' subprojects/glib/gio/gdbusproxy.c

#GumScriptFix
sed -i '/G_DEFINE_INTERFACE/i typedef GumScript SysScript;\ntypedef GumScriptInterface SysScriptInterface;' subprojects/frida-gum/bindings/gumjs/gumscript.c
sed -i 's/G_DEFINE_INTERFACE (GumScript,/G_DEFINE_INTERFACE (SysScript,/g' subprojects/frida-gum/bindings/gumjs/gumscript.c
sed -i 's/"GumScript"/"SysScript"/g' subprojects/frida-gum/bindings/gumjs/gumscript.c


# --- 8. Frida-Gum Meson Dependency Fix ---
echo "[*] Applying Meson Build Overrides..."
cat <<'EOF' > gum_glib_replacement.txt
glib_proj = subproject('glib', default_options: [
  'diet=' + diet.to_string(),
  'printf=' + allocator,
  'tests=false',
  'nls=disabled',
  'man=false',
  'gtk_doc=false',
])

glib_dep = glib_proj.get_variable('libglib_dep')
gobject_dep = glib_proj.get_variable('libgobject_dep')
gio_dep = glib_proj.get_variable('libgio_dep')
gio_os_package_dep = gio_dep

gio_dep_native = dependency('gio-2.0', native: true)

gio_os_package_name = (host_os_family == 'windows') ? 'gio-windows-2.0' : 'gio-unix-2.0'
EOF

sed -i "/glib_version_req = '>=2.72'/,/gio_dep_native = dependency('gio-2.0', native: true)/ {
    /glib_version_req = '>=2.72'/r gum_glib_replacement.txt
    d
}" subprojects/frida-gum/meson.build
rm gum_glib_replacement.txt

# --- 9. Python Wheel Preparation ---
echo "[*] Preparing Python Wheel..."
cd subprojects/frida-python
# Patching python source for the port before building the wheel
sed -i 's/27042/44444/g' frida/core.py
python setup.py bdist_wheel
pip uninstall -y frida
cd ../../

# --- 10. Final Build ---
echo "[*] Starting cross-compilation for Android..."
rm -rf build
./configure --host=android-arm64
make
