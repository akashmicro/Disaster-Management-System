-- =====================================================================
-- 02_create_tables.sql
-- Disaster Management System - Table Definitions (3NF)
-- =====================================================================
USE disaster_management_db;

-- ---------------------------------------------------------------------
-- 1. users  (system login / role based access)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    user_id         INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100)    NOT NULL,
    username        VARCHAR(50)     NOT NULL UNIQUE,
    email           VARCHAR(150)    UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    role            ENUM('Admin','Disaster Officer','Rescue Coordinator',
                          'Relief Officer','Medical Officer') NOT NULL,
    phone           VARCHAR(20),
    is_active       TINYINT(1)      NOT NULL DEFAULT 1,
    is_verified     TINYINT(1)      NOT NULL DEFAULT 1,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 2. disaster_types  (lookup table -> removes repeating text, 2NF/3NF)
-- ---------------------------------------------------------------------
CREATE TABLE disaster_types (
    disaster_type_id  INT AUTO_INCREMENT PRIMARY KEY,
    type_name         VARCHAR(50)  NOT NULL UNIQUE,
    description       VARCHAR(255)
);

-- ---------------------------------------------------------------------
-- 3. locations  (lookup table for districts/areas of Bangladesh)
-- ---------------------------------------------------------------------
CREATE TABLE locations (
    location_id     INT AUTO_INCREMENT PRIMARY KEY,
    district_name   VARCHAR(80)  NOT NULL,
    division_name   VARCHAR(80)  NOT NULL,
    zone_type       ENUM('Coastal','Flood-Prone','Cyclone-Prone','Hilly','Urban','Riverine')
                    NOT NULL DEFAULT 'Urban',
    latitude        DECIMAL(9,6),
    longitude       DECIMAL(9,6),
    UNIQUE KEY uq_location (district_name, division_name)
);

-- ---------------------------------------------------------------------
-- 4. disasters  (main transaction entity)
-- ---------------------------------------------------------------------
CREATE TABLE disasters (
    disaster_id           INT AUTO_INCREMENT PRIMARY KEY,
    disaster_name         VARCHAR(120) NOT NULL,
    disaster_type_id      INT NOT NULL,
    location_id           INT NOT NULL,
    reported_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description            TEXT,
    estimated_affected      INT NOT NULL DEFAULT 0 CHECK (estimated_affected >= 0),
    infrastructure_damage_pct DECIMAL(5,2) NOT NULL DEFAULT 0
                            CHECK (infrastructure_damage_pct BETWEEN 0 AND 100),
    severity_score         DECIMAL(6,2) DEFAULT 0,
    severity_level         ENUM('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT 'LOW',
    status                  ENUM('Reported','Under Assessment','Active Response',
                                 'Partially Controlled','Resolved') NOT NULL DEFAULT 'Reported',
    reported_by             INT,
    CONSTRAINT fk_dis_type FOREIGN KEY (disaster_type_id) REFERENCES disaster_types(disaster_type_id),
    CONSTRAINT fk_dis_loc  FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT fk_dis_user FOREIGN KEY (reported_by) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------
-- 5. affected_areas
-- ---------------------------------------------------------------------
CREATE TABLE affected_areas (
    area_id                 INT AUTO_INCREMENT PRIMARY KEY,
    disaster_id             INT NOT NULL,
    location_id              INT NOT NULL,
    area_name                VARCHAR(100) NOT NULL,
    population                INT NOT NULL DEFAULT 0,
    affected_population       INT NOT NULL DEFAULT 0,
    injured_count             INT NOT NULL DEFAULT 0,
    critical_count             INT NOT NULL DEFAULT 0,
    infrastructure_damage_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
    accessibility_status       ENUM('Accessible','Partially Accessible','Inaccessible') DEFAULT 'Accessible',
    CONSTRAINT fk_area_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE,
    CONSTRAINT fk_area_loc FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- ---------------------------------------------------------------------
-- 6. victims
-- ---------------------------------------------------------------------
CREATE TABLE victims (
    victim_id        INT AUTO_INCREMENT PRIMARY KEY,
    disaster_id       INT NOT NULL,
    area_id            INT NOT NULL,
    full_name          VARCHAR(100) NOT NULL,
    age                 INT CHECK (age BETWEEN 0 AND 120),
    gender              ENUM('Male','Female','Other') NOT NULL,
    condition_status    ENUM('Safe','Injured','Critical','Hospitalized','Rescued','Deceased')
                        NOT NULL DEFAULT 'Safe',
    medical_priority     ENUM('None','Low','Medium','High') DEFAULT 'None',
    rescue_status         ENUM('Not Rescued','In Progress','Rescued') DEFAULT 'Not Rescued',
    CONSTRAINT fk_vic_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE,
    CONSTRAINT fk_vic_area FOREIGN KEY (area_id) REFERENCES affected_areas(area_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 7. missing_persons
-- ---------------------------------------------------------------------
CREATE TABLE missing_persons (
    missing_id         INT AUTO_INCREMENT PRIMARY KEY,
    disaster_id          INT NOT NULL,
    area_id                INT NOT NULL,
    full_name              VARCHAR(100) NOT NULL,
    age                     INT CHECK (age BETWEEN 0 AND 120),
    gender                  ENUM('Male','Female','Other') NOT NULL,
    last_seen_location       VARCHAR(150),
    missing_date              DATE NOT NULL,
    description                VARCHAR(255),
    status                      ENUM('Missing','Located','Rescued','Reunited') DEFAULT 'Missing',
    CONSTRAINT fk_mp_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE,
    CONSTRAINT fk_mp_area FOREIGN KEY (area_id) REFERENCES affected_areas(area_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 8. rescue_teams
-- ---------------------------------------------------------------------
CREATE TABLE rescue_teams (
    team_id            INT AUTO_INCREMENT PRIMARY KEY,
    team_name           VARCHAR(100) NOT NULL UNIQUE,
    team_type            VARCHAR(50) NOT NULL,
    specialization         ENUM('Flood Rescue','Medical Rescue','Fire Rescue','Mountain Rescue',
                                'Search & Rescue','Emergency Medical Team') NOT NULL,
    team_leader             VARCHAR(100),
    member_count             INT NOT NULL DEFAULT 0 CHECK (member_count >= 0),
    current_location_id       INT,
    availability_status         ENUM('Available','Deployed','Unavailable') NOT NULL DEFAULT 'Available',
    contact_number             VARCHAR(20),
    CONSTRAINT fk_team_loc FOREIGN KEY (current_location_id) REFERENCES locations(location_id)
);

-- ---------------------------------------------------------------------
-- 9. team_members
-- ---------------------------------------------------------------------
CREATE TABLE team_members (
    member_id       INT AUTO_INCREMENT PRIMARY KEY,
    team_id          INT NOT NULL,
    full_name         VARCHAR(100) NOT NULL,
    designation        VARCHAR(60),
    phone               VARCHAR(20),
    CONSTRAINT fk_tm_team FOREIGN KEY (team_id) REFERENCES rescue_teams(team_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 10. rescue_assignments (junction: disaster <-> rescue_teams, M:N)
-- ---------------------------------------------------------------------
CREATE TABLE rescue_assignments (
    assignment_id      INT AUTO_INCREMENT PRIMARY KEY,
    disaster_id          INT NOT NULL,
    team_id                INT NOT NULL,
    area_id                  INT,
    assigned_at                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignment_status           ENUM('Assigned','En Route','On Site','Completed') DEFAULT 'Assigned',
    CONSTRAINT fk_ra_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE,
    CONSTRAINT fk_ra_team FOREIGN KEY (team_id) REFERENCES rescue_teams(team_id) ON DELETE CASCADE,
    CONSTRAINT fk_ra_area FOREIGN KEY (area_id) REFERENCES affected_areas(area_id),
    UNIQUE KEY uq_assignment (disaster_id, team_id)
);

-- ---------------------------------------------------------------------
-- 11. shelters
-- ---------------------------------------------------------------------
CREATE TABLE shelters (
    shelter_id         INT AUTO_INCREMENT PRIMARY KEY,
    shelter_name          VARCHAR(100) NOT NULL,
    location_id             INT NOT NULL,
    total_capacity            INT NOT NULL CHECK (total_capacity >= 0),
    occupied_capacity           INT NOT NULL DEFAULT 0 CHECK (occupied_capacity >= 0),
    has_medical_facility          TINYINT(1) NOT NULL DEFAULT 0,
    has_water                       TINYINT(1) NOT NULL DEFAULT 1,
    has_food                          TINYINT(1) NOT NULL DEFAULT 1,
    shelter_status                     ENUM('Open','Full','Closed') NOT NULL DEFAULT 'Open',
    CONSTRAINT fk_shelter_loc FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT chk_shelter_capacity CHECK (occupied_capacity <= total_capacity)
);

-- ---------------------------------------------------------------------
-- 12. shelter_allocations (junction: victims/disaster <-> shelters)
-- ---------------------------------------------------------------------
CREATE TABLE shelter_allocations (
    allocation_id       INT AUTO_INCREMENT PRIMARY KEY,
    shelter_id             INT NOT NULL,
    disaster_id               INT NOT NULL,
    victim_id                   INT,
    people_count                  INT NOT NULL DEFAULT 1 CHECK (people_count > 0),
    allocated_at                    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sa_shelter FOREIGN KEY (shelter_id) REFERENCES shelters(shelter_id) ON DELETE CASCADE,
    CONSTRAINT fk_sa_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE,
    CONSTRAINT fk_sa_victim FOREIGN KEY (victim_id) REFERENCES victims(victim_id) ON DELETE SET NULL
);

-- ---------------------------------------------------------------------
-- 13. blood_donors
-- ---------------------------------------------------------------------
CREATE TABLE blood_donors (
    donor_id             INT AUTO_INCREMENT PRIMARY KEY,
    full_name               VARCHAR(100) NOT NULL,
    blood_group                ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    phone                         VARCHAR(20) NOT NULL,
    location_id                     INT NOT NULL,
    is_available                       TINYINT(1) NOT NULL DEFAULT 1,
    last_donation_date                    DATE,
    CONSTRAINT fk_donor_loc FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- ---------------------------------------------------------------------
-- 14. blood_requests
-- ---------------------------------------------------------------------
CREATE TABLE blood_requests (
    request_id           INT AUTO_INCREMENT PRIMARY KEY,
    disaster_id             INT NOT NULL,
    hospital_name              VARCHAR(120) NOT NULL,
    blood_group                   ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    required_units                   INT NOT NULL CHECK (required_units > 0),
    urgency                             ENUM('Low','Medium','High','Critical') NOT NULL DEFAULT 'Medium',
    request_date                          DATE NOT NULL,
    request_status                          ENUM('Open','Partially Fulfilled','Fulfilled','Cancelled')
                                            NOT NULL DEFAULT 'Open',
    CONSTRAINT fk_br_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 15. relief_items  (also holds current stock -> avoids extra 1:1 table)
-- ---------------------------------------------------------------------
CREATE TABLE relief_items (
    item_id           INT AUTO_INCREMENT PRIMARY KEY,
    item_name             VARCHAR(80) NOT NULL UNIQUE,
    category                 ENUM('Food','Water','Medicine','Shelter Material','Clothing','Baby Care','First Aid')
                             NOT NULL,
    unit                       VARCHAR(20) NOT NULL,
    current_stock                INT NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    minimum_stock                   INT NOT NULL DEFAULT 0,
    maximum_stock                     INT NOT NULL DEFAULT 0
);

-- ---------------------------------------------------------------------
-- 16. relief_distribution
-- ---------------------------------------------------------------------
CREATE TABLE relief_distribution (
    distribution_id      INT AUTO_INCREMENT PRIMARY KEY,
    disaster_id              INT NOT NULL,
    area_id                     INT,
    item_id                       INT NOT NULL,
    distributed_quantity             INT NOT NULL CHECK (distributed_quantity > 0),
    distributed_at                     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    distributed_by                       INT,
    CONSTRAINT fk_rd_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE,
    CONSTRAINT fk_rd_area FOREIGN KEY (area_id) REFERENCES affected_areas(area_id),
    CONSTRAINT fk_rd_item FOREIGN KEY (item_id) REFERENCES relief_items(item_id),
    CONSTRAINT fk_rd_user FOREIGN KEY (distributed_by) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------
-- 17. rescue_vehicles
-- ---------------------------------------------------------------------
CREATE TABLE rescue_vehicles (
    vehicle_id           INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number            VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type                 ENUM('Ambulance','Rescue Boat','Fire Truck','Rescue Truck',
                                       'Helicopter','Emergency Van') NOT NULL,
    capacity                       INT NOT NULL DEFAULT 0,
    current_location_id               INT,
    vehicle_status                       ENUM('Available','Assigned','On Mission','Maintenance')
                                          NOT NULL DEFAULT 'Available',
    fuel_status                             ENUM('Full','Medium','Low','Empty') NOT NULL DEFAULT 'Full',
    CONSTRAINT fk_veh_loc FOREIGN KEY (current_location_id) REFERENCES locations(location_id)
);

-- ---------------------------------------------------------------------
-- 18. rescue_missions
-- ---------------------------------------------------------------------
CREATE TABLE rescue_missions (
    mission_id           INT AUTO_INCREMENT PRIMARY KEY,
    disaster_id             INT NOT NULL,
    team_id                    INT NOT NULL,
    vehicle_id                    INT NOT NULL,
    mission_type                     VARCHAR(60) NOT NULL,
    start_time                          DATETIME NOT NULL,
    end_time                               DATETIME,
    source_location                           VARCHAR(120),
    destination                                  VARCHAR(120),
    mission_status                                  ENUM('Planned','Ongoing','Completed','Aborted')
                                                     NOT NULL DEFAULT 'Planned',
    mission_result                                     VARCHAR(255),
    CONSTRAINT fk_rm_dis FOREIGN KEY (disaster_id) REFERENCES disasters(disaster_id) ON DELETE CASCADE,
    CONSTRAINT fk_rm_team FOREIGN KEY (team_id) REFERENCES rescue_teams(team_id),
    CONSTRAINT fk_rm_veh FOREIGN KEY (vehicle_id) REFERENCES rescue_vehicles(vehicle_id)
);
