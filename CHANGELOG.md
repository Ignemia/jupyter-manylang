# Changelog

All notable changes to the Jupyter Multi-Language Environment will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Support for additional language versions in future releases
- GPU support for machine learning frameworks
- JupyterHub integration capabilities

### Changed
- Continuous improvements to build performance
- Regular updates to language versions

## [1.0.0] - 2024-01-10

### Added
- Initial release of the unified Jupyter Multi-Language Environment
- JupyterLab 4.0 with modern interface and extensions
- Python kernels:
  - Python 2.7 (legacy support)
  - Python 3.7
  - Python 3.11 (default)
  - Python 3.12
  - Python 3.13
  - Python 3.14 (beta)
- C++ kernels:
  - C++11/14/17 via xeus-cling
  - C++23 support
  - C++26 experimental support
- Java kernels:
  - Java 14
  - Java 17 (LTS)
  - Java 21 (LTS)
  - Java 24 (Early Access)
- Additional language kernels:
  - R 4.1+ with tidyverse and visualization packages
  - Julia 1.10.0 with data science packages
  - Go 1.21.5 via Gophernotes
  - Rust 1.75.0 via EvCxR
  - Node.js/TypeScript 20.10.0 via tslab
  - Kotlin via kotlin-jupyter-kernel
  - Scala via Almond kernel
  - Bash shell scripting
  - SPARQL for RDF queries
- Comprehensive configuration system:
  - Environment variable configuration via .env file
  - Custom Jupyter configuration
  - Matplotlib configuration
- Docker Compose setup with health checks
- Persistent notebook storage via volume mounting
- Optimized multi-stage Docker build
- Zero-configuration startup (no token required by default)
- Comprehensive documentation and examples

### Technical Details
- Base image: Ubuntu 22.04
- Package manager: Conda/Mamba for faster operations
- Build optimization with layer caching
- Minimal final image size considering the number of languages
- Health monitoring with automatic restart capabilities

### Security
- Configurable authentication tokens
- Option to run without root privileges
- Isolated kernel environments

[Unreleased]: https://github.com/yourusername/jupyter-multilang/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/jupyter-multilang/releases/tag/v1.0.0