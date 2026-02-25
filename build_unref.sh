#!/bin/bash

# Note this script is made to be run on x86-64 architecture. Using it on other architecture will need some adaptations.

# Enable set to be sure that all command don't fail
set -eu

# Chroot config
dir_name="synapse-find-unreferenced-state-groups"
path_to_build="/opt/yunohost/$dir_name"

#################################################################

# commit of the sources to be built
# app_version="e873f9a"
app_version="$1"

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
apt-get install -y cargo gcc gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu

for arch_built in amd64 arm64 armhf; do
    dpkg --add-architecture ${arch_built}
    apt-get install -y libstd-rust-dev:${arch_built} libc6-dev:${arch_built}
done

# Clean environnement
rm -rf $path_to_build

export CARGO_HOME="$path_to_build/cargo"
mkdir -p "$CARGO_HOME"

# Install rustup
curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=minimal
$CARGO_HOME/bin/rustup target add aarch64-unknown-linux-gnu
$CARGO_HOME/bin/rustup target add armv7-unknown-linux-gnueabihf

git clone https://github.com/erikjohnston/synapse-find-unreferenced-state-groups.git "$path_to_build/repos"
pushd "$path_to_build/repos"
git reset --hard "$app_version"
popd

echo "[target.x86_64-unknown-linux-gnu]
linker = 'x86_64-linux-gnu-gcc'
rustflags = ['-L', '/usr/lib/rustlib/x86_64-unknown-linux-gnu/lib']

[target.aarch64-unknown-linux-gnu]
linker = 'aarch64-linux-gnu-gcc'
rustflags = ['-L', '/usr/lib/rustlib/aarch64-unknown-linux-gnu/lib']

[target.armv7-unknown-linux-gnueabihf]
linker = 'arm-linux-gnueabihf-gcc'
rustflags = ['-L', '/usr/lib/rustlib/armv7-unknown-linux-gnueabihf/lib']" >> "$CARGO_HOME/config.toml"

source "$CARGO_HOME/env"

old_pwd="${PWD/%\//}"

for arch_built in x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu armv7-unknown-linux-gnueabihf; do
    pushd "$path_to_build/repos"
    cargo build --release --target ${arch_built}
    popd
done

cp "$path_to_build/repos/target/x86_64-unknown-linux-gnu/release/rust-synapse-find-unreferenced-state-groups" "rust-synapse-find-unreferenced-state-groups_amd64"
cp "$path_to_build/repos/target/aarch64-unknown-linux-gnu/release/rust-synapse-find-unreferenced-state-groups" "rust-synapse-find-unreferenced-state-groups_arm64"
cp "$path_to_build/repos/target/armv7-unknown-linux-gnueabihf/release/rust-synapse-find-unreferenced-state-groups" "rust-synapse-find-unreferenced-state-groups_armv7"

exit 0
