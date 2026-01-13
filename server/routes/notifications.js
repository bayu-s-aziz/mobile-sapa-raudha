const express = require('express');
const router = express.Router();
const { authMiddleware } = require('./middleware/auth');

// GET /api/notifications - Get all notifications for current user
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const userRole = req.user.role;

    const [notifications] = await req.db.query(
      `SELECT * FROM notifications 
       WHERE (user_id = ? AND user_role = ?) OR is_broadcast = 1
       ORDER BY created_at DESC 
       LIMIT 50`,
      [userId, userRole]
    );

    res.json({
      success: true,
      notifications
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

// GET /api/notifications/unread - Get unread notifications
router.get('/unread', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const userRole = req.user.role;

    const [notifications] = await req.db.query(
      `SELECT * FROM notifications 
       WHERE ((user_id = ? AND user_role = ?) OR is_broadcast = 1)
       AND read_at IS NULL
       ORDER BY created_at DESC`,
      [userId, userRole]
    );

    res.json({
      success: true,
      notifications
    });
  } catch (error) {
    console.error('Error fetching unread notifications:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

// PUT /api/notifications/:id/read - Mark notification as read
router.put('/:id/read', authMiddleware, async (req, res) => {
  try {
    const notificationId = req.params.id;
    const userId = req.user.id;
    const userRole = req.user.role;

    await req.db.query(
      `UPDATE notifications 
       SET read_at = NOW() 
       WHERE id = ? AND user_id = ? AND user_role = ?`,
      [notificationId, userId, userRole]
    );

    res.json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

// POST /api/notifications - Create notification (admin only)
router.post('/', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.role !== 'kepsek') {
      return res.status(403).json({ 
        success: false, 
        message: 'Unauthorized' 
      });
    }

    const { 
      title, 
      body, 
      user_id, 
      user_role, 
      is_broadcast, 
      data 
    } = req.body;

    const [result] = await req.db.query(
      `INSERT INTO notifications 
       (title, body, user_id, user_role, is_broadcast, data, created_at) 
       VALUES (?, ?, ?, ?, ?, ?, NOW())`,
      [
        title, 
        body, 
        user_id || null, 
        user_role || null, 
        is_broadcast || 0,
        JSON.stringify(data || {})
      ]
    );

    const notification = {
      id: result.insertId,
      title,
      body,
      data: data || {}
    };

    // Send via WebSocket
    if (is_broadcast) {
      if (user_role) {
        req.app.broadcastToRole(user_role, notification);
      } else {
        req.app.broadcastToAll(notification);
      }
    } else if (user_id && user_role) {
      req.app.sendNotificationToUser(user_id, user_role, notification);
    }

    res.json({
      success: true,
      notification
    });
  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
});

module.exports = router;
