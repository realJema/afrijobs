-- Create enum for job status
DO $$ BEGIN
    CREATE TYPE job_status AS ENUM ('draft', 'published', 'closed', 'archived', 'active');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Drop existing status check constraint if it exists
ALTER TABLE public.jobs DROP CONSTRAINT IF EXISTS jobs_status_check;

-- Add new status check constraint
ALTER TABLE public.jobs ADD CONSTRAINT jobs_status_check 
    CHECK (status IN ('draft', 'published', 'closed', 'archived', 'active'));
