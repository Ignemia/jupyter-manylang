# jupyter-multilang:latest - Comprehensive multi-language Jupyter environment

# Language versions
ARG GOLANG_VERSION=1.21.5
ARG JULIA_VERSION=1.10.0
ARG RUST_VERSION=1.75.0
ARG NODE_VERSION=20.10.0

# =============================================================================
# Base system dependencies stage
# =============================================================================
FROM ubuntu:22.04 AS system-base
LABEL stage=system-base

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV NOTEBOOK_DIR=/notebooks
ENV JUPYTER_CONFIG_DIR=/config

# Install system dependencies and development tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    cmake \
    pkg-config \
    # Utilities
    curl \
    wget \
    git \
    gnupg \
    ca-certificates \
    lsb-release \
    software-properties-common \
    # Python build dependencies
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    # Libraries
    libzmq3-dev \
    libczmq-dev \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev \
    # Fonts
    fonts-liberation \
    fonts-dejavu-core \
    # Locale
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# =============================================================================
# Python base and Jupyter stage
# =============================================================================
FROM system-base AS python-jupyter
LABEL stage=python-jupyter

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean -a -y

ENV PATH=/opt/conda/bin:$PATH

# Install mamba for faster conda operations
RUN conda install -n base -c conda-forge mamba -y && \
    conda clean -a -y

# Install JupyterLab and core packages
RUN mamba install -y -c conda-forge \
    python=3.11 \
    jupyterlab=4.0 \
    notebook \
    ipywidgets \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator \
    nb_conda_kernels \
    pandas \
    numpy \
    matplotlib \
    scipy \
    scikit-learn \
    seaborn \
    plotly \
    && mamba clean -a -y

# =============================================================================
# Multiple Python versions stage
# =============================================================================
FROM python-jupyter AS python-versions
LABEL stage=python-versions

# Python 2.7 (from deadsnakes PPA for Ubuntu)
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python2.7 python2.7-dev && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2.7 get-pip.py && \
    rm get-pip.py && \
    python2.7 -m pip install ipykernel && \
    python2.7 -m ipykernel install --name python2 --display-name "Python 2.7" && \
    rm -rf /var/lib/apt/lists/*

# Python 3.7
RUN mamba create -n py37 python=3.7 ipykernel numpy pandas matplotlib -y && \
    /opt/conda/envs/py37/bin/python -m ipykernel install --name python3.7 --display-name "Python 3.7" && \
    mamba clean -a -y

# Python 3.11 (already installed as base)
RUN python -m ipykernel install --name python3.11 --display-name "Python 3.11"

# Python 3.12
RUN mamba create -n py312 python=3.12 ipykernel numpy pandas matplotlib -y && \
    /opt/conda/envs/py312/bin/python -m ipykernel install --name python3.12 --display-name "Python 3.12" && \
    mamba clean -a -y

# Python 3.13
RUN mamba create -n py313 python=3.13 ipykernel numpy pandas matplotlib -y && \
    /opt/conda/envs/py313/bin/python -m ipykernel install --name python3.13 --display-name "Python 3.13" && \
    mamba clean -a -y

# Python 3.14 beta (build from source)
RUN apt-get update && \
    apt-get install -y build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev && \
    cd /tmp && \
    wget https://www.python.org/ftp/python/3.14.0/Python-3.14.0a2.tgz && \
    tar xzf Python-3.14.0a2.tgz && \
    cd Python-3.14.0a2 && \
    ./configure --enable-optimizations --prefix=/opt/python3.14 && \
    make -j$(nproc) && \
    make install && \
    /opt/python3.14/bin/python3 -m pip install --upgrade pip && \
    /opt/python3.14/bin/python3 -m pip install ipykernel && \
    /opt/python3.14/bin/python3 -m ipykernel install --name python3.14 --display-name "Python 3.14 (beta)" && \
    cd / && rm -rf /tmp/Python-3.14* && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# C++ compilers and kernels stage
# =============================================================================
FROM python-versions AS cpp-stage
LABEL stage=cpp-stage

# Install modern C++ compilers
RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y gcc-13 g++-13 clang-15 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 && \
    rm -rf /var/lib/apt/lists/*

# Install xeus-cling C++ kernel
RUN mamba install -y -c conda-forge xeus-cling && \
    mamba clean -a -y

# Create C++23 and C++26 kernel specifications
RUN mkdir -p /opt/conda/share/jupyter/kernels/cpp23 && \
    echo '{"display_name": "C++23", "argv": ["xcpp", "-std=c++23", "-f", "{connection_file}"], "language": "c++"}' > \
    /opt/conda/share/jupyter/kernels/cpp23/kernel.json && \
    mkdir -p /opt/conda/share/jupyter/kernels/cpp26 && \
    echo '{"display_name": "C++26 (experimental)", "argv": ["xcpp", "-std=c++26", "-f", "{connection_file}"], "language": "c++"}' > \
    /opt/conda/share/jupyter/kernels/cpp26/kernel.json

# =============================================================================
# Java versions stage
# =============================================================================
FROM cpp-stage AS java-stage
LABEL stage=java-stage

# Install multiple Java versions
RUN apt-get update && \
    apt-get install -y wget unzip && \
    mkdir -p /opt/java && \
    cd /opt/java && \
    # Java 14
    wget https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_linux-x64_bin.tar.gz && \
    tar xzf openjdk-14.0.2_linux-x64_bin.tar.gz && \
    rm openjdk-14.0.2_linux-x64_bin.tar.gz && \
    # Java 17
    wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz && \
    tar xzf openjdk-17.0.2_linux-x64_bin.tar.gz && \
    rm openjdk-17.0.2_linux-x64_bin.tar.gz && \
    # Java 21
    wget https://download.java.net/java/GA/jdk21.0.1/415e3f918a1f4062a0074a2794853d0d/12/GPL/openjdk-21.0.1_linux-x64_bin.tar.gz && \
    tar xzf openjdk-21.0.1_linux-x64_bin.tar.gz && \
    rm openjdk-21.0.1_linux-x64_bin.tar.gz && \
    # Java 24 EA (if available)
    (wget https://download.java.net/java/early_access/jdk24/1/GPL/openjdk-24-ea+1_linux-x64_bin.tar.gz && \
    tar xzf openjdk-24-ea+1_linux-x64_bin.tar.gz && \
    rm openjdk-24-ea+1_linux-x64_bin.tar.gz || echo "Java 24 EA not available") && \
    rm -rf /var/lib/apt/lists/*

# Install IJava kernel
RUN cd /tmp && \
    wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip ijava-1.3.0.zip && \
    # Java 14 kernel
    JAVA_HOME=/opt/java/jdk-14.0.2 python install.py --sys-prefix --display-name "Java 14" && \
    # Java 17 kernel
    JAVA_HOME=/opt/java/jdk-17.0.2 python install.py --sys-prefix --display-name "Java 17" && \
    # Java 21 kernel
    JAVA_HOME=/opt/java/jdk-21.0.1 python install.py --sys-prefix --display-name "Java 21" && \
    # Java 24 kernel (if available)
    (test -d /opt/java/jdk-24 && JAVA_HOME=/opt/java/jdk-24 python install.py --sys-prefix --display-name "Java 24 EA" || echo "Skipping Java 24") && \
    rm -rf /tmp/ijava*

# =============================================================================
# Other languages stage
# =============================================================================
FROM java-stage AS other-languages
LABEL stage=other-languages

# R language
RUN mamba install -y -c conda-forge r-base r-irkernel r-tidyverse r-ggplot2 r-plotly && \
    mamba clean -a -y

# Julia
RUN cd /opt && \
    wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    rm julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    ln -s /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia && \
    julia -e 'using Pkg; Pkg.add("IJulia")'

# Go
RUN cd /opt && \
    wget https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    rm go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    ln -s /opt/go/bin/go /usr/local/bin/go && \
    export PATH=/opt/go/bin:$PATH && \
    go install github.com/gopherdata/gophernotes@latest && \
    mkdir -p /opt/conda/share/jupyter/kernels/gophernotes && \
    cp $HOME/go/pkg/mod/github.com/gopherdata/gophernotes@*/kernel/* /opt/conda/share/jupyter/kernels/gophernotes/ && \
    cd /opt/conda/share/jupyter/kernels/gophernotes && \
    chmod +w kernel.json && \
    sed -i "s|gophernotes|$HOME/go/bin/gophernotes|" kernel.json

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} && \
    export PATH=$HOME/.cargo/bin:$PATH && \
    cargo install evcxr_jupyter && \
    evcxr_jupyter --install

# Node.js/TypeScript
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript tslab && \
    tslab install --sys-prefix && \
    rm -rf /var/lib/apt/lists/*

# Kotlin
RUN mamba install -y -c jetbrains kotlin-jupyter-kernel && \
    mamba clean -a -y

# Scala (Almond kernel)
RUN curl -Lo coursier https://git.io/coursier-cli && \
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
# Final production stage
# =============================================================================
FROM other-languages AS final
LABEL maintainer="Jupyter Multi-Language Environment"
LABEL description="Comprehensive Jupyter Lab with multiple programming languages"
LABEL version="1.0.0"

# Create directories
RUN mkdir -p /notebooks /config

# Copy configuration files
COPY config/jupyter_notebook_config.py /config/
COPY config/matplotlibrc /config/

# Environment variables
ENV JUPYTER_CONFIG_DIR=/config
ENV JUPYTER_DATA_DIR=/root/.local/share/jupyter
ENV NOTEBOOK_DIR=/notebooks
ENV MPLCONFIGDIR=/config
ENV PATH=/opt/go/bin:/root/.cargo/bin:/opt/julia-${JULIA_VERSION}/bin:$PATH

# Final cleanup
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    conda clean -a -y

# Expose Jupyter port
EXPOSE 8888

# Set working directory
WORKDIR /notebooks

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--notebook-dir=/notebooks"]
