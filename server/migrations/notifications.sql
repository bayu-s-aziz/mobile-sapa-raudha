-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INT NULL,
  user_role ENUM('admin', 'guru', 'kepsek', 'parent') NULL,
  is_broadcast TINYINT(1) DEFAULT 0,
  data JSON NULL,
  read_at DATETIME NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user (user_id, user_role),
  INDEX idx_read (read_at),
  INDEX idx_created (created_at)
);

-- Add sample notification
INSERT INTO notifications (title, body, user_role, is_broadcast, data, created_at)
VALUES (
  'Selamat Datang di SAPA Raudha',
  'Terima kasih telah menggunakan aplikasi SAPA Raudha untuk monitoring kehadiran siswa',
  NULL,
  1,
  '{"type": "welcome"}',
  NOW()
);
