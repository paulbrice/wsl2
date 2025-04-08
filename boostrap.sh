#!/bin/bash
set -eou pipefail

ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"
ASDF_VER="v0.16.7"
DEFAULT_ASDF_PACKAGES=(
    ["hadolint"]="latest"
    ["nodejs"]="latest"
    ["opa"]="latest"
    ["opentofu"]="latest"
    ["packer"]="latest"
    ["python"]="latest"
    ["shellcheck"]="latest"
    ["shfmt"]="latest"
    ["terraform"]="latest"
    ["terraform-docs"]="latest"
    ["tf-sec"]="latest"
    ["tf-summarize"]="latest"
)

# clean up
echo "Removing directories and files..."
rm -rf "${HOME}/.asdf"
rm -rf "${HOME}/.config"
rm -f "${HOME}/.bash_profile"
rm -f "${HOME}/.gitconfig"

# hydrate
echo "Hydrating files..."
mkdir -p "${HOME}/.config"
cp .bash_profile "${HOME}/.bash_profile"

# Install Python dependencies
echo "Installing Python system dependencies..."
sudo apt update && sudo apt upgrade -y 
sudo apt install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    git

# Install Podman and dependencies
echo "Installing Podman and dependencies..."
sudo apt update && sudo apt install -y \
    podman \
    buildah \
    containers-common

# Check if asdf is installed and install if missing
if ! command -v asdf &> /dev/null; then
    echo "asdf command not found. Installing asdf..."
    curl -fsSL https://github.com/asdf-vm/asdf/releases/download/${ASDF_VER}/asdf-${ASDF_VER}-linux-arm64.tar.gz | tar -xzf - -C "${ASDF_DIR}"
else
    echo "asdf is already installed."
fi

# copy files
echo "Copying files..."
mkdir -p "${HOME}/.config"
cp .bash_profile "${HOME}/.bash_profile"
cp .bashrc "${HOME}/.bashrc"
cp .gitconfig "${HOME}/.gitconfig"

# Reload shell
echo "Reloading shell..."
source ~/.bashrc

# Install asdf plugins and versions
install_plugin_version() {
    local plugin=$1
    local version=$2

    if asdf list "$plugin" | grep -q "$version"; then
        echo "$plugin $version is already installed."
    else
        echo "Installing $plugin $version..."
        asdf install "$plugin" "$version"
        asdf set "$plugin" "$version"
    fi
}

# Install versions of each plugin
echo "Installing adsf plugin and versions of plugins..."
for plugin in "${!DEFAULT_ASDF_PACKAGES[@]}"; do
    version=${DEFAULT_ASDF_PACKAGES[$plugin]}
    if asdf plugin list | grep -q "$plugin"; then
        echo "$plugin is already installed."
    else
        asdf plugin add "$plugin"
    fi
    install_plugin_version "$plugin" "$version"
done

# Reshim adsf
echo "Reshim adsf..."
asdf reshim

# install awscli v2
echo "Installing AWS CLI v2..."
if ! command -v aws &> /dev/null; then
    echo "aws command not found. Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
else
    echo "AWS CLI v2 is already installed."
fi

# Install gcloud cli using asdf
echo "Installing gcloud cli using asdf..."
asdf plugin add gcloud
asdf install gcloud latest
asdf set gcloud latest


