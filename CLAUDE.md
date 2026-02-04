# CLAUDE.md - Podcast Studio

<project>
    <overview>
        Self-hosted video podcast recording platform designed for D&D sessions and podcasts.
        Supports 4K multi-track recording, remote guests, and live streaming.
        Hybrid architecture: LiveKit for real-time communication + local browser recording for quality.
    </overview>

    <repository>
        <name>podcast-studio</name>
        <url>https://github.com/jhathcock-sys/podcast-studio</url>
        <visibility>public</visibility>
        <local_path>/home/cib/podcast-studio</local_path>
        <deployment_ip>192.168.1.8</deployment_ip>
    </repository>

    <tech_stack>
        <webrtc>LiveKit - Real-time communication server</webrtc>
        <frontend>React 18 + TypeScript + Vite</frontend>
        <backend>Node.js/Express</backend>
        <storage>MinIO (S3-compatible object storage)</storage>
        <processing>FFmpeg (post-processing pipeline)</processing>
        <turn>Coturn (NAT traversal for remote guests)</turn>
    </tech_stack>

    <architecture>
        <approach>Hybrid LiveKit + Double-Ended Recording</approach>
        <real_time>
            LiveKit handles WebRTC communication and RTMP streaming
            Participants see/hear each other in real-time
            Optional live stream output to YouTube/Twitch
        </real_time>
        <recording>
            Each browser records locally (true 4K, no WebRTC compression)
            Files upload to MinIO after session
            FFmpeg syncs and normalizes multiple tracks
        </recording>
        <workflow>
            1. Host starts session
            2. Up to 6 participants join via browser (no install)
            3. Real-time communication via LiveKit
            4. Local 4K recording per participant
            5. Auto-upload to MinIO when done
            6. FFmpeg post-processes (sync, normalize, multi-track export)
        </workflow>
    </architecture>

    <access_urls>
        <frontend>http://192.168.1.8:8080</frontend>
        <api>http://192.168.1.8:3333</api>
        <livekit>ws://192.168.1.8:7880</livekit>
        <minio_console>http://192.168.1.8:9001</minio_console>
    </access_urls>

    <storage_planning>
        <quality name="1080p">
            <per_hour>~3.6 GB</per_hour>
            <six_person_session>~21.6 GB</six_person_session>
        </quality>
        <quality name="4K">
            <per_hour>~11.25 GB</per_hour>
            <six_person_session>~67.5 GB</six_person_session>
        </quality>
        <retention_policy>
            Raw uploads: 7 days (auto-delete after processing)
            Processed files: 90 days in MinIO
            Archive: Move to Synology NAS (192.168.1.5) for long-term storage
        </retention_policy>
        <recommendation>Plan ~70 GB per 1-hour 6-person 4K session</recommendation>
    </storage_planning>

    <network_requirements>
        <firewall_rules>
            # LiveKit
            sudo ufw allow 7880/tcp comment "LiveKit API"
            sudo ufw allow 7881/tcp comment "WebRTC TCP"
            sudo ufw allow 7882/udp comment "WebRTC UDP"

            # TURN Server (NAT traversal)
            sudo ufw allow 3478 comment "TURN"
            sudo ufw allow 10000:20000/udp comment "TURN relay"

            # Application (local network only)
            sudo ufw allow from 192.168.1.0/24 to any port 8080 comment "Podcast Frontend"
            sudo ufw allow from 192.168.1.0/24 to any port 3333 comment "Podcast API"
            sudo ufw allow from 192.168.1.0/24 to any port 9000:9001 comment "MinIO"
        </firewall_rules>
    </network_requirements>

    <development_phases>
        <phase number="1" status="planned">
            MVP - Basic 2-person video call with recording
        </phase>
        <phase number="2" status="planned">
            Multi-track recording (up to 6 participants)
        </phase>
        <phase number="3" status="planned">
            Post-processing pipeline (sync, normalize, multi-track export)
        </phase>
        <phase number="4" status="planned">
            Live streaming (YouTube/Twitch)
        </phase>
        <phase number="5" status="planned">
            Scene switching and polish (layouts, overlays, waiting room)
        </phase>
    </development_phases>

    <deployment_checklist>
        <task>Copy .env.example to .env and configure secrets</task>
        <task>Generate LiveKit API credentials (key + secret)</task>
        <task>Apply UFW firewall rules (see network_requirements)</task>
        <task>Deploy stack: docker compose up -d</task>
        <task>Test basic 2-person video call</task>
        <task>Configure Nginx Proxy Manager for SSL (podcast.domain.com)</task>
    </deployment_checklist>

    <use_case_dnd_sessions>
        <setup>
            DM starts session from main interface
            Up to 6 players join via browser (no software install)
            Each browser records local 4K video + audio
            LiveKit handles real-time communication
            Optional: Live stream to Twitch/YouTube
        </setup>
        <post_session>
            All recordings auto-upload to MinIO
            FFmpeg syncs and normalizes tracks
            Multi-track file exported for editing (Davinci Resolve, Premiere)
            Raw files deleted after 7 days
            Processed files archived to NAS (192.168.1.5)
        </post_session>
    </use_case_dnd_sessions>

    <why_not_just_obs>
        <reason>Multi-participant recording - Each person records locally (no quality loss)</reason>
        <reason>Remote guests - Browser-based, no software install required</reason>
        <reason>Multi-track export - Each participant's audio isolated for editing</reason>
        <reason>Live streaming - Built-in RTMP output capability</reason>
    </why_not_just_obs>

    <related_projects>
        <project>homelab-ops - Docker Compose deployment configuration</project>
        <project>homelab-docs - Documentation in Services/Monitoring/ and Projects/</project>
    </related_projects>

    <status>
        <created>2026-02-03</created>
        <current_phase>Initial setup complete, ready for deployment</current_phase>
        <deployment_status>Pending (see homelab-docs Roadmap/Current-TODO.md)</deployment_status>
        <participant_capacity>6 participants (LiveKit max: 10 for buffer)</participant_capacity>
    </status>

    <technical_considerations>
        <storage_strategy>
            MinIO on local SSD for recording uploads (fast write speed)
            NAS for long-term archive (7.2TB available)
            Automatic cleanup prevents disk fill
        </storage_strategy>
        <quality_vs_bandwidth>
            Real-time: WebRTC adapts to network conditions
            Recording: Full 4K quality (recorded locally, not affected by network)
            Best of both worlds: Good real-time experience + high-quality output
        </quality_vs_bandwidth>
    </technical_considerations>
</project>
