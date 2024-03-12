#!/bin/bash

# Enable set to be sure that all command don't fail
set -eu

# Chroot config
dir_name="matrix-synapse"
path_to_build="/opt/yunohost/$dir_name"

#################################################################

app_version="$1"
result_prefix_name="$2"

if [[ ! "$@" =~ "--chroot-yes" ]]
then
	echo "Est vous bien dans un chroot ? [y/n]"
	read a
	if [[ $a != "y" ]]
	then
		echo "Il est fortement conseillé d'être dans un chroot pour faire ces opérations"
		exit 0
	fi
fi

# Mount proc if it'isnt mouned.
if [[ $(mount) != *"proc on /proc type proc"* ]]
then
	mount -t proc proc /proc
fi

# Upgrade system
apt-get update
apt-get dist-upgrade -y
apt-get install -y build-essential python3-dev libffi-dev python3-pip python3-setuptools sqlite3 libssl-dev python3-venv libjpeg-dev libpq-dev postgresql libgcrypt20-dev libxml2-dev libxslt1-dev python3-lxml zlib1g-dev curl pkg-config

# Clean environnement
rm -rf $path_to_build
rm -rf ~/.cache/pip

echo "Start build time : $(date)" >> Synapse_build_stat_time.log

# Install rustup to build crytography
if [ -z $(which rustup) ]; then
    curl -sSf -L https://static.rust-lang.org/rustup.sh | sh -s -- -y --default-toolchain=stable --profile=minimal
else
    rustup update
fi
source $HOME/.cargo/env

# Create new environnement
mkdir -p $path_to_build
python3 -m venv --copies $path_to_build

# Go in virtualenv
old_pwd="${PWD/%\//}"
pushd $path_to_build
set +u; source bin/activate; set -u

# Install source and build binary
pip3 install --upgrade pip
pip3 install --upgrade setuptools wheel cffi
pip3 install --upgrade ndg-httpsclient psycopg2 lxml jinja2
pip3 install --upgrade matrix-synapse==$app_version matrix-synapse-ldap3
pip3 freeze | grep -v 'pkg_resources' > $old_pwd/${result_prefix_name}-build1_requirement.txt

# Quit virtualenv
set +u; deactivate; set -u
cd ..

# Build archive of binary and put everything on correct path to be used by auto update script
tar -czf "${result_prefix_name}-bin1_armv7l.tar.gz" "$dir_name"
sha256sumarchive=$(sha256sum "${result_prefix_name}-bin1_armv7l.tar.gz" | cut -d' ' -f1)
mv "${result_prefix_name}-bin1_armv7l.tar.gz" "$old_pwd"/
echo $sha256sumarchive > "$old_pwd/${result_prefix_name}-bin1_armv7l-sha256.txt"

popd

echo "Finish build time : $(date)" >> Synapse_build_stat_time.log
echo "sha256 SUM : $sha256sumarchive"

exit 0
