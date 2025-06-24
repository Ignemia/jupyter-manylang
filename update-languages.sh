#!/bin/bash
set -e

echo "==================================================================="
echo "Updating language-agnostic versions and latest betas..."
echo "==================================================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package lists
echo "Updating package lists..."
apt-get update -qq

# =============================================================================
# Update C++26 Beta
# =============================================================================
echo ""
echo "Checking for C++26 beta updates..."
# C++26 is still experimental, kernel spec already exists
# Just ensure we have the latest GCC that supports C++26 features
if command_exists g++-14; then
    echo "GCC 14 already installed for C++26 support"
else
    echo "Installing GCC 14 for C++26 beta support..."
    apt-get install -y -qq gcc-14 g++-14
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 110
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 110
fi

# =============================================================================
# Update Java 24 Beta
# =============================================================================
echo ""
echo "Checking for Java 24 beta updates..."
cd /tmp
# Try to download latest Java 24 EA build
JAVA24_URL="https://download.java.net/java/early_access/jdk24/latest/GPL/openjdk-24-ea_linux-x64_bin.tar.gz"
if wget -q --spider "$JAVA24_URL"; then
    echo "Downloading latest Java 24 EA..."
    wget -q "$JAVA24_URL" -O openjdk-24-ea_linux-x64_bin.tar.gz

    # Remove old Java 24 if exists
    rm -rf /opt/java/jdk-24*

    # Extract new version
    cd /opt/java
    tar xzf /tmp/openjdk-24-ea_linux-x64_bin.tar.gz
    rm /tmp/openjdk-24-ea_linux-x64_bin.tar.gz

    # Find the extracted directory name
    JAVA24_DIR=$(ls -d jdk-24* | head -n1)

    # Install Java 24 kernel if IJava is available
    if [ -f /tmp/ijava-install.py ]; then
        echo "Installing Java 24 kernel..."
        cd /tmp
        wget -q https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip
        unzip -q ijava-1.3.0.zip
        JAVA_HOME=/opt/java/$JAVA24_DIR python install.py --sys-prefix --display-name="Java 24 (beta)"
        rm -rf /tmp/ijava*
    fi
    echo "Java 24 beta updated successfully"
else
    echo "Java 24 EA not available yet, skipping..."
fi

# =============================================================================
# Update Python 3.14 Beta
# =============================================================================
echo ""
echo "Checking for Python 3.14 beta updates..."
# Get the latest Python 3.14 alpha/beta release
PYTHON_314_VERSION=$(curl -s https://www.python.org/ftp/python/ | grep -oP '3\.14\.[0-9]+(?:a|b|rc)?[0-9]*' | sort -V | tail -n1)
if [ -n "$PYTHON_314_VERSION" ]; then
    echo "Found Python $PYTHON_314_VERSION"

    # Check if we need to update
    if [ ! -f /opt/python3.14/bin/python3 ] || ! /opt/python3.14/bin/python3 --version 2>&1 | grep -q "$PYTHON_314_VERSION"; then
        echo "Installing Python $PYTHON_314_VERSION..."
        cd /tmp
        wget -q "https://www.python.org/ftp/python/${PYTHON_314_VERSION}/Python-${PYTHON_314_VERSION}.tgz"
        tar xzf "Python-${PYTHON_314_VERSION}.tgz"
        cd "Python-${PYTHON_314_VERSION}"

        # Install build dependencies
        apt-get install -y -qq build-essential gdb lcov pkg-config \
            libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
            libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
            lzma lzma-dev tk-dev uuid-dev zlib1g-dev

        # Configure and build
        ./configure --enable-optimizations --prefix=/opt/python3.14
        make -j$(nproc) -s
        make install -s

        # Install ipykernel
        /opt/python3.14/bin/python3 -m pip install --upgrade pip
        /opt/python3.14/bin/python3 -m pip install ipykernel
        /opt/python3.14/bin/python3 -m ipykernel install --name python3.14 --display-name "Python 3.14 (beta)"

        # Cleanup
        cd /
        rm -rf /tmp/Python-${PYTHON_314_VERSION}*
        echo "Python 3.14 beta updated successfully"
    else
        echo "Python $PYTHON_314_VERSION already installed"
    fi
else
    echo "No Python 3.14 beta available yet"
fi

# =============================================================================
# Update C# .NET 9 Preview
# =============================================================================
echo ""
echo "Checking for .NET 9 preview updates..."
cd /tmp
# Download the installation script
if wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh; then
    chmod +x dotnet-install.sh

    # Get the latest .NET 9 preview version
    DOTNET9_VERSION=$(./dotnet-install.sh --list-runtimes | grep -E "^9\." | grep -i preview | sort -V | tail -n1 | awk '{print $2}')

    if [ -n "$DOTNET9_VERSION" ]; then
        echo "Found .NET $DOTNET9_VERSION"

        # Check if we need to update
        if [ ! -f /opt/dotnet9/dotnet ] || ! /opt/dotnet9/dotnet --version | grep -q "$DOTNET9_VERSION"; then
            echo "Installing .NET $DOTNET9_VERSION..."
            ./dotnet-install.sh --channel 9.0 --quality preview --install-dir /opt/dotnet9

            # Update .NET Interactive
            export PATH=/opt/dotnet9/bin:$PATH
            dotnet tool update -g Microsoft.dotnet-interactive

            # Reinstall kernel
            export PATH=/root/.dotnet/tools:$PATH
            /opt/dotnet9/bin/dotnet interactive jupyter install --path /opt/conda/share/jupyter/kernels/dotnet9-csharp

            # Update kernel display name
            if [ -d /opt/conda/share/jupyter/kernels/dotnet9-csharp ]; then
                sed -i 's/"display_name": ".*"/"display_name": "C# (.NET 9 Preview)"/' /opt/conda/share/jupyter/kernels/dotnet9-csharp/kernel.json
            fi

            echo ".NET 9 preview updated successfully"
        else
            echo ".NET $DOTNET9_VERSION already installed"
        fi
    else
        echo "No .NET 9 preview version found"
    fi

    rm -f dotnet-install.sh
else
    echo "Failed to download .NET installation script"
fi

# =============================================================================
# Update Go to latest stable
# =============================================================================
echo ""
echo "Updating Go to latest stable version..."
cd /tmp
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
if [ -n "$GO_VERSION" ]; then
    echo "Installing $GO_VERSION..."
    wget -q "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
    rm -rf /opt/go
    cd /opt
    tar xzf "/tmp/${GO_VERSION}.linux-amd64.tar.gz"
    rm "/tmp/${GO_VERSION}.linux-amd64.tar.gz"

    # Update Gophernotes
    export PATH=/opt/go/bin:$PATH
    go install github.com/gopherdata/gophernotes@latest

    # Update kernel
    mkdir -p /opt/conda/share/jupyter/kernels/gophernotes
    cp $HOME/go/pkg/mod/github.com/gopherdata/gophernotes@*/kernel/* /opt/conda/share/jupyter/kernels/gophernotes/
    cd /opt/conda/share/jupyter/kernels/gophernotes
    chmod +w kernel.json
    sed -i "s|gophernotes|$HOME/go/bin/gophernotes|" kernel.json
    echo "Go updated to $GO_VERSION"
fi

# =============================================================================
# Update Rust to latest stable
# =============================================================================
echo ""
echo "Updating Rust to latest stable version..."
if [ -f "$HOME/.cargo/bin/rustup" ]; then
    export PATH=$HOME/.cargo/bin:$PATH
    rustup update stable
    cargo install --force evcxr_jupyter
    evcxr_jupyter --install
    echo "Rust updated to latest stable"
else
    echo "Rust not found, installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH=$HOME/.cargo/bin:$PATH
    cargo install evcxr_jupyter
    evcxr_jupyter --install
    echo "Rust installed successfully"
fi

# =============================================================================
# Update Julia to latest stable
# =============================================================================
echo ""
echo "Updating Julia to latest stable version..."
cd /tmp
JULIA_VERSION=$(curl -s https://api.github.com/repos/JuliaLang/julia/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
if [ -n "$JULIA_VERSION" ]; then
    echo "Installing Julia $JULIA_VERSION..."
    wget -q "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"

    # Remove old Julia
    rm -rf /opt/julia-*

    # Install new version
    cd /opt
    tar xzf "/tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
    rm "/tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
    ln -sf "/opt/julia-${JULIA_VERSION}/bin/julia" /usr/local/bin/julia

    # Update IJulia kernel
    julia -e 'using Pkg; Pkg.update("IJulia"); Pkg.build("IJulia")'
    echo "Julia updated to $JULIA_VERSION"
fi

# =============================================================================
# Update Node.js/TypeScript to latest LTS
# =============================================================================
echo ""
echo "Updating Node.js to latest LTS version..."
# Install latest LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y -qq nodejs

# Update TypeScript and tslab
npm install -g typescript@latest tslab@latest
tslab install --sys-prefix
echo "Node.js and TypeScript updated to latest versions"

# =============================================================================
# Update R packages
# =============================================================================
echo ""
echo "Updating R packages..."
if command_exists R; then
    R -e "update.packages(ask = FALSE, repos = 'https://cloud.r-project.org')"
    echo "R packages updated"
fi

# =============================================================================
# Update Kotlin kernel
# =============================================================================
echo ""
echo "Updating Kotlin kernel..."
if command_exists mamba; then
    mamba update -y -c jetbrains kotlin-jupyter-kernel
    mamba clean -a -y
    echo "Kotlin kernel updated"
fi

# =============================================================================
# Update Scala kernel (Almond)
# =============================================================================
echo ""
echo "Updating Scala kernel..."
if [ -f ./coursier ]; then
    rm ./coursier
fi
curl -Lo coursier https://git.io/coursier-cli
chmod +x coursier
export JAVA_HOME=/opt/java/jdk-17*
export PATH=$JAVA_HOME/bin:$PATH
./coursier launch --fork almond -- --install --force
rm coursier
echo "Scala kernel updated"

# =============================================================================
# Update SPARQL kernel
# =============================================================================
echo ""
echo "Updating SPARQL kernel..."
pip install --upgrade sparqlkernel
python -m sparqlkernel.install --sys-prefix
echo "SPARQL kernel updated"

# =============================================================================
# Clean up
# =============================================================================
echo ""
echo "Cleaning up..."
apt-get autoremove -y -qq
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo ""
echo "==================================================================="
echo "Language updates completed successfully!"
echo "==================================================================="

# List all available kernels
echo ""
echo "Available kernels:"
jupyter kernelspec list
