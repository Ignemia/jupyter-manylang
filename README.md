# Jupyter Multi-Language Environment

A comprehensive Jupyter Lab environment with support for multiple programming languages and their various versions, all packaged in a single Docker container.

## 🚀 Features

- **JupyterLab 4.0** with modern interface and extensions
- **Multiple language kernels** in a single environment
- **Zero-configuration setup** - just run and start coding
- **Persistent notebooks** via volume mounting
- **Customizable configuration** through environment variables
- **Optimized Docker build** with minimal image size
- **Health monitoring** and automatic restart capabilities

## 📚 Supported Languages

### Python
- Python 2.7 (legacy support)
- Python 3.7
- Python 3.11 (default)
- Python 3.12
- Python 3.13
- Python 3.14 (beta)

### C/C++
- C++11/14/17 (via xeus-cling)
- C++23
- C++26 (experimental)

### Java
- Java 14
- Java 17 (LTS)
- Java 21 (LTS)
- Java 24 (Early Access)

### Other Languages
- **R** (4.1+) with tidyverse, ggplot2, and plotly
- **Julia** (1.10.0) with DataFrames and plotting libraries
- **Go** (1.21.5) via Gophernotes
- **Rust** (1.75.0) via EvCxR
- **Node.js/TypeScript** (20.10.0) via tslab
- **Kotlin** via kotlin-jupyter-kernel
- **Scala** via Almond kernel
- **Bash** for shell scripting
- **SPARQL** for RDF queries

## 🛠️ Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- At least 8GB RAM (16GB recommended)
- 20GB free disk space

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/jupyter-multilang.git
cd jupyter-multilang
```

2. Build and start the container:
```bash
docker compose up -d
```

3. Access JupyterLab:
   - Open http://localhost:8888 in your browser
   - No token/password required by default (configurable)

### Basic Commands

```bash
# Start the environment
docker compose up -d

# Stop the environment
docker compose down

# View logs
docker compose logs -f

# Rebuild after changes
docker compose build --no-cache

# Clean up everything (including notebooks)
docker compose down -v && rm -rf ./notebooks/*
```

## 📁 Project Structure

```
jupyter-multilang/
├── Dockerfile              # Main multi-stage Dockerfile
├── docker-compose.yml      # Docker Compose configuration
├── .env                    # Environment variables
├── config/                 # Configuration files
│   ├── jupyter_notebook_config.py
│   └── matplotlibrc
├── notebooks/              # Your notebook files (persistent)
├── .gitignore
├── .dockerignore
├── README.md              # This file
└── CHANGELOG.md           # Version history
```

## ⚙️ Configuration

### Environment Variables

Key configuration options in `.env`:

```env
# Port configuration
JUPYTER_PORT=8888

# Security (set a token for production)
JUPYTER_TOKEN=your-secure-token-here

# Language versions
GOLANG_VERSION=1.21.5
JULIA_VERSION=1.10.0
RUST_VERSION=1.75.0
NODE_VERSION=20.10.0

# Resource limits
MEMORY_LIMIT=8g
CPU_LIMIT=4
```

### Custom Configuration

1. **Jupyter Configuration**: Edit `config/jupyter_notebook_config.py`
2. **Matplotlib Settings**: Edit `config/matplotlibrc`
3. **Environment Variables**: Modify `.env` file

### Disabling Kernels

To disable specific language kernels, set the corresponding variable to 0 in `.env`:

```env
ENABLE_PYTHON2=0    # Disables Python 2.7
ENABLE_JAVA=0       # Disables all Java kernels
```

## 🧪 Testing Kernels

Create a new notebook and test each kernel:

```python
# Python
import sys
print(f"Python {sys.version}")

# Display plots
import matplotlib.pyplot as plt
import numpy as np
x = np.linspace(0, 2*np.pi, 100)
plt.plot(x, np.sin(x))
plt.show()
```

```cpp
// C++23
#include <iostream>
#include <format>
auto main() -> int {
    std::cout << std::format("Hello from C++23!\n");
    return 0;
}
```

```java
// Java
System.out.println("Java version: " + System.getProperty("java.version"));
```

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs jupyter

# Verify port availability
netstat -an | grep 8888
```

### Kernel connection issues
```bash
# Restart the container
docker compose restart

# Check kernel specifications
docker exec jupyter-multilang jupyter kernelspec list
```

### Out of memory errors
- Increase Docker memory allocation
- Set memory limits in `.env`
- Close unused kernels in JupyterLab

### Permission issues
```bash
# Fix notebook directory permissions
sudo chown -R $(id -u):$(id -g) notebooks/
```

## 🚀 Advanced Usage

### Adding Custom Packages

1. **Python packages**: Create a cell in any Python notebook:
```python
!pip install package-name
```

2. **System packages**: Extend the Dockerfile:
```dockerfile
RUN apt-get update && apt-get install -y package-name
```

### Custom Kernel Configuration

Add kernel specifications to `/opt/conda/share/jupyter/kernels/`.

### Running Multiple Instances

```bash
# Create separate directories
cp -r jupyter-multilang jupyter-instance2
cd jupyter-instance2

# Modify port in .env
sed -i 's/JUPYTER_PORT=8888/JUPYTER_PORT=8889/' .env

# Start second instance
docker compose up -d
```

## 📊 Resource Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4GB | 16GB |
| CPU | 2 cores | 4+ cores |
| Disk | 15GB | 30GB |
| Docker | 20.10+ | Latest |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Adding New Languages

1. Modify the Dockerfile to install the language runtime
2. Install the Jupyter kernel for that language
3. Update documentation
4. Test the kernel thoroughly

## 📝 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🙏 Acknowledgments

- Jupyter Project for JupyterLab
- All language communities for their kernel implementations
- Docker for containerization technology

## 📞 Support

- **Issues**: GitHub Issues for bug reports
- **Discussions**: GitHub Discussions for questions
- **Security**: Report vulnerabilities privately

---

**Note**: This environment is intended for development and educational purposes. For production use, ensure proper security measures including authentication tokens and network isolation.