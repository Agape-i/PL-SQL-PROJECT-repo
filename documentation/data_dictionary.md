
---

## 📋 **File: `data_dictionary.md`**

# Data Dictionary
## Coffee Farmers Payment System

**Student:** INEZA Agape  
**ID:** 27464  
**Version:** 1.0  
**Last Updated:** December 2025  

---

## 📊 Table of Contents

1. [FARMERS Table](#farmers-table)
2. [COFFEE_QUALITY Table](#coffee_quality-table)
3. [DELIVERIES Table](#deliveries-table)
4. [PAYMENTS Table](#payments-table)
5. [SYSTEM_USERS Table](#system_users-table)
6. [AUDIT_LOG Table](#audit_log-table)
7. [HOLIDAYS Table](#holidays-table)
8. [ALERTS Table](#alerts-table)
9. [Views](#views)
10. [Sequences](#sequences)
11. [Indexes](#indexes)

---

## 1. FARMERS Table

**Description:** Stores information about registered coffee farmers.

| Column Name | Data Type | Size | Nullable | Default | Constraint | Description |
|-------------|-----------|------|----------|---------|------------|-------------|
| FARMER_ID | NUMBER | - | NOT NULL | GENERATED ALWAYS AS IDENTITY | PRIMARY KEY | Unique identifier for each farmer |
| FULL_NAME | VARCHAR2 | 150 | NOT NULL | - | - | Farmer's complete name |
| PHONE | VARCHAR2 | 20 | NOT NULL | - | UNIQUE | Rwanda phone number (format: 07XXXXXXXX) |
| NATIONAL_ID | VARCHAR2 | 20 | NOT NULL | - | UNIQUE | National identification number |
| SECTOR | VARCHAR2 | 100 | NOT NULL | - | - | Village or sector of residence |
| REGISTRATION_DATE | TIMESTAMP | - | NOT NULL | SYSTIMESTAMP | - | Date and time of registration |

**Sample Data:**

FARMER_ID  FULL_NAME        PHONE        NATIONAL_ID  SECTOR    REGISTRATION_DATE
---------  ---------------  -----------  -----------  --------  -------------------
1          John Doe         0788100001   NID001       Sector A  2025-03-10 09:15:00
2          Jane Smith       0788100002   NID002       Sector B  2025-03-12 10:30:00


Business Rules:

Phone must be unique across all farmers

National ID must be unique across all farmers

Registration date automatically recorded

All fields except ID are mandatory

Relationships:

One-to-Many with DELIVERIES (One farmer makes many deliveries)

2. COFFEE_QUALITY Table
Description: Reference table for coffee quality grades and pricing.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
QUALITY_ID	NUMBER	-	NOT NULL	-	PRIMARY KEY	Quality grade identifier
QUALITY_NAME	VARCHAR2	50	NOT NULL	-	-	Descriptive name of quality grade
PRICE_PER_KG	NUMBER	10,2	NOT NULL	-	CHECK (> 0)	Price per kilogram in Rwandan Francs
Sample Data:

QUALITY_ID  QUALITY_NAME  PRICE_PER_KG
----------  ------------  ------------
1           Grade A       5.50
2           Grade B       4.00
3           Grade C       3.00

Business Rules:

Price must be greater than 0

Quality names must be unique (enforced by application logic)

Used as reference data - changes require audit logging

Relationships:

One-to-Many with DELIVERIES (One grade assigned to many deliveries)

3. DELIVERIES Table
Description: Records coffee deliveries made by farmers.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
DELIVERY_ID	NUMBER	-	NOT NULL	GENERATED ALWAYS AS IDENTITY	PRIMARY KEY	Unique delivery identifier
FARMER_ID	NUMBER	-	NOT NULL	-	FOREIGN KEY	Reference to delivering farmer
DELIVERY_DATE	DATE	-	NOT NULL	-	-	Date of delivery
WEIGHT_KG	NUMBER	8,2	NOT NULL	-	CHECK (> 0)	Weight in kilograms
QUALITY_ID	NUMBER	-	NOT NULL	-	FOREIGN KEY	Assigned quality grade
Sample Data:

DELIVERY_ID  FARMER_ID  DELIVERY_DATE  WEIGHT_KG  QUALITY_ID
-----------  ---------  -------------  ---------  ----------
1            1          2025-04-01     100.50     1
2            1          2025-04-10     80.00      2
3            2          2025-04-03     90.25      2

Business Rules:

Weight must be greater than 0

Delivery date cannot be in the future

Must reference valid farmer and quality grade

Triggers payment calculation automatically

Relationships:

Many-to-One with FARMERS (Many deliveries by one farmer)

Many-to-One with COFFEE_QUALITY (Many deliveries of one quality)

One-to-One with PAYMENTS (One delivery generates one payment)

One-to-Many with ALERTS (One delivery may trigger many alerts)

4. PAYMENTS Table
Description: Records payments made to farmers for deliveries.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
PAYMENT_ID	NUMBER	-	NOT NULL	GENERATED ALWAYS AS IDENTITY	PRIMARY KEY	Unique payment identifier
DELIVERY_ID	NUMBER	-	NOT NULL	-	FOREIGN KEY, UNIQUE	Reference to delivery being paid
AMOUNT_PAID	NUMBER	12,2	YES	Calculated by trigger	-	Payment amount in RWF
PAYMENT_DATE	DATE	-	YES	SYSDATE	-	Date payment was issued
Sample Data:

Business Rules:

Weight must be greater than 0

Delivery date cannot be in the future

Must reference valid farmer and quality grade

Triggers payment calculation automatically

Relationships:

Many-to-One with FARMERS (Many deliveries by one farmer)

Many-to-One with COFFEE_QUALITY (Many deliveries of one quality)

One-to-One with PAYMENTS (One delivery generates one payment)

One-to-Many with ALERTS (One delivery may trigger many alerts)

4. PAYMENTS Table
Description: Records payments made to farmers for deliveries.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
PAYMENT_ID	NUMBER	-	NOT NULL	GENERATED ALWAYS AS IDENTITY	PRIMARY KEY	Unique payment identifier
DELIVERY_ID	NUMBER	-	NOT NULL	-	FOREIGN KEY, UNIQUE	Reference to delivery being paid
AMOUNT_PAID	NUMBER	12,2	YES	Calculated by trigger	-	Payment amount in RWF
PAYMENT_DATE	DATE	-	YES	SYSDATE	-	Date payment was issued
Sample Data:

Business Rules:

Amount calculated automatically: weight × price_per_kg

One payment per delivery (enforced by UNIQUE constraint)

Payment date defaults to current date

Cannot be created on weekdays/holidays (business rule)

Calculation Formula:

text
AMOUNT_PAID = DELIVERIES.WEIGHT_KG × COFFEE_QUALITY.PRICE_PER_KG
Relationships:

One-to-One with DELIVERIES (One payment for one delivery)

5. SYSTEM_USERS Table
Description: Stores system users for authentication and authorization.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
USER_ID	NUMBER	-	NOT NULL	GENERATED ALWAYS AS IDENTITY	PRIMARY KEY	Unique user identifier
USERNAME	VARCHAR2	100	NOT NULL	-	UNIQUE	Login username
PASSWORD_HASH	VARCHAR2	200	NOT NULL	-	-	Hashed password
FULL_NAME	VARCHAR2	150	NOT NULL	-	-	User's complete name
ROLE	VARCHAR2	50	NOT NULL	-	-	User role (admin, clerk, manager)
STATUS	VARCHAR2	20	YES	'ACTIVE'	-	Account status
CREATED_AT	TIMESTAMP	-	YES	SYSTIMESTAMP	-	Account creation timestamp
Sample Data:

USER_ID  USERNAME  PASSWORD_HASH      FULL_NAME        ROLE     STATUS  CREATED_AT
-------  --------  ----------------   ---------------  -------  ------  -------------------
1        admin     hashed_password_1  System Admin     admin    ACTIVE  2025-12-01 08:00:00
2        clerk     hashed_password_2  Station Clerk    clerk    ACTIVE  2025-12-01 08:05:00


Business Rules:

Username must be unique

Default status is 'ACTIVE'

Password stored as hash (not plain text)

Created timestamp automatically recorded

Roles:

admin: Full system access, user management

clerk: Farmer registration, delivery recording

manager: Reporting, price updates, oversight

6. AUDIT_LOG Table
Description: Comprehensive audit trail of all system operations.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
AUDIT_ID	NUMBER	-	NOT NULL	GENERATED ALWAYS AS IDENTITY	PRIMARY KEY	Unique audit identifier
USERNAME	VARCHAR2	100	NOT NULL	-	-	User performing operation
OPERATION	VARCHAR2	10	NOT NULL	-	-	Type: INSERT, UPDATE, DELETE
OBJECT_NAME	VARCHAR2	100	NOT NULL	-	-	Table/object affected
OBJECT_KEY	VARCHAR2	200	YES	-	-	Key value affected
OPERATION_STATUS	VARCHAR2	20	NOT NULL	-	-	Status: ALLOWED, DENIED
REASON	VARCHAR2	1000	NOT NULL	-	-	Description/reason
LOG_TIMESTAMP	TIMESTAMP	-	YES	SYSTIMESTAMP	-	Time of operation
Sample Data:

AUDIT_ID  USERNAME  OPERATION  OBJECT_NAME  OBJECT_KEY     STATUS   REASON                          LOG_TIMESTAMP
--------  --------  ---------  -----------  ------------   -------  ------------------------------  -------------------
1         admin     INSERT     FARMERS      FARMER_ID=16   DENIED   Operation not allowed on...    2025-12-08 10:15:00
2         clerk     INSERT     DELIVERIES   DELIVERY_ID=41 ALLOWED  Delivery recorded: 75.5kg      2025-12-08 10:20:00


Business Rules:

All DML operations must be logged

Reason must explain operation

Timestamp automatically recorded

Status indicates success/failure

Audited Operations:

All INSERT, UPDATE, DELETE on business tables

Price changes in COFFEE_QUALITY

User management operations

Business rule violations

7. HOLIDAYS Table
Description: Public holidays when operations are restricted.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
HOLIDAY_DATE	DATE	-	NOT NULL	-	PRIMARY KEY	Date of holiday
HOLIDAY_NAME	VARCHAR2	200	NOT NULL	-	-	Name of holiday
CREATED_AT	TIMESTAMP	-	YES	SYSTIMESTAMP	-	Record creation timestamp
Sample Data:
HOLIDAY_DATE  HOLIDAY_NAME      CREATED_AT
------------  ----------------  -------------------
2025-12-25    Christmas Day     2025-12-01 09:00:00
2025-12-26    Boxing Day        2025-12-01 09:00:00
2026-01-01    New Year's Day    2025-12-01 09:00:00

Business Rules:

Date must be unique (primary key)

Holiday name is mandatory

Used to enforce business restrictions

Typically populated for upcoming month

Restriction Logic:

sql
IF (TODAY IS WEEKDAY OR TODAY IS HOLIDAY) THEN
    OPERATIONS ARE DENIED
ELSE
    OPERATIONS ARE ALLOWED (Weekends only)
8. ALERTS Table
Description: System-generated alerts for anomalies and issues.

Column Name	Data Type	Size	Nullable	Default	Constraint	Description
ALERT_ID	NUMBER	-	NOT NULL	GENERATED ALWAYS AS IDENTITY	PRIMARY KEY	Unique alert identifier
DELIVERY_ID	NUMBER	-	YES	-	FOREIGN KEY	Related delivery (if applicable)
ALERT_TYPE	VARCHAR2	50	NOT NULL	-	-	Type of alert
DESCRIPTION	VARCHAR2	4000	YES	-	-	Alert description/details
ALERT_DATE	TIMESTAMP	-	YES	SYSTIMESTAMP	-	Time alert generated
RESOLVED_FLAG	CHAR	1	YES	'N'	-	Resolution status: Y/N
RESOLVED_AT	TIMESTAMP	-	YES	-	-	Time resolved
Sample Data:

ALERT_ID  DELIVERY_ID  ALERT_TYPE      DESCRIPTION                          ALERT_DATE            RESOLVED
--------  -----------  ------------    ----------------------------------  -------------------  ---------
1         41           WEIGHT_ANOMALY  Weight deviation: 525% (Avg: 80kg)  2025-12-08 10:25:00  N

Business Rules:

Default status is 'N' (not resolved)

Resolution timestamp recorded when resolved

Alert type categorizes the issue

Description provides details for investigation

Alert Types:

WEIGHT_ANOMALY: Weight deviation > 50% from farmer average

DUPLICATE_DETECTED: Possible duplicate delivery

SYSTEM_ERROR: Technical issues detected

COMPLIANCE_VIOLATION: Business rule violations

9. Views
VW_AUDIT_MONITOR
Purpose: Real-time monitoring of audit trail with formatted data.

Column	Source	Description
AUDIT_ID	AUDIT_LOG.AUDIT_ID	Unique audit identifier
USERNAME	AUDIT_LOG.USERNAME	User performing operation
OPERATION	AUDIT_LOG.OPERATION	Type of operation
OBJECT_NAME	AUDIT_LOG.OBJECT_NAME	Object affected
OBJECT_KEY	AUDIT_LOG.OBJECT_KEY	Key value affected
OPERATION_STATUS	AUDIT_LOG.OPERATION_STATUS	Status (ALLOWED/DENIED)
REASON	AUDIT_LOG.REASON	Operation reason
TIMESTAMP_FORMATTED	TO_CHAR(AUDIT_LOG.LOG_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')	Formatted timestamp
STATUS_ICON	CASE expression	Visual status indicator
Query:

CREATE OR REPLACE VIEW VW_AUDIT_MONITOR AS
SELECT 
    audit_id,
    username,
    operation,
    object_name,
    object_key,
    operation_status,
    reason,
    TO_CHAR(log_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS timestamp_formatted,
    CASE 
        WHEN operation_status = 'DENIED' THEN '🔴'
        WHEN operation_status = 'ALLOWED_WITH_ALERT' THEN '🟡'
        ELSE '🟢'
    END AS status_icon
FROM audit_log
ORDER BY log_timestamp DESC;
VW_ALERTS_MONITOR
Purpose: Monitoring dashboard for system alerts.

Column	Source	Description
ALERT_ID	ALERTS.ALERT_ID	Unique alert identifier
DELIVERY_ID	ALERTS.DELIVERY_ID	Related delivery
FARMER_NAME	FARMERS.FULL_NAME	Farmer's name
ALERT_TYPE	ALERTS.ALERT_TYPE	Type of alert
DESCRIPTION	ALERTS.DESCRIPTION	Alert details
ALERT_TIME	TO_CHAR(ALERTS.ALERT_DATE, 'YYYY-MM-DD HH24:MI:SS')	Formatted alert time
RESOLVED_FLAG	ALERTS.RESOLVED_FLAG	Resolution flag
RESOLVED_TIME	TO_CHAR(ALERTS.RESOLVED_AT, 'YYYY-MM-DD HH24:MI:SS')	Formatted resolution time
ALERT_STATUS	CASE expression	Status description
10. Sequences
FARMERS_SEQ

CREATE SEQUENCE farmers_seq
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

urpose: Used for generating unique farmer codes

DELIVERIES_SEQ
urpose: Used for generating unique farmer codes

DELIVERIES_SEQ


11. Indexes
Index Name	Table	Columns	Type	Purpose
IDX_DELIVERIES_FARMER	DELIVERIES	FARMER_ID	B-Tree	Fast farmer delivery lookup
IDX_DELIVERIES_QUALITY	DELIVERIES	QUALITY_ID	B-Tree	Quality-based queries
IDX_DELIVERIES_DATE	DELIVERIES	DELIVERY_DATE	B-Tree	Date-range queries
IDX_AUDIT_LOG_USER	AUDIT_LOG	USERNAME	B-Tree	User activity analysis
IDX_AUDIT_LOG_DATE	AUDIT_LOG	LOG_TIMESTAMP	B-Tree	Time-based audit queries
SYS_C008247 (Auto)	PAYMENTS	DELIVERY_ID	Unique	Enforces one payment per delivery
📊 Data Volume Summary
Table	Current Rows	Estimated Monthly Growth	Indexes
FARMERS	15	10	Phone, National ID
COFFEE_QUALITY	3	0	Primary Key
DELIVERIES	50	100	Farmer, Quality, Date
PAYMENTS	40	100	Delivery (Unique)
SYSTEM_USERS	3	1	Username
AUDIT_LOG	100+	500	User, Date
HOLIDAYS	6	1	Primary Key
ALERTS	5	20	Delivery
🔗 Relationship Summary
Primary Relationships:
FARMERS → DELIVERIES (1:N)

One farmer makes many deliveries

Foreign Key: DELIVERIES.FARMER_ID → FARMERS.FARMER_ID

COFFEE_QUALITY → DELIVERIES (1:N)

One quality grade assigned to many deliveries

Foreign Key: DELIVERIES.QUALITY_ID → COFFEE_QUALITY.QUALITY_ID

DELIVERIES → PAYMENTS (1:1)

One delivery generates exactly one payment

Foreign Key: PAYMENTS.DELIVERY_ID → DELIVERIES.DELIVERY_ID

Unique constraint ensures 1:1 relationship

SYSTEM_USERS → AUDIT_LOG (1:N)

One user performs many audit-logged operations

Relationship via USERNAME field

DELIVERIES → ALERTS (1:N)

One delivery may trigger multiple alerts

Foreign Key: ALERTS.DELIVERY_ID → DELIVERIES.DELIVERY_ID

Business Rule Enforcement:
Weekday/Holiday Restriction: Triggers on FARMERS, DELIVERIES, PAYMENTS

Payment Calculation: Trigger on PAYMENTS INSERT

Anomaly Detection: Trigger on DELIVERIES INSERT

Audit Logging: Procedure calls and triggers

📝 Data Quality Rules
1. Completeness
All NOT NULL columns must have values

Foreign keys must reference existing records

Default values provided where appropriate

2. Consistency
Phone numbers follow Rwanda format (07XXXXXXXX)

National IDs are unique across farmers

Delivery dates not in future

Weight values positive (> 0)

3. Validity
Price per kg > 0

Weight kg > 0

Payment amounts match calculated values

Status values from predefined sets

4. Timeliness
Registration dates not in future

Delivery dates reflect actual delivery time

Audit timestamps automatically recorded

Payment dates default to current date

🔄 Data Lifecycle
1. Creation
Farmers register via register_farmer procedure

Deliveries recorded via record_delivery procedure

Payments auto-generated via trigger

Audit entries auto-created

2. Update
Coffee prices updated via update_coffee_price procedure

User status changes via administration

Alert resolution updates

3. Retention
Business data: 7 years (compliance)

Audit data: 3 years (monitoring)

Archived data moved to separate tablespace

4. Deletion
Only via administrative procedures

Full audit trail maintained

Referential integrity preserved
