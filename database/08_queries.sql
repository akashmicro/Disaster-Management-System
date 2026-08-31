-- =====================================================================
-- 08_queries.sql
-- Demonstration of required SQL features for the DBMS Lab (Section 17 & 27)
-- Every query is documented with its purpose; used by the
-- "SQL Operations / Reports" page and the analytics module.
-- =====================================================================
USE disaster_management_db;

-- Q1. Basic SELECT / WHERE / ORDER BY -----------------------------------
-- Purpose: List all critical disasters, most recent first.
SELECT disaster_id, disaster_name, severity_level, reported_at
FROM disasters
WHERE severity_level = 'CRITICAL'
ORDER BY reported_at DESC;

-- Q2. GROUP BY / HAVING / COUNT ------------------------------------------
-- Purpose: Disaster type that occurs most frequently (Investigation Q1).
SELECT dt.type_name, COUNT(*) AS total_occurrences
FROM disasters d
JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id
GROUP BY dt.type_name
HAVING COUNT(*) >= 1
ORDER BY total_occurrences DESC;

-- Q3. Multiple JOIN + Aggregate ------------------------------------------
-- Purpose: Location with the highest number of affected people (Investigation Q2).
SELECT l.district_name, SUM(d.estimated_affected) AS total_affected
FROM disasters d
JOIN locations l ON d.location_id = l.location_id
GROUP BY l.district_name
ORDER BY total_affected DESC
LIMIT 5;

-- Q4. Subquery in WHERE ---------------------------------------------------
-- Purpose: Disaster(s) with the highest severity score (Investigation Q3).
SELECT disaster_id, disaster_name, severity_score
FROM disasters
WHERE severity_score = (SELECT MAX(severity_score) FROM disasters);

-- Q5. Correlated subquery -------------------------------------------------
-- Purpose: Rescue team that completed the most missions (Investigation Q4).
SELECT rt.team_id, rt.team_name,
       (SELECT COUNT(*) FROM rescue_missions rm
         WHERE rm.team_id = rt.team_id AND rm.mission_status = 'Completed') AS completed_missions
FROM rescue_teams rt
ORDER BY completed_missions DESC
LIMIT 5;

-- Q6. HAVING with aggregate ------------------------------------------------
-- Purpose: Shelter with the highest occupancy percentage (Investigation Q5).
SELECT s.shelter_name, s.total_capacity, s.occupied_capacity,
       ROUND((s.occupied_capacity / s.total_capacity) * 100, 2) AS occupancy_pct
FROM shelters s
GROUP BY s.shelter_id, s.shelter_name, s.total_capacity, s.occupied_capacity
HAVING occupancy_pct > 50
ORDER BY occupancy_pct DESC;

-- Q7. GROUP BY + SUM ---------------------------------------------------------
-- Purpose: Blood group with the highest total demand (Investigation Q6).
SELECT blood_group, SUM(required_units) AS total_units_requested
FROM blood_requests
GROUP BY blood_group
ORDER BY total_units_requested DESC;

-- Q8. Subquery with IN --------------------------------------------------------
-- Purpose: Relief items that have fallen below minimum stock (Investigation Q7).
SELECT item_name, current_stock, minimum_stock
FROM relief_items
WHERE item_id IN (SELECT item_id FROM relief_items WHERE current_stock <= minimum_stock);

-- Q9. Date functions + GROUP BY -----------------------------------------------
-- Purpose: Month with the highest disaster frequency (Investigation Q8).
SELECT DATE_FORMAT(reported_at, '%Y-%m') AS report_month, COUNT(*) AS disaster_count
FROM disasters
GROUP BY report_month
ORDER BY disaster_count DESC;

-- Q10. CASE + aggregate ---------------------------------------------------------
-- Purpose: Percentage of victims rescued (Investigation Q9).
SELECT
    SUM(CASE WHEN rescue_status = 'Rescued' THEN 1 ELSE 0 END) AS rescued,
    COUNT(*) AS total_victims,
    ROUND(SUM(CASE WHEN rescue_status = 'Rescued' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS rescue_pct
FROM victims;

-- Q11. GROUP BY + ORDER BY -------------------------------------------------------
-- Purpose: Area with the highest critical victim count (Investigation Q10).
SELECT aa.area_name, aa.critical_count
FROM affected_areas aa
ORDER BY aa.critical_count DESC
LIMIT 5;

-- Q12. INNER JOIN --------------------------------------------------------------
-- Purpose: List every disaster with its type and district in one row.
SELECT d.disaster_name, dt.type_name, l.district_name
FROM disasters d
INNER JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id
INNER JOIN locations l ON d.location_id = l.location_id;

-- Q13. LEFT JOIN ------------------------------------------------------------------
-- Purpose: Show every rescue team even if it has zero assignments.
SELECT rt.team_name, COUNT(ra.assignment_id) AS assignments
FROM rescue_teams rt
LEFT JOIN rescue_assignments ra ON rt.team_id = ra.team_id
GROUP BY rt.team_name
ORDER BY assignments ASC;

-- Q14. RIGHT JOIN -------------------------------------------------------------------
-- Purpose: Show every relief item and its distribution history (RIGHT JOIN form).
SELECT rd.distribution_id, rd.distributed_quantity, ri.item_name
FROM relief_distribution rd
RIGHT JOIN relief_items ri ON rd.item_id = ri.item_id
ORDER BY ri.item_name;

-- Q15. SELF JOIN ----------------------------------------------------------------------
-- Purpose: Pair up disasters that occurred in the same district (comparative analysis).
SELECT d1.disaster_name AS disaster_a, d2.disaster_name AS disaster_b, d1.location_id
FROM disasters d1
JOIN disasters d2 ON d1.location_id = d2.location_id AND d1.disaster_id < d2.disaster_id
ORDER BY d1.location_id
LIMIT 20;

-- Q16. EXISTS -------------------------------------------------------------------------
-- Purpose: Disasters that currently have at least one open, unfulfilled blood request.
SELECT d.disaster_id, d.disaster_name
FROM disasters d
WHERE EXISTS (
    SELECT 1 FROM blood_requests br
    WHERE br.disaster_id = d.disaster_id AND br.request_status = 'Open'
);

-- Q17. NOT EXISTS ----------------------------------------------------------------------
-- Purpose: Disasters that have NOT yet had any rescue team assigned.
SELECT d.disaster_id, d.disaster_name
FROM disasters d
WHERE NOT EXISTS (
    SELECT 1 FROM rescue_assignments ra WHERE ra.disaster_id = d.disaster_id
);

-- Q18. BETWEEN --------------------------------------------------------------------------
-- Purpose: Disasters reported within a specific date range.
SELECT disaster_name, reported_at
FROM disasters
WHERE reported_at BETWEEN '2023-06-01' AND '2023-12-31'
ORDER BY reported_at;

-- Q19. LIKE + string function ------------------------------------------------------------
-- Purpose: Search disasters whose name contains "Flood" (case-insensitive search feature).
SELECT disaster_name FROM disasters WHERE disaster_name LIKE '%Flood%';

-- Q20. DISTINCT -----------------------------------------------------------------------------
-- Purpose: List every unique blood group currently requested.
SELECT DISTINCT blood_group FROM blood_requests;

-- Q21. NULL handling ---------------------------------------------------------------------------
-- Purpose: Missions that have not yet ended (still ongoing).
SELECT mission_id, mission_type, start_time
FROM rescue_missions
WHERE end_time IS NULL;

-- Q22. Aggregate MIN/MAX/AVG -----------------------------------------------------------------------
-- Purpose: Overview of disaster impact (used on the analytics dashboard cards).
SELECT MIN(estimated_affected) AS min_affected, MAX(estimated_affected) AS max_affected,
       ROUND(AVG(estimated_affected), 0) AS avg_affected
FROM disasters;

-- Q23. GROUP BY multiple columns + CASE -------------------------------------------------------------
-- Purpose: Victim condition distribution per disaster severity level (dashboard chart).
SELECT d.severity_level, v.condition_status, COUNT(*) AS total
FROM victims v
JOIN disasters d ON v.disaster_id = d.disaster_id
GROUP BY d.severity_level, v.condition_status
ORDER BY d.severity_level, total DESC;
