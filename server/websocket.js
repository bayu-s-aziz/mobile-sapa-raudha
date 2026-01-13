const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

// Map untuk menyimpan koneksi WebSocket berdasarkan user ID dan role
const connections = new Map();

function initializeWebSocket(server) {
  const wss = new WebSocket.Server({ 
    server,
    path: '/ws'
  });

  wss.on('connection', async (ws, req) => {
    let userId = null;
    let userRole = null;
    let isAuthenticated = false;

    try {
      // Parse token dari query string
      const url = new URL(req.url, `http://${req.headers.host}`);
      const token = url.searchParams.get('token');

      if (!token) {
        ws.close(1008, 'No token provided');
        return;
      }

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
      userId = decoded.id;
      userRole = decoded.role;
      isAuthenticated = true;

      // Store connection
      const connectionKey = `${userRole}_${userId}`;
      connections.set(connectionKey, ws);

      console.log(`WebSocket connected: User ${userId} (${userRole})`);

      // Send welcome message
      ws.send(JSON.stringify({
        type: 'message',
        message: 'Connected to SAPA Raudha notification service'
      }));

    } catch (error) {
      console.error('WebSocket authentication error:', error);
      ws.close(1008, 'Authentication failed');
      return;
    }

    // Handle incoming messages
    ws.on('message', (message) => {
      try {
        const data = JSON.parse(message.toString());
        
        switch (data.type) {
          case 'ping':
            // Respond to heartbeat
            ws.send(JSON.stringify({ type: 'pong' }));
            break;
          
          default:
            console.log('Unknown message type:', data.type);
        }
      } catch (error) {
        console.error('Error parsing message:', error);
      }
    });

    // Handle connection close
    ws.on('close', () => {
      if (isAuthenticated) {
        const connectionKey = `${userRole}_${userId}`;
        connections.delete(connectionKey);
        console.log(`WebSocket disconnected: User ${userId} (${userRole})`);
      }
    });

    // Handle errors
    ws.on('error', (error) => {
      console.error('WebSocket error:', error);
    });
  });

  return wss;
}

// Function untuk mengirim notifikasi ke user tertentu
function sendNotificationToUser(userId, userRole, notification) {
  const connectionKey = `${userRole}_${userId}`;
  const ws = connections.get(connectionKey);

  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({
      type: 'notification',
      ...notification
    }));
    return true;
  }
  return false;
}

// Function untuk mengirim notifikasi ke semua user dengan role tertentu
function broadcastToRole(role, notification) {
  let sentCount = 0;
  
  connections.forEach((ws, key) => {
    if (key.startsWith(`${role}_`) && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'notification',
        ...notification
      }));
      sentCount++;
    }
  });

  console.log(`Broadcast to ${role}: ${sentCount} connections`);
  return sentCount;
}

// Function untuk broadcast ke semua user
function broadcastToAll(notification) {
  let sentCount = 0;
  
  connections.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({
        type: 'notification',
        ...notification
      }));
      sentCount++;
    }
  });

  console.log(`Broadcast to all: ${sentCount} connections`);
  return sentCount;
}

module.exports = {
  initializeWebSocket,
  sendNotificationToUser,
  broadcastToRole,
  broadcastToAll
};
