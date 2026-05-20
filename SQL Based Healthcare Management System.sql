-- SQL Based Halthcare Management System 
-- Create Database
CREATE DATABASE hospital_management_analysis;

USE hospital_management_analysis;

-- Create Tables
CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    date_of_birth DATE,
    contact_number BIGINT,
    address VARCHAR(255),
    registration_date DATE,
    insurance_provider VARCHAR(100),
    insurance_number VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialization VARCHAR(100),
    phone_number BIGINT,
    years_experience INT,
    hospital_branch VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10),
    doctor_id VARCHAR(10),
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit VARCHAR(255),
    status VARCHAR(50),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
CREATE TABLE treatments (
    treatment_id VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR(10),
    treatment_type VARCHAR(100),
    description VARCHAR(255),
    cost DECIMAL(10,2),
    treatment_date DATE,
    FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
);

CREATE TABLE billing (
    bill_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10),
    treatment_id VARCHAR(10),
    bill_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id),
    FOREIGN KEY (treatment_id)
    REFERENCES treatments(treatment_id)
);

-- Check Data Loaded Properly:

select * from patients;
select * from treatments;
select * from doctors;
select * from billing;
select * from appointments;

-- Patients Full Name  
alter table patients
add patient_name VARCHAR(100);

SET SQL_SAFE_UPDATES = 0;

update patients
set patient_name =
concat(first_name, ' ', last_name);

select patient_id,first_name,last_name,patient_name
from patients
limit 10;

-- doctor full name 
alter table doctors
add doctor_name VARCHAR(100);

SET SQL_SAFE_UPDATES = 0;

update doctors
set doctor_name =
concat(first_name, ' ', last_name);

select * from doctors;

-- Data Understanding:
-- Total Records in Each Table
-- 1. Patients count 
SELECT COUNT(*) AS total_patients
FROM patients;

-- 2.doctors count 
SELECT COUNT(*) AS total_doctors
FROM doctors;

-- 3. Appointment count 
SELECT COUNT(*) AS total_appointments
FROM appointments;

-- 4. Treatments Count
SELECT COUNT(*) AS total_treatments
FROM treatments;

-- 5. Billing Count
SELECT COUNT(*) AS total_bills
FROM billing;

-- Data Checking and Cleaning 
-- 1. Check Null Values : 
SELECT *
FROM patients
WHERE first_name IS NULL OR last_name IS NULL;
   
SELECT *
FROM doctors
WHERE specialization IS NULL;

-- 2. Check Duplicate IDs
SELECT patient_id, COUNT(*)
FROM patients
GROUP BY patient_id
HAVING COUNT(*) > 1;

SELECT doctor_id, COUNT(*)
FROM doctors
GROUP BY doctor_id
HAVING COUNT(*) > 1;

--------------------------------------------------------------------------------
-- Question -- 
-- 1. Patient Analysis :
-- 1. Total Patients
SELECT COUNT(*) AS total_patients
FROM patients;

-- 2. Gender-Wise Patient Distribution (GROUP BY)
SELECT gender, COUNT(*) AS total_patients
FROM patients
GROUP BY gender;

-- 3. Age Group Categorization
SELECT patient_name,
CASE
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18
    THEN 'Children'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 40
    THEN 'Adults'
    ELSE 'Senior Citizens'
END AS age_group
FROM patients;

-- 4. Patients with Highest Hospital Spending (JOIN + GROUP BY)
SELECT p.patient_name, SUM(b.amount) AS total_bill
FROM patients p
JOIN billing b
ON p.patient_id = b.patient_id
GROUP BY p.patient_name
ORDER BY total_bill DESC
LIMIT 5;

-- 5. Which Age Group Visits Hospital Most?
SELECT
CASE
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18
    THEN 'Children'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 40
    THEN 'Adults'
    ELSE 'Senior Citizens'
END AS age_group,
COUNT(a.appointment_id) AS total_visits
FROM patients p
JOIN appointments a
ON p.patient_id = a.patient_id
GROUP BY age_group
ORDER BY total_visits DESC;

-- 2. DOCTOR ANALYSIS
-- 1. Total Doctors
SELECT COUNT(*) AS total_doctors
FROM doctors;

-- 2. Doctors by Specialization (GROUP BY)
SELECT specialization, COUNT(*) AS total_doctors
FROM doctors
GROUP BY specialization;

-- 3. Doctors by Hospital Branch (GROUP BY)
SELECT hospital_branch, COUNT(*) AS total_doctors
FROM doctors
GROUP BY hospital_branch;

-- 4. Experienced Doctors
SELECT doctor_name, years_experience
FROM doctors
WHERE years_experience > 10;

-- 5. Which Doctor Has Most Appointments?
SELECT d.doctor_name, COUNT(a.appointment_id) AS total_appointments
FROM doctors d
JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_name
ORDER BY total_appointments DESC;

-- 3. APPOINTMENT ANALYSIS
-- 1. Total Appointments
SELECT COUNT(*) AS total_appointments
FROM appointments;

-- 2. Appointment Status Count (GROUP BY)
SELECT status, COUNT(*) AS total_appointments
FROM appointments
GROUP BY status;

-- 3. Monthly Appointment Count (GROUP BY)
SELECT MONTH(appointment_date) AS month_no, COUNT(*) AS total_appointments
FROM appointments
GROUP BY month_no;

-- 4. Patients with Multiple Appointments
SELECT patient_id, COUNT(*) AS total_appointments
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- 5. Which Month Has Highest Appointments?
SELECT MONTH(appointment_date) AS month_no, COUNT(*) AS total_appointments
FROM appointments
GROUP BY month_no
ORDER BY total_appointments DESC
LIMIT 1;

-- 4. TREATMENT ANALYSIS
-- 1. Total Treatments
SELECT COUNT(*) AS total_treatments
FROM treatments;

-- 2. Most Common Treatment Type (GROUP BY)
SELECT treatment_type, COUNT(*) AS total_treatments
FROM treatments
GROUP BY treatment_type;

-- 3. Average Treatment Cost
SELECT AVG(cost) AS average_cost
FROM treatments;

-- 4. High Cost Treatments
SELECT treatment_type, cost
FROM treatments
WHERE cost > 10000;

-- 5.  Which Treatment Generates Highest Revenue?
SELECT treatment_type, SUM(cost) AS total_revenue
FROM treatments
GROUP BY treatment_type
ORDER BY total_revenue DESC;

-- 5. BILLING ANALYSIS
-- 1. Total Revenue
SELECT SUM(amount) AS total_revenue
FROM billing;

-- 2. Revenue by Payment Method (GROUP BY)
SELECT payment_method, SUM(amount) AS total_revenue
FROM billing
GROUP BY payment_method;

-- 3. Payment Status Count (GROUP BY)
SELECT payment_status, COUNT(*) AS total_payments
FROM billing
GROUP BY payment_status;

-- 4. High Billing Amounts
SELECT bill_id, amount
FROM billing
WHERE amount > 2000;

-- 5. Which Payment Method Is Used Most?
SELECT payment_method, COUNT(*) AS total_transactions
FROM billing
GROUP BY payment_method
ORDER BY total_transactions DESC;
