-- Create the database
CREATE DATABASE IF NOT EXISTS afrijob_db;
USE afrijob_db;

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    logo_url VARCHAR(255),
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Jobs table
CREATE TABLE IF NOT EXISTS jobs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    salary_min DECIMAL(10,2),
    salary_max DECIMAL(10,2),
    job_type ENUM('Full-time', 'Part-time', 'Contract', 'Remote') NOT NULL,
    location VARCHAR(255),
    requirements TEXT,
    applicants_count INT DEFAULT 0,
    status ENUM('active', 'closed') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

-- Tags table for job categories/skills
CREATE TABLE IF NOT EXISTS tags (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Job tags relation table
CREATE TABLE IF NOT EXISTS job_tags (
    job_id INT,
    tag_id INT,
    PRIMARY KEY (job_id, tag_id),
    FOREIGN KEY (job_id) REFERENCES jobs(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);

-- Clear existing data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE job_tags;
TRUNCATE TABLE jobs;
TRUNCATE TABLE companies;
TRUNCATE TABLE tags;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert companies
INSERT INTO companies (name, logo_url, location) VALUES
('Apple Computer, Inc', 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', 'Mountain View, CA'),
('Google Inc', 'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg', 'California, USA'),
('Microsoft Corporation', 'https://upload.wikimedia.org/wikipedia/commons/9/96/Microsoft_logo_%282012%29.svg', 'Redmond, WA'),
('Meta', 'https://upload.wikimedia.org/wikipedia/commons/7/7b/Meta_Platforms_Inc._logo.svg', 'Menlo Park, CA'),
('Amazon', 'https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg', 'Seattle, WA');

-- Insert tags for job categories and skills
INSERT INTO tags (name) VALUES
('Frontend'),
('Backend'),
('Full Stack'),
('Remote'),
('Senior'),
('Junior'),
('React'),
('Flutter'),
('JavaScript'),
('Python'),
('Full-time'),
('Contract');

-- Insert jobs
INSERT INTO jobs (company_id, title, description, salary_min, salary_max, job_type, location, requirements, applicants_count, status) VALUES
(1, 'Junior Front End Developer', 'Work together with other front-end developers to build the user interface of mobile applications and website. They showcase their skills with the application\'s visual elements, including graphics, typography, and layouts.', 50000, 100000, 'Full-time', 'Mountain View, CA', 'HTML, CSS, JavaScript experience required', 1468, 'active'),
(2, 'Senior Front End Developer', 'Lead the frontend development team and architect scalable solutions for our most critical web applications.', 50000, 100000, 'Remote', 'Remote', '5+ years of frontend development experience', 2254, 'active'),
(3, 'Full Stack Developer', 'Build and maintain both frontend and backend components of our enterprise applications.', 70000, 130000, 'Full-time', 'Redmond, WA', 'Experience with React and Node.js', 1897, 'active'),
(4, 'React Native Developer', 'Develop cross-platform mobile applications using React Native framework.', 60000, 110000, 'Remote', 'Remote', 'Strong JavaScript and React Native experience', 1565, 'active'),
(5, 'Frontend Engineer', 'Join our team to create beautiful and responsive web interfaces.', 55000, 95000, 'Full-time', 'Seattle, WA', 'Proficiency in modern JavaScript frameworks', 1123, 'active');

-- Link jobs with tags
INSERT INTO job_tags (job_id, tag_id) VALUES
-- Junior Front End Developer tags
(1, 1), -- Frontend
(1, 6), -- Junior
(1, 9), -- JavaScript
(1, 11), -- Full-time

-- Senior Front End Developer tags
(2, 1), -- Frontend
(2, 5), -- Senior
(2, 4), -- Remote
(2, 9), -- JavaScript

-- Full Stack Developer tags
(3, 3), -- Full Stack
(3, 7), -- React
(3, 11), -- Full-time

-- React Native Developer tags
(4, 7), -- React
(4, 4), -- Remote
(4, 9), -- JavaScript

-- Frontend Engineer tags
(5, 1), -- Frontend
(5, 9), -- JavaScript
(5, 11); -- Full-time
