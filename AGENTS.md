# Agent Instructions

## IMPORTANT: Read First

**Before performing ANY actions on this project, you MUST read the README.md file in its entirety.**

The README.md contains critical information about:
- Project architecture and structure
- Language version specifications
- Docker configuration requirements
- Build and deployment procedures

## Key Points

1. **Language Versions**: This project has VERY SPECIFIC version requirements:
   - C++: 11, 14, 17, 23, and 26 (latest beta)
   - Java: 11, 17, 24 (latest beta)
   - Python: 2.7, 3.13, 3.14 (latest beta)
   - C#: .NET 7, 8, 9 (latest beta)
   - All other languages: Latest stable versions

2. **Update Mechanism**: The `update-languages.sh` script in the project root must be executed on container start to update all language-agnostic versions and latest betas.

3. **Port Configuration**: JupyterLab runs on port 7654 (NOT 8888).

4. **Docker Architecture**: The project uses a multi-stage Dockerfile approach for better organization and caching.

## Workflow

1. Read README.md completely
2. Review the current Dockerfile structure
3. Check docker-compose.yml configuration
4. Verify the update-languages.sh script exists and is properly configured
5. Test all changes using `docker compose up`

## Testing Protocol

After any changes:
```bash
# Build the image
docker compose build

# Run the container
docker compose up

# Verify all kernels are available
docker exec jupyter-multilang jupyter kernelspec list

# Test each language kernel
# Create test notebooks for each language version
```

## Do NOT:
- Change language version specifications without explicit permission
- Use port 8888 (it's reserved for other services)
- Assume default versions for C++, Java, or Python
- Skip the README.md reading step
