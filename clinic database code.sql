CREATE DATABASE IF NOT EXISTS clinic;
USE clinic;

CREATE TABLE IF NOT EXISTS STAFF (
    staffID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    role VARCHAR(255),
    contactinfo VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS PATIENT (
    patientID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255),
    contactinfo VARCHAR(255),
    medicalHistory TEXT,
    insuranceDetails VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DOCTOR (
    doctorID INT AUTO_INCREMENT PRIMARY KEY,
    doctorName VARCHAR(255),
    doctorNationalID VARCHAR(20), 
    email VARCHAR(255),
    discount FLOAT,
    password VARCHAR(255),
    sessionPrice FLOAT,
    phoneNumber VARCHAR(20), 
    gender VARCHAR(10) 
);

CREATE TABLE IF NOT EXISTS MATERIAL (
    materialID INT AUTO_INCREMENT PRIMARY KEY,
    materialName VARCHAR(255),
    count INT, 
    box BOOLEAN,
    price FLOAT,
    batchNumber INT,
    productionDate DATE,
    expirationDate DATE
);

CREATE TABLE IF NOT EXISTS AVAILABLE_TIME (
    availableTimeID INT AUTO_INCREMENT PRIMARY KEY, 
    doctorID INT,
    date DATE,
    time VARCHAR(50),
    FOREIGN KEY (doctorID) REFERENCES DOCTOR(doctorID)
);

CREATE TABLE IF NOT EXISTS PRESCRIPTION (
    prescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    patientID INT,
    doctorID INT,
    itemDescription VARCHAR(255), 
    itemType ENUM('Medicine', 'Test'), 
    FOREIGN KEY (patientID) REFERENCES PATIENT(patientID),
    FOREIGN KEY (doctorID) REFERENCES DOCTOR(doctorID)
);

CREATE TABLE IF NOT EXISTS MATERIAL_USAGE (
    materialUsageID INT AUTO_INCREMENT PRIMARY KEY,
    materialID INT,
    prescriptionID INT,
    quantity INT,
    FOREIGN KEY (materialID) REFERENCES MATERIAL(materialID),
    FOREIGN KEY (prescriptionID) REFERENCES PRESCRIPTION(prescriptionID)
);

CREATE PROCEDURE add_patient(
    IN p_name VARCHAR(255),
    IN p_address VARCHAR(255),
    IN p_contactinfo VARCHAR(255),
    IN p_medicalHistory TEXT,
    IN p_insuranceDetails VARCHAR(255)
)
BEGIN
    INSERT INTO PATIENT (name, address, contactinfo, medicalHistory, insuranceDetails)
    VALUES (p_name, p_address, p_contactinfo, p_medicalHistory, p_insuranceDetails);
END;

CREATE PROCEDURE delete_patient(IN p_patientID INT)
BEGIN
    DELETE FROM PATIENT WHERE patientID = p_patientID;
END;

CREATE PROCEDURE search_patient(IN p_patientID INT, OUT result_set CURSOR)
BEGIN
    DECLARE result CURSOR FOR SELECT * FROM PATIENT WHERE patientID = p_patientID;
    OPEN result_set FOR SELECT * FROM PATIENT WHERE patientID = p_patientID;
END;

CREATE PROCEDURE schedule_appointment(IN p_doctorID INT, IN p_date DATE, IN p_time VARCHAR(50))
BEGIN
    INSERT INTO AVAILABLE_TIME (doctorID, date, time)
    VALUES (p_doctorID, p_date, p_time);
END;

CREATE PROCEDURE prescribe_medicine(
    IN p_patientID INT,
    IN p_doctorID INT,
    IN p_medicineName VARCHAR(255)
)
BEGIN
    INSERT INTO PRESCRIPTION (patientID, doctorID, itemDescription, itemType)
    VALUES (p_patientID, p_doctorID, p_medicineName, 'Medicine');
END;

CREATE PROCEDURE prescribe_test(
    IN p_patientID INT,
    IN p_doctorID INT,
    IN p_testName VARCHAR(255)
)
BEGIN
    INSERT INTO PRESCRIPTION (patientID, doctorID, itemDescription, itemType)
    VALUES (p_patientID, p_doctorID, p_testName, 'Test');
END;

CREATE PROCEDURE add_material(
    IN p_materialName VARCHAR(255),
    IN p_count INT, 
    IN p_box BOOLEAN,
    IN p_price FLOAT,
    IN p_batchNumber INT,
    IN p_productionDate DATE,
    IN p_expirationDate DATE
)
BEGIN
    INSERT INTO MATERIAL (materialName, count, box, price, batchNumber, productionDate, expirationDate)
    VALUES (p_materialName, p_count, p_box, p_price, p_batchNumber, p_productionDate, p_expirationDate);
END;

CREATE PROCEDURE delete_material(IN p_materialID INT)
BEGIN
    DELETE FROM MATERIAL WHERE materialID = p_materialID;
END;
