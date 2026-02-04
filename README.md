# Video Podcast Recording Platform

Self-hosted web application for recording video podcasts at 4K with premium audio, featuring remote guest support, multi-track recording, live streaming, and scene switching.

## Overview

**Architecture**: Hybrid LiveKit + Double-Ended Recording
- **LiveKit** handles real-time WebRTC communication and RTMP streaming
- **Local recording** on each participant's browser for true 4K quality
- **MinIO** for S3-compatible storage of recordings
- **FFmpeg** for post-processing and multi-track synchronization

## Tech Stack

| Layer | Technology |
|-------|------------|
| **WebRTC Server** | LiveKit (Go-based SFU) |
| **Frontend** | React 18 + TypeScript + Vite |
| **Backend API** | Node.js/Express |
| **Local Recording** | MediaRecorder API (VP9 codec) |
| **File Upload** | Uppy.js (resumable uploads) |
| **Storage** | MinIO (S3-compatible) |
| **Processing** | FFmpeg |
| **TURN Server** | Coturn (NAT traversal) |
| **State** | Redis |

## Quick Start

1. Copy `.env.example` to `.env` and fill in your values
2. Run `docker compose up -d`
3. Access the frontend at `http://192.168.1.8:8080`
4. MinIO console at `http://192.168.1.8:9001`

## Network Configuration

**Assigned IP**: `192.168.1.8`

### Required Firewall Rules

```bash
# LiveKit
sudo ufw allow 7880/tcp comment "LiveKit API"
sudo ufw allow 7881/tcp comment "WebRTC TCP"
sudo ufw allow 7882/udp comment "WebRTC UDP"

# TURN Server
sudo ufw allow 3478 comment "TURN"
sudo ufw allow 10000:20000/udp comment "TURN relay"

# Application (local network only)
sudo ufw allow from 192.168.1.0/24 to any port 8080 comment "Frontend"
sudo ufw allow from 192.168.1.0/24 to any port 3333 comment "API"
sudo ufw allow from 192.168.1.0/24 to any port 9000:9001 comment "MinIO"
```

## Storage Planning

| Quality | Per Hour | 4-Person 1hr Session |
|---------|----------|---------------------|
| 1080p | ~3.6 GB | ~14.4 GB |
| 4K | ~11.25 GB | ~45 GB |

**Recommendation**: Plan ~50 GB per 1-hour 4K session

### Retention Policy
- **Raw uploads**: 7 days (auto-delete after processing)
- **Processed files**: 90 days in MinIO
- **Archive**: Move to NAS for long-term storage

## Development Phases

### Phase 1: MVP (Foundation) ✓
- Docker Compose stack with LiveKit + Redis
- Basic React frontend with LiveKit SDK
- Simple 2-person video call
- Server-side recording via LiveKit Egress
- UFW firewall rules

### Phase 2: Multi-Track Recording
- MinIO S3 storage integration
- Client-side MediaRecorder for 4K local capture
- Resumable uploads with Uppy.js
- Sync marker system for alignment
- Support for up to 4 participants
- Session management API

### Phase 3: Post-Processing Pipeline
- FFmpeg worker container
- Automated sync detection and alignment
- Audio normalization (loudnorm filter)
- Multi-track export (MKV with separate audio tracks)
- Processing queue with status tracking

### Phase 4: Live Streaming
- LiveKit Egress RTMP configuration
- YouTube/Twitch stream key management
- Start/stop streaming controls in UI
- Stream health monitoring

### Phase 5: Scene Switching & Polish
- Custom scene layouts (grid, spotlight, side-by-side)
- Transitions and overlays
- Guest waiting room
- Pre-flight equipment check
- Sound effects board

## External Access

Use Nginx Proxy Manager (192.168.1.6) for SSL termination:
- Proxy host: `podcast.yourdomain.com` -> `192.168.1.8:8080`

## Alternative: Simpler Approach

If the full custom solution feels too complex, consider **VDO.Ninja + OBS**:
- Self-host VDO.Ninja (simple static files)
- Use OBS for recording, streaming, and scene switching
- Add Ennuicastr for multi-track audio recording

This trades some features for significantly reduced complexity.

## License

MIT
