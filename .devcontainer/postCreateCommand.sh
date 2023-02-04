echo 'Installing Spatialite'
sudo apt install -y libsqlite3-mod-spatialite

echo 'Installing Python dependencies'
pipenv sync --dev

echo 'Installing Datasette plugins'
make install_plugins

echo 'Remaking databases'
make clean
make