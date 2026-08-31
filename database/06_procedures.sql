-- =====================================================================
-- 06_procedures.sql
-- Stored procedures for the Disaster Response Intelligence Engine
-- =====================================================================
USE disaster_management_db;

DELIMITER //

-- ---------------------------------------------------------------------
-- PROCEDURE 1: Recalculate full disaster severity using ALL factors -
-- affected population, infrastructure damage, victim counts, and
-- missing persons. This is the authoritative severity engine, called
-- after areas/victims/missing-persons data exists for a disaster.
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_calculate_severity(IN p_disaster_id INT)
BEGIN
    DECLARE v_affected INT DEFAULT 0;
    DECLARE v_damage DECIMAL(5,2) DEFAULT 0;
    DECLARE v_victims INT DEFAULT 0;
    DECLARE v_critical INT DEFAULT 0;
    DECLARE v_missing INT DEFAULT 0;
    DECLARE v_score DECIMAL(6,2) DEFAULT 0;
    DECLARE v_level VARCHAR(10);

    SELECT estimated_affected, infrastructure_damage_pct
      INTO v_affected, v_damage
      FROM disasters WHERE disaster_id = p_disaster_id;

    SELECT COUNT(*) INTO v_victims FROM victims WHERE disaster_id = p_disaster_id;
    SELECT COUNT(*) INTO v_critical FROM victims
      WHERE disaster_id = p_disaster_id AND condition_status IN ('Critical','Hospitalized');
    SELECT COUNT(*) INTO v_missing FROM missing_persons
      WHERE disaster_id = p_disaster_id AND status = 'Missing';

    -- Weighted scoring: affected population 35%, damage 25%,
    -- victim severity 25%, missing persons 15%
    SET v_score = (LEAST(v_affected, 100000) / 100000) * 35
                + (v_damage / 100) * 25
                + (LEAST(v_victims, 500) / 500) * 15
                + (LEAST(v_critical, 100) / 100) * 10
                + (LEAST(v_missing, 100) / 100) * 15;

    SET v_level = CASE
        WHEN v_score >= 75 THEN 'CRITICAL'
        WHEN v_score >= 50 THEN 'HIGH'
        WHEN v_score >= 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END;

    UPDATE disasters
       SET severity_score = v_score, severity_level = v_level
     WHERE disaster_id = p_disaster_id;

    SELECT p_disaster_id AS disaster_id, v_score AS severity_score, v_level AS severity_level,
           v_affected AS estimated_affected, v_victims AS total_victims,
           v_critical AS critical_victims, v_missing AS missing_count;
END//

-- ---------------------------------------------------------------------
-- PROCEDURE 2: Recommend suitable rescue teams for a disaster based
-- on specialization matching the disaster type, availability, and
-- proximity (same location first).
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_recommend_teams(IN p_disaster_id INT)
BEGIN
    DECLARE v_type_name VARCHAR(50);
    DECLARE v_location_id INT;

    SELECT dt.type_name, d.location_id INTO v_type_name, v_location_id
      FROM disasters d JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id
     WHERE d.disaster_id = p_disaster_id;

    SELECT rt.team_id, rt.team_name, rt.specialization, rt.availability_status,
           rt.member_count,
           CASE WHEN rt.current_location_id = v_location_id THEN 'Same Location' ELSE 'Other Location' END AS proximity,
           CASE
               WHEN v_type_name IN ('Flood','Flash Flood','River Erosion') AND rt.specialization = 'Flood Rescue' THEN 3
               WHEN v_type_name = 'Fire' AND rt.specialization = 'Fire Rescue' THEN 3
               WHEN v_type_name IN ('Landslide','Earthquake') AND rt.specialization IN ('Search & Rescue','Mountain Rescue') THEN 3
               WHEN rt.specialization IN ('Medical Rescue','Emergency Medical Team') THEN 2
               ELSE 1
           END AS match_score
      FROM rescue_teams rt
     WHERE rt.availability_status = 'Available'
     ORDER BY match_score DESC, proximity ASC, rt.member_count DESC
     LIMIT 10;
END//

-- ---------------------------------------------------------------------
-- PROCEDURE 3: Find available blood donors matching a blood request,
-- prioritizing donors in the same district as the requesting hospital's
-- disaster and who have not donated in the last 90 days.
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_find_blood_donors(IN p_request_id INT)
BEGIN
    DECLARE v_blood_group VARCHAR(3);
    DECLARE v_location_id INT;

    SELECT br.blood_group, d.location_id INTO v_blood_group, v_location_id
      FROM blood_requests br JOIN disasters d ON br.disaster_id = d.disaster_id
     WHERE br.request_id = p_request_id;

    SELECT bd.donor_id, bd.full_name, bd.blood_group, bd.phone, l.district_name,
           bd.last_donation_date,
           CASE WHEN bd.location_id = v_location_id THEN 'Nearby' ELSE 'Other District' END AS proximity
      FROM blood_donors bd
      JOIN locations l ON bd.location_id = l.location_id
     WHERE bd.blood_group = v_blood_group
       AND bd.is_available = 1
       AND (bd.last_donation_date IS NULL OR bd.last_donation_date <= DATE_SUB(CURDATE(), INTERVAL 90 DAY))
     ORDER BY proximity ASC, bd.last_donation_date ASC
     LIMIT 20;
END//

-- ---------------------------------------------------------------------
-- PROCEDURE 4: Find a suitable shelter for a given disaster - ranks
-- shelters by available capacity, medical facility, and same location.
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_find_shelter(IN p_disaster_id INT, IN p_people_needed INT)
BEGIN
    DECLARE v_location_id INT;
    SELECT location_id INTO v_location_id FROM disasters WHERE disaster_id = p_disaster_id;

    SELECT s.shelter_id, s.shelter_name, l.district_name,
           s.total_capacity, s.occupied_capacity,
           (s.total_capacity - s.occupied_capacity) AS available_capacity,
           s.has_medical_facility, s.has_water, s.has_food, s.shelter_status,
           CASE WHEN s.location_id = v_location_id THEN 'Same District' ELSE 'Other District' END AS proximity
      FROM shelters s
      JOIN locations l ON s.location_id = l.location_id
     WHERE s.shelter_status <> 'Closed'
       AND (s.total_capacity - s.occupied_capacity) >= p_people_needed
     ORDER BY proximity ASC, s.has_medical_facility DESC, available_capacity DESC
     LIMIT 10;
END//

-- ---------------------------------------------------------------------
-- PROCEDURE 5: Generate a comprehensive disaster summary report.
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_disaster_summary(IN p_disaster_id INT)
BEGIN
    SELECT d.disaster_id, d.disaster_name, dt.type_name, l.district_name, l.division_name,
           d.status, d.severity_level, d.severity_score, d.estimated_affected,
           d.infrastructure_damage_pct, d.reported_at,
           (SELECT COUNT(*) FROM affected_areas a WHERE a.disaster_id = d.disaster_id) AS total_areas,
           (SELECT COUNT(*) FROM victims v WHERE v.disaster_id = d.disaster_id) AS total_victims,
           (SELECT COUNT(*) FROM victims v WHERE v.disaster_id = d.disaster_id AND v.condition_status = 'Deceased') AS deceased,
           (SELECT COUNT(*) FROM victims v WHERE v.disaster_id = d.disaster_id AND v.rescue_status = 'Rescued') AS rescued,
           (SELECT COUNT(*) FROM missing_persons m WHERE m.disaster_id = d.disaster_id AND m.status = 'Missing') AS still_missing,
           (SELECT COUNT(*) FROM rescue_assignments ra WHERE ra.disaster_id = d.disaster_id) AS teams_assigned,
           (SELECT COUNT(*) FROM rescue_missions rm WHERE rm.disaster_id = d.disaster_id) AS total_missions,
           (SELECT COALESCE(SUM(rd.distributed_quantity),0) FROM relief_distribution rd WHERE rd.disaster_id = d.disaster_id) AS relief_units_distributed,
           (SELECT COALESCE(SUM(sa.people_count),0) FROM shelter_allocations sa WHERE sa.disaster_id = d.disaster_id) AS people_sheltered,
           (SELECT COALESCE(SUM(br.required_units),0) FROM blood_requests br WHERE br.disaster_id = d.disaster_id) AS blood_units_requested
      FROM disasters d
      JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id
      JOIN locations l ON d.location_id = l.location_id
     WHERE d.disaster_id = p_disaster_id;
END//

-- ---------------------------------------------------------------------
-- PROCEDURE 6: Process a relief distribution as a single transaction -
-- checks stock, inserts distribution, updates inventory, and reports
-- whether a low-stock alert was triggered. Demonstrates COMMIT/ROLLBACK.
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_distribute_relief(
    IN p_disaster_id INT, IN p_area_id INT, IN p_item_id INT,
    IN p_quantity INT, IN p_user_id INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_min INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT current_stock, minimum_stock INTO v_stock, v_min
      FROM relief_items WHERE item_id = p_item_id FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Relief item not found';
    ELSEIF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock to distribute requested quantity';
    END IF;

    INSERT INTO relief_distribution (disaster_id, area_id, item_id, distributed_quantity, distributed_by)
    VALUES (p_disaster_id, p_area_id, p_item_id, p_quantity, p_user_id);
    -- trigger trg_relief_distribution_after also decrements stock; the FOR UPDATE lock
    -- above ensures no race condition between the check and the trigger's update.

    COMMIT;

    SELECT item_id, current_stock, minimum_stock,
           (current_stock <= minimum_stock) AS low_stock_alert
      FROM relief_items WHERE item_id = p_item_id;
END//

DELIMITER ;
