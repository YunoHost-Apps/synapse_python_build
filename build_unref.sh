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
arch_built="amd64"
#result_suffix_name="$2"
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

cp $HOME/.cargo/config.toml /opt/yunohost/cargo_config_bkp.toml



# Build amd64
arch_built="amd64"

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
echo "[target.${arch_built}gc-unknown-linux-gnu]                                                                                       
linker = '${arch_built}-linux-gnu-gcc'
rustflags = ['-L', '/usr/lib/rustlib/${arch_built}gc-unknown-linux-gnu/lib']" >> $HOME/.cargo/config.toml

source $HOME/.cargo/env
#source ~/.bashrc 

# Create new environnement
#mkdir -p $path_to_build

# Go in virtualenv
old_pwd="${PWD/%\//}"

git clone https://github.com/erikjohnston/synapse-find-unreferenced-state-groups.git $path_to_build
pushd $path_to_build
git reset --hard $app_version

sudo dpkg --add-architecture ${arch_built}
sudo apt update
sudo apt install libstd-rust-dev:${arch_built} libc6-dev:${arch_built}
cargo build --target ${arch_built}gc-unknown-linux-gnu
cp /opt/yunohost/cargo_config_bkp.toml $HOME/.cargo/config.toml 

cd ..

# Build archive of binary and put everything on correct path to be used by auto update script
tar -czf "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" "$dir_name"
sha256sumarchive=$(sha256sum "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" | cut -d' ' -f1)
mv "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" "$old_pwd"/
echo $sha256sumarchive > "$old_pwd/${dir_name}_${app_version}-bin1_$arch_built-sha256.txt"

popd

echo "Finish build time : $(date)" >> build_synapse_find_unref_stat_time.log
echo "sha256 SUM : $sha256sumarchive"


# Build arm64
arch_built="arm64"

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
echo "[target.${arch_built}gc-unknown-linux-gnu]                                                                                       
linker = '${arch_built}-linux-gnu-gcc'
rustflags = ['-L', '/usr/lib/rustlib/${arch_built}gc-unknown-linux-gnu/lib']" >> $HOME/.cargo/config.toml

source $HOME/.cargo/env
#source ~/.bashrc 

# Create new environnement
#mkdir -p $path_to_build

# Go in virtualenv
old_pwd="${PWD/%\//}"

git clone https://github.com/erikjohnston/synapse-find-unreferenced-state-groups.git $path_to_build
pushd $path_to_build
git reset --hard $app_version

sudo dpkg --add-architecture ${arch_built}
sudo apt update
sudo apt install libstd-rust-dev:${arch_built} libc6-dev:${arch_built}
cargo build --target ${arch_built}gc-unknown-linux-gnu
cp /opt/yunohost/cargo_config_bkp.toml $HOME/.cargo/config.toml 

cd ..

# Build archive of binary and put everything on correct path to be used by auto update script
tar -czf "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" "$dir_name"
sha256sumarchive=$(sha256sum "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" | cut -d' ' -f1)
mv "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" "$old_pwd"/
echo $sha256sumarchive > "$old_pwd/${dir_name}_${app_version}-bin1_$arch_built-sha256.txt"

popd

echo "Finish build time : $(date)" >> build_synapse_find_unref_stat_time.log
echo "sha256 SUM : $sha256sumarchive"



# Build armhf
arch_built="armhf"

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
echo "[target.${arch_built}gc-unknown-linux-gnu]                                                                                       
linker = '${arch_built}-linux-gnu-gcc'
rustflags = ['-L', '/usr/lib/rustlib/${arch_built}gc-unknown-linux-gnu/lib']" >> $HOME/.cargo/config.toml

source $HOME/.cargo/env
#source ~/.bashrc 

# Create new environnement
#mkdir -p $path_to_build

# Go in virtualenv
old_pwd="${PWD/%\//}"

git clone https://github.com/erikjohnston/synapse-find-unreferenced-state-groups.git $path_to_build
pushd $path_to_build
git reset --hard $app_version

sudo dpkg --add-architecture ${arch_built}
sudo apt update
sudo apt install libstd-rust-dev:${arch_built} libc6-dev:${arch_built}
cargo build --target ${arch_built}gc-unknown-linux-gnu
cp /opt/yunohost/cargo_config_bkp.toml $HOME/.cargo/config.toml 

cd ..

# Build archive of binary and put everything on correct path to be used by auto update script
tar -czf "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" "$dir_name"
sha256sumarchive=$(sha256sum "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" | cut -d' ' -f1)
mv "${dir_name}_${app_version}-bin1_$arch_built.tar.gz" "$old_pwd"/
echo $sha256sumarchive > "$old_pwd/${dir_name}_${app_version}-bin1_$arch_built-sha256.txt"

popd

echo "Finish build time : $(date)" >> build_synapse_find_unref_stat_time.log
echo "sha256 SUM : $sha256sumarchive"

rm -rf /opt/yunohost/cargo_config_bkp.toml

exit 0



