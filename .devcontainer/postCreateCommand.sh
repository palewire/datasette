echo 'Installing Spatialite'
apt install libsqlite3-mod-spatialite
echo 'Installing Python dependencies'
pipenv sync --dev
echo 'Installing Datasette plugins'
make install_plugins