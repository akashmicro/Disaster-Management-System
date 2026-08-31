-- =====================================================================
-- 07_views.sql
-- =====================================================================
USE disaster_management_db;

-- VIEW 1: active_disasters_view
CREATE OR REPLACE VIEW active_disasters_view AS
SELECT d.disaster_id, d.disaster_name, dt.type_name, l.district_name, l.division_name,
       d.status, d.severity_level, d.severity_score, d.estimated_affected, d.reported_at
  FROM disasters d
  JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id
  JOIN locations l ON d.location_id = l.location_id
 WHERE d.status NOT IN ('Resolved');

-- VIEW 2: disaster_summary_view
CREATE OR REPLACE VIEW disaster_summary_view AS
SELECT d.disaster_id, d.disaster_name, dt.type_name, l.district_name,
       d.severity_level, d.status,
       COUNT(DISTINCT v.victim_id) AS total_victims,
       COUNT(DISTINCT CASE WHEN v.condition_status = 'Deceased' THEN v.victim_id END) AS deceased,
       COUNT(DISTINCT mp.missing_id) AS total_missing,
       COUNT(DISTINCT ra.assignment_id) AS teams_assigned
  FROM disasters d
  JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id
  JOIN locations l ON d.location_id = l.location_id
  LEFT JOIN victims v ON v.disaster_id = d.disaster_id
  LEFT JOIN missing_persons mp ON mp.disaster_id = d.disaster_id
  LEFT JOIN rescue_assignments ra ON ra.disaster_id = d.disaster_id
 GROUP BY d.disaster_id, d.disaster_name, dt.type_name, l.district_name, d.severity_level, d.status;

-- VIEW 3: shelter_status_view
CREATE OR REPLACE VIEW shelter_status_view AS
SELECT s.shelter_id, s.shelter_name, l.district_name, s.total_capacity, s.occupied_capacity,
       (s.total_capacity - s.occupied_capacity) AS available_capacity,
       ROUND((s.occupied_capacity / NULLIF(s.total_capacity,0)) * 100, 2) AS occupancy_pct,
       s.has_medical_facility, s.shelter_status
  FROM shelters s
  JOIN locations l ON s.location_id = l.location_id;

-- VIEW 4: relief_stock_alert_view
CREATE OR REPLACE VIEW relief_stock_alert_view AS
SELECT item_id, item_name, category, unit, current_stock, minimum_stock, maximum_stock,
       ROUND((current_stock / NULLIF(maximum_stock,0)) * 100, 2) AS stock_pct,
       CASE WHEN current_stock <= minimum_stock THEN 'LOW STOCK' ELSE 'OK' END AS stock_alert
  FROM relief_items;

-- VIEW 5: rescue_mission_view
CREATE OR REPLACE VIEW rescue_mission_view AS
SELECT rm.mission_id, rm.disaster_id, d.disaster_name, rt.team_name, rv.vehicle_number, rv.vehicle_type,
       rm.mission_type, rm.start_time, rm.end_time, rm.mission_status, rm.mission_result,
       TIMESTAMPDIFF(HOUR, rm.start_time, COALESCE(rm.end_time, NOW())) AS duration_hours
  FROM rescue_missions rm
  JOIN disasters d ON rm.disaster_id = d.disaster_id
  JOIN rescue_teams rt ON rm.team_id = rt.team_id
  JOIN rescue_vehicles rv ON rm.vehicle_id = rv.vehicle_id;

-- VIEW 6 (bonus): blood_request_status_view
CREATE OR REPLACE VIEW blood_request_status_view AS
SELECT br.request_id, d.disaster_name, br.hospital_name, br.blood_group, br.required_units,
       br.urgency, br.request_status,
       (SELECT COUNT(*) FROM blood_donors bd
         WHERE bd.blood_group = br.blood_group AND bd.is_available = 1) AS available_donors_citywide
  FROM blood_requests br
  JOIN disasters d ON br.disaster_id = d.disaster_id;
