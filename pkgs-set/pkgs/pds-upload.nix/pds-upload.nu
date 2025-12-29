#!/usr/bin/env nu

# A script to upload a blob and create a record in the AT Protocol (Bluesky).
# Usage: nu pds-upload.nu <path-to-image>

def main [
    file_path: path  # The path to the file you want to upload
] {
    # --- 1. Setup & Configuration ---
    let identifier = ($env.ATPROTO_DID? | default "")
    let password = ($env.ATPROTO_PASSWORD? | default "")
    
    # Default to the main network if not specified in env
    let pds_host = ($env.ATPROTO_PDS_URL? | default "https://bsky.social")

    # Validation
    if ($identifier | is-empty) or ($password | is-empty) {
        error make {
            msg: "Missing Credentials", 
            label: {
                text: "Please set ATPROTO_DID and ATPROTO_PASSWORD environment variables.",
                span: (metadata $identifier).span 
            }
        }
    }

    if not ($file_path | path exists) {
        error make { msg: $"File not found: ($file_path)" }
    }

    # Detect mime-type
    let mime_type = (try { 
        ^file --mime-type -b $file_path | str trim 
    } catch { 
        "application/octet-stream" 
    })

    # --- 2. Create Session (Authentication) ---
    let session_res = (http post 
        --content-type "application/json"
        $"($pds_host)/xrpc/com.atproto.server.createSession"
        { identifier: $identifier, password: $password }
    )

    let access_token = $session_res.accessJwt
    let repo_did = $session_res.did

    # --- 3. Upload Blob ---
    let file_data = (open $file_path)

    let blob_res = (http post
        --content-type $mime_type
        --headers { Authorization: $"Bearer ($access_token)" }
        $"($pds_host)/xrpc/com.atproto.repo.uploadBlob"
        $file_data
    )

    let blob_ref = $blob_res.blob
    
    # --- 4. Create Record ---
    let file_name = ($file_path | path basename)
    let now = (date now | format date "%Y-%m-%dT%H:%M:%SZ")
    
    let record_payload = {
        repo: $repo_did
        collection: "systems.gaze.file"
        record: {
            "$type": "systems.gaze.file"
            createdAt: $now
            file: $blob_ref
            filename: $file_name
        }
    }

    let record_res = (http post
        --content-type "application/json"
        --headers { Authorization: $"Bearer ($access_token)" }
        $"($pds_host)/xrpc/com.atproto.repo.createRecord"
        $record_payload
    )

    # --- 5. Construct Return Value ---
    # We construct the public URL for the blob
    # The '$link' key requires special handling to extract
    let cid = ($blob_ref.ref | get '$link')
    let blob_url = $"($pds_host)/xrpc/com.atproto.sync.getBlob?did=($repo_did)&cid=($cid)"

    # Return a structured record with both the URI and the direct URL
    let result = {
        uri: $record_res.uri
        cid: $record_res.cid
        blob_url: $blob_url
    } | to json

    return $result
}