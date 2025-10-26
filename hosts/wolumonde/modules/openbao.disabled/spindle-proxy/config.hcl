vault {
    address = "%vault_address%"

    # Retry configuration
    retry {
    num_retries = 5
    }
}

# Auto-Auth using AppRole
auto_auth {
    method "approle" {
    mount_path = "auth/approle"
    config = {
        role_id_file_path   = "%role_id%"
        secret_id_file_path = "%secret_id%"
        remove_secret_id_file_after_reading = false
    }
    }

    # Write authenticated token to file
    sink "file" {
    config = {
        path = "/var/lib/%name%/token"
        mode = 0640
    }
    }
}

# API Proxy listener for Spindle
listener "tcp" {
    address     = "127.0.0.1:%listener_port%"
    tls_disable = true

    # Security headers
    require_request_header = false

    # Enable proxy API for management
    proxy_api {
    enable_quit = true
    }
}

# Enable API proxy with auto-auth token
api_proxy {
    use_auto_auth_token = true
}

cache {
}

# Logging configuration
log_level = "info"
log_format = "standard"
log_file = "/var/lib/%name%/proxy.log"
log_rotate_duration = "24h"
log_rotate_max_files = 30

# Process management
pid_file = "/var/lib/%name%/proxy.pid"

# Disable idle connections for reliability
disable_idle_connections = ["auto-auth", "proxying"]
