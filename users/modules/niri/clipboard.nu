#!/usr/bin/env nu

def main [] {
    # Get clipboard history from clipman
    let history = clipman show-history
    
    if ($history | is-empty) {
        notify-send "Clipman" "No clipboard history"
        exit 1
    }
    
    # Show in tofi and get selection
    let selection = ($history | lines | tofi --prompt-text "select clipboard item: " | str trim)
    
    if ($selection | is-empty) {
        exit 0
    }
    
    # Copy selection to clipboard
    $selection | wl-copy
}
