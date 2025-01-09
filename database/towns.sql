-- Create towns table
CREATE TABLE IF NOT EXISTS towns (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert major Cameroonian towns
INSERT INTO towns (name, region) VALUES
-- Adamawa Region
('Ngaoundéré', 'Adamawa'),
('Banyo', 'Adamawa'),
('Tibati', 'Adamawa'),
('Meiganga', 'Adamawa'),

-- Centre Region
('Yaoundé', 'Centre'),
('Mbalmayo', 'Centre'),
('Obala', 'Centre'),
('Bafia', 'Centre'),

-- East Region
('Bertoua', 'East'),
('Abong-Mbang', 'East'),
('Yokadouma', 'East'),
('Batouri', 'East'),

-- Far North Region
('Maroua', 'Far North'),
('Kousseri', 'Far North'),
('Mokolo', 'Far North'),
('Yagoua', 'Far North'),

-- Littoral Region
('Douala', 'Littoral'),
('Nkongsamba', 'Littoral'),
('Edéa', 'Littoral'),
('Loum', 'Littoral'),

-- North Region
('Garoua', 'North'),
('Guider', 'North'),
('Poli', 'North'),
('Tcholliré', 'North'),

-- Northwest Region
('Bamenda', 'Northwest'),
('Kumbo', 'Northwest'),
('Nkambé', 'Northwest'),
('Wum', 'Northwest'),

-- South Region
('Ebolowa', 'South'),
('Kribi', 'South'),
('Sangmélima', 'South'),
('Ambam', 'South'),

-- Southwest Region
('Buea', 'Southwest'),
('Limbe', 'Southwest'),
('Kumba', 'Southwest'),
('Tiko', 'Southwest'),

-- West Region
('Bafoussam', 'West'),
('Dschang', 'West'),
('Foumban', 'West'),
('Mbouda', 'West');

-- Add foreign key to jobs table
ALTER TABLE jobs ADD COLUMN town_id INT;
ALTER TABLE jobs ADD FOREIGN KEY (town_id) REFERENCES towns(id);

-- Create an API endpoint to get towns
CREATE VIEW towns_by_region AS
SELECT 
    id,
    name,
    region,
    COUNT(*) OVER (PARTITION BY region) as towns_in_region
FROM towns
ORDER BY region, name;
