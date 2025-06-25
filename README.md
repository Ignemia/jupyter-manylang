# Jupyter Manylang Docker Environment

**IMPORTANT: This is a VERSION-AGNOSTIC JupyterLab environment where ALL languages use their LATEST STABLE versions, EXCEPT for the specifically listed versions below.**

## 🎯 Project Philosophy

This Docker image provides a JupyterLab environment with multiple programming language kernels. The core principle is:
- **ALL languages use their LATEST STABLE versions**
- **EXCEPT for C++, Java, Python, and C# which have SPECIFIC version requirements**
- **Latest beta versions and all other languages are updated on container start**

## 📌 Version Specifications

### FIXED VERSIONS (Do NOT change these)

#### C++ Versions
- **C++11** (GCC with -std=c++11)
- **C++14** (GCC with -std=c++14)
- **C++17** (GCC with -std=c++17)
- **C++23** (GCC with -std=c++23)
- **C++26** (Latest beta, updated on container start)

#### Java Versions
- **Java 11** (OpenJDK 11)
- **Java 17** (OpenJDK 17)
- **Java 24** (Latest beta, updated on container start)

#### Python Versions
- **Python 2.7** (Legacy support)
- **Python 3.13** (Current stable)
- **Python 3.14** (Latest beta, updated on container start)

#### C# Versions
- **C# (.NET 7)**
- **C# (.NET 8)** (LTS)
- **C# (.NET 9)** (Latest preview, updated on container start)

### LATEST VERSIONS (Updated on container start)
All other languages use their **LATEST STABLE** versions:
- **Go** (latest stable)
- **Rust** (latest stable)
- **Julia** (latest stable)
- **R** (latest stable)
- **TypeScript/JavaScript** (latest Node.js LTS)
- **Kotlin** (latest stable)
- **Scala** (latest stable)
- **Bash** (system default)
- **SPARQL** (latest stable)

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- At least 8GB RAM (16GB recommended)
- 20GB free disk space

### Installation & Usage

1. Clone the repository:
```bash
git clone <repository-url>
cd jupyter
```

2. Build the Docker image:
```bash
# Make the build script executable
chmod +x build-composite.sh

# Run the build script
./build-composite.sh
```

3. Start the container:
```bash
docker compose up -d
```

4. Access JupyterLab at: **http://localhost:7654**
   
   **NOTE: Port 7654 is used, NOT 8888**

5. (Optional) Check available kernels:
```bash
docker exec jupyter-manylang jupyter kernelspec list
```

## 🔄 **Current Status**

### ✅ Latest Updates (June 2025)
- **Project Renamed**: Now called "Jupyter Manylang" (from JupyterLab Multi-Language)
- **Kernel Logos**: Custom icons added for all kernels showing language abbreviations
- **R Kernel Fixed**: Manually configured and working

### 📊 Kernel Summary
- **22 Functional Kernels**: Python, C++, Java, Go, Julia, TypeScript, Kotlin, Scala, Bash, R
- **C# Kernels**: ⚠️ Placeholders (.NET 7, 8, 9) - awaiting upstream fixes
- **Rust Kernel**: ⚠️ Placeholder - compatibility issues
- **SPARQL Kernel**: ❌ Not installed (mentioned in docs but not implemented)

**Image Size**: 8.73GB | **Total Kernels**: 24 (22 working + 2 placeholders)

## 🔧 Architecture

### Docker Structure
The project uses a multi-stage build approach with individual kernel Dockerfiles:
1. **Individual Kernel Dockerfiles**: Located in `kernels/` directory (one per language)
2. **Composite Dockerfile**: `Dockerfile.composite` combines all kernels
3. **Build Script**: `build-composite.sh` orchestrates the build process
4. **Multi-stage Build**: Each kernel is built in isolation then combined
5. **Final Stage**: Assembled JupyterLab environment with all kernels

### Automatic Updates
The `update-languages.sh` script runs on container start to:
- Update all version-agnostic languages to their latest stable versions
- Update C++26 to the latest beta
- Update Java 24 to the latest beta
- Update Python 3.14 to the latest beta
- Update C# (.NET 9) to the latest preview

## 📁 Project Structure

```
jupyter/
├── Dockerfile.composite    # Main composite Dockerfile
├── docker-compose.yml      # Docker Compose configuration
├── build-composite.sh      # Build script for all kernels
├── update-languages.sh     # Auto-update script for latest versions
├── kernels/                # Individual kernel Dockerfiles
│   ├── Dockerfile.cpplang      # C++ kernels
│   ├── Dockerfile.javalang     # Java kernels
│   ├── Dockerfile.pythonlang   # Python kernels
│   ├── Dockerfile.csharplang   # C# kernels
│   └── ...                     # Other language kernels
├── config/                 # JupyterLab configuration
│   ├── jupyter_notebook_config.py
│   └── matplotlibrc
├── notebooks/              # Persistent notebook storage
├── AGENTS.md              # Instructions for AI agents
├── CONTINUE.md            # Development status and notes
└── README.md              # This file
```

## ⚙️ Configuration

### Port Configuration
- **JupyterLab Port**: 7654 (configurable in docker-compose.yml)
- **Do NOT use port 8888** - reserved for other services

### Environment Variables
Set in `docker-compose.yml`:
```yaml
JUPYTER_PORT: 7654
JUPYTER_TOKEN: ""  # Set for security in production
```

## 🧪 Testing Language Kernels

After starting the container, verify all kernels:
```bash
docker exec jupyter-manylang jupyter kernelspec list
```

Expected kernels:
- Python 2.7, 3.13, 3.14 (beta)
- C++11, C++14, C++17, C++23, C++26 (beta)
- Java 11, 17, 24 (beta)
- C# (.NET 7), C# (.NET 8 LTS), C# (.NET 9 preview)
- Go (latest)
- Rust (latest)
- Julia (latest)
- R (latest)
- TypeScript/JavaScript (latest)
- Kotlin (latest)
- Scala (latest)
- Bash
- SPARQL

## 📝 Important Notes

1. **Version Policy**: Do NOT change the specified versions for C++, Java, Python, or C# without explicit approval
2. **Port Usage**: Always use port 7654, NOT 8888
3. **Updates**: The update-languages.sh script ensures latest versions for non-specified languages
4. **Beta Versions**: C++26, Java 24, Python 3.14, and C# (.NET 9) beta/preview versions are automatically updated

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs -f

# Verify port 7654 is available
netstat -an | grep 7654
```

### Kernel not found
```bash
# Restart container to trigger update script
docker compose restart

# Check installed kernels
docker exec jupyter-manylang jupyter kernelspec list
```

### R Kernel Issues
```bash
# Check if R is working
docker exec jupyter-manylang R --version

# Verify R packages are installed
docker exec jupyter-manylang R -e "library(IRkernel)"

# Check IRkernel installation
docker exec jupyter-manylang find /usr -name "*ir*" -path "*/jupyter/kernels/*"
```

### Permission issues
```bash
# Fix notebook directory permissions
sudo chown -R $(id -u):$(id -g) notebooks/
```

### Build Issues
```bash
# Clean rebuild if having issues
docker compose down
docker system prune -f
./build-composite.sh
```

## ⚠️ Current Limitations

### Known Issues
- **R Kernel**: Currently being finalized - R 4.3.2 installed but IRkernel may need completion
- **C# Kernels**: Placeholder only - .NET Interactive has upstream installation issues
- **Rust Kernel**: Placeholder only - evcxr_jupyter compatibility issues with Rust 2024 edition
- **Locale Warnings**: Some kernels show locale warnings (functionality not affected)

### Performance Notes
- **Build Time**: Initial build takes 30-60 minutes depending on system
- **Image Size**: ~8.7GB (includes all language runtimes)
- **Memory Usage**: Recommended 8GB+ RAM for optimal performance
</text>

## 🍴 Forking and Customization

This project is designed to be **forked and customized** for your specific needs! We encourage you to:

### ✅ Fork This Project If You Want To:
- Customize language versions for your organization
- Add additional programming languages or kernels
- Modify the JupyterLab configuration
- Create specialized versions for research or education
- Build derivative Docker images
- Integrate with your existing infrastructure

### 🔧 Customization Guidelines
When forking and customizing:
1. **Feel free** to modify any language versions to suit your needs
2. **Customize** the Docker configuration as needed
3. **Add or remove** kernels based on your requirements
4. **Modify** JupyterLab settings and extensions
5. **Rebrand** the project for your organization

### 🚫 Direct Contributions Policy
**Please do not submit direct pull requests to this repository.** Instead:
- **Fork the project** and make your changes there
- **Share your fork** with the community if others might benefit
- **Create issues** only for critical bugs or security vulnerabilities
- **Discuss major architectural changes** in issues before implementing

### Development Workflow for Your Fork
```bash
# 1. Fork this repository to your account
# 2. Clone your fork
git clone https://github.com/YOUR-USERNAME/jupyter-manylang.git

# 3. Make your customizations to Dockerfile.composite or other files
# 4. Build your customized image
./build-composite.sh

# 5. Test your container
docker compose down && docker compose up -d

# 6. Verify kernels work as expected
docker exec jupyter-manylang jupyter kernelspec list

# 7. Push your changes to your fork
git add . && git commit -m "Custom modifications" && git push
```

### 🎯 Why This Approach?
This project serves as a **reference implementation** and **foundation** for multi-language Jupyter environments. By encouraging forks rather than direct contributions, we:
- Keep the main branch stable and focused
- Allow unlimited customization without conflicts
- Enable diverse use cases without bloating the core project
- Maintain clear version specifications while allowing flexibility

## 📄 License

**MIT License** - This project is fully open source and **free to fork, modify, and redistribute**.

- ✅ **Fork freely** for personal, academic, or commercial use
- ✅ **Modify and redistribute** without restrictions
- ✅ **Create derivative works** and commercial products
- ✅ **No attribution required** (but appreciated!)

See `LICENSE.txt` for complete legal details.

---

**Remember**: This is a VERSION-AGNOSTIC environment with SPECIFIC EXCEPTIONS. When in doubt, refer to the version specifications above.