-- Create the database
CREATE DATABASE IF NOT EXISTS afrijob_db;
USE afrijob_db;

-- Companies table
CREATE TABLE companies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    logo_url VARCHAR(255),
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Jobs table
CREATE TABLE jobs (
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
CREATE TABLE tags (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Job tags relation table
CREATE TABLE job_tags (
    job_id INT,
    tag_id INT,
    PRIMARY KEY (job_id, tag_id),
    FOREIGN KEY (job_id) REFERENCES jobs(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);

-- Insert some sample data
INSERT INTO companies (name, logo_url, location) VALUES
('Apple Computer, Inc', '/assets/logos/apple.png', 'Mountain View, CA'),
('Google Inc', '/assets/logos/google.png', 'California, USA');

INSERT INTO tags (name) VALUES
('Frontend'),
('Remote'),
('Senior'),
('Junior'),
('Full-time');

INSERT INTO jobs (company_id, title, description, salary_min, salary_max, job_type, location, applicants_count)
VALUES
(1, 'Junior Front End Developer', 'Work together with other front-end developers to build the user interface of mobile applications and website. They showcase their skills with the application\'s visual elements, including graphics, typography, and layouts.', 50000, 100000, 'Full-time', 'Mountain View, CA', 1468),
(2, 'Senior Front End Developer', 'Lead the frontend development team and architect scalable solutions', 50000, 100000, 'Remote', 'Remote', 2254);
