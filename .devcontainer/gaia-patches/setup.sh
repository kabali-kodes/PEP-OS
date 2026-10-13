#!/bin/bash
apt update
apt install -y git python3 curl nodejs npm build-essential libgl1-mesa-dev \
bison flex gperf g++-multilib gcc-multilib libncurses5 ccache libssl-dev \
openjdk-11-jdk repo lxc waydroid python-is-python3 libgtk-3-dev netcat-openbsd unzip

npm install -g n && n 16.20.2
git config --global user.name "PEP OS"
git config --global user.email "pep@os.local"
ccache -M 30G

# Tools
cat > /usr/local/bin/build-pep <<'EOF'
#!/bin/bash
set -e
cd /workspaces/PEP-OS
if [! -d "B2G" ]; then
  git clone https://github.com/mozilla-b2g/B2G.git B2G
fi
cd B2G
./config.sh emulator-arm64
./build.sh -j$(nproc)
echo "=== BUILD DONE ==="
echo "Images: out/target/product/emulator-arm64/"
EOF

cat > /usr/local/bin/branding-pep <<'EOF'
#!/bin/bash
cd /workspaces/PEP-OS/B2G
# Patch branding to PEP OS
find gaia -type f -name "*.html" -exec sed -i 's/Firefox OS/PEP OS/g' {} \;
find gaia -type f -name "*.properties" -exec sed -i 's/Firefox OS/PEP OS/g' {} \;
echo "Branded to PEP OS"
EOF

chmod +x /usr/local/bin/build-pep /usr/local/bin/branding-pep
chmod +x.devcontainer/setup.sh