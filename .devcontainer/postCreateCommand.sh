sudo apt install libsqlite3-mod-spatialite
pipenv sync --dev
make install_plugins
curl -L https://fly.io/install.sh | sh
export FLYCTL_INSTALL="/home/vscode/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"