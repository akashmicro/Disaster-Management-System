-- =====================================================================
-- 03_constraints_indexes.sql
-- Additional indexes for frequently searched / joined columns.
-- (PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT are already defined in 02_create_tables.sql)
-- =====================================================================
USE disaster_management_db;

-- Disasters are searched constantly by status, location, date, type
CREATE INDEX idx_disaster_status       ON disasters(status);
CREATE INDEX idx_disaster_location     ON disasters(location_id);
CREATE INDEX idx_disaster_reported_at  ON disasters(reported_at);
CREATE INDEX idx_disaster_type         ON disasters(disaster_type_id);
CREATE INDEX idx_disaster_severity     ON disasters(severity_level);

-- Victims / missing persons are always filtered by disaster and area
CREATE INDEX idx_victims_disaster      ON victims(disaster_id);
CREATE INDEX idx_victims_area          ON victims(area_id);
CREATE INDEX idx_victims_condition     ON victims(condition_status);

CREATE INDEX idx_missing_disaster      ON missing_persons(disaster_id);
CREATE INDEX idx_missing_status        ON missing_persons(status);

-- Blood donor lookup is keyed on blood group + availability + location
CREATE INDEX idx_donor_bloodgroup      ON blood_donors(blood_group);
CREATE INDEX idx_donor_availability    ON blood_donors(is_available);
CREATE INDEX idx_donor_location        ON blood_donors(location_id);

-- Relief stock alerting scans item stock levels often
CREATE INDEX idx_relief_item_stock     ON relief_items(current_stock);

-- Rescue teams / vehicles filtered by availability & specialization
CREATE INDEX idx_team_availability     ON rescue_teams(availability_status);
CREATE INDEX idx_team_specialization   ON rescue_teams(specialization);
CREATE INDEX idx_vehicle_status        ON rescue_vehicles(vehicle_status);

-- Shelters filtered by status
CREATE INDEX idx_shelter_status        ON shelters(shelter_status);

-- Missions frequently filtered by disaster and status
CREATE INDEX idx_mission_disaster      ON rescue_missions(disaster_id);
CREATE INDEX idx_mission_status        ON rescue_missions(mission_status);
