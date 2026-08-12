-- ===================================================
-- Project: Hospital Capacity Management System
-- Feature: Automated Bed Allocation via PostgreSQL Triggers
-- ===================================================

-- 1. Create Beds Table
CREATE TABLE beds (
    bed_id INT PRIMARY KEY,
    ward_name VARCHAR(50),
    is_occupied BOOLEAN DEFAULT FALSE
);

-- 2. Create Patients Table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50),
    bed_id INT UNIQUE,
    admission_time TIMESTAMP
);

-- 3. Populate Initial Beds
INSERT INTO beds (bed_id, ward_name, is_occupied) VALUES 
(101, 'ICU', FALSE),
(102, 'ICU', FALSE),
(103, 'ICU', FALSE);

-- 4. Create Trigger Function to update bed status automatically
CREATE OR REPLACE FUNCTION update_bed_status()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE beds 
    SET is_occupied = TRUE 
    WHERE bed_id = NEW.bed_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Attach Trigger to Patients Table
CREATE TRIGGER trigger_patient_admitted
AFTER INSERT ON patients
FOR EACH ROW
EXECUTE FUNCTION update_bed_status();

-- 6. Insert New Admission
INSERT INTO patients (patient_id, patient_name, bed_id, admission_time)
VALUES (1, 'Ahmad Raza', 101, '2026-08-13 01:00:00');

-- 7. Query Bed Occupancy Status
SELECT 
    b.bed_id,
    b.ward_name,
    b.is_occupied,
    p.patient_name,
    p.admission_time
FROM beds b
LEFT JOIN patients p ON b.bed_id = p.bed_id
ORDER BY b.bed_id;
