# =============================================================================
# JupyterLab Multi-Language Docker Environment
# Version-agnostic with specific exceptions for C++, Java, and Python
# =============================================================================

# Language version arguments
ARG GOLANG_VERSION=1.23.4
ARG JULIA_VERSION=1.11.2
ARG RUST_VERSION=1.83.0
ARG NODE_VERSION=22-bullseye

# Multi-stage builds for language environments
FROM golang:${GOLANG_VERSION}-bullseye as golang
FROM julia:${JULIA_VERSION}-bullseye as julia
FROM rust:${RUST_VERSION}-bullseye as rust
FROM node:${NODE_VERSION} as node
FROM openjdk:11-jdk-bullseye as java11
FROM openjdk:17-jdk-bullseye as java17

# Main image based on Python 3.13
FROM python:3.13-bullseye

LABEL maintainer="JupyterLab Multi-Language Environment"
LABEL description="Version-agnostic JupyterLab with specific C++, Java, Python versions"
LABEL version="3.0.0"

# Environment setup
ENV DEBIAN_FRONTEND=noninteractive
ENV NOTEBOOK_DIR=/notebooks
ENV JUPYTER_CONFIG_DIR=/config

# Install system dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    cmake \
    pkg-config \
    make \
    # Compilers and tools
    gcc g++ gfortran \
    # Utilities
    curl wget git vim nano \
    gnupg ca-certificates lsb-release \
    software-properties-common \
    apt-transport-https \
    # Development libraries
    libzmq3-dev libczmq-dev \
    libssl-dev libffi-dev \
    libbz2-dev libreadline-dev \
    libsqlite3-dev libncursesw5-dev \
    xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev liblzma-dev \
    # Additional dependencies
    unzip tar gzip locales \
    fonts-liberation fonts-dejavu-core \
    # Python 2.7 dependencies
    python2.7 python2.7-dev \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# =============================================================================
# Install JupyterLab and extensions
# =============================================================================
# Install JupyterLab and core packages
RUN pip install --no-cache-dir \
    jupyterlab==4.0.* \
    notebook \
    ipykernel \
    ipywidgets \
    jupyter-console \
    nbconvert

# =============================================================================
# Python Versions (2.7, 3.13, 3.14-beta)
# =============================================================================

# Python 3.13 is already installed as base
RUN python -m ipykernel install --name python3.13 --display-name "Python 3.13"

# Python 2.7
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    python2.7 get-pip.py && \
    python2.7 -m pip install ipykernel && \
    python2.7 -m ipykernel install --name python2.7 --display-name "Python 2.7" && \
    rm get-pip.py

# Python 3.14 beta (build from source)
RUN cd /tmp && \
    wget -q https://www.python.org/ftp/python/3.14.0/Python-3.14.0a3.tgz && \
    tar xzf Python-3.14.0a3.tgz && \
    cd Python-3.14.0a3 && \
    ./configure --enable-optimizations --prefix=/opt/python3.14 && \
    make -j$(nproc) && \
    make install && \
    /opt/python3.14/bin/python3 -m pip install --upgrade pip ipykernel && \
    /opt/python3.14/bin/python3 -m ipykernel install --name python3.14 --display-name "Python 3.14 (beta)" && \
    cd / && rm -rf /tmp/Python-*

# =============================================================================
# C++ Versions (11, 14, 17, 23, 26-beta)
# =============================================================================

# Install Miniconda for xeus-cling
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/miniconda && \
    rm /tmp/miniconda.sh && \
    /opt/miniconda/bin/conda install -y -c conda-forge xeus-cling && \
    /opt/miniconda/bin/conda clean -a -y

# Create kernel specifications for different C++ standards
RUN mkdir -p /usr/local/share/jupyter/kernels/cpp11 && \
    echo '{"display_name": "C++11", "argv": ["/opt/miniconda/bin/xcpp", "-std=c++11", "-f", "{connection_file}"], "language": "c++"}' > \
    /usr/local/share/jupyter/kernels/cpp11/kernel.json && \
    \
    mkdir -p /usr/local/share/jupyter/kernels/cpp14 && \
    echo '{"display_name": "C++14", "argv": ["/opt/miniconda/bin/xcpp", "-std=c++14", "-f", "{connection_file}"], "language": "c++"}' > \
    /usr/local/share/jupyter/kernels/cpp14/kernel.json && \
    \
    mkdir -p /usr/local/share/jupyter/kernels/cpp17 && \
    echo '{"display_name": "C++17", "argv": ["/opt/miniconda/bin/xcpp", "-std=c++17", "-f", "{connection_file}"], "language": "c++"}' > \
    /usr/local/share/jupyter/kernels/cpp17/kernel.json && \
    \
    mkdir -p /usr/local/share/jupyter/kernels/cpp23 && \
    echo '{"display_name": "C++23", "argv": ["/opt/miniconda/bin/xcpp", "-std=c++23", "-f", "{connection_file}"], "language": "c++"}' > \
    /usr/local/share/jupyter/kernels/cpp23/kernel.json && \
    \
    mkdir -p /usr/local/share/jupyter/kernels/cpp26 && \
    echo '{"display_name": "C++26 (beta)", "argv": ["/opt/miniconda/bin/xcpp", "-std=c++2c", "-f", "{connection_file}"], "language": "c++"}' > \
    /usr/local/share/jupyter/kernels/cpp26/kernel.json

# =============================================================================
# Java Versions (11, 17, 24-beta)
# =============================================================================

# Copy Java installations from multi-stage builds
COPY --from=java11 /usr/local/openjdk-11 /opt/java/jdk-11
COPY --from=java17 /usr/local/openjdk-17 /opt/java/jdk-17

# Try to get Java 24 EA
RUN cd /opt/java && \
    (wget -q https://download.java.net/java/early_access/jdk24/latest/GPL/openjdk-24-ea_linux-x64_bin.tar.gz && \
    tar xzf openjdk-24-ea_linux-x64_bin.tar.gz && \
    rm openjdk-24-ea_linux-x64_bin.tar.gz && \
    mv jdk-24* jdk-24) || echo "Java 24 EA not available"

# Install IJava kernel
RUN cd /tmp && \
    wget -q https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip -q ijava-1.3.0.zip && \
    # Java 11
    JAVA_HOME=/opt/java/jdk-11 python install.py --sys-prefix && \
    mv /usr/local/share/jupyter/kernels/java /usr/local/share/jupyter/kernels/java11 && \
    sed -i 's/"display_name": "Java"/"display_name": "Java 11"/' /usr/local/share/jupyter/kernels/java11/kernel.json && \
    # Java 17
    JAVA_HOME=/opt/java/jdk-17 python install.py --sys-prefix && \
    mv /usr/local/share/jupyter/kernels/java /usr/local/share/jupyter/kernels/java17 && \
    sed -i 's/"display_name": "Java"/"display_name": "Java 17"/' /usr/local/share/jupyter/kernels/java17/kernel.json && \
    # Java 24 if available
    if [ -d /opt/java/jdk-24 ]; then \
    JAVA_HOME=/opt/java/jdk-24 python install.py --sys-prefix && \
    mv /usr/local/share/jupyter/kernels/java /usr/local/share/jupyter/kernels/java24 && \
    sed -i 's/"display_name": "Java"/"display_name": "Java 24 (beta)"/' /usr/local/share/jupyter/kernels/java24/kernel.json; \
    fi && \
    rm -rf /tmp/ijava*

# =============================================================================
# Go (latest stable)
# =============================================================================
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go/ /usr/local/go/

RUN go install github.com/gopherdata/gophernotes@latest && \
    mkdir -p /usr/local/share/jupyter/kernels/gophernotes && \
    cd /usr/local/share/jupyter/kernels/gophernotes && \
    cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@*/kernel/* . && \
    chmod +w kernel.json && \
    sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json

# =============================================================================
# Julia (latest stable)
# =============================================================================
ENV JULIA_PATH=/usr/local/julia
ENV PATH=${JULIA_PATH}/bin:$PATH
COPY --from=julia ${JULIA_PATH} ${JULIA_PATH}

RUN julia -e 'using Pkg; Pkg.add("IJulia"); Pkg.add("DataFrames"); Pkg.add("CSV"); Pkg.add("Plots"); Pkg.add("PlotlyJS");'

# =============================================================================
# Rust (latest stable)
# =============================================================================
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
COPY --from=rust ${RUSTUP_HOME} ${RUSTUP_HOME}
COPY --from=rust ${CARGO_HOME} ${CARGO_HOME}

RUN cargo install evcxr_jupyter && \
    evcxr_jupyter --install

# =============================================================================
# Node.js/TypeScript (latest LTS)
# =============================================================================
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    npm install -g typescript tslab && \
    tslab install --sys-prefix

# =============================================================================
# R (latest stable)
# =============================================================================
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    echo "deb https://cloud.r-project.org/bin/linux/debian bullseye-cran40/" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y r-base r-base-dev && \
    rm -rf /var/lib/apt/lists/* && \
    R -e "install.packages('IRkernel', repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(sys_prefix = TRUE)"

# =============================================================================
# C# Versions (.NET 7, .NET 8, .NET 9 beta)
# =============================================================================

# Install .NET SDK dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libc6 libgcc1 libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET versions
RUN cd /tmp && \
    wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    # .NET 7
    ./dotnet-install.sh --channel 7.0 --install-dir /opt/dotnet7 && \
    # .NET 8 LTS
    ./dotnet-install.sh --channel 8.0 --install-dir /opt/dotnet8 && \
    # .NET 9 Preview
    ./dotnet-install.sh --channel 9.0 --quality preview --install-dir /opt/dotnet9 && \
    rm dotnet-install.sh

# Install .NET Interactive
RUN export PATH=/opt/dotnet8/bin:$PATH && \
    dotnet tool install -g Microsoft.dotnet-interactive && \
    export PATH=/root/.dotnet/tools:$PATH && \
    # Install base kernel
    dotnet interactive jupyter install && \
    # Copy kernels for each version
    cp -r /usr/local/share/jupyter/kernels/.net-csharp /usr/local/share/jupyter/kernels/dotnet7-csharp && \
    cp -r /usr/local/share/jupyter/kernels/.net-csharp /usr/local/share/jupyter/kernels/dotnet8-csharp && \
    cp -r /usr/local/share/jupyter/kernels/.net-csharp /usr/local/share/jupyter/kernels/dotnet9-csharp && \
    # Update kernel specifications
    sed -i 's|"dotnet-interactive"|"/opt/dotnet7/bin/dotnet"|g; s/"display_name": ".*"/"display_name": "C# (.NET 7)"/' \
    /usr/local/share/jupyter/kernels/dotnet7-csharp/kernel.json && \
    sed -i 's|"dotnet-interactive"|"/opt/dotnet8/bin/dotnet"|g; s/"display_name": ".*"/"display_name": "C# (.NET 8 LTS)"/' \
    /usr/local/share/jupyter/kernels/dotnet8-csharp/kernel.json && \
    sed -i 's|"dotnet-interactive"|"/opt/dotnet9/bin/dotnet"|g; s/"display_name": ".*"/"display_name": "C# (.NET 9 Preview)"/' \
    /usr/local/share/jupyter/kernels/dotnet9-csharp/kernel.json

# =============================================================================
# Additional Language Kernels
# =============================================================================

# Kotlin
RUN /opt/miniconda/bin/conda install -y -c jetbrains kotlin-jupyter-kernel && \
    /opt/miniconda/bin/conda clean -a -y && \
    # Copy kernel to standard location
    cp -r /opt/miniconda/share/jupyter/kernels/kotlin /usr/local/share/jupyter/kernels/

# Scala (Almond kernel)
RUN export JAVA_HOME=/opt/java/jdk-17 && \
    export PATH=$JAVA_HOME/bin:$PATH && \
    curl -Lo coursier https://git.io/coursier-cli && \
    chmod +x coursier && \
    ./coursier launch --fork almond -- --install && \
    rm coursier

# Bash kernel
RUN pip install bash_kernel && \
    python -m bash_kernel.install --sys-prefix

# SPARQL kernel
RUN pip install sparqlkernel && \
    python -m sparqlkernel.install --sys-prefix

# =============================================================================
# Final Configuration
# =============================================================================

# Create directories
RUN mkdir -p /notebooks /config

# Copy configuration files and update script
COPY config/jupyter_notebook_config.py /config/
COPY config/matplotlibrc /config/
COPY update-languages.sh /usr/local/bin/update-languages.sh
RUN chmod +x /usr/local/bin/update-languages.sh

# Environment variables
ENV JUPYTER_CONFIG_DIR=/config
ENV JUPYTER_DATA_DIR=/root/.local/share/jupyter
ENV NOTEBOOK_DIR=/notebooks
ENV MPLCONFIGDIR=/config

# Expose port 7654
EXPOSE 7654

# Set working directory
WORKDIR /notebooks

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=7654", "--no-browser", "--allow-root", "--notebook-dir=/notebooks", "--config=/config/jupyter_notebook_config.py"]
