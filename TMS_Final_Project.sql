-- DROP TABLES
-- =========================================

-- 1. Drop Child Tables
DROP TABLE Job_Assignment CASCADE CONSTRAINTS;
DROP TABLE Job CASCADE CONSTRAINTS;
DROP TABLE Project CASCADE CONSTRAINTS;

-- 2. Drop Sub-type tables
DROP TABLE Internal_Employee CASCADE CONSTRAINTS;
DROP TABLE Vendor CASCADE CONSTRAINTS;

-- 3. Drop Main Entity tables
DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;

-- 4. Drop Lookup/Reference tables
DROP TABLE Service CASCADE CONSTRAINTS;
DROP TABLE Unit_Type CASCADE CONSTRAINTS;
DROP TABLE Project_Status CASCADE CONSTRAINTS;
DROP TABLE Time_Zone CASCADE CONSTRAINTS;
DROP TABLE Currency CASCADE CONSTRAINTS;
DROP TABLE Department CASCADE CONSTRAINTS;
DROP TABLE Language CASCADE CONSTRAINTS;

COMMIT;


-- =========================================
-- LOOKUP TABLES
-- =========================================

CREATE TABLE Service (
    Service_ID NUMBER(11,0) NOT NULL,
    Service_Name VARCHAR2(50),
    CREATED_AT DATE DEFAULT SYSDATE,
    CONSTRAINT PK_Service PRIMARY KEY (Service_ID)
);

CREATE TABLE Unit_Type (
    Unit_Type_ID NUMBER(11,0) NOT NULL,
    Unit_Type_Name VARCHAR2(50),
    CONSTRAINT PK_Unit PRIMARY KEY (Unit_Type_ID)
);

CREATE TABLE Project_Status (
    Project_Status_ID NUMBER(11,0) NOT NULL,
    Status_Name VARCHAR2(50),
    CONSTRAINT PK_Status PRIMARY KEY (Project_Status_ID)
);

CREATE TABLE Time_Zone (
    Timezone_ID NUMBER(11,0) NOT NULL,
    Timezone_Name VARCHAR2(100) NOT NULL,
    UTC_Offset VARCHAR2(10),
    CONSTRAINT PK_TimeZone PRIMARY KEY (Timezone_ID)
);

CREATE TABLE Currency (
    CurrencyID NUMBER(11,0) NOT NULL,
    Currency_Type VARCHAR2(20),
    CREATED_AT DATE DEFAULT SYSDATE,
    CONSTRAINT PK_Currency PRIMARY KEY (CurrencyID)
);

-- FIXED: increased Department_Name size
CREATE TABLE Department (
    Department_ID NUMBER(11,0),
    Department_Name VARCHAR2(100),
    CREATED_AT DATE DEFAULT SYSDATE,
    CONSTRAINT PK_Dep PRIMARY KEY (Department_ID)
);

CREATE TABLE Language (
    Language_ID NUMBER(11,0) NOT NULL,
    Language_Name VARCHAR2(50),
    Language_Code VARCHAR2(10),
    CREATED_AT DATE DEFAULT SYSDATE,
    CONSTRAINT PK_Language PRIMARY KEY (Language_ID),
    CONSTRAINT UQ_Language_Code UNIQUE (Language_Code)
);

-- =========================================
-- MAIN TABLES
-- =========================================

--1
CREATE TABLE Employee (
    Employee_ID NUMBER(11,0) NOT NULL,
    Department_ID NUMBER(11,0) NOT NULL,
    CurrencyID NUMBER(11,0) NOT NULL,

    Employee_Name VARCHAR2(100),
    Employee_Email VARCHAR2(100),
    Employee_Status VARCHAR2(20),

    CREATED_AT DATE DEFAULT SYSDATE,

    CONSTRAINT PK_Employee PRIMARY KEY (Employee_ID),

    CONSTRAINT FK_Employee1
        FOREIGN KEY (CurrencyID)
        REFERENCES Currency(CurrencyID),

    CONSTRAINT FK_Employee2
        FOREIGN KEY (Department_ID)
        REFERENCES Department(Department_ID)
);

-- =========================================
-- SUBTYPE TABLES
-- =========================================

CREATE TABLE Internal_Employee (
    Employee_ID NUMBER(11,0) NOT NULL,
    Monthly_Salary NUMBER(10,2) DEFAULT 0,
    Job_Title VARCHAR2(50),

    CONSTRAINT PK_Internal PRIMARY KEY (Employee_ID),

    CONSTRAINT FK_PM
        FOREIGN KEY (Employee_ID)
        REFERENCES Employee(Employee_ID)
);

CREATE TABLE Vendor (
    Employee_ID NUMBER(11,0) NOT NULL,
    Payment_Method VARCHAR2(100) DEFAULT 'None',

    Source_Language_ID NUMBER(11,0),
    Target_Language_ID NUMBER(11,0),

    CONSTRAINT PK_Vendor PRIMARY KEY (Employee_ID),

    CONSTRAINT FK_Vendor
        FOREIGN KEY (Employee_ID)
        REFERENCES Employee(Employee_ID),

    CONSTRAINT FK_Source_Language
        FOREIGN KEY(Source_Language_ID)
        REFERENCES Language(Language_ID),

    CONSTRAINT FK_Target_Language
        FOREIGN KEY(Target_Language_ID)
        REFERENCES Language(Language_ID)
);




CREATE TABLE Customer (
    Customer_ID NUMBER(11,0) NOT NULL,
    Creation_Date DATE DEFAULT SYSDATE,
    Customer_Status VARCHAR2(20),
    Cust_Address VARCHAR2(200),
    Email VARCHAR2(100),
    Website VARCHAR2(100),
    Contact_Person VARCHAR2(100),
    Timezone_ID NUMBER(11,0),

    CONSTRAINT PK_Customer PRIMARY KEY (Customer_ID),

    CONSTRAINT FK_Cust_TZ
        FOREIGN KEY (Timezone_ID)
        REFERENCES Time_Zone(Timezone_ID)
);



-- =========================================
-- PROJECT TABLE
-- =========================================

CREATE TABLE Project (
    Project_ID NUMBER(11,0) NOT NULL,
    Project_Name VARCHAR2(100),

    Created_At DATE DEFAULT SYSDATE,

    Customer_ID NUMBER(11,0),

    Project_Manager_ID NUMBER(11,0),
    Operation_Manager_ID NUMBER(11,0),

    Service_ID NUMBER(11,0),

    Project_Due_Date DATE,

    Project_Instructions VARCHAR2(1000) DEFAULT 'None',

    Timezone_ID NUMBER(11,0),
    Project_Status_ID NUMBER(11,0),

    Source_Language_ID NUMBER(11,0),
    Target_Language_ID NUMBER(11,0),

    Unit_Type_ID NUMBER(11,0),

    Price_Per_Unit NUMBER(10,2),
    Unit_Count NUMBER(12,6),

    --Derived Attribute
    Total_Price NUMBER(10,2) GENERATED ALWAYS AS (Price_Per_Unit * Unit_Count) VIRTUAL,

    CONSTRAINT PK_Project PRIMARY KEY (Project_ID),

    CONSTRAINT FK_P_Cust
        FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID),

    CONSTRAINT FK_P_TZ
        FOREIGN KEY (Timezone_ID)
        REFERENCES Time_Zone(Timezone_ID),

    CONSTRAINT FK_P_PM
        FOREIGN KEY (Project_Manager_ID)
        REFERENCES Internal_Employee(Employee_ID),

    CONSTRAINT FK_P_OM
        FOREIGN KEY (Operation_Manager_ID)
        REFERENCES Internal_Employee(Employee_ID),

    CONSTRAINT FK_P_Service
        FOREIGN KEY (Service_ID)
        REFERENCES Service(Service_ID),

    CONSTRAINT FK_P_SL
        FOREIGN KEY (Source_Language_ID)
        REFERENCES Language(Language_ID),

    CONSTRAINT FK_P_TL
        FOREIGN KEY (Target_Language_ID)
        REFERENCES Language(Language_ID),

    CONSTRAINT FK_P_UT
        FOREIGN KEY (Unit_Type_ID)
        REFERENCES Unit_Type(Unit_Type_ID),

    CONSTRAINT FK_P_Status
        FOREIGN KEY (Project_Status_ID)
        REFERENCES Project_Status(Project_Status_ID)
);

-- =========================================
-- JOB TABLE
-- =========================================
--JOB FOR : pure work definition only
CREATE TABLE Job ( 
    Job_ID NUMBER(11,0) NOT NULL,
    Project_ID NUMBER(11,0) NOT NULL,

    Created_At DATE DEFAULT SYSDATE,

    Service_ID NUMBER(11,0),

    Source_Language_ID NUMBER(11,0),
    Target_Language_ID NUMBER(11,0),

    Unit_Type_ID NUMBER(11,0),

    Quantity NUMBER(10,2),

    CONSTRAINT PK_Job PRIMARY KEY (Job_ID),

    CONSTRAINT FK_JP FOREIGN KEY (Project_ID) REFERENCES Project(Project_ID),

    CONSTRAINT FK_JS FOREIGN KEY (Service_ID) REFERENCES Service(Service_ID),

    CONSTRAINT FK_JSL FOREIGN KEY (Source_Language_ID) REFERENCES Language(Language_ID),

    CONSTRAINT FK_JTL FOREIGN KEY (Target_Language_ID) REFERENCES Language(Language_ID)

);

COMMIT;

-- =========================================
-- ASSOCIATIVE ENTITY
-- =========================================

CREATE TABLE Job_Assignment (
    Assignment_ID NUMBER(11,0) NOT NULL,

    Job_ID NUMBER(11,0) NOT NULL,
    Vendor_ID NUMBER(11,0) NOT NULL,

    Actual_Units NUMBER(10,2),
    Vendor_Rate NUMBER(10,2),

    Vendor_Total NUMBER(10,2)
        GENERATED ALWAYS AS (Actual_Units * Vendor_Rate) VIRTUAL,

    Created_At DATE DEFAULT SYSDATE,

    Assignment_Role VARCHAR2(50),
    Assigned_Date DATE,
    Due_Date DATE,
    Assignment_Status VARCHAR2(20),

    CONSTRAINT PK_Assignment PRIMARY KEY (Assignment_ID),

    CONSTRAINT FK_A_JOB
        FOREIGN KEY (Job_ID)
        REFERENCES Job(Job_ID),

    CONSTRAINT FK_A_VENDOR
        FOREIGN KEY (Vendor_ID)
        REFERENCES Vendor(Employee_ID)
);

-- =========================================
-- LOOKUP DATA
-- =========================================

INSERT INTO Time_Zone VALUES (1, 'Africa/Cairo', 'UTC+2');
INSERT INTO Time_Zone VALUES (2, 'Europe/Madrid', 'UTC+1');
INSERT INTO Time_Zone VALUES (3, 'America/New_York', 'UTC-5');
INSERT INTO Time_Zone VALUES (4, 'Asia/Tokyo', 'UTC+9');

INSERT INTO Time_Zone VALUES (5, 'Europe/London', 'UTC+0');

INSERT INTO Currency VALUES (1, 'USD', SYSDATE);
INSERT INTO Currency VALUES (2, 'EURO', SYSDATE);
INSERT INTO Currency VALUES (3, 'EGP', SYSDATE);

INSERT INTO Currency VALUES (4, 'GBP', SYSDATE);

INSERT INTO Currency VALUES (5, 'JPY', SYSDATE);


INSERT INTO Department VALUES (1, 'Localization Engineering', SYSDATE);
INSERT INTO Department VALUES (2, 'Project Management and Production', SYSDATE);
INSERT INTO Department VALUES (3, 'Vendor Management', SYSDATE);
INSERT INTO Department VALUES (4, 'Business Development', SYSDATE);
INSERT INTO Department VALUES (5, 'Quality Assurance', SYSDATE);


INSERT INTO Service VALUES (1, 'Translation', SYSDATE);
INSERT INTO Service VALUES (2, 'LQA', SYSDATE);
INSERT INTO Service VALUES (3, 'MTPE', SYSDATE);
INSERT INTO Service VALUES (4, 'Transcription', SYSDATE);
INSERT INTO Service VALUES (5, 'Editing', SYSDATE);




INSERT INTO Unit_Type VALUES (1, 'Word');
INSERT INTO Unit_Type VALUES (2, 'Hour');
INSERT INTO Unit_Type VALUES (3, 'Page');
INSERT INTO Unit_Type VALUES (4, 'Minute');
INSERT INTO Unit_Type VALUES (5, 'Segment');



INSERT INTO Project_Status VALUES (1, 'PENDING');
INSERT INTO Project_Status VALUES (2, 'IN_PROGRESS');
INSERT INTO Project_Status VALUES (3, 'DELIVERED');
INSERT INTO Project_Status VALUES (4, 'CANCELLED');
INSERT INTO Project_Status VALUES (5, 'ON_HOLD');


INSERT INTO Language VALUES (1, 'English', 'EN', SYSDATE);
INSERT INTO Language VALUES (2, 'Arabic', 'AR', SYSDATE);
INSERT INTO Language VALUES (3, 'Spanish', 'ES', SYSDATE);
INSERT INTO Language VALUES (4, 'French', 'FR', SYSDATE);
INSERT INTO Language VALUES (5, 'German', 'DE', SYSDATE);


-- =========================================
-- EMPLOYEES
-- =========================================
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (1, 2, 1, 'Fatma', 'fatma@yahoo.com', 'Active');
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (2, 2, 1, 'Mohamed', 'x@yahoo.com', 'Idle');
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (3, 2, 3, 'Basma', 'y@yahoo.com', 'Active');
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (4, 3, 2, 'Sahar', 'h@yahoo.com', 'Active');
INSERT INTO Employee  (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (5, 4, 1, 'Israa', 'z@yahoo.com', 'Active');
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (6, 3, 1, 'Omar', 'm@yahoo.com', 'Active');
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (7, 3, 2, 'Aya', 'r@yahoo.com', 'Active');
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (8, 3, 3, 'Amr', 's@yahoo.com', 'Active');
INSERT INTO Employee (Employee_ID, Department_ID, CURRENCYID, EMPLOYEE_NAME, EMPLOYEE_EMAIL, EMPLOYEE_STATUS) VALUES (9, 2, 2, 'Dina', 'Dina@yahoo.com', 'Active');

-- =========================================
-- INTERNAL EMPLOYEES
-- =========================================

INSERT INTO Internal_Employee VALUES (1, 1200, 'Project Manager');
INSERT INTO Internal_Employee VALUES (2, 1000, 'Senior Project Manager');
INSERT INTO Internal_Employee VALUES (3, 2000, 'Operations Manager');
INSERT INTO Internal_Employee VALUES (5, 800, 'Business Development Manager');
INSERT INTO Internal_Employee VALUES (9, 800, 'Project Manager');
-- =========================================
-- VENDORS
-- =========================================

INSERT INTO Vendor (Employee_ID, Payment_Method, Source_Language_ID, Target_Language_ID) VALUES (6, 'Payoneer', 1, 2);
INSERT INTO Vendor (Employee_ID, Payment_Method, Source_Language_ID, Target_Language_ID) VALUES (7, 'Paypal', 1, 3);
INSERT INTO Vendor (Employee_ID, Payment_Method, Source_Language_ID, Target_Language_ID) VALUES (8, 'Bank Transfer', 1, 4);
INSERT INTO Vendor (Employee_ID, Payment_Method, Source_Language_ID, Target_Language_ID) VALUES (4, 'Bank Transfer', 2, 1);
INSERT INTO Vendor (Employee_ID, Payment_Method, Source_Language_ID, Target_Language_ID) VALUES (3, 'Internal Transfer', 1, 2);


-- =========================================
-- CUSTOMERS
-- =========================================

INSERT INTO Customer (
    Customer_ID,
    Creation_Date,
    Customer_Status,
    Cust_Address,
    Email,
    Website,
    Contact_Person,
    Timezone_ID
)
VALUES (
    1,
    SYSDATE,
    'ACTIVE',
    'Cairo, Egypt',
    'client1@lio.com',
    'www.client1.com',
    'L.I/O',
    1
);

INSERT INTO Customer (
    Customer_ID,
    Creation_Date,
    Customer_Status,
    Cust_Address,
    Email,
    Website,
    Contact_Person,
    Timezone_ID
)
VALUES (
    2,
    SYSDATE,
    'ACTIVE',
    'Alexandria, Egypt',
    'ahmed@client.com',
    'www.client2.com',
    'Ahmed Ali',
    1
);

INSERT INTO Customer (
    Customer_ID,
    Creation_Date,
    Customer_Status,
    Cust_Address,
    Email,
    Website,
    Contact_Person,
    Timezone_ID
)
VALUES (
    3,
    SYSDATE,
    'ACTIVE',
    'Madrid, Spain',
    'sara@client.com',
    'www.client3.com',
    'Sara Ahmed',
    2
);

INSERT INTO Customer (
    Customer_ID,
    Creation_Date,
    Customer_Status,
    Cust_Address,
    Email,
    Website,
    Contact_Person,
    Timezone_ID
)
VALUES (
    4,
    SYSDATE,
    'ACTIVE',
    'New York, USA',
    'john.smith@globalcom.com',
    'www.globalcom.com',
    'John Smith',
    3 -- America/New_York
);

INSERT INTO Customer (
    Customer_ID,
    Creation_Date,
    Customer_Status,
    Cust_Address,
    Email,
    Website,
    Contact_Person,
    Timezone_ID
)
VALUES (
    5,
    SYSDATE,
    'ACTIVE',
    'Barcelona, Spain',
    'm.garcia@techtrans.es',
    'www.techtrans.es',
    'Maria Garcia',
    2 -- Europe/Madrid
);

COMMIT;

-- =========================================
-- PROJECTS
-- =========================================


INSERT INTO Project (
    Project_ID,
    Project_Name,
    Created_At,
    Customer_ID,
    Project_Manager_ID,
    Operation_Manager_ID,
    Service_ID,
    Project_Due_Date,
    Project_Instructions,
    Timezone_ID,
    Project_Status_ID,
    Source_Language_ID,
    Target_Language_ID,
    Unit_Type_ID,
    Price_Per_Unit,
    Unit_Count
)
VALUES (
    1,
    'Translate marketing content',
    SYSDATE,
    1,
    1,
    3,
    1,
    SYSDATE + 7,
    'Translate marketing content from English to Arabic.',
    1,
    1,
    1,
    2,
    1,
    0.10,
    10000
);

INSERT INTO Project (
    Project_ID,
    Project_Name,
    Created_At,
    Customer_ID,
    Project_Manager_ID,
    Operation_Manager_ID,
    Service_ID,
    Project_Due_Date,
    Project_Instructions,
    Timezone_ID,
    Project_Status_ID,
    Source_Language_ID,
    Target_Language_ID,
    Unit_Type_ID,
    Price_Per_Unit,
    Unit_Count
)
VALUES (
    2,
    'Project Beta',
    SYSDATE,
    2,
    2,
    3,
    2,
    SYSDATE + 5,
    'LQA review for gaming project.',
    1,
    2,
    1,
    3,
    1,
    0.20,
    5000
);

INSERT INTO Project (
    Project_ID,
    Project_Name,
    Created_At,
    Customer_ID,
    Project_Manager_ID,
    Operation_Manager_ID,
    Service_ID,
    Project_Due_Date,
    Project_Instructions,
    Timezone_ID,
    Project_Status_ID,
    Source_Language_ID,
    Target_Language_ID,
    Unit_Type_ID,
    Price_Per_Unit,
    Unit_Count
)
VALUES (
    3,
    'Project Gamma',
    SYSDATE,
    3,
    1,
    3,
    3,
    SYSDATE + 10,
    'MTPE project for legal documents.',
    2,
    1,
    1,
    4,
    1,
    0.08,
    1200
);


INSERT INTO Project (
    Project_ID, Project_Name, Customer_ID, 
    Project_Manager_ID, Operation_Manager_ID, Project_Due_Date, 
    Service_ID, Timezone_ID, Project_Status_ID, 
    Project_Instructions, Source_Language_ID, 
    Target_Language_ID, Unit_Type_ID, Price_Per_Unit, Unit_Count
)
VALUES (
    4, 
    'Transcription - Arabic',  
    1, 
    1,                       --PM 
    3,                       --Operation manager 
    TO_DATE('12-06-2026', 'DD-MM-YYYY'), 
    4, 
    2, 
    1,
    'Transcription of AR Audio + Make sure to add labels as you transcribe, check the guidelines uploaded to the job input section', 
    1, 
    3, 
    1, 
    0.08, 
    2000
    );

INSERT INTO Project (
    Project_ID,
    Project_Name,
    Created_At,
    Customer_ID,
    Project_Manager_ID,
    Operation_Manager_ID,
    Service_ID,
    Project_Due_Date,
    Project_Instructions,
    Timezone_ID,
    Project_Status_ID,
    Source_Language_ID,
    Target_Language_ID,
    Unit_Type_ID,
    Price_Per_Unit,
    Unit_Count
)
VALUES (
    5,
    'German LQA Project',
    SYSDATE,
    4,
    2,
    3,
    2,
    SYSDATE + 6,
    'LQA for e-commerce website.',
    5,
    2,
    1,
    5,
    1,
    0.18,
    7000
);



-- =========================================
-- JOBS
-- =========================================


    INSERT INTO Job (
        Job_ID,
        Project_ID,
        Service_ID,
        Source_Language_ID,
        Target_Language_ID,
        Unit_Type_ID,
        Quantity
    )
    VALUES (
        1,
        1,
        1,
        1,
        2,
        1,
        6000
    );

    INSERT INTO Job (
        Job_ID,
        Project_ID,
        Service_ID,
        Source_Language_ID,
        Target_Language_ID,
        Unit_Type_ID,
        Quantity
    )
    VALUES (
        2,
        1,
        2,
        1,
        2,
        1,
        4000
    );

    INSERT INTO Job (
        Job_ID,
        Project_ID,
        Service_ID,
        Source_Language_ID,
        Target_Language_ID,
        Unit_Type_ID,
        Quantity
    )
    VALUES (
        3,
        2,
        2,
        1,
        3,
        1,
        5000
    );
      INSERT INTO Job (
        Job_ID,
        Project_ID,
        Service_ID,
        Source_Language_ID,
        Target_Language_ID,
        Unit_Type_ID,
        Quantity
    )
    VALUES 
    (
        4, 4, 3, 3, 1, 1, 2000
    );


    INSERT INTO Job (
        Job_ID,
        Project_ID,
        Service_ID,
        Source_Language_ID,
        Target_Language_ID,
        Unit_Type_ID,
        Quantity
    )
    VALUES (
        5,
        3,
        3,
        1,
        4,
        1,
        800
    );


    INSERT INTO Job (
        Job_ID,
        Project_ID,
        Service_ID,
        Source_Language_ID,
        Target_Language_ID,
        Unit_Type_ID,
        Quantity
    )
    VALUES 
    (
        6, 4, 5, 3, 1, 1, 2000
    );

INSERT INTO Job (
    Job_ID,
    Project_ID,
    Service_ID,
    Source_Language_ID,
    Target_Language_ID,
    Unit_Type_ID,
    Quantity
)
VALUES (
    7,
    5,
    2,
    1,
    5,
    1,
    7000
);

   -- =========================================
-- JOB ASSIGNMENTS (CLEAN VERSION)
-- =========================================

INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    1, 1, 6, 6000, 0.05,
    SYSDATE,
    'Translator',
    SYSDATE,
    SYSDATE + 3,
    'IN_PROGRESS'
);

INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    2, 2, 3, 4000, 0.04,
    SYSDATE,
    'Reviewer',
    SYSDATE,
    SYSDATE + 5,
    'NOT_STARTED'
);

INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    3, 3, 7, 5000, 0.07,
    SYSDATE,
    'LQA Specialist',
    SYSDATE,
    SYSDATE + 4,
    'IN_PROGRESS'
);

INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    4, 4, 8, 15000, 0.03,
    SYSDATE,
    'MTPE Editor',
    SYSDATE,
    SYSDATE + 8,
    'PENDING'
);

INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    5, 5, 8, 800, 0.03,
    SYSDATE,
    'Translator',
    SYSDATE,
    SYSDATE + 8,
    'PENDING'
);

INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    6, 6, 7, 2000, 0.02,
    SYSDATE,
    'Reviewer',
    TO_DATE('10-06-2026','DD-MM-YYYY'),
    TO_DATE('11-06-2026','DD-MM-YYYY'),
    'PENDING'
);

INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    7, 4, 6, 2000, 0.03,
    SYSDATE,
    'Translator',
    TO_DATE('09-06-2026','DD-MM-YYYY'),
    TO_DATE('10-06-2026','DD-MM-YYYY'),
    'IN_PROGRESS'
);


INSERT INTO Job_Assignment (
    Assignment_ID,
    Job_ID,
    Vendor_ID,
    Actual_Units,
    Vendor_Rate,
    Created_At,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    Assignment_Status
)
VALUES (
    8,
    7,
    7,
    7000,
    0.06,
    SYSDATE,
    'LQA Specialist',
    SYSDATE,
    SYSDATE + 5,
    'IN_PROGRESS'
);

--=========================================
--  5 QUERIES--
--=========================================

--1-Display the Number of assigned jobs in each project

SELECT Project_ID, count(*)
FROM Job
GROUP BY Project_ID;

--2-Modification to Unit_Count of Project_ID #4, adjusting its jobs' values accordingly.

-- 1. Increasing Project 4 Volume and Price (To attain Higher Revenue)
UPDATE Project 
SET Unit_Count = 20000, 
    Price_Per_Unit = 0.15
WHERE Project_ID = 4;

-- 2. Alignment of Job 4 Volume with the new Project volume
UPDATE Job 
SET Quantity = 20000 
WHERE Job_ID = 4;

-- 3. Adjusting the Assignments so Vendor Rate < Project Rate
-- Assignment 4 (MTPE Editor)
UPDATE Job_Assignment 
SET Actual_Units = 20000, 
    Vendor_Rate = 0.04 
WHERE Assignment_ID = 4;

-- Assignment 5 (Translator - previously duplicate Job 4/5 confusion)
UPDATE Job_Assignment 
SET Actual_Units = 20000, 
    Vendor_Rate = 0.03 
WHERE Assignment_ID = 5;


-- Increasing Project 3 Volume and Price (To attain Higher Revenue), since there was a problem with the profit value.
UPDATE Project
SET Price_Per_Unit = 0.15,
    Unit_Count = 5000
WHERE Project_ID = 3;

UPDATE Job_Assignment
SET Actual_Units = 5000,
    Vendor_Rate = 0.07
WHERE Assignment_ID = 5;



--3- Full Project Dashboard
CREATE OR REPLACE VIEW Project_Dashboard AS
SELECT 
    p.Project_ID,
    p.Project_Name,

    s.Status_Name,

    sl.Language_Name AS Source_Language,
    tl.Language_Name AS Target_Language,

    sr.Service_Name,
    p.Project_Due_Date AS Deadline, --   deadline  

    pm.Employee_Name AS Project_Manager,

    p.Total_Price AS Revenue,

    costs.Total_Cost AS Cost,

    (p.Total_Price - costs.Total_Cost) AS Margin,

    CASE 
        WHEN p.Total_Price = 0 THEN 0
        ELSE ROUND(
            (p.Total_Price - costs.Total_Cost) / p.Total_Price * 100,
        2)
    END AS Margin_Percentage

FROM Project p

JOIN Project_Status s
    ON p.Project_Status_ID = s.Project_Status_ID

JOIN Language sl
    ON p.Source_Language_ID = sl.Language_ID

JOIN Language tl
    ON p.Target_Language_ID = tl.Language_ID

JOIN Service sr
    ON p.Service_ID = sr.Service_ID

JOIN Employee pm
    ON pm.Employee_ID = p.Project_Manager_ID

LEFT JOIN (
    SELECT 
        j.Project_ID,
        SUM(ja.Vendor_Total) AS Total_Cost
    FROM Job j
    JOIN Job_Assignment ja
        ON j.Job_ID = ja.Job_ID
    GROUP BY j.Project_ID
) costs
    ON costs.Project_ID = p.Project_ID;

COMMIT;

--4--Highest Revenue Projects

SELECT 
    Project_Name,
    Total_Price AS Revenue
FROM Project
ORDER BY Total_Price DESC;


--5--PM Performance Report
-- Projects handled by each Project Manager
SELECT 
    e.Employee_Name,
    COUNT(p.Project_ID) AS Managed_Projects
FROM Employee e
JOIN Project p
    ON e.Employee_ID = p.Project_Manager_ID
GROUP BY e.Employee_Name
ORDER BY Managed_Projects DESC;



--6--Language Pair Demand Report
-- Most requested language pairs
SELECT 
    sl.Language_Name AS Source_Language,
    tl.Language_Name AS Target_Language,
    COUNT(*) AS Total_Projects
FROM Project p
JOIN Language sl
    ON p.Source_Language_ID = sl.Language_ID
JOIN Language tl
    ON p.Target_Language_ID = tl.Language_ID
GROUP BY sl.Language_Name, tl.Language_Name
ORDER BY Total_Projects DESC;


--7--Customer Revenue Contribution
-- Revenue generated per customer
SELECT 
    c.Contact_Person,
    SUM(p.Total_Price) AS Total_Revenue
FROM Customer c
JOIN Project p
    ON c.Customer_ID = p.Customer_ID
GROUP BY c.Contact_Person
ORDER BY Total_Revenue DESC;


--8-- Turnaround Time for Each Project
-- Turnaround time for each project
SELECT 
    Project_ID,
    Project_Name,
    Created_At,
    Project_Due_Date,
    (Project_Due_Date - Created_At) AS Turnaround_Days
FROM Project
ORDER BY Turnaround_Days;


--9- Assignment Delivery Schedule

-- Assignment delivery schedule
SELECT 
    Assignment_ID,
    Assignment_Role,
    Assigned_Date,
    Due_Date,
    (Due_Date - Assigned_Date) AS Assignment_Duration
FROM Job_Assignment
ORDER BY Due_Date;


---10 ---Projects Assigned to Each Vendor that are in progress: To decide if we can assign them more projects or not
-- Number of IN_PROGRESS projects assigned to each vendor
SELECT 
    e.Employee_Name AS Vendor_Name,
    COUNT(DISTINCT j.Project_ID) AS Total_Projects
FROM Employee e
JOIN Vendor v
    ON e.Employee_ID = v.Employee_ID
JOIN Job_Assignment ja
    ON v.Employee_ID = ja.Vendor_ID
JOIN Job j
    ON ja.Job_ID = j.Job_ID
WHERE ja.Assignment_Status = 'IN_PROGRESS'
GROUP BY e.Employee_Name
ORDER BY Total_Projects DESC;