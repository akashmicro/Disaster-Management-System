-- =====================================================================
-- 05_triggers.sql
-- Business-logic triggers for the Disaster Response Intelligence Engine
-- =====================================================================
USE disaster_management_db;

DELIMITER //

-- ---------------------------------------------------------------------
-- TRIGGER 1: Automatically calculate disaster severity on INSERT
-- severity_score = weighted combination of affected population,
-- infrastructure damage, victims and missing persons (victims/missing
-- do not exist yet at insert time, so this initial score uses affected
-- population + damage; it is refined later by the sp_calculate_severity
-- procedure once victims/areas are recorded).
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_disaster_severity_insert
BEFORE INSERT ON disasters
FOR EACH ROW
BEGIN
    DECLARE v_score DECIMAL(6,2);
    SET v_score = (LEAST(NEW.estimated_affected, 100000) / 100000) * 60
                  + (NEW.infrastructure_damage_pct / 100) * 40;
    SET NEW.severity_score = v_score;
    SET NEW.severity_level = CASE
        WHEN v_score >= 75 THEN 'CRITICAL'
        WHEN v_score >= 50 THEN 'HIGH'
        WHEN v_score >= 25 THEN 'MEDIUM'
        ELSE 'LOW'
    END;
END//

-- ---------------------------------------------------------------------
-- TRIGGER 2: Recalculate severity whenever estimated_affected or
-- infrastructure_damage_pct is updated directly on the disaster record.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_disaster_severity_update
BEFORE UPDATE ON disasters
FOR EACH ROW
BEGIN
    DECLARE v_score DECIMAL(6,2);
    IF NEW.estimated_affected <> OLD.estimated_affected
       OR NEW.infrastructure_damage_pct <> OLD.infrastructure_damage_pct THEN
        SET v_score = (LEAST(NEW.estimated_affected, 100000) / 100000) * 60
                      + (NEW.infrastructure_damage_pct / 100) * 40;
        SET NEW.severity_score = v_score;
        SET NEW.severity_level = CASE
            WHEN v_score >= 75 THEN 'CRITICAL'
            WHEN v_score >= 50 THEN 'HIGH'
            WHEN v_score >= 25 THEN 'MEDIUM'
            ELSE 'LOW'
        END;
    END IF;
END//

-- ---------------------------------------------------------------------
-- TRIGGER 3: Automatically decrease relief inventory after distribution
-- and raise an application-level warning (via SIGNAL) if the requested
-- quantity exceeds current stock, preventing negative stock.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_relief_distribution_before
BEFORE INSERT ON relief_distribution
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    SELECT current_stock INTO v_stock FROM relief_items WHERE item_id = NEW.item_id;
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Relief item does not exist';
    ELSEIF v_stock < NEW.distributed_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient relief stock for this distribution';
    END IF;
END//

CREATE TRIGGER trg_relief_distribution_after
AFTER INSERT ON relief_distribution
FOR EACH ROW
BEGIN
    UPDATE relief_items
       SET current_stock = current_stock - NEW.distributed_quantity
     WHERE item_id = NEW.item_id;
    -- LOW STOCK alert is derived live through relief_stock_alert_view (see 07_views.sql)
END//

-- ---------------------------------------------------------------------
-- TRIGGER 4: Prevent shelter over-allocation.
-- Keeps shelters.occupied_capacity in sync and blocks allocation
-- once available capacity is exhausted.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_shelter_allocation_before
BEFORE INSERT ON shelter_allocations
FOR EACH ROW
BEGIN
    DECLARE v_total INT;
    DECLARE v_occupied INT;
    SELECT total_capacity, occupied_capacity INTO v_total, v_occupied
      FROM shelters WHERE shelter_id = NEW.shelter_id FOR UPDATE;

    IF v_total IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Shelter does not exist';
    ELSEIF (v_occupied + NEW.people_count) > v_total THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Shelter allocation exceeds available capacity';
    END IF;
END//

CREATE TRIGGER trg_shelter_allocation_after
AFTER INSERT ON shelter_allocations
FOR EACH ROW
BEGIN
    UPDATE shelters
       SET occupied_capacity = occupied_capacity + NEW.people_count,
           shelter_status = CASE WHEN (occupied_capacity + NEW.people_count) >= total_capacity
                                  THEN 'Full' ELSE shelter_status END
     WHERE shelter_id = NEW.shelter_id;
END//

-- ---------------------------------------------------------------------
-- TRIGGER 5: Prevent assigning an unavailable rescue vehicle to a
-- new mission, and mark the vehicle as "On Mission" once assigned.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_mission_vehicle_before
BEFORE INSERT ON rescue_missions
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT vehicle_status INTO v_status FROM rescue_vehicles WHERE vehicle_id = NEW.vehicle_id;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rescue vehicle does not exist';
    ELSEIF v_status = 'Maintenance' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot assign a vehicle under maintenance';
    ELSEIF v_status = 'On Mission' AND NEW.mission_status IN ('Planned','Ongoing') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle is already on an active mission';
    END IF;
END//

CREATE TRIGGER trg_mission_vehicle_after
AFTER INSERT ON rescue_missions
FOR EACH ROW
BEGIN
    IF NEW.mission_status IN ('Planned','Ongoing') THEN
        UPDATE rescue_vehicles SET vehicle_status = 'On Mission' WHERE vehicle_id = NEW.vehicle_id;
    END IF;
END//

-- ---------------------------------------------------------------------
-- TRIGGER 6: When a mission is marked Completed/Aborted, free the vehicle.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_mission_vehicle_release
AFTER UPDATE ON rescue_missions
FOR EACH ROW
BEGIN
    IF NEW.mission_status IN ('Completed','Aborted') AND OLD.mission_status NOT IN ('Completed','Aborted') THEN
        UPDATE rescue_vehicles SET vehicle_status = 'Available' WHERE vehicle_id = NEW.vehicle_id;
    END IF;
END//

DELIMITER ;
