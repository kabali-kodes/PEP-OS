#!/bin/bash
set -euo pipefail
apt update
apt install -y git python3 curl nodejs npm build-essential libgl1-mesa-dev \
bison flex gperf g++-multilib gcc-multilib libncurses5 ccache libssl-dev \
openjdk-11-jdk repo lxc waydroid python-is-python3 libgtk-3-dev netcat-openbsd unzip

npm install -g n && n 16.20.2
git config --global user.name "PEP OS"
git config --global user.email "pep@os.local"
ccache -M 30G
curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo
chmod +x /usr/local/bin/repo

# Tools
cat > /usr/local/bin/build-pep <<'EOF'
#!/bin/bash
set -euo pipefail
cd /workspaces/PEP-OS
if [[ ! -d "B2G" ]]; then
  git clone https://github.com/mozilla-b2g/B2G.git B2G
fi
cd B2G
REPO=/usr/local/bin/repo \
GITREPO=https://github.com/mozilla-b2g/b2g-manifest \
GIT_CONFIG_COUNT=2 \
GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf \
GIT_CONFIG_VALUE_0=git://github.com/ \
GIT_CONFIG_KEY_1=url.https://android.googlesource.com/.insteadOf \
GIT_CONFIG_VALUE_1=git://codeaurora.org/ \
./config.sh emulator
branding-pep
./build.sh -j$(nproc)
echo "=== BUILD DONE ==="
echo "Images: out/target/product/generic/"
EOF

cat > /usr/local/bin/branding-pep <<'EOF'
#!/bin/bash
set -euo pipefail
cd /workspaces/PEP-OS/B2G
sed -i 's/Firefox OS/PEP OS/g' gaia/build/config/common-settings.json
printf '%s\n' '{"name":"PEP OS","brand":"PEP OS"}' > gaia/locales/branding.json
install -m 0644 /workspaces/PEP-OS/.devcontainer/gaia-patches/apk_installer.js gaia/apps/system/js/apk_installer.js
if ! grep -q apk_installer gaia/apps/system/index.html; then
  sed -i 's|</head>|<script defer src="js/apk_installer.js"></script></head>|' gaia/apps/system/index.html
fi
printf 'PEP OS\n' > gaia/apps/homescreen/name
EOF

chmod +x /usr/local/bin/build-pep /usr/local/bin/branding-pep
chmod +x /usr/local/bin/build-pep /usr/local/bin/branding-pep