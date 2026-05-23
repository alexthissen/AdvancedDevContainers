#!/usr/bin/env bash
set -e

version="${VERSION:-"latest"}"
install_dir="/opt/microsoft/dev-proxy"

echo "Installing Dev Proxy version: $version"

# Make certificates trusted in the container
# Copy the post-create script into the image so it survives to runtime
mkdir -p /usr/local/share/features/devproxy
cp "$(dirname "$0")/post-create.sh" /usr/local/share/features/devproxy/post-create.sh
chmod +x /usr/local/share/features/devproxy/post-create.sh

# Create installation directory
mkdir -p "$install_dir"
cd "$install_dir"

set -e # Terminates program immediately if any command below exits with a non-zero exit status

if [ "$version" == "latest" ]
then
	echo "Getting latest Dev Proxy version..."
	version=$(curl -s https://api.github.com/repos/dotnet/dev-proxy/releases/latest | awk -F: '/"tag_name"/ {print $2}' | sed 's/[", ]//g')
	echo "Latest version is $version"
else
	version="v$version"
fi

echo "Downloading Dev Proxy $version..."

base_url="https://github.com/dotnet/dev-proxy/releases/download/$version/dev-proxy"

ARCH="$(uname -m)"
if [ "$(expr substr ${ARCH} 1 5)" == "arm64" ] || [ "$(expr substr ${ARCH} 1 7)" == "aarch64" ]; then
	curl -sL -o ./devproxy.zip "$base_url-linux-arm64-$version.zip" || { echo "Cannot download Dev Proxy. Aborting"; exit 1; }
elif [ "$(expr substr ${ARCH} 1 6)" == "x86_64" ]; then
	curl -sL -o ./devproxy.zip "$base_url-linux-x64-$version.zip" || { echo "Cannot download Dev Proxy. Aborting"; exit 1; }
else
	echo "unsupported architecture ${ARCH}"
	exit
fi

unzip -o ./devproxy.zip -d ./
rm ./devproxy.zip
echo "Configuring devproxy and its files as executable..."
chmod +x ./devproxy ./libe_sqlite3.so

# Create symlink to executable
ln -sf "$install_dir/devproxy" /usr/local/bin/devproxy

echo "Dev Proxy $version installed!"