#!/bin/bash

# Enable set to be sure that all command don't fail
set -eu

# Chroot config
dir_name="synapse-find-unreferenced-state-groups"
path_to_build="/opt/yunohost/$dir_name"

#################################################################

# commit of the sources to be built
app_version="e873f9a"
#app_version="$1"
# architecture to be built
result_suffix_name="$2"
#result_prefix_name="$2"

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
apt-get install -y cargo # rustc build-essential curl pkg-config

# Clean environnement
rm -rf $path_to_build
# Clean cargo build env
rm -rf $HOME/.cargo/env

echo "Start build time : $(date)" >> build_synapse_find_unref_stat_time.log

# Install rustup
if [ -z $(which rustup) ]; then
    #curl -sSf -L https://static.rust-lang.org/rustup.sh | sh -s -- -y --default-toolchain=stable --profile=minimal
    curl https://sh.rustup.rs -sSf | sh
else
    rustup update
fi
source $HOME/.cargo/env
#source ~/.bashrc 

# Create new environnement
#mkdir -p $path_to_build

# Go in virtualenv
old_pwd="${PWD/%\//}"

git clone https://github.com/erikjohnston/synapse-find-unreferenced-state-groups.git $path_to_build
pushd $path_to_build
git reset --hard $app_version
cargo build

cd ..

# Build archive of binary and put everything on correct path to be used by auto update script
tar -czf "${dir_name}_${app_version}-bin1_$result_suffix_name.tar.gz" "$dir_name"
sha256sumarchive=$(sha256sum "${dir_name}_${app_version}-bin1_$result_suffix_name.tar.gz" | cut -d' ' -f1)
mv "${dir_name}_${app_version}-bin1_$result_suffix_name.tar.gz" "$old_pwd"/
echo $sha256sumarchive > "$old_pwd/${dir_name}_${app_version}-bin1_$result_suffix_name-sha256.txt"

popd

echo "Finish build time : $(date)" >> build_synapse_find_unref_stat_time.log
echo "sha256 SUM : $sha256sumarchive"

exit 0



