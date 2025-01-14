-- Create an enum type for job status if it doesn't exist
DO $$ BEGIN
    CREATE TYPE job_status AS ENUM ('draft', 'published', 'closed', 'archived');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create tables with proper constraints
CREATE TABLE IF NOT EXISTS public.companies (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    website TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.towns (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.job_types (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tags (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    town_id UUID REFERENCES public.towns(id) ON DELETE SET NULL,
    min_salary INTEGER,
    max_salary INTEGER,
    applicants INTEGER DEFAULT 0,
    job_type_id UUID REFERENCES public.job_types(id) ON DELETE SET NULL,
    is_remote BOOLEAN DEFAULT false,
    posted_by UUID,
    company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
    status job_status DEFAULT 'published',
    application_deadline TIMESTAMPTZ,
    tag_names TEXT[] DEFAULT ARRAY[]::TEXT[],
    CONSTRAINT jobs_salary_check CHECK (min_salary IS NULL OR max_salary IS NULL OR min_salary <= max_salary)
);

CREATE TABLE IF NOT EXISTS public.job_tags (
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (job_id, tag_id)
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_jobs_company_id ON public.jobs(company_id);
CREATE INDEX IF NOT EXISTS idx_jobs_job_type_id ON public.jobs(job_type_id);
CREATE INDEX IF NOT EXISTS idx_jobs_posted_by ON public.jobs(posted_by);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON public.jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_title ON public.jobs(title);
CREATE INDEX IF NOT EXISTS idx_jobs_town_id ON public.jobs(town_id);

-- Insert default job types if they don't exist
INSERT INTO public.job_types (name) VALUES
    ('Full-time'),
    ('Part-time'),
    ('Contract'),
    ('Freelance'),
    ('Internship')
ON CONFLICT (name) DO NOTHING;
