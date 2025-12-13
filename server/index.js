import express from 'express';
import cors from 'cors';
import jwt from 'jsonwebtoken';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
import { pool } from './mysql.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());
app.use(express.json());

// Serve static files (uploads)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret';

function sign(profile) {
  return jwt.sign(profile, JWT_SECRET, { expiresIn: '12h' });
}

// Middleware untuk autentikasi
function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: 'No token provided' });
  
  const token = authHeader.replace('Bearer ', '');
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (e) {
    return res.status(401).json({ message: 'Invalid token' });
  }
}

// Setup multer untuk upload file
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, 'uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage,
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

app.post('/auth/admin/login', async (req, res) => {
  const { identifier, password } = req.body; // NIK
  const [rows] = await pool.query('SELECT * FROM admins WHERE nik=?', [identifier]);
  const user = rows[0];
  if (!user) return res.status(401).json({ message: 'not found' });
  const ok = user.password_hash === password; // plaintext comparison
  if (!ok) return res.status(401).json({ message: 'bad creds' });
  const profile = { id: user.id, role: 'admin', name: user.name };
  return res.json({ token: sign(profile), profile });
});

app.post('/auth/guru/login', async (req, res) => {
  const { identifier, password } = req.body; // NIK
  const [rows] = await pool.query('SELECT * FROM gurus WHERE nik=?', [identifier]);
  const user = rows[0];
  if (!user) return res.status(401).json({ message: 'not found' });
  const ok = user.password_hash === password; // plaintext comparison
  if (!ok) return res.status(401).json({ message: 'bad creds' });
  const profile = { id: user.id, role: user.role, name: user.name };
  return res.json({ token: sign(profile), profile });
});

app.post('/auth/parent/login', async (req, res) => {
  const { identifier, password } = req.body; // NISN
  const [rows] = await pool.query(
    `SELECT p.* FROM parents p
     JOIN students s ON p.student_id = s.id WHERE s.nisn=?`,
    [identifier]
  );
  const user = rows[0];
  if (!user) return res.status(401).json({ message: 'not found' });
  const ok = user.password_hash === password; // plaintext comparison
  if (!ok) return res.status(401).json({ message: 'bad creds' });
  const [stuRows] = await pool.query('SELECT * FROM students WHERE id=?', [user.student_id]);
  const student = stuRows[0];
  const profile = { id: user.id, role: 'orangtua', name: user.name, nisn: student.nisn, anak: student.name, kelas: student.kelas };
  return res.json({ token: sign(profile), profile });
});

// Unified login: detects role automatically using identifier (NIK or NISN)
app.post('/auth/login', async (req, res) => {
  const { identifier, password } = req.body;
  if (!identifier || !password) {
    return res.status(400).json({ message: 'identifier and password required' });
  }

  // Try Admin by NIK
  try {
    const [admins] = await pool.query('SELECT * FROM admins WHERE nik=?', [identifier]);
    const admin = admins[0];
    if (admin && admin.password_hash === password) {
      const profile = { id: admin.id, role: 'admin', name: admin.name };
      return res.json({ token: sign(profile), profile });
    }
  } catch (e) {
    // continue
  }

  // Try Guru/Kepsek by NIK
  try {
    const [gurus] = await pool.query('SELECT * FROM gurus WHERE nik=?', [identifier]);
    const guru = gurus[0];
    if (guru && guru.password_hash === password) {
      const profile = { id: guru.id, role: guru.role || 'guru', name: guru.name };
      return res.json({ token: sign(profile), profile });
    }
  } catch (e) {
    // continue
  }

  // Try Parent via child NISN
  try {
    const [parents] = await pool.query(
      `SELECT p.*, s.nisn, s.name AS anak, c.name AS kelas,
              COALESCE(p.father_name, p.mother_name, 'Orang Tua') AS parent_name
       FROM parents p
       JOIN students s ON p.student_id = s.id
       LEFT JOIN classes c ON s.class_id = c.id
       WHERE s.nisn = ?`,
      [identifier]
    );
    const parent = parents[0];
    if (parent && parent.password_hash === password) {
      const profile = {
        id: parent.id,
        role: 'orangtua',
        name: parent.parent_name,
        nisn: parent.nisn,
        anak: parent.anak,
        kelas: parent.kelas,
      };
      return res.json({ token: sign(profile), profile });
    }
  } catch (e) {
    // continue
  }

  return res.status(401).json({ message: 'bad creds' });
});

// ============================================
// STUDENTS ENDPOINTS
// ============================================

// GET /students - List all students (untuk guru)
app.get('/students', authMiddleware, async (req, res) => {
  try {
    const { class_id } = req.query;
    let query = `
      SELECT s.*, c.name as class_name, c.grade,
             p.father_name, p.mother_name, p.guardian_name,
             p.father_job, p.mother_job, p.guardian_job,
             p.father_phone, p.mother_phone, p.guardian_phone
      FROM students s
      LEFT JOIN classes c ON s.class_id = c.id
      LEFT JOIN parents p ON s.id = p.student_id
    `;
    const params = [];
    
    if (class_id) {
      query += ' WHERE s.class_id = ?';
      params.push(class_id);
    }
    
    query += ' ORDER BY c.grade, c.name, s.name';
    
    const [rows] = await pool.query(query, params);
    return res.json({ students: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /students/:id - Detail student
app.get('/students/:id', authMiddleware, async (req, res) => {
  try {
    const [students] = await pool.query(`
      SELECT s.*, c.name as class_name, c.grade,
             p.father_name, p.mother_name, p.father_phone, p.mother_phone,
             p.father_job, p.mother_job, p.guardian_name
      FROM students s
      LEFT JOIN classes c ON s.class_id = c.id
      LEFT JOIN parents p ON s.id = p.student_id
      WHERE s.id = ?
    `, [req.params.id]);
    
    if (!students[0]) {
      return res.status(404).json({ message: 'Student not found' });
    }
    
    return res.json({ student: students[0] });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /students/nisn/:nisn - Get student by NISN
app.get('/students/nisn/:nisn', authMiddleware, async (req, res) => {
  try {
    const [students] = await pool.query(`
      SELECT s.*, c.name as class_name, c.grade,
             p.father_name, p.mother_name, p.father_phone, p.mother_phone
      FROM students s
      LEFT JOIN classes c ON s.class_id = c.id
      LEFT JOIN parents p ON s.id = p.student_id
      WHERE s.nisn = ?
    `, [req.params.nisn]);
    
    if (!students[0]) {
      return res.status(404).json({ message: 'Student not found' });
    }
    
    return res.json({ student: students[0] });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /classes - List all classes
app.get('/classes', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT c.*, g.name as homeroom_teacher_name,
             COUNT(s.id) as student_count
      FROM classes c
      LEFT JOIN gurus g ON c.homeroom_teacher_id = g.id
      LEFT JOIN students s ON c.id = s.class_id
      GROUP BY c.id
      ORDER BY c.grade, c.name
    `);
    return res.json({ classes: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// ============================================
// ANNOUNCEMENTS ENDPOINTS
// ============================================

// GET /announcements - List announcements
app.get('/announcements', authMiddleware, async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;
    
    const [rows] = await pool.query(`
      SELECT a.*, 
             CASE 
               WHEN a.author_type = 'admin' THEN ad.name
               WHEN a.author_type = 'guru' THEN g.name
             END as author_name,
             (SELECT COUNT(*) FROM attachments WHERE announcement_id = a.id) as attachment_count
      FROM announcements a
      LEFT JOIN admins ad ON a.author_type = 'admin' AND a.author_id = ad.id
      LEFT JOIN gurus g ON a.author_type = 'guru' AND a.author_id = g.id
      ORDER BY a.created_at DESC
      LIMIT ? OFFSET ?
    `, [parseInt(limit), parseInt(offset)]);
    
    return res.json({ announcements: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /announcements/:id - Detail announcement
app.get('/announcements/:id', authMiddleware, async (req, res) => {
  try {
    const [announcements] = await pool.query(`
      SELECT a.*, 
             CASE 
               WHEN a.author_type = 'admin' THEN ad.name
               WHEN a.author_type = 'guru' THEN g.name
             END as author_name
      FROM announcements a
      LEFT JOIN admins ad ON a.author_type = 'admin' AND a.author_id = ad.id
      LEFT JOIN gurus g ON a.author_type = 'guru' AND a.author_id = g.id
      WHERE a.id = ?
    `, [req.params.id]);
    
    if (!announcements[0]) {
      return res.status(404).json({ message: 'Announcement not found' });
    }
    
    // Get attachments
    const [attachments] = await pool.query(
      'SELECT * FROM attachments WHERE announcement_id = ?',
      [req.params.id]
    );
    
    const announcement = announcements[0];
    announcement.attachments = attachments;
    
    return res.json({ announcement });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /announcements - Create announcement
app.post('/announcements', authMiddleware, upload.single('attachment'), async (req, res) => {
  try {
    const { title, content, target_audience = 'all', target_class_id } = req.body;
    const { id: author_id, role } = req.user;
    
    if (!title || !content) {
      return res.status(400).json({ message: 'Title and content required' });
    }
    
    const author_type = role === 'admin' ? 'admin' : 'guru';
    
    const [result] = await pool.query(
      `INSERT INTO announcements (title, content, author_id, author_type, target_audience, target_class_id)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [title, content, author_id, author_type, target_audience, target_class_id || null]
    );
    
    const announcementId = result.insertId;
    
    // Handle attachment if uploaded
    if (req.file) {
      await pool.query(
        `INSERT INTO attachments (announcement_id, filename, file_path, file_type, file_size)
         VALUES (?, ?, ?, ?, ?)`,
        [
          announcementId,
          req.file.originalname,
          `/uploads/${req.file.filename}`,
          req.file.mimetype,
          req.file.size
        ]
      );
    }
    
    return res.status(201).json({ 
      message: 'Announcement created',
      id: announcementId
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// DELETE /announcements/:id - Delete announcement
app.delete('/announcements/:id', authMiddleware, async (req, res) => {
  try {
    // Only admin or author can delete
    const [announcements] = await pool.query(
      'SELECT * FROM announcements WHERE id = ?',
      [req.params.id]
    );
    
    if (!announcements[0]) {
      return res.status(404).json({ message: 'Announcement not found' });
    }
    
    const announcement = announcements[0];
    const isAuthor = announcement.author_id === req.user.id && 
                     announcement.author_type === req.user.role;
    const isAdmin = req.user.role === 'admin';
    
    if (!isAuthor && !isAdmin) {
      return res.status(403).json({ message: 'Forbidden' });
    }
    
    // Delete attachments from filesystem
    const [attachments] = await pool.query(
      'SELECT file_path FROM attachments WHERE announcement_id = ?',
      [req.params.id]
    );
    
    for (const att of attachments) {
      const filePath = path.join(__dirname, att.file_path);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }
    
    // Delete from database (cascade will delete attachments)
    await pool.query('DELETE FROM announcements WHERE id = ?', [req.params.id]);
    
    return res.json({ message: 'Announcement deleted' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// ============================================
// ATTENDANCE ENDPOINTS
// ============================================

// POST /attendance/scan - Record attendance via QR scan
app.post('/attendance/scan', authMiddleware, async (req, res) => {
  try {
    const { nisn } = req.body;
    const scanned_by = req.user.id;
    
    if (!nisn) {
      return res.status(400).json({ message: 'NISN required' });
    }
    
    // Check if guru
    if (req.user.role !== 'guru' && req.user.role !== 'kepsek') {
      return res.status(403).json({ message: 'Only teachers can scan attendance' });
    }
    
    // Get student
    const [students] = await pool.query('SELECT * FROM students WHERE nisn = ?', [nisn]);
    if (!students[0]) {
      return res.status(404).json({ message: 'Student not found' });
    }
    
    const student = students[0];
    const today = new Date().toISOString().split('T')[0];
    const now = new Date().toTimeString().split(' ')[0];
    
    // Check if already recorded today
    const [existing] = await pool.query(
      'SELECT * FROM attendance WHERE student_id = ? AND date = ?',
      [student.id, today]
    );
    
    if (existing[0]) {
      return res.status(400).json({ 
        message: 'Attendance already recorded today',
        student: student.name,
        status: existing[0].status
      });
    }
    
    // Record attendance
    await pool.query(
      `INSERT INTO attendance (student_id, date, status, check_in, scanned_by)
       VALUES (?, ?, 'hadir', ?, ?)`,
      [student.id, today, now, scanned_by]
    );
    
    return res.json({ 
      message: 'Attendance recorded',
      student: {
        name: student.name,
        nisn: student.nisn,
        class: student.class_id
      },
      time: now
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /attendance/student/:nisn - Get attendance history for student
app.get('/attendance/student/:nisn', authMiddleware, async (req, res) => {
  try {
    const { start_date, end_date, limit = 30 } = req.query;
    
    const [students] = await pool.query('SELECT id FROM students WHERE nisn = ?', [req.params.nisn]);
    if (!students[0]) {
      return res.status(404).json({ message: 'Student not found' });
    }
    
    let query = `
      SELECT a.*, g.name as scanned_by_name
      FROM attendance a
      LEFT JOIN gurus g ON a.scanned_by = g.id
      WHERE a.student_id = ?
    `;
    const params = [students[0].id];
    
    if (start_date) {
      query += ' AND a.date >= ?';
      params.push(start_date);
    }
    if (end_date) {
      query += ' AND a.date <= ?';
      params.push(end_date);
    }
    
    query += ' ORDER BY a.date DESC LIMIT ?';
    params.push(parseInt(limit));
    
    const [rows] = await pool.query(query, params);
    return res.json({ attendance: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /attendance/class/:classId/date/:date - Get attendance for class on specific date
app.get('/attendance/class/:classId/date/:date', authMiddleware, async (req, res) => {
  try {
    const { classId, date } = req.params;
    
    const [rows] = await pool.query(`
      SELECT s.id, s.nisn, s.name, 
             a.status, a.check_in, a.check_out, a.notes
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id AND a.date = ?
      WHERE s.class_id = ?
      ORDER BY s.name
    `, [date, classId]);
    
    return res.json({ attendance: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /attendance/stats - Get attendance statistics
app.get('/attendance/stats', authMiddleware, async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    const [totalStudents] = await pool.query('SELECT COUNT(*) as count FROM students');
    const [todayPresent] = await pool.query(
      'SELECT COUNT(*) as count FROM attendance WHERE date = ? AND status = "hadir"',
      [today]
    );
    const [todaySick] = await pool.query(
      'SELECT COUNT(*) as count FROM attendance WHERE date = ? AND status = "sakit"',
      [today]
    );
    const [todayPermit] = await pool.query(
      'SELECT COUNT(*) as count FROM attendance WHERE date = ? AND status = "izin"',
      [today]
    );
    
    return res.json({
      total_students: totalStudents[0].count,
      today: {
        present: todayPresent[0].count,
        sick: todaySick[0].count,
        permit: todayPermit[0].count,
        absent: totalStudents[0].count - todayPresent[0].count - todaySick[0].count - todayPermit[0].count
      }
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// ============================================
// LEAVE REQUESTS ENDPOINTS
// ============================================

// POST /leave-requests - Submit leave request (parent)
app.post('/leave-requests', authMiddleware, upload.single('attachment'), async (req, res) => {
  try {
    const { student_nisn, request_date, reason } = req.body;
    
    if (!student_nisn || !request_date || !reason) {
      return res.status(400).json({ message: 'NISN, date, and reason required' });
    }
    
    // Get student
    const [students] = await pool.query('SELECT * FROM students WHERE nisn = ?', [student_nisn]);
    if (!students[0]) {
      return res.status(404).json({ message: 'Student not found' });
    }
    
    const attachment_path = req.file ? `/uploads/${req.file.filename}` : null;
    
    const [result] = await pool.query(
      `INSERT INTO leave_requests (student_id, request_date, reason, attachment_path)
       VALUES (?, ?, ?, ?)`,
      [students[0].id, request_date, reason, attachment_path]
    );
    
    // Auto-create attendance record with 'izin' status
    await pool.query(
      `INSERT INTO attendance (student_id, date, status, notes)
       VALUES (?, ?, 'izin', ?)
       ON DUPLICATE KEY UPDATE status = 'izin', notes = ?`,
      [students[0].id, request_date, reason, reason]
    );
    
    return res.status(201).json({ 
      message: 'Leave request submitted',
      id: result.insertId
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /leave-requests - Get leave requests (filter by role)
app.get('/leave-requests', authMiddleware, async (req, res) => {
  try {
    const { status, student_nisn } = req.query;
    
    let query = `
      SELECT lr.*, s.nisn, s.name as student_name, c.name as class_name,
             g.name as reviewed_by_name
      FROM leave_requests lr
      JOIN students s ON lr.student_id = s.id
      LEFT JOIN classes c ON s.class_id = c.id
      LEFT JOIN gurus g ON lr.reviewed_by = g.id
    `;
    const params = [];
    const conditions = [];
    
    if (student_nisn) {
      conditions.push('s.nisn = ?');
      params.push(student_nisn);
    }
    
    if (status) {
      conditions.push('lr.status = ?');
      params.push(status);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ' ORDER BY lr.submitted_at DESC';
    
    const [rows] = await pool.query(query, params);
    return res.json({ leave_requests: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// PUT /leave-requests/:id/approve - Approve leave request
app.put('/leave-requests/:id/approve', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'guru' && req.user.role !== 'kepsek') {
      return res.status(403).json({ message: 'Only teachers can approve' });
    }
    
    const { review_notes } = req.body;
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
    
    await pool.query(
      `UPDATE leave_requests 
       SET status = 'approved', reviewed_by = ?, reviewed_at = ?, review_notes = ?
       WHERE id = ?`,
      [req.user.id, now, review_notes || 'Disetujui', req.params.id]
    );
    
    return res.json({ message: 'Leave request approved' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// PUT /leave-requests/:id/reject - Reject leave request
app.put('/leave-requests/:id/reject', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'guru' && req.user.role !== 'kepsek') {
      return res.status(403).json({ message: 'Only teachers can reject' });
    }
    
    const { review_notes } = req.body;
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
    
    // Get leave request to update attendance
    const [requests] = await pool.query(
      'SELECT student_id, request_date FROM leave_requests WHERE id = ?',
      [req.params.id]
    );
    
    if (requests[0]) {
      // Remove izin status from attendance
      await pool.query(
        'DELETE FROM attendance WHERE student_id = ? AND date = ? AND status = "izin"',
        [requests[0].student_id, requests[0].request_date]
      );
    }
    
    await pool.query(
      `UPDATE leave_requests 
       SET status = 'rejected', reviewed_by = ?, reviewed_at = ?, review_notes = ?
       WHERE id = ?`,
      [req.user.id, now, review_notes || 'Ditolak', req.params.id]
    );
    
    return res.json({ message: 'Leave request rejected' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// ============================================
// PROFILE & MISC ENDPOINTS
// ============================================

// GET /profile - Get current user profile
app.get('/profile', authMiddleware, async (req, res) => {
  try {
    const { id, role } = req.user;
    
    if (role === 'admin') {
      const [admins] = await pool.query('SELECT id, nik, name, email, phone FROM admins WHERE id = ?', [id]);
      return res.json({ profile: admins[0] });
    }
    
    if (role === 'guru' || role === 'kepsek') {
      const [gurus] = await pool.query('SELECT id, nik, name, email, phone, role, subject, photo_url FROM gurus WHERE id = ?', [id]);
      return res.json({ profile: gurus[0] });
    }
    
    if (role === 'orangtua') {
      const [parents] = await pool.query(`
        SELECT p.*, s.nisn, s.name as student_name, c.name as class_name
        FROM parents p
        JOIN students s ON p.student_id = s.id
        LEFT JOIN classes c ON s.class_id = c.id
        WHERE p.id = ?
      `, [id]);
      return res.json({ profile: parents[0] });
    }
    
    return res.status(404).json({ message: 'Profile not found' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// PUT /profile/photo - Update profile photo
app.put('/profile/photo', authMiddleware, upload.single('photo'), async (req, res) => {
  try {
    const { id, role } = req.user;
    
    if (!req.file) {
      return res.status(400).json({ message: 'No photo uploaded' });
    }
    
    const photo_url = `/uploads/${req.file.filename}`;
    
    if (role === 'admin') {
      await pool.query('UPDATE admins SET photo_url = ? WHERE id = ?', [photo_url, id]);
    } else if (role === 'guru' || role === 'kepsek') {
      await pool.query('UPDATE gurus SET photo_url = ? WHERE id = ?', [photo_url, id]);
    } else if (role === 'orangtua') {
      await pool.query('UPDATE parents SET photo_url = ? WHERE id = ?', [photo_url, id]);
    } else {
      return res.status(400).json({ message: 'Invalid role' });
    }
    
    return res.json({ 
      message: 'Photo updated successfully',
      photo_url 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API listening on ${port}`));