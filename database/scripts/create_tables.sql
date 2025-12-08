
-- CREATE TABLES FOR COFFEE FARMERS SYSTEM


-- 1. FARMERS table
CREATE TABLE farmers (
    farmer_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name          VARCHAR2(150) NOT NULL,
    phone              VARCHAR2(20) UNIQUE NOT NULL,
    national_id        VARCHAR2(20) UNIQUE NOT NULL,
    sector             VARCHAR2(100) NOT NULL,
    registration_date  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- 2. COFFEE_QUALITY table
CREATE TABLE coffee_quality (
    quality_id     NUMBER PRIMARY KEY,
    quality_name   VARCHAR2(50) NOT NULL,
    price_per_kg   NUMBER(10,2) NOT NULL CHECK (price_per_kg > 0)
);

-- 3. DELIVERIES table
CREATE TABLE deliveries (
    delivery_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_id       NUMBER NOT NULL,
    delivery_date   DATE NOT NULL,
    weight_kg       NUMBER(8,2) NOT NULL CHECK (weight_kg > 0),
    quality_id      NUMBER NOT NULL,
    
    CONSTRAINT fk_delivery_farmer 
        FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id),
    CONSTRAINT fk_delivery_quality 
        FOREIGN KEY (quality_id) REFERENCES coffee_quality(quality_id)
);

-- 4. PAYMENTS table
CREATE TABLE payments (
    payment_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    delivery_id     NUMBER NOT NULL UNIQUE,
    amount_paid     NUMBER(12,2),
    payment_date    DATE DEFAULT SYSDATE,
    
    CONSTRAINT fk_payment_delivery 
        FOREIGN KEY (delivery_id) REFERENCES deliveries(delivery_id)
);

-- 5. SYSTEM_USERS table
CREATE TABLE system_users (
    user_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username        VARCHAR2(100) UNIQUE NOT NULL,
    password_hash   VARCHAR2(200) NOT NULL,
    full_name       VARCHAR2(150) NOT NULL,
    role            VARCHAR2(50) NOT NULL,
    status          VARCHAR2(20) DEFAULT 'ACTIVE',
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- 6. AUDIT_LOG table
CREATE TABLE audit_log (
    audit_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username         VARCHAR2(100) NOT NULL,
    operation        VARCHAR2(10) NOT NULL,
    object_name      VARCHAR2(100) NOT NULL,
    object_key       VARCHAR2(200),
    operation_status VARCHAR2(20) NOT NULL,
    reason           VARCHAR2(1000) NOT NULL,
    log_timestamp    TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- 7. HOLIDAYS table
CREATE TABLE holidays (
    holiday_date    DATE PRIMARY KEY,
    holiday_name    VARCHAR2(200) NOT NULL,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP
);
