#!/bin/bash

# Migration Script: alislam_rdm -> alislam_sapa_raudha
# Migrate students, parents, and classes data

DB_SOURCE="alislam_rdm"
DB_TARGET="alislam_sapa_raudha"
DB_USER="alislam_root"
DB_PASS="Alislam123"

echo "======================================"
echo "Data Migration Script"
echo "Source: $DB_SOURCE"
echo "Target: $DB_TARGET"
echo "======================================"
echo ""

# Step 1: Migrate Classes
echo "Step 1: Migrating classes..."
mariadb -u $DB_USER -p$DB_PASS $DB_TARGET << 'EOF'
-- Backup existing classes (optional)
-- DELETE FROM classes WHERE id > 2; -- Uncomment to clean test data

-- Insert classes from source
INSERT INTO classes (name, grade, academic_year, created_at)
SELECT 
    COALESCE(k.kelas_nama, 'Unknown') as name,
    COALESCE(k.tingkat_id, 1) as grade,
    COALESCE(ta.tahunajaran_nama, '2025/2026') as academic_year,
    NOW() as created_at
FROM alislam_rdm.e_kelas k
LEFT JOIN alislam_rdm.e_tahunajaran ta ON k.tahunajaran_id = ta.tahunajaran_id
WHERE k.kelas_nama IS NOT NULL
ON DUPLICATE KEY UPDATE name=VALUES(name);

SELECT CONCAT('✓ Migrated ', COUNT(*), ' classes') as result FROM classes;
EOF

echo ""

# Step 2: Migrate Students
echo "Step 2: Migrating students..."
mariadb -u $DB_USER -p$DB_PASS $DB_TARGET << 'EOF'
-- Create temporary mapping table
CREATE TEMPORARY TABLE class_mapping AS
SELECT 
    s.kelas_id as old_kelas_id,
    c.id as new_class_id
FROM alislam_rdm.e_siswa s
LEFT JOIN alislam_rdm.e_kelas k ON s.kelas_id = k.kelas_id
LEFT JOIN classes c ON k.kelas_nama = c.name
WHERE s.kelas_id IS NOT NULL
GROUP BY s.kelas_id, c.id;

-- Insert students
INSERT INTO students (
    nisn, 
    nis, 
    name, 
    class_id, 
    gender, 
    birth_place, 
    birth_date, 
    religion, 
    address,
    created_at
)
SELECT 
    COALESCE(s.siswa_nisn, CONCAT('TEMP-', s.siswa_id)) as nisn,
    s.siswa_nis as nis,
    s.siswa_nama as name,
    cm.new_class_id as class_id,
    CASE 
        WHEN UPPER(s.siswa_gender) LIKE '%L%' OR UPPER(s.siswa_gender) LIKE '%LAKI%' THEN 'L'
        WHEN UPPER(s.siswa_gender) LIKE '%P%' OR UPPER(s.siswa_gender) LIKE '%PEREMPUAN%' THEN 'P'
        ELSE NULL
    END as gender,
    s.siswa_tempat as birth_place,
    s.siswa_tgllahir as birth_date,
    s.siswa_agama as religion,
    COALESCE(s.siswa_alamat, s.alamat_ortu) as address,
    NOW() as created_at
FROM alislam_rdm.e_siswa s
LEFT JOIN class_mapping cm ON s.kelas_id = cm.old_kelas_id
WHERE s.siswa_nama IS NOT NULL
ON DUPLICATE KEY UPDATE 
    name=VALUES(name),
    class_id=VALUES(class_id);

SELECT CONCAT('✓ Migrated ', COUNT(*), ' students') as result FROM students;
EOF

echo ""

# Step 3: Migrate Parents Data
echo "Step 3: Migrating parent data..."
mariadb -u $DB_USER -p$DB_PASS $DB_TARGET << 'EOF'
-- Insert parents data
INSERT INTO parents (
    student_id,
    father_name,
    father_phone,
    mother_name,
    mother_phone,
    guardian_name,
    guardian_phone,
    password_hash,
    created_at
)
SELECT 
    st.id as student_id,
    s.nama_ayah as father_name,
    COALESCE(s.telpon_ortu, s.siswa_telpon) as father_phone,
    s.nama_ibu as mother_name,
    s.telpon_ortu as mother_phone,
    s.nama_wali as guardian_name,
    s.telpon_wali as guardian_phone,
    COALESCE(s.password, CONCAT(s.siswa_nisn, '123')) as password_hash,
    NOW() as created_at
FROM alislam_rdm.e_siswa s
JOIN students st ON s.siswa_nisn = st.nisn
WHERE s.siswa_nama IS NOT NULL
    AND (s.nama_ayah IS NOT NULL OR s.nama_ibu IS NOT NULL OR s.nama_wali IS NOT NULL)
ON DUPLICATE KEY UPDATE
    father_name=VALUES(father_name),
    mother_name=VALUES(mother_name);

SELECT CONCAT('✓ Migrated ', COUNT(*), ' parent records') as result FROM parents;
EOF

echo ""
echo "======================================"
echo "Migration Summary"
echo "======================================"

mariadb -u $DB_USER -p$DB_PASS $DB_TARGET << 'EOF'
SELECT 'Classes' as Item, COUNT(*) as Total FROM classes
UNION ALL
SELECT 'Students', COUNT(*) FROM students
UNION ALL
SELECT 'Parents', COUNT(*) FROM parents;
EOF

echo ""
echo "✓ Migration completed successfully!"
echo ""
echo "Notes:"
echo "- Students without NISN were assigned temporary NISN (TEMP-xxx)"
echo "- Parent passwords are based on NISN + '123' as default"
echo "- Students without class mapping will have NULL class_id"
echo ""
