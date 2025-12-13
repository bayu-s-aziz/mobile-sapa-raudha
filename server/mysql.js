import mysql from 'mysql2/promise';

export const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'Sabay2601',
  database: process.env.DB_NAME || 'sapa_raudha',
  waitForConnections: true,
  connectionLimit: 10,
});