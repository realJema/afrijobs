-- CreateMigration
BEGIN;

-- Include the SQL from our previous migration file
-- 1. Add missing columns from job_details to jobs
ALTER TABLE jobs
ADD COLUMN IF NOT EXISTS tag_names text[] DEFAULT '{}';

-- 2. Normalize company information
-- First, ensure all companies are in the companies table
INSERT INTO companies (name, logo_url, created_at, updated_at)
SELECT DISTINCT j.company, j.company_logo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM jobs j
LEFT JOIN companies c ON c.name = j.company
WHERE c.id IS NULL;

-- Update jobs table to use company_id
UPDATE jobs j
SET company_id = c.id
FROM companies c
WHERE j.company = c.name AND j.company_id IS NULL;

-- 3. Clean up jobs table
ALTER TABLE jobs
DROP COLUMN IF EXISTS company,
DROP COLUMN IF EXISTS logo_url,
DROP COLUMN IF EXISTS company_logo,
ALTER COLUMN company_id SET NOT NULL,
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL,
ALTER COLUMN created_at SET DEFAULT timezone('utc'::text, now()),
ALTER COLUMN updated_at SET DEFAULT timezone('utc'::text, now());

-- 4. Add indexes
CREATE INDEX IF NOT EXISTS idx_jobs_company_id ON jobs(company_id);
CREATE INDEX IF NOT EXISTS idx_jobs_job_type_id ON jobs(job_type_id);
CREATE INDEX IF NOT EXISTS idx_jobs_town_id ON jobs(town_id);
CREATE INDEX IF NOT EXISTS idx_jobs_posted_by ON jobs(posted_by);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_title ON jobs(title);

CREATE INDEX IF NOT EXISTS idx_job_applications_job_id ON job_applications(job_id);
CREATE INDEX IF NOT EXISTS idx_job_applications_user_id ON job_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_job_applications_reviewed_by ON job_applications(reviewed_by);

CREATE INDEX IF NOT EXISTS idx_job_tags_job_id ON job_tags(job_id);
CREATE INDEX IF NOT EXISTS idx_job_tags_tag_id ON job_tags(tag_id);

CREATE INDEX IF NOT EXISTS idx_profiles_company_id ON profiles(company_id);

CREATE INDEX IF NOT EXISTS idx_saved_jobs_user_id ON saved_jobs(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_jobs_job_id ON saved_jobs(job_id);

-- 5. Drop job_details table as it's now redundant
DROP TABLE IF EXISTS job_details;

-- 6. Add constraints
ALTER TABLE jobs
ADD CONSTRAINT jobs_salary_check 
CHECK (min_salary IS NULL OR max_salary IS NULL OR min_salary <= max_salary);

-- 7. Update timestamp defaults for consistency
ALTER TABLE job_types
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN created_at SET DEFAULT timezone('utc'::text, now());

ALTER TABLE towns
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN created_at SET DEFAULT timezone('utc'::text, now());

ALTER TABLE tags
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN created_at SET DEFAULT timezone('utc'::text, now());

-- 8. Add updated_at columns where missing
ALTER TABLE job_types
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now());

ALTER TABLE towns
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now());

ALTER TABLE tags
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now());

ALTER TABLE job_tags
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now());

-- 9. Create triggers to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_types_updated_at
    BEFORE UPDATE ON job_types
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_towns_updated_at
    BEFORE UPDATE ON towns
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tags_updated_at
    BEFORE UPDATE ON tags
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_tags_updated_at
    BEFORE UPDATE ON job_tags
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_applications_updated_at
    BEFORE UPDATE ON job_applications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saved_jobs_updated_at
    BEFORE UPDATE ON saved_jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMIT;
