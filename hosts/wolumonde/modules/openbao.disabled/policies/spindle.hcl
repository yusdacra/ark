# Full access to spindle KV v2 data
path "spindle/data/*" {
  capabilities = ["create", "read", "update", "delete"]
}

# Access to metadata for listing and management
path "spindle/metadata/*" {
  capabilities = ["list", "read", "delete", "update"]
}

# Allow listing at root level
path "spindle/" {
  capabilities = ["list"]
}

# Required for connection testing and health checks
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
