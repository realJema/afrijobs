-- Drop the salary_range column and add min_salary and max_salary
ALTER TABLE jobs
  DROP COLUMN IF EXISTS salary_range,
  ADD COLUMN IF NOT EXISTS min_salary INTEGER,
  ADD COLUMN IF NOT EXISTS max_salary INTEGER,
  ADD COLUMN IF NOT EXISTS company_logo TEXT,
  ADD COLUMN IF NOT EXISTS applicants INTEGER DEFAULT 0;

-- Add a check constraint to ensure min_salary is less than or equal to max_salary
ALTER TABLE jobs
  ADD CONSTRAINT salary_range_check 
  CHECK (min_salary IS NULL OR max_salary IS NULL OR min_salary <= max_salary);

-- Update existing jobs with random salary ranges and applicant counts
UPDATE jobs
SET 
  min_salary = FLOOR(RANDOM() * 80 + 20), -- Random number between 20 and 100
  max_salary = FLOOR(RANDOM() * 100 + 100), -- Random number between 100 and 200
  applicants = FLOOR(RANDOM() * 2000 + 500); -- Random number between 500 and 2500

-- Ensure min_salary is always less than max_salary
UPDATE jobs
SET min_salary = max_salary - FLOOR(RANDOM() * 20 + 10)
WHERE min_salary >= max_salary;
