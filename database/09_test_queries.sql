-- =====================================================================
-- 09_test_queries.sql
-- Sanity/verification queries used during the DBMS Lab viva.
-- Run these AFTER 01-07 have been executed.
-- =====================================================================
USE disaster_management_db;

-- TEST 1: Verify severity trigger fired on insert (should show non-zero scores)
SELECT disaster_id, disaster_name, severity_score, severity_level FROM disasters LIMIT 10;

-- TEST 2: Recalculate full severity for disaster 1 using the stored procedure
CALL sp_calculate_severity(1);

-- TEST 3: Recommend rescue teams for disaster 1
CALL sp_recommend_teams(1);

-- TEST 4: Find blood donors for request 1
CALL sp_find_blood_donors(1);

-- TEST 5: Find a shelter for 50 people from disaster 1
CALL sp_find_shelter(1, 50);

-- TEST 6: Full disaster summary report
CALL sp_disaster_summary(1);

-- TEST 7: Transaction-safe relief distribution (should succeed and show stock)
CALL sp_distribute_relief(1, NULL, 1, 10, 1);

-- TEST 8: Attempt to over-distribute stock (should raise an error and roll back)
-- CALL sp_distribute_relief(1, NULL, 1, 999999, 1);

-- TEST 9: Attempt to over-allocate a shelter (should raise an error, trigger blocks it)
-- INSERT INTO shelter_allocations (shelter_id, disaster_id, victim_id, people_count)
-- VALUES (1, 1, NULL, 999999);

-- TEST 10: Attempt to assign a vehicle under maintenance (should raise an error)
-- INSERT INTO rescue_missions (disaster_id, team_id, vehicle_id, mission_type, start_time)
-- SELECT 1, 1, vehicle_id, 'Test Mission', NOW() FROM rescue_vehicles WHERE vehicle_status = 'Maintenance' LIMIT 1;

-- TEST 11: Views return data
SELECT * FROM active_disasters_view LIMIT 5;
SELECT * FROM disaster_summary_view LIMIT 5;
SELECT * FROM shelter_status_view LIMIT 5;
SELECT * FROM relief_stock_alert_view WHERE stock_alert = 'LOW STOCK';
SELECT * FROM rescue_mission_view LIMIT 5;
SELECT * FROM blood_request_status_view LIMIT 5;
