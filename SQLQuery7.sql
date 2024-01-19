IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'clinic')
BEGIN
    CREATE DATABASE clinic;
END
GO

USE clinic;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'STAFF')
BEGIN
    CREATE TABLE STAFF (
        staffID INT PRIMARY KEY IDENTITY(1,1),
        name NVARCHAR(255),
        role NVARCHAR(255),
        contactinfo NVARCHAR(255)
    );
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PATIENT')
BEGIN
    CREATE TABLE PATIENT (
        patientID INT PRIMARY KEY IDENTITY(1,1),
        name NVARCHAR(255),
        address NVARCHAR(255),
        contactinfo NVARCHAR(255),
        medicalHistory NVARCHAR(MAX),
        insuranceDetails NVARCHAR(255)
    );
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DOCTOR')
BEGIN
    CREATE TABLE DOCTOR (
        doctorID INT PRIMARY KEY IDENTITY(1,1),
        doctorName NVARCHAR(255),
        doctorNationalID NVARCHAR(20), 
        email NVARCHAR(255),
        discount FLOAT,
        [password] NVARCHAR(255),
        sessionPrice FLOAT,
        phoneNumber NVARCHAR(20),
        gender NVARCHAR(10)
    );
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MATERIAL')
BEGIN
    CREATE TABLE MATERIAL (
        materialID INT PRIMARY KEY IDENTITY(1,1),
        materialName NVARCHAR(255),
        count INT, 
        box BIT,
        price FLOAT,
        batchNumber INT,
        productionDate DATE,
        expirationDate DATE
    );
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AVAILABLE_TIME')
BEGIN
    CREATE TABLE AVAILABLE_TIME (
        availableTimeID INT PRIMARY KEY IDENTITY(1,1),
        doctorID INT,
        [date] DATE,
        [time] NVARCHAR(50),
        FOREIGN KEY (doctorID) REFERENCES DOCTOR(doctorID)
    );
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PRESCRIPTION')
BEGIN
    CREATE TABLE PRESCRIPTION (
        prescriptionID INT PRIMARY KEY IDENTITY(1,1),
        patientID INT,
        doctorID INT,
        itemDescription NVARCHAR(255),
        itemType NVARCHAR(10),
        FOREIGN KEY (patientID) REFERENCES PATIENT(patientID),
        FOREIGN KEY (doctorID) REFERENCES DOCTOR(doctorID)
    );
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MATERIAL_USAGE')
BEGIN
    CREATE TABLE MATERIAL_USAGE (
        materialUsageID INT PRIMARY KEY IDENTITY(1,1),
        materialID INT,
        prescriptionID INT,
        quantity INT,
        FOREIGN KEY (materialID) REFERENCES MATERIAL(materialID),
        FOREIGN KEY (prescriptionID) REFERENCES PRESCRIPTION(prescriptionID)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[add_patient]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE add_patient
        @p_name NVARCHAR(255),
        @p_address NVARCHAR(255),
        @p_contactinfo NVARCHAR(255),
        @p_medicalHistory NVARCHAR(MAX),
        @p_insuranceDetails NVARCHAR(255)
    AS
    BEGIN
        INSERT INTO PATIENT (name, address, contactinfo, medicalHistory, insuranceDetails)
        VALUES (@p_name, @p_address, @p_contactinfo, @p_medicalHistory, @p_insuranceDetails);
    END');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delete_patient]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE delete_patient
        @p_patientID INT
    AS
    BEGIN
        DELETE FROM PATIENT WHERE patientID = @p_patientID;
    END');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[search_patient]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE search_patient
        @p_patientID INT,
        @result_set CURSOR VARYING OUTPUT
    AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @result CURSOR;
        DECLARE @temp INT;
        SET @temp = 1; -- This line was missing in the original code
        EXEC(''DECLARE @temp CURSOR;
        SET @temp = CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR SELECT * FROM PATIENT WHERE patientID = '' + CAST(@p_patientID AS NVARCHAR(10));
        OPEN @temp;
        FETCH NEXT FROM @temp INTO @result_set OUTPUT;
        CLOSE @temp;
        DEALLOCATE @temp;'');
    END');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[schedule_appointment]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE schedule_appointment
        @p_doctorID INT,
        @p_date DATE,
        @p_time NVARCHAR(50)
    AS
    BEGIN
        INSERT INTO AVAILABLE_TIME (doctorID, [date], [time])
        VALUES (@p_doctorID, @p_date, @p_time);
    END');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prescribe_medicine]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE prescribe_medicine
        @p_patientID INT,
        @p_doctorID INT,
        @p_medicineName NVARCHAR(255)
    AS
    BEGIN
        INSERT INTO PRESCRIPTION (patientID, doctorID, itemDescription, itemType)
        VALUES (@p_patientID, @p_doctorID, @p_medicineName, ''Medicine'');
    END');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prescribe_test]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE prescribe_test
        @p_patientID INT,
        @p_doctorID INT,
        @p_testName NVARCHAR(255)
    AS
    BEGIN
        INSERT INTO PRESCRIPTION (patientID, doctorID, itemDescription, itemType)
        VALUES (@p_patientID, @p_doctorID, @p_testName, ''Test'');
    END');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[add_material]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE add_material
        @p_materialName NVARCHAR(255),
        @p_count INT, 
        @p_box BIT,
        @p_price FLOAT,
        @p_batchNumber INT,
        @p_productionDate DATE,
        @p_expirationDate DATE
    AS
    BEGIN
        INSERT INTO MATERIAL (materialName, count, box, price, batchNumber, productionDate, expirationDate)
        VALUES (@p_materialName, @p_count, @p_box, @p_price, @p_batchNumber, @p_productionDate, @p_expirationDate);
    END');
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delete_material]') AND type in (N'P', N'PC'))
BEGIN
    EXEC('CREATE PROCEDURE delete_material
        @p_materialID INT
    AS
    BEGIN
        DELETE FROM MATERIAL WHERE materialID = @p_materialID;
    END');
END
GO
