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

// POST /students - Create new student
app.post('/students', authMiddleware, async (req, res) => {
  try {
    const {
      nisn, name, gender, birth_place, birth_date, address, class_id,
      father_name, mother_name, guardian_name,
      father_job, mother_job, guardian_job,
      father_phone, mother_phone, guardian_phone,
      password
    } = req.body;
    
    // Check if NISN already exists
    const [existing] = await pool.query('SELECT id FROM students WHERE nisn = ?', [nisn]);
    if (existing.length > 0) {
      return res.status(400).json({ message: 'NISN already exists' });
    }
    
    // Convert birth_date from ISO string to MySQL DATE format (YYYY-MM-DD)
    const formattedBirthDate = birth_date ? new Date(birth_date).toISOString().split('T')[0] : null;
    
    // Insert student
    const [studentResult] = await pool.query(
      `INSERT INTO students (nisn, name, gender, birth_place, birth_date, address, class_id) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [nisn, name, gender, birth_place, formattedBirthDate, address, class_id]
    );
    
    const studentId = studentResult.insertId;
    
    // Insert parent data
    await pool.query(
      `INSERT INTO parents (student_id, father_name, mother_name, guardian_name,
                            father_job, mother_job, guardian_job,
                            father_phone, mother_phone, guardian_phone, password_hash)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [studentId, father_name, mother_name, guardian_name,
       father_job, mother_job, guardian_job,
       father_phone, mother_phone, guardian_phone, password || '123456']
    );
    
    return res.json({ 
      id: studentId,
      message: 'Student created successfully' 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error: ' + e.message });
  }
});

// PUT /students/:id - Update student
app.put('/students/:id', authMiddleware, async (req, res) => {
  try {
    const {
      nisn, name, gender, birth_place, birth_date, address, class_id,
      father_name, mother_name, guardian_name,
      father_job, mother_job, guardian_job,
      father_phone, mother_phone, guardian_phone
    } = req.body;
    
    // Convert birth_date from ISO string to MySQL DATE format (YYYY-MM-DD)
    const formattedBirthDate = birth_date ? new Date(birth_date).toISOString().split('T')[0] : null;
    
    // Update student
    await pool.query(
      `UPDATE students 
       SET nisn = ?, name = ?, gender = ?, birth_place = ?, birth_date = ?, 
           address = ?, class_id = ?
       WHERE id = ?`,
      [nisn, name, gender, birth_place, formattedBirthDate, address, class_id, req.params.id]
    );
    
    // Update or insert parent data
    const [parentExists] = await pool.query(
      'SELECT id FROM parents WHERE student_id = ?',
      [req.params.id]
    );
    
    if (parentExists.length > 0) {
      await pool.query(
        `UPDATE parents 
         SET father_name = ?, mother_name = ?, guardian_name = ?,
             father_job = ?, mother_job = ?, guardian_job = ?,
             father_phone = ?, mother_phone = ?, guardian_phone = ?
         WHERE student_id = ?`,
        [father_name, mother_name, guardian_name,
         father_job, mother_job, guardian_job,
         father_phone, mother_phone, guardian_phone, req.params.id]
      );
    } else {
      await pool.query(
        `INSERT INTO parents (student_id, father_name, mother_name, guardian_name,
                              father_job, mother_job, guardian_job,
                              father_phone, mother_phone, guardian_phone, password_hash)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [req.params.id, father_name, mother_name, guardian_name,
         father_job, mother_job, guardian_job,
         father_phone, mother_phone, guardian_phone, '123456']
      );
    }
    
    return res.json({ message: 'Student updated successfully' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error: ' + e.message });
  }
});

// DELETE /students/:id - Delete student
app.delete('/students/:id', authMiddleware, async (req, res) => {
  try {
    // Delete parent data first (foreign key)
    await pool.query('DELETE FROM parents WHERE student_id = ?', [req.params.id]);
    
    // Delete student
    await pool.query('DELETE FROM students WHERE id = ?', [req.params.id]);
    
    return res.json({ message: 'Student deleted successfully' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error: ' + e.message });
  }
});

// POST /students/:id/photo - Upload student photo
app.post('/students/:id/photo', authMiddleware, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }
    
    const photoUrl = `/uploads/${req.file.filename}`;
    
    await pool.query(
      'UPDATE students SET photo_url = ? WHERE id = ?',
      [photoUrl, req.params.id]
    );
    
    return res.json({ 
      photo_url: photoUrl,
      message: 'Photo uploaded successfully' 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error: ' + e.message });
  }
});

// GET /classes - List all classes
app.get('/classes', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT c.*, g.name as homeroom_teacher_name, g.nik as homeroom_teacher_nik,
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

// POST /classes - Create new class
app.post('/classes', authMiddleware, async (req, res) => {
  try {
    const { name, academic_year, homeroom_teacher_id } = req.body;
    
    if (!name || !academic_year) {
      return res.status(400).json({ message: 'Name and academic year are required' });
    }

    const [result] = await pool.query(
      'INSERT INTO classes (name, academic_year, homeroom_teacher_id) VALUES (?, ?, ?)',
      [name, academic_year, homeroom_teacher_id || null]
    );

    return res.status(201).json({ 
      id: result.insertId, 
      message: 'Class created successfully' 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// PUT /classes/:id - Update class
app.put('/classes/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, academic_year, homeroom_teacher_id } = req.body;

    if (!name || !academic_year) {
      return res.status(400).json({ message: 'Name and academic year are required' });
    }

    const [result] = await pool.query(
      'UPDATE classes SET name = ?, academic_year = ?, homeroom_teacher_id = ? WHERE id = ?',
      [name, academic_year, homeroom_teacher_id || null, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Class not found' });
    }

    return res.json({ message: 'Class updated successfully' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// DELETE /classes/:id - Delete class
app.delete('/classes/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if class has students
    const [students] = await pool.query('SELECT COUNT(*) as count FROM students WHERE class_id = ?', [id]);
    if (students[0].count > 0) {
      // Set students' class_id to NULL instead of blocking deletion
      await pool.query('UPDATE students SET class_id = NULL WHERE class_id = ?', [id]);
    }

    const [result] = await pool.query('DELETE FROM classes WHERE id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Class not found' });
    }

    return res.json({ message: 'Class deleted successfully' });
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

// PUT /announcements/:id - Update announcement
app.put('/announcements/:id', authMiddleware, async (req, res) => {
  try {
    const { title, content, category, is_pinned } = req.body;
    
    // Check if announcement exists
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
    
    // Build update query dynamically
    const updates = [];
    const values = [];
    
    if (title !== undefined) {
      updates.push('title = ?');
      values.push(title);
    }
    if (content !== undefined) {
      updates.push('content = ?');
      values.push(content);
    }
    if (category !== undefined) {
      updates.push('category = ?');
      values.push(category);
    }
    if (is_pinned !== undefined) {
      updates.push('is_pinned = ?');
      values.push(is_pinned ? 1 : 0);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ message: 'No fields to update' });
    }
    
    values.push(req.params.id);
    await pool.query(
      `UPDATE announcements SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    return res.json({ message: 'Announcement updated successfully' });
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

// GET /attendance/recap - Get attendance recap with filters
app.get('/attendance/recap', authMiddleware, async (req, res) => {
  try {
    const { class_id, start_date, end_date, nisn } = req.query;
    
    // Use LEFT JOIN to show all students, even without attendance records
    let query = `
      SELECT 
        s.id as student_id,
        s.nisn, 
        s.name as student_name, 
        c.name as class_name, 
        s.class_id,
        a.id,
        a.date,
        a.check_in as time,
        a.status,
        a.notes
      FROM students s
      LEFT JOIN classes c ON s.class_id = c.id
      LEFT JOIN attendance a ON s.id = a.student_id 
        ${start_date && end_date && start_date === end_date ? 'AND a.date = ?' : ''}
        ${start_date && end_date && start_date !== end_date && start_date ? 'AND a.date >= ?' : ''}
        ${start_date && end_date && start_date !== end_date && end_date ? 'AND a.date <= ?' : ''}
    `;
    const params = [];
    const conditions = [];

    // Add date parameters to LEFT JOIN
    if (start_date && end_date && start_date === end_date) {
      params.push(start_date);
    } else if (start_date && end_date && start_date !== end_date) {
      if (start_date) params.push(start_date);
      if (end_date) params.push(end_date);
    }

    // Only filter students table (not attendance)
    if (class_id) {
      conditions.push('s.class_id = ?');
      params.push(class_id);
    }

    if (nisn) {
      conditions.push('s.nisn = ?');
      params.push(nisn);
    }

    // For date ranges, only show students with attendance records
    if (start_date && end_date && start_date !== end_date) {
      conditions.push('a.id IS NOT NULL');
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY c.name ASC, s.name ASC';

    const [rows] = await pool.query(query, params);
    return res.json({ data: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /attendance/summary - Get attendance summary statistics
app.get('/attendance/summary', authMiddleware, async (req, res) => {
  try {
    const { class_id, start_date, end_date } = req.query;
    
    let query = `
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN a.status = 'hadir' THEN 1 ELSE 0 END) as hadir,
        SUM(CASE WHEN a.status = 'sakit' THEN 1 ELSE 0 END) as sakit,
        SUM(CASE WHEN a.status = 'izin' THEN 1 ELSE 0 END) as izin,
        SUM(CASE WHEN a.status = 'alpa' THEN 1 ELSE 0 END) as alpa
      FROM attendance a
      JOIN students s ON a.student_id = s.id
      WHERE 1=1
    `;
    const params = [];

    if (class_id) {
      query += ' AND s.class_id = ?';
      params.push(class_id);
    }

    if (start_date) {
      query += ' AND a.date >= ?';
      params.push(start_date);
    }

    if (end_date) {
      query += ' AND a.date <= ?';
      params.push(end_date);
    }

    const [rows] = await pool.query(query, params);
    return res.json(rows[0] || { total: 0, hadir: 0, sakit: 0, izin: 0, alpa: 0 });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /attendance/aggregate - Get aggregated attendance per student (for week/month view)
app.get('/attendance/aggregate', authMiddleware, async (req, res) => {
  try {
    const { class_id, start_date, end_date } = req.query;
    
    let query = `
      SELECT 
        s.nisn,
        s.name as student_name,
        c.name as class_name,
        s.class_id,
        SUM(CASE WHEN a.status = 'hadir' THEN 1 ELSE 0 END) as jumlah_hadir,
        SUM(CASE WHEN a.status = 'sakit' THEN 1 ELSE 0 END) as jumlah_sakit,
        SUM(CASE WHEN a.status = 'izin' THEN 1 ELSE 0 END) as jumlah_izin,
        SUM(CASE WHEN a.status = 'alpa' THEN 1 ELSE 0 END) as jumlah_alpa
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id 
        ${start_date ? 'AND a.date >= ?' : ''}
        ${end_date ? 'AND a.date <= ?' : ''}
      LEFT JOIN classes c ON s.class_id = c.id
      WHERE 1=1
    `;
    const params = [];

    if (start_date) {
      params.push(start_date);
    }

    if (end_date) {
      params.push(end_date);
    }

    if (class_id) {
      query += ' AND s.class_id = ?';
      params.push(class_id);
    }

    query += ' GROUP BY s.id, s.nisn, s.name, c.name, s.class_id ORDER BY c.name ASC, s.name ASC';

    const [rows] = await pool.query(query, params);
    return res.json({ data: rows });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /attendance - Create new attendance record
app.post('/attendance', authMiddleware, async (req, res) => {
  try {
    const { student_id, date, status, notes } = req.body;

    if (!student_id || !date || !status) {
      return res.status(400).json({ message: 'student_id, date, and status are required' });
    }

    const validStatuses = ['hadir', 'sakit', 'izin', 'alpa'];
    if (!validStatuses.includes(status.toLowerCase())) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    // Check if attendance already exists
    const [existing] = await pool.query(
      'SELECT id FROM attendance WHERE student_id = ? AND date = ?',
      [student_id, date]
    );

    if (existing.length > 0) {
      return res.status(400).json({ message: 'Attendance record already exists for this date' });
    }

    const [result] = await pool.query(
      'INSERT INTO attendance (student_id, date, status, notes, scanned_by) VALUES (?, ?, ?, ?, ?)',
      [student_id, date, status.toLowerCase(), notes || null, req.user.id]
    );

    return res.json({ 
      message: 'Attendance created successfully',
      id: result.insertId
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// PUT /attendance/:id - Update attendance
app.put('/attendance/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    if (!status) {
      return res.status(400).json({ message: 'Status is required' });
    }

    const validStatuses = ['hadir', 'sakit', 'izin', 'alpa'];
    if (!validStatuses.includes(status.toLowerCase())) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const [result] = await pool.query(
      'UPDATE attendance SET status = ?, notes = ? WHERE id = ?',
      [status.toLowerCase(), notes || null, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Attendance record not found' });
    }

    return res.json({ message: 'Attendance updated successfully' });
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

// ============= TEACHERS API =============
// GET /api/teachers - Get all teachers
app.get('/api/teachers', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT id, nik, name, email, phone, role, subject, photo_url, password_hash, created_at FROM gurus ORDER BY name'
    );
    return res.json(rows);
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/teachers/:id - Get teacher by ID
app.get('/api/teachers/:id', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT id, nik, name, email, phone, role, subject, photo_url, created_at FROM gurus WHERE id = ?',
      [req.params.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Teacher not found' });
    }
    return res.json(rows[0]);
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/teachers - Create new teacher
app.post('/api/teachers', authMiddleware, async (req, res) => {
  try {
    const { nik, name, email, phone, role, subject, password } = req.body;
    
    // Check if NIK already exists
    const [existing] = await pool.query('SELECT id FROM gurus WHERE nik = ?', [nik]);
    if (existing.length > 0) {
      return res.status(400).json({ message: 'NIK already exists' });
    }
    
    const [result] = await pool.query(
      'INSERT INTO gurus (nik, name, email, phone, role, subject, password_hash) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [nik, name, email, phone, role || 'guru', subject, password || '123456']
    );
    
    return res.json({ 
      id: result.insertId,
      message: 'Teacher created successfully' 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// PUT /api/teachers/:id - Update teacher
app.put('/api/teachers/:id', authMiddleware, async (req, res) => {
  try {
    const { nik, name, email, phone, role, subject } = req.body;
    
    await pool.query(
      'UPDATE gurus SET nik = ?, name = ?, email = ?, phone = ?, role = ?, subject = ? WHERE id = ?',
      [nik, name, email, phone, role, subject, req.params.id]
    );
    
    return res.json({ message: 'Teacher updated successfully' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// DELETE /api/teachers/:id - Delete teacher
app.delete('/api/teachers/:id', authMiddleware, async (req, res) => {
  try {
    await pool.query('DELETE FROM gurus WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Teacher deleted successfully' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// ============= PARENTS API =============
// GET /api/parents - Get all parents
app.get('/api/parents', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.id, p.student_id, p.father_name, p.father_job, p.father_phone,
              p.mother_name, p.mother_job, p.mother_phone,
              p.guardian_name, p.guardian_job, p.guardian_phone,
              p.photo_url, p.password_hash, p.created_at,
              s.name as student_name, s.nisn as student_nisn
       FROM parents p
       LEFT JOIN students s ON p.student_id = s.id
       ORDER BY p.id`
    );
    return res.json(rows);
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/parents/:id - Get parent by ID
app.get('/api/parents/:id', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, s.name as student_name, s.nisn as student_nisn
       FROM parents p
       LEFT JOIN students s ON p.student_id = s.id
       WHERE p.id = ?`,
      [req.params.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Parent not found' });
    }
    return res.json(rows[0]);
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/parents - Create new parent
app.post('/api/parents', authMiddleware, async (req, res) => {
  try {
    const { 
      student_id, father_name, father_job, father_phone,
      mother_name, mother_job, mother_phone,
      guardian_name, guardian_job, guardian_phone,
      password 
    } = req.body;
    
    const [result] = await pool.query(
      `INSERT INTO parents (student_id, father_name, father_job, father_phone,
                           mother_name, mother_job, mother_phone,
                           guardian_name, guardian_job, guardian_phone, password_hash)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [student_id, father_name, father_job, father_phone,
       mother_name, mother_job, mother_phone,
       guardian_name, guardian_job, guardian_phone, password || '123456']
    );
    
    return res.json({ 
      id: result.insertId,
      message: 'Parent created successfully' 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// PUT /api/parents/:id - Update parent
app.put('/api/parents/:id', authMiddleware, async (req, res) => {
  try {
    const { 
      student_id, father_name, father_job, father_phone,
      mother_name, mother_job, mother_phone,
      guardian_name, guardian_job, guardian_phone
    } = req.body;
    
    // Build update query dynamically to only update provided fields
    const updates = [];
    const values = [];
    
    if (student_id !== undefined) {
      updates.push('student_id = ?');
      values.push(student_id);
    }
    if (father_name !== undefined) {
      updates.push('father_name = ?');
      values.push(father_name);
    }
    if (father_job !== undefined) {
      updates.push('father_job = ?');
      values.push(father_job);
    }
    if (father_phone !== undefined) {
      updates.push('father_phone = ?');
      values.push(father_phone);
    }
    if (mother_name !== undefined) {
      updates.push('mother_name = ?');
      values.push(mother_name);
    }
    if (mother_job !== undefined) {
      updates.push('mother_job = ?');
      values.push(mother_job);
    }
    if (mother_phone !== undefined) {
      updates.push('mother_phone = ?');
      values.push(mother_phone);
    }
    if (guardian_name !== undefined) {
      updates.push('guardian_name = ?');
      values.push(guardian_name);
    }
    if (guardian_job !== undefined) {
      updates.push('guardian_job = ?');
      values.push(guardian_job);
    }
    if (guardian_phone !== undefined) {
      updates.push('guardian_phone = ?');
      values.push(guardian_phone);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ message: 'No fields to update' });
    }
    
    values.push(req.params.id);
    await pool.query(
      `UPDATE parents SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    return res.json({ message: 'Parent updated successfully' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// DELETE /api/parents/:id - Delete parent
app.delete('/api/parents/:id', authMiddleware, async (req, res) => {
  try {
    await pool.query('DELETE FROM parents WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Parent deleted successfully' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/teachers/:id/photo - Upload teacher photo
app.post('/api/teachers/:id/photo', authMiddleware, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const photoUrl = `/uploads/${req.file.filename}`;
    await pool.query('UPDATE gurus SET photo_url = ? WHERE id = ?', [photoUrl, req.params.id]);

    return res.json({ 
      message: 'Photo uploaded successfully',
      photoUrl 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/parents/:id/photo - Upload parent photo
app.post('/api/parents/:id/photo', authMiddleware, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const photoUrl = `/uploads/${req.file.filename}`;
    await pool.query('UPDATE parents SET photo_url = ? WHERE id = ?', [photoUrl, req.params.id]);

    return res.json({ 
      message: 'Photo uploaded successfully',
      photoUrl 
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: 'Server error' });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API listening on ${port}`));