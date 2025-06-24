# Configuration file for Jupyter Lab
# Minimal configuration for containerized environment

c = get_config()

# Allow running as root (required for Docker)
c.NotebookApp.allow_root = True
c.ServerApp.allow_root = True

# Set the notebook directory
c.NotebookApp.notebook_dir = '/notebooks'
c.ServerApp.root_dir = '/notebooks'

# IP configuration for container access
c.NotebookApp.ip = '0.0.0.0'
c.ServerApp.ip = '0.0.0.0'

# Port configuration
c.NotebookApp.port = 7654
c.ServerApp.port = 7654

# Disable token and password for local development
# WARNING: Only use this for local development!
c.NotebookApp.token = ''
c.NotebookApp.password = ''
c.ServerApp.token = ''
c.ServerApp.password = ''

# Open browser
c.NotebookApp.open_browser = False
c.ServerApp.open_browser = False

# Allow origin for CORS
c.NotebookApp.allow_origin = '*'
c.ServerApp.allow_origin = '*'

# WebSocket settings
c.NotebookApp.tornado_settings = {
    'ws_ping_interval': 30000,
    'ws_ping_timeout': 10000,
}

# Enable widgets extension
c.NotebookApp.nbserver_extensions = {
    'jupyter_nbextensions_configurator': True,
    'jupyterlab': True,
}

# File size limit (in bytes) - 100MB
c.NotebookApp.max_buffer_size = 104857600
c.ServerApp.max_buffer_size = 104857600

# Shut down the server after N seconds with no kernels or terminals
c.NotebookApp.shutdown_no_activity_timeout = 0
c.ServerApp.shutdown_no_activity_timeout = 0

# The base URL for the notebook server
c.NotebookApp.base_url = '/'
c.ServerApp.base_url = '/'
