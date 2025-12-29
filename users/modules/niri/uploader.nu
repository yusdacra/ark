#!/usr/bin/env nu

def main [] {
    # --- 1. Get Clipboard Content ---
    let timestamp = (date now | format date '%Y%m%d_%H%M%S')
    let temp_file = $"/tmp/clip_($timestamp)"
    
    # Save clipboard to temp file
    # We remove --no-newline to safely handle binary data if necessary, 
    # though wl-paste usually handles it.
    try {
        wl-paste | save -f $temp_file
    } catch {
        notify-send "Upload Failed" "Could not get content from clipboard"
        exit 1
    }

    # Detect MIME type just for logging/notification
    let mime_type = (try { 
        ^file --mime-type -b $temp_file | str trim 
    } catch { 
        "application/octet-stream" 
    })

    print $"📤 Uploading ($mime_type)..."
    notify-send "ATProto Upload" $"Uploading ($mime_type)..." -t 2000

    try {
        # --- 2. Call pds-upload ---
        # pds-upload now returns: { uri, cid, blob_url }
        let res = pds-upload $temp_file | from json
        
        let record_uri = $res.uri
        let blob_url = $res.blob_url
        
        print $"🔗 Blob URL: ($blob_url)"
        print "✂️  Shortening with is.gd..."

        # --- 3. Shorten URL ---
        # is.gd expects the URL to be passed as a query parameter 'url'
        # We must URL-encode the blob_url
        let encoded_target = ($blob_url | url encode)
        let shorten_api = $"https://is.gd/create.php?format=simple&url=($encoded_target)"
        
        # is.gd returns the short URL as the body text
        let short_url = (http get $shorten_api)

        # --- 4. Success & Clipboard ---
        # Check if is.gd returned a URL (starts with http) or an error
        if ($short_url | str starts-with "http") {
            $short_url | wl-copy
            notify-send "ATProto Upload" $"Shortened: ($short_url)"
            print $"✅ Shortened: ($short_url)"
        } else {
            # Fallback to the long blob URL if shortening failed
            $blob_url | wl-copy
            notify-send "ATProto Upload" $"Uploaded (Shorten failed)"
            print $"⚠️ Shorten failed: ($short_url)"
        }

    } catch {|e|
        # Parse error for notification
        let err_msg = ($e | to text)
        notify-send "ATProto Upload" $"Upload failed: ($err_msg)" -u critical
        print $"❌ Upload failed: ($err_msg)"
    }
    
    # Cleanup
    rm -f $temp_file
}