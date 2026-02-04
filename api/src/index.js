// Podcast Studio API Server
// Basic Express server with LiveKit integration

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { AccessToken } from 'livekit-server-sdk';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.API_PORT || 3333;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Generate LiveKit access token
app.post('/api/token', async (req, res) => {
  try {
    const { roomName, participantName } = req.body;

    if (!roomName || !participantName) {
      return res.status(400).json({ error: 'roomName and participantName are required' });
    }

    // Create access token
    const at = new AccessToken(
      process.env.LIVEKIT_API_KEY,
      process.env.LIVEKIT_API_SECRET,
      {
        identity: participantName,
        // Token expires in 24 hours
        ttl: '24h',
      }
    );

    // Grant permissions
    at.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    });

    const token = at.toJwt();

    res.json({
      token,
      url: process.env.LIVEKIT_URL,
    });
  } catch (error) {
    console.error('Error generating token:', error);
    res.status(500).json({ error: 'Failed to generate token' });
  }
});

// Create new session
app.post('/api/sessions', async (req, res) => {
  try {
    const { title, description } = req.body;

    // TODO: Store session in database/Redis
    const sessionId = `session-${Date.now()}`;

    res.json({
      sessionId,
      title,
      description,
      createdAt: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error creating session:', error);
    res.status(500).json({ error: 'Failed to create session' });
  }
});

// Get session details
app.get('/api/sessions/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // TODO: Retrieve session from database/Redis
    res.json({
      sessionId: id,
      status: 'active',
      // More session details here
    });
  } catch (error) {
    console.error('Error fetching session:', error);
    res.status(500).json({ error: 'Failed to fetch session' });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🎙️  Podcast Studio API running on port ${PORT}`);
  console.log(`📡 LiveKit URL: ${process.env.LIVEKIT_URL}`);
});
