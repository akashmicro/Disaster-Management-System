-- seed_data.sql
-- Seed data for Disaster Management System (Bangladesh realistic data)
-- WARNING: BACKUP your database before running this script.
USE disaster_management_db;

-- ------------------------------------------------------------------
-- 1) Users (system roles)
-- ------------------------------------------------------------------
INSERT INTO users (user_id, full_name, username, password_hash, role, phone, is_active, created_at) VALUES
(1, 'Md. Ashraf Hossain', 'ashraf.h', '$2b$12$examplehash1', 'Admin', '+8801711000100', 1, '2025-01-10 09:12:00'),
(2, 'Farzana Begum', 'farzana.b', '$2b$12$examplehash2', 'Disaster Officer', '+8801711000101', 1, '2025-02-05 11:20:00'),
(3, 'Rajib Chandra', 'rajib.c', '$2b$12$examplehash3', 'Rescue Coordinator', '+8801711000102', 1, '2025-03-01 08:10:00'),
(4, 'Dr. Nazma Akter', 'nazma.a', '$2b$12$examplehash4', 'Medical Officer', '+8801711000103', 1, '2025-03-15 14:05:00'),
(5, 'Sabbir Ahmed', 'sabbir.a', '$2b$12$examplehash5', 'Relief Officer', '+8801711000104', 1, '2025-04-01 10:00:00'),
(6, 'Anika Sultana', 'anika.s', '$2b$12$examplehash6', 'Disaster Officer', '+8801711000105', 1, '2025-04-20 16:30:00');

-- ------------------------------------------------------------------
-- 2) Disaster types
-- ------------------------------------------------------------------
INSERT INTO disaster_types (disaster_type_id, type_name, description) VALUES
(1, 'Flood','High river water and urban flooding'),
(2, 'Cyclone','Severe cyclonic storm with high winds and storm surge'),
(3, 'River Erosion','Gradual or sudden erosion of river banks'),
(4, 'Fire','Urban or rural fire incidents'),
(5, 'Landslide','Slope failure in hilly areas'),
(6, 'Storm','Severe thunderstorm and windstorm'),
(7, 'Building Collapse','Structural collapse of buildings');

-- ------------------------------------------------------------------
-- 3) Locations (districts/divisions)
-- ------------------------------------------------------------------
-- Insert 20 Bangladesh districts with divisions and approximate zone types
INSERT INTO locations (location_id, district_name, division_name, zone_type, latitude, longitude) VALUES
(1, 'Dhaka', 'Dhaka','Urban',23.8103,90.4125),
(2, 'Chattogram', 'Chattogram','Coastal',22.3569,91.7832),
(3, 'Cox\'s Bazar', 'Chattogram','Coastal',21.4272,92.0058),
(4, 'Noakhali','Chattogram','Coastal',22.8497,91.0910),
(5, 'Feni','Chattogram','Coastal',23.0112,91.3977),
(6, 'Bhola','Barishal','Coastal',22.6850,90.6270),
(7, 'Barishal','Barishal','Riverine',22.7010,90.3535),
(8, 'Sylhet','Sylhet','Hilly',24.8949,91.8687),
(9, 'Sunamganj','Sylhet','Flood-Prone',24.9333,91.2586),
(10, 'Khulna','Khulna','Coastal',22.8456,89.5403),
(11, 'Satkhira','Khulna','Coastal',22.7083,89.0750),
(12, 'Bagerhat','Khulna','Coastal',22.6474,89.7900),
(13, 'Rangpur','Rangpur','Flood-Prone',25.7439,89.2752),
(14, 'Kurigram','Rangpur','Flood-Prone',25.8011,89.6163),
(15, 'Lalmonirhat','Rangpur','Flood-Prone',25.7466,89.2345),
(16, 'Rajshahi','Rajshahi','Urban',24.3745,88.6042),
(17, 'Patuakhali','Barishal','Coastal',22.3596,90.3296),
(18, 'Kishoreganj','Dhaka','Riverine',24.4265,90.7842),
(19, 'Narayanganj','Dhaka','Urban',23.6273,90.5008),
(20, 'Madaripur','Dhaka','Riverine',23.1796,90.2250);

-- ------------------------------------------------------------------
-- 4) Disasters (create 20 realistic disasters)
-- ------------------------------------------------------------------
-- Each disaster references disaster_type_id, location_id, and reported_by (users)
INSERT INTO disasters (disaster_id, disaster_name, disaster_type_id, location_id, reported_at, description, estimated_affected, infrastructure_damage_pct, severity_score, severity_level, status, reported_by) VALUES
(1, 'Monsoon Flooding in Dhaka North', 1, 1, '2026-07-28 05:20:00', 'Heavy monsoon rains caused urban flooding in northern Dhaka, inundating residential areas and marketplaces.', 120000, 12.5, 5.6, 'HIGH', 'Active Response', 2),
(2, 'Cyclone Remnant – Chattogram Coast', 2, 2, '2026-05-14 02:10:00', 'Severe cyclone remnant produced storm surge and coastal flooding along Chattogram.', 85000, 28.0, 7.9, 'CRITICAL', 'Active Response', 2),
(3, 'Cox\'s Bazar Coastal Surge', 1, 3, '2026-06-03 07:30:00', 'High tide combined with storm surge damaged coastal embankments and resorts.', 22000, 33.0, 6.8, 'HIGH', 'Under Assessment', 5),
(4, 'Noakhali Riverbank Collapse', 3, 4, '2026-04-11 10:00:00', 'Severe erosion caused large sections of riverbank to collapse, displacing villages.', 18000, 40.0, 8.1, 'CRITICAL', 'Active Response', 3),
(5, 'Feni Urban Fire – Market Area', 4, 5, '2025-12-22 21:45:00', 'A major market fire destroyed stalls and several adjoining buildings.', 2500, 15.0, 4.5, 'MEDIUM', 'Partially Controlled', 1),
(6, 'Bhola Low-Lying Flooding', 1, 6, '2026-07-30 04:00:00', 'Tidal flooding affected many low-lying communities on Bhola.', 42000, 9.0, 4.9, 'MEDIUM', 'Active Response', 5),
(7, 'Barishal River Surge', 1, 7, '2026-07-02 11:30:00', 'Sudden river surge inundated roads and farmland.', 15000, 10.5, 5.2, 'MEDIUM', 'Reported', 6),
(8, 'Sylhet Landslide near Jaflong', 5, 8, '2025-11-10 03:20:00', 'Heavy rains triggered landslides in hilly tea garden areas, blocking roads and damaging homes.', 3200, 22.0, 6.0, 'HIGH', 'Active Response', 4),
(9, 'Sunamganj Flash Flood', 1, 9, '2026-06-20 13:40:00', 'Flash flooding after intense localized rainfall affected multiple unions.', 9200, 8.0, 4.2, 'LOW', 'Resolved', 2),
(10, 'Khulna Storm Damage', 6, 10, '2026-03-18 18:00:00', 'A severe windstorm damaged roofs and uprooted trees across Khulna.', 5400, 12.0, 5.1, 'MEDIUM', 'Partially Controlled', 5),
(11, 'Satkhira Cyclone Threat', 2, 11, '2026-05-16 05:50:00', 'Cyclonic conditions threatened coastal communities; preventive evacuations conducted.', 12000, 3.0, 3.6, 'LOW', 'Reported', 3),
(12, 'Bagerhat Coastal Erosion', 3, 12, '2026-02-10 09:00:00', 'Ongoing river and tidal erosion affecting embankments and homesteads.', 7600, 20.0, 6.4, 'HIGH', 'Under Assessment', 2),
(13, 'Rangpur River Flooding', 1, 13, '2026-07-09 08:00:00', 'River overflow inundated croplands and villages nearby.', 30000, 7.0, 5.8, 'MEDIUM', 'Active Response', 1),
(14, 'Kurigram Bank Erosion', 3, 14, '2026-04-25 14:00:00', 'Severe bank erosion displaced households and cut access roads.', 5200, 27.0, 6.9, 'HIGH', 'Active Response', 2),
(15, 'Lalmonirhat Flash Flood', 1, 15, '2026-06-30 22:10:00', 'Localized flash flood after torrential rain caused house inundation.', 4200, 5.5, 4.0, 'LOW', 'Reported', 6),
(16, 'Rajshahi Building Collapse - Market Block', 7, 16, '2026-01-05 16:30:00', 'Partial collapse of an old market building resulted in casualties and rescue operations.', 800, 60.0, 8.8, 'CRITICAL', 'Active Response', 3),
(17, 'Patuakhali Tidal Flooding', 1, 17, '2026-07-01 03:15:00', 'High tides and weakened embankments flooded several unions.', 9000, 11.0, 5.0, 'MEDIUM', 'Active Response', 5),
(18, 'Kishoreganj Bridge Damage', 6, 18, '2025-10-12 07:40:00', 'Storm damaged a local bridge affecting transport and access.', 1400, 6.0, 3.9, 'LOW', 'Resolved', 4),
(19, 'Narayanganj Chemical Fire', 4, 19, '2026-02-28 02:50:00', 'Factory fire with hazardous smoke forced nearby evacuations and medical response.', 2100, 18.0, 6.2, 'HIGH', 'Partially Controlled', 1),
(20, 'Madaripur River Flooding', 1, 20, '2026-06-15 12:00:00', 'Monsoon floods affected paddy fields and low-lying homes.', 7600, 4.5, 4.8, 'LOW', 'Reported', 6);

-- ------------------------------------------------------------------
-- 5) Affected areas (one per disaster, with realistic area names)
-- ------------------------------------------------------------------
INSERT INTO affected_areas (area_id, disaster_id, location_id, area_name, population, affected_population, injured_count, critical_count, infrastructure_damage_pct, accessibility_status) VALUES
(1,1,1,'Uttara & Mirpur Lowlands',150000,48000,120,8,12.5,'Partially Accessible'),
(2,2,2,'Patenga Coastline',80000,35000,450,60,28.0,'Inaccessible'),
(3,3,3,'Laboni & Kolatoli',22000,4500,30,2,33.0,'Partially Accessible'),
(4,4,4,'Hatiya Riverbank Area',25000,15000,200,18,40.0,'Inaccessible'),
(5,5,5,'Feni Main Market',10000,2300,75,5,15.0,'Accessible'),
(6,6,6,'Bhola Island South',60000,22000,60,4,9.0,'Partially Accessible'),
(7,7,7,'Barishal Sadar & Surrounding Unions',50000,12000,90,6,10.5,'Accessible'),
(8,8,8,'Jaflong Hillside Tea Gardens',12000,3200,45,12,22.0,'Inaccessible'),
(9,9,9,'Sunamganj Lowlands',28000,9200,50,3,8.0,'Accessible'),
(10,10,10,'Khulna City Periphery',23000,5400,25,1,12.0,'Accessible'),
(11,11,11,'Satkhira Coastal Unions',30000,12000,110,9,3.0,'Partially Accessible'),
(12,12,12,'Bagerhat Embankment Area',18000,7600,40,2,20.0,'Partially Accessible'),
(13,13,13,'Rangpur North Floodplain',90000,30000,300,22,7.0,'Accessible'),
(14,14,14,'Kurigram Charlands',45000,5200,75,10,27.0,'Inaccessible'),
(15,15,15,'Lalmonirhat Lowlands',12000,4200,20,1,5.5,'Accessible'),
(16,16,16,'Rajshahi Old Market Area',8000,800,120,30,60.0,'Partially Accessible'),
(17,17,17,'Patuakhali Coastal Unions',22000,9000,70,6,11.0,'Partially Accessible'),
(18,18,18,'Kishoreganj Bridge Vicinity',7000,1400,10,0,6.0,'Accessible'),
(19,19,19,'Narayanganj Industrial Zone',15000,2100,90,12,18.0,'Partially Accessible'),
(20,20,20,'Madaripur Charlands',16000,7600,35,2,4.5,'Accessible');

-- Some SQL clients are picky about trailing commas and quotes; ensure the above rows are syntactically correct.
-- If any insertion fails, disable foreign key checks temporarily when seeding and re-enable after: 
-- SET FOREIGN_KEY_CHECKS=0; (run before) and SET FOREIGN_KEY_CHECKS=1; (after)

-- ------------------------------------------------------------------
-- 6) Victims (at least 20 records)
-- ------------------------------------------------------------------
INSERT INTO victims (victim_id, disaster_id, area_id, full_name, age, gender, condition_status, medical_priority, rescue_status) VALUES
(1,1,1,'Mohammad Rahman',45,'Male','Injured','Medium','In Progress'),
(2,1,1,'Shathi Akter',32,'Female','Safe','None','Rescued'),
(3,2,2,'Abdul Karim',60,'Male','Hospitalized','High','In Progress'),
(4,3,3,'Nusrat Jahan',27,'Female','Injured','Low','Rescued'),
(5,4,4,'Sultan Mia',50,'Male','Critical','High','In Progress'),
(6,5,5,'Fahim Hassan',22,'Male','Injured','Low','Rescued'),
(7,6,6,'Rokeya Sultana',38,'Female','Safe','None','Rescued'),
(8,7,7,'Imran Hossain',29,'Male','Injured','Medium','In Progress'),
(9,8,8,'Mst. Rina Begum',55,'Female','Critical','High','In Progress'),
(10,9,9,'Kazi Monir',41,'Male','Safe','None','Not Rescued'),
(11,10,10,'Anowar Hossen',66,'Male','Injured','Medium','Rescued'),
(12,11,11,'Salma Khatun',70,'Female','Safe','None','Not Rescued'),
(13,12,12,'Raju Sarker',34,'Male','Injured','Low','Rescued'),
(14,13,13,'Tania Rahman',19,'Female','Safe','None','Not Rescued'),
(15,14,14,'Habib Ullah',48,'Male','Injured','Medium','In Progress'),
(16,15,15,'Mahi Akter',8,'Female','Injured','High','In Progress'),
(17,16,16,'Babul Chowdhury',52,'Male','Critical','High','In Progress'),
(18,17,17,'Rumana Begum',30,'Female','Safe','None','Rescued'),
(19,18,18,'Nazrul Islam',44,'Male','Injured','Low','Rescued'),
(20,19,19,'Sabbir Hossain',28,'Male','Injured','Medium','In Progress'),
(21,20,20,'Parul Khatun',36,'Female','Safe','None','Not Rescued'),
(22,2,2,'Md. Elias',15,'Male','Injured','Low','Rescued'),
(23,4,4,'Jamal Uddin',62,'Male','Injured','Medium','In Progress'),
(24,1,1,'Rita Chowdhury',71,'Female','Hospitalized','High','In Progress'),
(25,3,3,'Shafiqur Rahman',40,'Male','Safe','None','Rescued');

-- ------------------------------------------------------------------
-- 7) Missing persons (at least 20)
-- ------------------------------------------------------------------
INSERT INTO missing_persons (missing_id, disaster_id, area_id, full_name, age, gender, last_seen_location, missing_date, description, status) VALUES
(1,1,1,'Hasan Ali',34,'Male','Mirpur 10B', '2026-07-28','Last seen walking towards lowland shelter','Missing'),
(2,2,2,'Jahanara Begum',58,'Female','Patenga Beach Front','2026-05-14','Was swept away by surge near embankment','Missing'),
(3,3,3,'Rafiq Uddin',27,'Male','Kolatoli Road','2026-06-03','Encountered strong current near pier','Located'),
(4,4,4,'Nasima Khatun',19,'Female','Hatiya Bazar','2026-04-11','Last seen near embankment','Missing'),
(5,5,5,'Monir Hossain',45,'Male','Feni Sadar Market','2025-12-22','Trapped under debris after fire','Missing'),
(6,6,6,'Shamima Akhter',70,'Female','Char Lalmon','2026-07-30','Evacuated but separated from family','Reunited'),
(7,7,7,'Rashedul Islam',22,'Male','Barishal Sadar','2026-07-02','Last seen on flooded road','Missing'),
(8,8,8,'Mitu Rani',16,'Female','Jaflong Trail','2025-11-10','Slid down hillside during landslide','Missing'),
(9,9,9,'Farid Ahmed',39,'Male','Sunamganj Union 6','2026-06-20','Left home to check livestock','Located'),
(10,10,10,'Rasheda Begum',53,'Female','Khulna East','2026-03-18','Roof collapse and missing since storm','Missing'),
(11,11,11,'Abul Kalam',60,'Male','Satkhira Coastal Road','2026-05-16','Was taken by strong current while fishing','Missing'),
(12,12,12,'Nazneen Sultana',31,'Female','Bagerhat Embankment','2026-02-10','Was evacuating to shelter and separated','Missing'),
(13,13,13,'Masud Rana',28,'Male','Rangpur North Union','2026-07-09','Vehicle washed away during crossing','Missing'),
(14,14,14,'Rupali Khatun',24,'Female','Kurigram Charland','2026-04-25','Washed away while collecting firewood','Located'),
(15,15,15,'Nur Hossain',67,'Male','Lalmonirhat Market','2026-06-30','Left home to buy medicine','Reunited'),
(16,16,16,'Sabbir Khan',34,'Male','Rajshahi Old Market','2026-01-05','Caught under collapsed roof','Rescued'),
(17,17,17,'Afsana Begum',29,'Female','Patuakhali Union 3','2026-07-01','Separated during evacuation','Missing'),
(18,18,18,'Iftikar Hossain',41,'Male','Kishoreganj Bridge','2025-10-12','Fell from damaged bridge','Missing'),
(19,19,19,'Rina Akter',26,'Female','Narayanganj Industry Road','2026-02-28','Evacuating from factory and not seen since','Missing'),
(20,20,20,'Monira Binte',50,'Female','Madaripur Char','2026-06-15','Last seen near riverbank','Missing');

-- ------------------------------------------------------------------
-- 8) Rescue teams (20 teams)
-- ------------------------------------------------------------------
INSERT INTO rescue_teams (team_id, team_name, team_type, specialization, team_leader, member_count, current_location_id, availability_status, contact_number) VALUES
(1,'Dhaka Water Rescue Unit A','Water Rescue','Flood Rescue','Lt. Colonel Mahmud',20,1,'Deployed','+8801712000101'),
(2,'Chattogram Coastal Rescue','General Rescue','Search & Rescue','Captain Rahman',25,2,'Available','+8801712000102'),
(3,'Cox\'s Bazar Marine Team','Water Rescue','Flood Rescue','Lt. Shafiq',18,3,'Deployed','+8801712000103'),
(4,'Noakhali Erosion Response','General Rescue','Search & Rescue','Md. Karim',15,4,'Available','+8801712000104'),
(5,'Feni Fire & Rescue','Fire Rescue','Fire Rescue','Fire Chief Alam',22,5,'Available','+8801712000105'),
(6,'Bhola Community Rescue','General Rescue','Search & Rescue','Abdul Wahab',12,6,'Available','+8801712000106'),
(7,'Barishal Rapid Response','General Rescue','Emergency Medical Team','Dr. Rahman',30,7,'Deployed','+8801712000107'),
(8,'Sylhet Hill Rescue','Mountain Rescue','Search & Rescue','Mr. Kawsar',14,8,'Available','+8801712000108'),
(9,'Sunamganj Flood Team','Water Rescue','Flood Rescue','Md. Hasan',16,9,'Available','+8801712000109'),
(10,'Khulna Storm Unit','General Rescue','Search & Rescue','Captain Karim',20,10,'Available','+8801712000110'),
(11,'Satkhira Coastal Unit','Water Rescue','Flood Rescue','Md. Rahim',18,11,'Available','+8801712000111'),
(12,'Bagerhat Embankment Team','General Rescue','Search & Rescue','Sabbir H',13,12,'Available','+8801712000112'),
(13,'Rangpur Flood Response','Water Rescue','Flood Rescue','Mr. Anis',21,13,'Deployed','+8801712000113'),
(14,'Kurigram River Rescue','Water Rescue','Flood Rescue','Lt. Nazim',17,14,'Available','+8801712000114'),
(15,'Lalmonirhat Rapid Team','General Rescue','Search & Rescue','Md. Zaman',12,15,'Available','+8801712000115'),
(16,'Rajshahi Urban Rescue','General Rescue','Search & Rescue','Inspector Farhad',26,16,'Deployed','+8801712000116'),
(17,'Patuakhali Cyclone Unit','Water Rescue','Flood Rescue','Captain Shams',19,17,'Available','+8801712000117'),
(18,'Kishoreganj Bridge Team','General Rescue','Search & Rescue','Md. Iqbal',11,18,'Available','+8801712000118'),
(19,'Narayanganj Industrial Rescue','Fire Rescue','Emergency Medical Team','Dr. Sultana',24,19,'Deployed','+8801712000119'),
(20,'Madaripur Char Rescue','General Rescue','Search & Rescue','Mr. Javed',10,20,'Available','+8801712000120');

-- ------------------------------------------------------------------
-- 9) Team members (a few per team)
-- ------------------------------------------------------------------
INSERT INTO team_members (member_id, team_id, full_name, designation, phone) VALUES
(1,1,'Sujon Ahmed','Rescuer','+8801713000101'),
(2,1,'Rashed Khan','Boat Operator','+8801713000102'),
(3,2,'Nazrul Islam','Rescuer','+8801713000103'),
(4,2,'Anwar Hossain','Medic','+8801713000104'),
(5,3,'Salim Uddin','Rescuer','+8801713000105'),
(6,3,'Kamal Hossain','Diver','+8801713000106'),
(7,4,'Biplob Roy','Coordinator','+8801713000107'),
(8,5,'Firoz Ahmed','Firefighter','+8801713000108'),
(9,6,'Rakib Hasan','Rescuer','+8801713000109'),
(10,7,'Dr. Iqbal','Doctor','+8801713000110'),
(11,8,'Shahidul Islam','Rescuer','+8801713000111'),
(12,9,'Kamal Mia','Boat Driver','+8801713000112'),
(13,10,'Mamunur Rashid','Engineer','+8801713000113'),
(14,11,'Momen Ali','Rescuer','+8801713000114'),
(15,12,'Abdullah Al','Rescuer','+8801713000115'),
(16,13,'Nurul Amin','Rescuer','+8801713000116'),
(17,14,'Sohail Ahmed','Boat Operator','+8801713000117'),
(18,15,'Farid Uddin','Rescuer','+8801713000118'),
(19,16,'Tanvir Hossain','Coordinator','+8801713000119'),
(20,17,'Mahbub Ali','Rescuer','+8801713000120');

-- ------------------------------------------------------------------
-- 10) Rescue vehicles (20 vehicles)
-- ------------------------------------------------------------------
INSERT INTO rescue_vehicles (vehicle_id, vehicle_number, vehicle_type, capacity, current_location_id, vehicle_status, fuel_status) VALUES
(1,'DHA-AMB-001','Ambulance',4,1,'On Mission','Medium'),
(2,'CTG-BOAT-01','Rescue Boat',12,2,'Assigned','Full'),
(3,'COX-BOAT-02','Rescue Boat',10,3,'On Mission','Full'),
(4,'NOA-TRK-01','Rescue Truck',20,4,'Available','Full'),
(5,'FEN-FIRE-01','Fire Truck',6,5,'Assigned','Medium'),
(6,'BHO-TRK-01','Rescue Truck',15,6,'Available','Full'),
(7,'BAR-AMB-02','Ambulance',4,7,'Assigned','Low'),
(8,'SYL-VAN-01','Emergency Van',8,8,'Available','Full'),
(9,'SUN-BOAT-01','Rescue Boat',10,9,'Available','Full'),
(10,'KHU-FIRE-01','Fire Truck',6,10,'Assigned','Medium'),
(11,'SAT-BOAT-01','Rescue Boat',10,11,'Available','Full'),
(12,'BAG-TRK-01','Rescue Truck',18,12,'Available','Full'),
(13,'RAN-TRK-01','Rescue Truck',20,13,'Assigned','Medium'),
(14,'KUR-BOAT-01','Rescue Boat',8,14,'Available','Full'),
(15,'LAL-VAN-01','Emergency Van',6,15,'Available','Full'),
(16,'RAJ-AMB-01','Ambulance',4,16,'Assigned','Low'),
(17,'PAT-BOAT-01','Rescue Boat',12,17,'Available','Full'),
(18,'KIS-TRK-01','Rescue Truck',10,18,'Available','Full'),
(19,'NAR-FIRE-01','Fire Truck',6,19,'On Mission','Low'),
(20,'MAD-VAN-01','Emergency Van',6,20,'Available','Full');

-- ------------------------------------------------------------------
-- 11) Rescue assignments (20 assignments linking disasters and teams)
-- ------------------------------------------------------------------
INSERT INTO rescue_assignments (assignment_id, disaster_id, team_id, area_id, assigned_at, assignment_status) VALUES
(1,1,1,1,'2026-07-28 06:00:00','On Site'),
(2,2,2,2,'2026-05-14 03:00:00','On Site'),
(3,3,3,3,'2026-06-03 08:10:00','Assigned'),
(4,4,4,4,'2026-04-11 11:30:00','On Site'),
(5,5,5,5,'2025-12-22 22:00:00','Completed'),
(6,6,6,6,'2026-07-30 05:10:00','En Route'),
(7,7,7,7,'2026-07-02 12:00:00','Assigned'),
(8,8,8,8,'2025-11-10 04:00:00','On Site'),
(9,9,9,9,'2026-06-20 14:00:00','Completed'),
(10,10,10,10,'2026-03-18 19:00:00','On Site'),
(11,11,11,11,'2026-05-16 06:30:00','Assigned'),
(12,12,12,12,'2026-02-10 10:30:00','Completed'),
(13,13,13,13,'2026-07-09 09:00:00','On Site'),
(14,14,14,14,'2026-04-25 15:00:00','En Route'),
(15,15,15,15,'2026-06-30 23:00:00','Assigned'),
(16,16,16,16,'2026-01-05 17:00:00','On Site'),
(17,17,17,17,'2026-07-01 04:00:00','Assigned'),
(18,18,18,18,'2025-10-12 08:20:00','Completed'),
(19,19,19,19,'2026-02-28 03:30:00','On Site'),
(20,20,20,20,'2026-06-15 13:00:00','Assigned');

-- ------------------------------------------------------------------
-- 12) Rescue missions (20 missions)
-- ------------------------------------------------------------------
INSERT INTO rescue_missions (mission_id, disaster_id, team_id, vehicle_id, mission_type, start_time, end_time, source_location, destination, mission_status, mission_result) VALUES
(1,1,1,1,'Evacuation','2026-07-28 06:10:00','2026-07-28 12:30:00','Uttara Embankment','Mirpur Shelter 2','Completed','Evacuated 120 families'),
(2,2,2,2,'Search & Rescue','2026-05-14 03:15:00',NULL,'Patenga Jetty','Coastal Villages','Ongoing','Search in zone A'),
(3,3,3,3,'Medical Rescue','2026-06-03 08:15:00','2026-06-03 14:00:00','Kolatoli Pier','Cox\'s Bazar Field Hosp','Completed','Treated 85 injured'),
(4,4,4,4,'Bank Stabilization Support','2026-04-11 11:45:00',NULL,'Hatiya Embankment','Affected Char','Ongoing','Assessing bank stability'),
(5,5,5,5,'Firefighting','2025-12-22 22:10:00','2025-12-23 03:00:00','Feni Market','Feni General Storage','Completed','Fire contained; 6 injured'),
(6,6,6,6,'Evacuation','2026-07-30 05:20:00',NULL,'Bhola South Center','Char Shelter 1','Ongoing','Evacuating households'),
(7,7,7,7,'Medical Camp','2026-07-02 12:20:00','2026-07-02 18:00:00','Barishal Sadar','Barishal Hospital','Completed','200 patients treated'),
(8,8,8,8,'Search & Rescue','2025-11-10 04:10:00','2025-11-10 09:00:00','Jaflong Trail','Tea Garden Village','Completed','10 people rescued'),
(9,9,9,9,'Relief Distribution','2026-06-20 14:10:00','2026-06-20 17:00:00','Sunamganj Center','Union Relief Point','Completed','Distributed dry food'),
(10,10,10,10,'Storm Response','2026-03-18 19:10:00','2026-03-19 02:00:00','Khulna Periphery','Khulna Shelter 3','Completed','Secured 80 households'),
(11,11,11,11,'Evacuation Drill','2026-05-16 07:00:00','2026-05-16 09:00:00','Satkhira Road','Coastal Shelter A','Completed','Prepared community'),
(12,12,12,12,'Embankment Repair','2026-02-10 10:50:00','2026-02-12 18:00:00','Bagerhat Embankment','Repair Site 2','Completed','Temporary repairs done'),
(13,13,13,13,'Animal Rescue','2026-07-09 09:15:00','2026-07-09 13:00:00','Rangpur Floodplain','Village 7','Completed','Rescued livestock'),
(14,14,14,14,'Road Clearance','2026-04-25 15:10:00','2026-04-25 20:00:00','Kurigram Charland','Main Road 2','Completed','Cleared debris'),
(15,15,15,15,'Shelter Support','2026-06-30 23:10:00','2026-07-01 06:00:00','Lalmonirhat Center','Shelter 5','Completed','Shelter setup for 350 people'),
(16,16,16,16,'Collapse Rescue','2026-01-05 17:10:00','2026-01-06 02:00:00','Rajshahi Market','Collapsed Block','Completed','Rescued and retrieved 14 people'),
(17,17,17,17,'Coastal Patrol','2026-07-01 04:10:00','2026-07-01 10:00:00','Patuakhali Jetty','Coastal Villages','Completed','Monitored embankments'),
(18,18,18,18,'Bridge Assessment','2025-10-12 08:30:00','2025-10-12 17:00:00','Kishoreganj Bridge','Nearby Union','Completed','Bridge partially repaired'),
(19,19,19,19,'Industrial Fire Support','2026-02-28 03:40:00','2026-02-28 11:00:00','Narayanganj Factory','Factory Compound','Completed','Fire suppressed; 12 injured'),
(20,20,20,20,'Char Evacuation','2026-06-15 13:10:00','2026-06-15 18:00:00','Madaripur Char','Relief Camp','Completed','Evacuated 240 people');

-- ------------------------------------------------------------------
-- 13) Shelters (20 shelters)
-- ------------------------------------------------------------------
INSERT INTO shelters (shelter_id, shelter_name, location_id, total_capacity, occupied_capacity, has_medical_facility, has_water, has_food, shelter_status) VALUES
(1,'Uttara Secondary School Shelter',1,1200,640,1,1,1,'Open'),
(2,'Patenga Cyclone Shelter',2,800,720,1,1,1,'Open'),
(3,'Cox\'s Bazar Community Centre',3,600,420,0,1,1,'Open'),
(4,'Hatiya Govt High School Shelter',4,500,480,0,1,1,'Open'),
(5,'Feni Town Hall Shelter',5,300,200,0,1,1,'Open'),
(6,'Bhola Upazila Stadium Shelter',6,1500,900,1,1,1,'Open'),
(7,'Barishal Govt College Shelter',7,700,250,1,1,1,'Open'),
(8,'Jaflong Community Shelter',8,200,160,0,1,1,'Open'),
(9,'Sunamganj Union Relief Camp',9,350,140,0,1,1,'Open'),
(10,'Khulna District Stadium Shelter',10,1200,600,1,1,1,'Open'),
(11,'Satkhira Coastal Shelter A',11,900,880,0,1,1,'Open'),
(12,'Bagerhat Upazila School Shelter',12,400,160,0,1,1,'Open'),
(13,'Rangpur Flood Relief Center',13,1600,1120,1,1,1,'Open'),
(14,'Kurigram High School Shelter',14,800,300,0,1,1,'Open'),
(15,'Lalmonirhat Community Hall',15,350,200,0,1,1,'Open'),
(16,'Rajshahi Old Market Shelter',16,250,120,1,1,1,'Open'),
(17,'Patuakhali Cyclone Shelter',17,1000,720,1,1,1,'Open'),
(18,'Kishoreganj Union Center',18,300,60,0,1,1,'Open'),
(19,'Narayanganj Industrial Relief Camp',19,500,240,1,1,1,'Open'),
(20,'Madaripur Char Shelter',20,600,420,0,1,1,'Open');

-- ------------------------------------------------------------------
-- 14) Shelter allocations (20 allocations) linking victims/shelters/disasters
-- ------------------------------------------------------------------
INSERT INTO shelter_allocations (allocation_id, shelter_id, disaster_id, victim_id, people_count, allocated_at) VALUES
(1,1,1,2,4,'2026-07-28 07:00:00'),
(2,2,2,3,3,'2026-05-14 04:00:00'),
(3,3,3,4,2,'2026-06-03 09:00:00'),
(4,4,4,5,5,'2026-04-11 12:15:00'),
(5,5,5,6,1,'2025-12-22 23:00:00'),
(6,6,6,7,6,'2026-07-30 06:30:00'),
(7,7,7,8,3,'2026-07-02 13:00:00'),
(8,8,8,9,2,'2025-11-10 05:30:00'),
(9,9,9,10,1,'2026-06-20 15:00:00'),
(10,10,10,11,2,'2026-03-18 20:00:00'),
(11,11,11,12,4,'2026-05-16 08:00:00'),
(12,12,12,13,2,'2026-02-10 11:00:00'),
(13,13,13,14,3,'2026-07-09 10:30:00'),
(14,14,14,15,1,'2026-04-25 16:00:00'),
(15,15,15,16,5,'2026-06-30 23:30:00'),
(16,16,16,17,1,'2026-01-05 18:00:00'),
(17,17,17,18,2,'2026-07-01 05:00:00'),
(18,18,18,19,2,'2025-10-12 09:00:00'),
(19,19,19,20,3,'2026-02-28 04:30:00'),
(20,20,20,21,2,'2026-06-15 14:00:00');

-- ------------------------------------------------------------------
-- 15) Blood donors (20 donors)
-- ------------------------------------------------------------------
INSERT INTO blood_donors (donor_id, full_name, blood_group, phone, location_id, is_available, last_donation_date) VALUES
(1,'Md. Jahangir','A+', '+8801714000101',1,1,'2025-11-10'),
(2,'Rahima Khatun','O+', '+8801714000102',2,1,'2026-03-12'),
(3,'Sajib Ahmed','B+', '+8801714000103',3,1,'2026-01-20'),
(4,'Laila Begum','AB+', '+8801714000104',4,1,'2025-12-05'),
(5,'Biplob Kumar','O-','+8801714000105',5,1,'2026-05-22'),
(6,'Mitu Chowdhury','A-','+8801714000106',6,1,'2026-02-14'),
(7,'Nazrul Islam','B-','+8801714000107',7,1,'2025-09-30'),
(8,'Shamima Sultana','AB-','+8801714000108',8,1,'2026-04-01'),
(9,'Kamal Hossain','A+','+8801714000109',9,1,'2026-06-10'),
(10,'Farida Akther','O+','+8801714000110',10,1,'2026-06-15'),
(11,'Tanvir Khan','B+','+8801714000111',11,1,'2026-05-05'),
(12,'Rupali Begum','A+','+8801714000112',12,1,'2025-08-12'),
(13,'Hafizur Rahman','O-','+8801714000113',13,1,'2026-01-18'),
(14,'Simanta Roy','B+','+8801714000114',14,1,'2026-02-25'),
(15,'Anwara Khatun','A+','+8801714000115',15,1,'2026-06-01'),
(16,'Moniruzzaman','O+','+8801714000116',16,1,'2026-03-20'),
(17,'Shihab Uddin','AB+','+8801714000117',17,1,'2025-10-10'),
(18,'Rasheda Begum','B-','+8801714000118',18,1,'2026-04-14'),
(19,'Sabbir Ahmed','O+','+8801714000119',19,1,'2026-05-30'),
(20,'Nazma Khatun','A+','+8801714000120',20,1,'2026-06-22');

-- ------------------------------------------------------------------
-- 16) Blood requests (20 requests)
-- ------------------------------------------------------------------
INSERT INTO blood_requests (request_id, disaster_id, hospital_name, blood_group, required_units, urgency, request_date, request_status) VALUES
(1,16,'Rajshahi Medical College Hospital','O+',10,'High','2026-01-05','Partially Fulfilled'),
(2,19,'Narayanganj General Hospital','A+',8,'Critical','2026-02-28','Open'),
(3,5,'Feni Sadar Hospital','B+',4,'Medium','2025-12-22','Fulfilled'),
(4,1,'Dhaka Emergency Centre','AB+',15,'Critical','2026-07-28','Open'),
(5,2,'Chattogram District Hospital','O-',12,'High','2026-05-14','Open'),
(6,3,'Cox\'s Bazar Field Hospital','A-','6','Medium','2026-06-03','Open'),
(7,4,'Hatiya Island Health Complex','O+',5,'Medium','2026-04-11','Open'),
(8,6,'Bhola Upazila Health Complex','B+','7','Medium','2026-07-30','Open'),
(9,7,'Barishal Medical Centre','A+','9','High','2026-07-02','Open'),
(10,8,'Sylhet Sadar Hospital','AB-','3','Low','2025-11-10','Fulfilled'),
(11,9,'Sunamganj Health Complex','O+','4','Low','2026-06-20','Open'),
(12,10,'Khulna Medical College','B-','6','Medium','2026-03-18','Open'),
(13,11,'Satkhira Sadar Hospital','A+','10','High','2026-05-16','Open'),
(14,12,'Bagerhat Upazila Hospital','O+','5','Low','2026-02-10','Fulfilled'),
(15,13,'Rangpur Medical College','A+','14','High','2026-07-09','Open'),
(16,14,'Kurigram Health Complex','B+','6','Medium','2026-04-25','Open'),
(17,15,'Lalmonirhat Hospital','O-','4','Low','2026-06-30','Fulfilled'),
(18,17,'Patuakhali General Hospital','AB+','7','Medium','2026-07-01','Open'),
(19,18,'Kishoreganj Hospital','A+','5','Low','2025-10-12','Fulfilled'),
(20,20,'Madaripur Sadar Hospital','O+','6','Medium','2026-06-15','Open');

-- ------------------------------------------------------------------
-- 17) Relief items (20+ items with stock)
-- ------------------------------------------------------------------
INSERT INTO relief_items (item_id, item_name, category, unit, current_stock, minimum_stock, maximum_stock) VALUES
(1,'Rice (25kg sack)','Food','kg',50000,2000,60000),
(2,'Drinking Water Bottles (1.5L)','Water','bottle',30000,1000,50000),
(3,'Dry Food Pack (Meal Kit)','Food','pack',15000,500,20000),
(4,'Oral Rehydration Salts (ORS)','Medicine','unit',5000,200,8000),
(5,'Antibiotic Kits','Medicine','kit',2500,100,5000),
(6,'Blanket (thermal)','Clothing','piece',8000,200,10000),
(7,'First Aid Kit','First Aid','kit',2000,100,3000),
(8,'Baby Food (Powder)','Baby Care','kg',1200,50,2000),
(9,'Water Purification Tablets','Water','box',5000,200,8000),
(10,'Cooking Oil (5L)','Food','liter',10000,500,15000),
(11,'Lentils (Masoor) (kg)','Food','kg',8000,200,12000),
(12,'Tents (family)','Shelter Material','unit',400,20,1000),
(13,'Mosquito Nets','Shelter Material','piece',3500,100,5000),
(14,'Sanitary Napkins','First Aid','pack',6000,200,8000),
(15,'Baby Diapers','Baby Care','pack',3000,100,5000),
(16,'Fuel (liters)','Food','liter',20000,1000,40000),
(17,'Blanket (cotton)','Clothing','piece',6000,200,8000),
(18,'Face Mask Packs','First Aid','pack',15000,500,20000),
(19,'Hand Sanitizer (500ml)','First Aid','bottle',8000,200,12000),
(20,'Portable Stove','Shelter Material','unit',1200,50,2000),
(21,'Electric Generator','Shelter Material','unit',200,10,500),
(22,'Tapioca/Potato (kg)','Food','kg',4000,200,8000),
(23,'Cooking Utensils Set','Shelter Material','set',1500,50,2500),
(24,'Baby Blankets','Baby Care','piece',2200,50,4000),
(25,'Emergency Lighting (solar)','Shelter Material','unit',800,20,1500);

-- ------------------------------------------------------------------
-- 18) Relief distribution records (20+ records)
-- ------------------------------------------------------------------
INSERT INTO relief_distribution (distribution_id, disaster_id, area_id, item_id, distributed_quantity, distributed_at, distributed_by) VALUES
(1,1,1,1,5000,'2026-07-28 09:00:00',5),
(2,2,2,2,3000,'2026-05-14 06:00:00',5),
(3,3,3,3,800,'2026-06-03 10:30:00',5),
(4,4,4,4,400,'2026-04-11 13:00:00',4),
(5,5,5,5,120,'2025-12-23 01:30:00',4),
(6,6,6,6,600,'2026-07-30 07:30:00',5),
(7,7,7,7,350,'2026-07-02 14:30:00',5),
(8,8,8,8,180,'2025-11-10 06:20:00',4),
(9,9,9,9,400,'2026-06-20 16:10:00',3),
(10,10,10,10,220,'2026-03-18 21:30:00',3),
(11,11,11,11,900,'2026-05-16 08:45:00',5),
(12,12,12,12,100,'2026-02-12 09:30:00',5),
(13,13,13,13,700,'2026-07-09 11:20:00',5),
(14,14,14,14,120,'2026-04-25 17:00:00',5),
(15,15,15,15,300,'2026-07-01 01:10:00',5),
(16,16,16,16,50,'2026-01-06 03:50:00',4),
(17,17,17,17,420,'2026-07-01 08:30:00',5),
(18,18,18,18,60,'2025-10-12 12:20:00',4),
(19,19,19,19,150,'2026-02-28 06:00:00',4),
(20,20,20,20,280,'2026-06-15 15:30:00',5),
(21,1,1,6,1200,'2026-07-28 10:00:00',5),
(22,2,2,9,2500,'2026-05-14 07:30:00',5),
(23,16,16,7,200,'2026-01-05 20:00:00',4),
(24,19,19,5,300,'2026-02-28 07:00:00',4),
(25,13,13,1,6000,'2026-07-09 12:00:00',5);

-- ------------------------------------------------------------------
-- Final notes: After running, verify counts such as:
-- SELECT COUNT(*) FROM disasters; SELECT COUNT(*) FROM victims; etc.
-- If any FOREIGN KEY errors occur during insertion, try temporarily disabling FK checks:
-- SET FOREIGN_KEY_CHECKS=0; SOURCE seed_data.sql; SET FOREIGN_KEY_CHECKS=1;
-- However, avoid disabling checks on production systems.

COMMIT;
