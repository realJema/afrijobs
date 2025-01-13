-- First, drop the foreign key if it exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.table_constraints 
        WHERE constraint_name = 'jobs_town_id_fkey'
    ) THEN
        ALTER TABLE jobs DROP CONSTRAINT jobs_town_id_fkey;
    END IF;
END $$;

-- Add town_id column to jobs table
ALTER TABLE jobs ADD COLUMN town_id UUID REFERENCES towns(id);

-- Copy data from location to town_id (this will need to be handled manually as we need to match locations to town IDs)
-- After data is copied, we can drop the location column
ALTER TABLE jobs DROP COLUMN location;

-- Clear existing towns data
TRUNCATE TABLE towns CASCADE;

-- Insert Cameroon towns
INSERT INTO towns (name, region) VALUES
-- Adamawa Region
('Ngaoundéré', 'Adamawa'),
('Banyo', 'Adamawa'),
('Tibati', 'Adamawa'),
('Meiganga', 'Adamawa'),
('Tignère', 'Adamawa'),

-- Centre Region
('Yaoundé', 'Centre'),
('Mbalmayo', 'Centre'),
('Obala', 'Centre'),
('Nanga Eboko', 'Centre'),
('Bafia', 'Centre'),

-- East Region
('Bertoua', 'East'),
('Abong-Mbang', 'East'),
('Yokadouma', 'East'),
('Batouri', 'East'),
('Belabo', 'East'),

-- Far North Region
('Maroua', 'Far North'),
('Kousseri', 'Far North'),
('Mokolo', 'Far North'),
('Yagoua', 'Far North'),
('Mora', 'Far North'),

-- Littoral Region
('Douala', 'Littoral'),
('Nkongsamba', 'Littoral'),
('Edéa', 'Littoral'),
('Loum', 'Littoral'),
('Manjo', 'Littoral'),

-- North Region
('Garoua', 'North'),
('Guider', 'North'),
('Poli', 'North'),
('Rey Bouba', 'North'),
('Tchollire', 'North'),

-- Northwest Region
('Bamenda', 'Northwest'),
('Kumbo', 'Northwest'),
('Nkambe', 'Northwest'),
('Wum', 'Northwest'),
('Fundong', 'Northwest'),

-- South Region
('Ebolowa', 'South'),
('Kribi', 'South'),
('Sangmélima', 'South'),
('Ambam', 'South'),
('Lolodorf', 'South'),

-- Southwest Region
('Buea', 'Southwest'),
('Limbe', 'Southwest'),
('Kumba', 'Southwest'),
('Mamfe', 'Southwest'),
('Tiko', 'Southwest'),

-- West Region
('Bafoussam', 'West'),
('Dschang', 'West'),
('Mbouda', 'West'),
('Foumban', 'West'),
('Bafang', 'West');
