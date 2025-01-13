-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create jobs table
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    logo_url TEXT,
    location VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL,
    salary_range VARCHAR(100),
    type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create towns table
CREATE TABLE towns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create job_types table
CREATE TABLE job_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create tags table
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for jobs table
CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert mock job types
INSERT INTO job_types (name) VALUES
    ('Full-time'),
    ('Part-time'),
    ('Contract'),
    ('Remote'),
    ('Internship');

-- Insert mock tags
INSERT INTO tags (name) VALUES
    ('JavaScript'),
    ('Python'),
    ('React'),
    ('Node.js'),
    ('Flutter'),
    ('DevOps'),
    ('UI/UX'),
    ('Database'),
    ('Cloud'),
    ('Mobile');

-- Insert mock towns and regions
INSERT INTO towns (name, region) VALUES
    ('Dakar', 'Dakar'),
    ('Thiès', 'Thiès'),
    ('Saint-Louis', 'Saint-Louis'),
    ('Ziguinchor', 'Ziguinchor'),
    ('Mbour', 'Thiès'),
    ('Rufisque', 'Dakar'),
    ('Kaolack', 'Kaolack'),
    ('Touba', 'Diourbel'),
    ('Diourbel', 'Diourbel'),
    ('Louga', 'Louga');

-- Insert mock jobs
INSERT INTO jobs (
    title,
    company,
    location,
    region,
    salary_range,
    type,
    description,
    requirements,
    contact_email,
    contact_phone,
    tags
) VALUES
(
    'Senior Flutter Developer',
    'TechSenegal',
    'Dakar',
    'Dakar',
    '1,500,000 - 2,500,000 FCFA',
    'Full-time',
    'We are looking for an experienced Flutter developer to join our mobile development team. You will be responsible for developing and maintaining our cross-platform mobile applications.',
    '- 3+ years of Flutter development experience\n- Strong knowledge of Dart programming language\n- Experience with state management solutions\n- Good understanding of REST APIs',
    'careers@techsenegal.com',
    '+221 77 123 4567',
    ARRAY['Flutter', 'Mobile']
),
(
    'Frontend React Developer',
    'AfriTech Solutions',
    'Saint-Louis',
    'Saint-Louis',
    '800,000 - 1,500,000 FCFA',
    'Full-time',
    'Join our team as a Frontend Developer working with React. You will be responsible for building user interfaces for our web applications.',
    '- 2+ years of React development experience\n- Proficiency in JavaScript/ES6\n- Experience with Redux\n- Knowledge of modern frontend tools',
    'hr@afritech.sn',
    '+221 78 234 5678',
    ARRAY['JavaScript', 'React']
),
(
    'DevOps Engineer',
    'SenCloud',
    'Thiès',
    'Thiès',
    '2,000,000 - 3,000,000 FCFA',
    'Contract',
    'Looking for a DevOps engineer to help us improve our deployment processes and infrastructure management.',
    '- Experience with AWS or similar cloud platforms\n- Knowledge of Docker and Kubernetes\n- Scripting skills (Python, Bash)\n- CI/CD pipeline experience',
    'jobs@sencloud.sn',
    '+221 76 345 6789',
    ARRAY['DevOps', 'Cloud']
),
(
    'UI/UX Design Intern',
    'DesignHub Senegal',
    'Dakar',
    'Dakar',
    '250,000 - 400,000 FCFA',
    'Internship',
    'Join our design team as an intern and learn about modern UI/UX design practices while working on real projects.',
    '- Basic knowledge of design tools (Figma, Adobe XD)\n- Understanding of UI/UX principles\n- Strong creative skills\n- Good communication abilities',
    'internships@designhub.sn',
    '+221 75 456 7890',
    ARRAY['UI/UX']
),
(
    'Backend Python Developer',
    'DataTech Senegal',
    'Mbour',
    'Thiès',
    '1,200,000 - 2,000,000 FCFA',
    'Remote',
    'We are seeking a Python developer to work on our data processing backend services.',
    '- 3+ years Python development experience\n- Experience with Django or FastAPI\n- Database design skills\n- API development experience',
    'careers@datatech.sn',
    '+221 77 567 8901',
    ARRAY['Python', 'Database']
);

-- Create RLS policies
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE towns ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

-- Create policies for public access
CREATE POLICY "Allow public read access" ON jobs FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON towns FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON job_types FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON tags FOR SELECT USING (true);
