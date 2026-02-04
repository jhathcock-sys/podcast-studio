#!/bin/bash
# FFmpeg Post-Processing Script for Podcast Sessions
# Syncs multi-track recordings and normalizes audio

set -euo pipefail

# Configuration
INPUT_DIR="${1:-/input}"
OUTPUT_DIR="${2:-/output}"
SESSION_ID="${3:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if session ID provided
if [ -z "$SESSION_ID" ]; then
    error "Session ID required"
    echo "Usage: $0 <input_dir> <output_dir> <session_id>"
    exit 1
fi

log "Processing session: $SESSION_ID"

# Find all video files for this session
VIDEO_FILES=("$INPUT_DIR/$SESSION_ID"/*.webm)

if [ ${#VIDEO_FILES[@]} -eq 0 ]; then
    error "No video files found for session $SESSION_ID"
    exit 1
fi

log "Found ${#VIDEO_FILES[@]} video file(s)"

# Create output directory
mkdir -p "$OUTPUT_DIR/$SESSION_ID"

# Process each video file
for video in "${VIDEO_FILES[@]}"; do
    filename=$(basename "$video")
    participant="${filename%.*}"

    log "Processing participant: $participant"

    # Extract audio for normalization
    audio_extracted="$OUTPUT_DIR/$SESSION_ID/${participant}_audio.wav"

    ffmpeg -i "$video" \
        -vn -acodec pcm_s16le -ar 48000 -ac 2 \
        "$audio_extracted" \
        -y 2>&1 | grep -v "frame="

    # Normalize audio (loudnorm filter)
    audio_normalized="$OUTPUT_DIR/$SESSION_ID/${participant}_audio_normalized.wav"

    ffmpeg -i "$audio_extracted" \
        -af loudnorm=I=-16:TP=-1.5:LRA=11 \
        "$audio_normalized" \
        -y 2>&1 | grep -v "frame="

    # Combine normalized audio with video
    output_file="$OUTPUT_DIR/$SESSION_ID/${participant}_processed.mkv"

    ffmpeg -i "$video" -i "$audio_normalized" \
        -c:v copy -c:a aac -b:a 192k \
        -map 0:v:0 -map 1:a:0 \
        "$output_file" \
        -y 2>&1 | grep -v "frame="

    # Cleanup temporary files
    rm "$audio_extracted" "$audio_normalized"

    log "✓ Processed: $participant"
done

# Create multi-track MKV with all participants
log "Creating multi-track output..."

# TODO: Implement sync detection and multi-track merging
# This requires audio fingerprinting or sync markers
# For now, we just have individual processed files

log "✓ Session processing complete: $SESSION_ID"
log "Output directory: $OUTPUT_DIR/$SESSION_ID"

exit 0
