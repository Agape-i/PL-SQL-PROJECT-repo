
-- INSERT REALISTIC TEST DATA

-- FARMERS DATA (15 farmers)
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('John Doe', '0788100001', 'NID001', 'Sector A', TO_TIMESTAMP('2025-03-10 09:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Jane Smith', '0788100002', 'NID002', 'Sector B', TO_TIMESTAMP('2025-03-12 10:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Mike Johnson', '0788100003', 'NID003', 'Sector A', TO_TIMESTAMP('2025-03-14 11:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Alice Brown', '0788100004', 'NID004', 'Sector C', TO_TIMESTAMP('2025-03-15 08:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Bob Martin', '0788100005', 'NID005', 'Sector B', TO_TIMESTAMP('2025-03-16 09:10:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Carol Lee', '0788100006', 'NID006', 'Sector D', TO_TIMESTAMP('2025-03-17 09:50:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('David King', '0788100007', 'NID007', 'Sector A', TO_TIMESTAMP('2025-03-18 10:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Eva Green', '0788100008', 'NID008', 'Sector C', TO_TIMESTAMP('2025-03-19 11:05:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Frank White', '0788100009', 'NID009', 'Sector D', TO_TIMESTAMP('2025-03-20 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Grace Hill', '0788100010', 'NID010', 'Sector B', TO_TIMESTAMP('2025-03-21 09:25:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Hank Adams', '0788100011', 'NID011', 'Sector A', TO_TIMESTAMP('2025-03-22 10:40:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Ivy Scott', '0788100012', 'NID012', 'Sector C', TO_TIMESTAMP('2025-03-23 11:20:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Jack Turner', '0788100013', 'NID013', 'Sector D', TO_TIMESTAMP('2025-03-24 08:55:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Kara Young', '0788100014', 'NID014', 'Sector B', TO_TIMESTAMP('2025-03-25 09:35:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO farmers (full_name, phone, national_id, sector, registration_date) VALUES ('Leo Hall', '0788100015', 'NID015', 'Sector A', TO_TIMESTAMP('2025-03-26 10:50:00', 'YYYY-MM-DD HH24:MI:SS'));

-- COFFEE QUALITY DATA (3 grades)
INSERT INTO coffee_quality VALUES (1, 'Grade A', 5.50);
INSERT INTO coffee_quality VALUES (2, 'Grade B', 4.00);
INSERT INTO coffee_quality VALUES (3, 'Grade C', 3.00);

-- DELIVERIES DATA (15 deliveries)
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (1, DATE '2025-04-01', 100.5, 1);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (1, DATE '2025-04-10', 80.0, 2);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (2, DATE '2025-04-03', 90.25, 2);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (2, DATE '2025-04-12', 75.5, 3);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (3, DATE '2025-04-05', 60.0, 1);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (3, DATE '2025-04-14', 95.0, 2);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (4, DATE '2025-04-06', 120.0, 3);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (4, DATE '2025-04-15', 85.5, 1);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (5, DATE '2025-04-07', 70.0, 2);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (5, DATE '2025-04-16', 65.25, 3);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (6, DATE '2025-04-08', 110.0, 1);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (6, DATE '2025-04-17', 88.0, 2);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (7, DATE '2025-04-09', 92.5, 3);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (7, DATE '2025-04-18', 77.5, 1);
INSERT INTO deliveries (farmer_id, delivery_date, weight_kg, quality_id) VALUES (8, DATE '2025-04-11', 85.0, 2);

-- HOLIDAYS DATA
INSERT INTO holidays (holiday_date, holiday_name) VALUES (DATE '2025-12-25', 'Christmas Day');
INSERT INTO holidays (holiday_date, holiday_name) VALUES (DATE '2025-12-26', 'Boxing Day');
INSERT INTO holidays (holiday_date, holiday_name) VALUES (DATE '2026-01-01', 'New Year''s Day');
