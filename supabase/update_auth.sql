-- Drop existing triggers first
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS handle_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS handle_job_applications_updated_at ON public.job_applications;

-- Drop existing functions
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.handle_updated_at();

-- Create companies table
CREATE TABLE IF NOT EXISTS public.companies (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  logo_url text,
  website text,
  description text,
  industry text,
  size text check (size in ('1-10', '11-50', '51-200', '201-500', '501-1000', '1000+')),
  founded_year integer,
  created_by uuid references auth.users on delete set null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Alter profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role text check (role in ('job_seeker', 'employer', 'admin')) default 'job_seeker',
ADD COLUMN IF NOT EXISTS company_id uuid references public.companies(id);

-- Alter jobs table
ALTER TABLE public.jobs 
ADD COLUMN IF NOT EXISTS requirements text[],
ADD COLUMN IF NOT EXISTS responsibilities text[],
ADD COLUMN IF NOT EXISTS salary_range_min integer,
ADD COLUMN IF NOT EXISTS salary_range_max integer,
ADD COLUMN IF NOT EXISTS is_remote boolean default false,
ADD COLUMN IF NOT EXISTS experience_level text check (experience_level in ('entry', 'junior', 'mid', 'senior', 'lead')),
ADD COLUMN IF NOT EXISTS posted_by uuid references public.profiles(id) on delete set null,
ADD COLUMN IF NOT EXISTS company_id uuid references public.companies(id) on delete cascade,
ADD COLUMN IF NOT EXISTS status text check (status in ('draft', 'published', 'closed', 'archived')) default 'published',
ADD COLUMN IF NOT EXISTS application_deadline timestamp with time zone;

-- Alter job_applications table
ALTER TABLE public.job_applications 
ADD COLUMN IF NOT EXISTS reviewed_by uuid references public.profiles(id),
ADD COLUMN IF NOT EXISTS review_notes text;

-- Enable RLS on companies table
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Companies are viewable by everyone" ON public.companies;
DROP POLICY IF EXISTS "Employers can create companies" ON public.companies;
DROP POLICY IF EXISTS "Company creators can update their companies" ON public.companies;
DROP POLICY IF EXISTS "Jobs are viewable by everyone" ON public.jobs;
DROP POLICY IF EXISTS "Employers can create jobs for their company" ON public.jobs;
DROP POLICY IF EXISTS "Job creators can update their jobs" ON public.jobs;
DROP POLICY IF EXISTS "Users can view their applications" ON public.job_applications;
DROP POLICY IF EXISTS "Users can apply for jobs" ON public.job_applications;
DROP POLICY IF EXISTS "Employers can review applications for their jobs" ON public.job_applications;

-- Create policies for companies
CREATE POLICY "Companies are viewable by everyone" ON public.companies
  FOR SELECT USING (true);

CREATE POLICY "Employers can create companies" ON public.companies
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'employer'
    )
  );

CREATE POLICY "Company creators can update their companies" ON public.companies
  FOR UPDATE USING (created_by = auth.uid());

-- Create policies for jobs
CREATE POLICY "Jobs are viewable by everyone" ON public.jobs
  FOR SELECT USING (status = 'published');

CREATE POLICY "Employers can create jobs for their company" ON public.jobs
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() 
      AND role = 'employer'
      AND company_id IS NOT NULL
    )
  );

CREATE POLICY "Job creators can update their jobs" ON public.jobs
  FOR UPDATE USING (posted_by = auth.uid());

-- Create policies for job applications
CREATE POLICY "Users can view their applications" ON public.job_applications
  FOR SELECT USING (
    auth.uid() = user_id OR 
    EXISTS (
      SELECT 1 FROM public.jobs j
      WHERE j.id = job_id AND j.posted_by = auth.uid()
    )
  );

CREATE POLICY "Users can apply for jobs" ON public.job_applications
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM public.jobs j
      WHERE j.id = job_id AND j.status = 'published'
    )
  );

CREATE POLICY "Employers can review applications for their jobs" ON public.job_applications
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.jobs j
      WHERE j.id = job_id AND j.posted_by = auth.uid()
    )
  );

-- Recreate function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    COALESCE(new.raw_user_meta_data->>'role', 'job_seeker')
  );
  RETURN new;
END;
$$;

-- Recreate function to update timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN new;
END;
$$;

-- Recreate triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

CREATE TRIGGER handle_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_companies_updated_at
  BEFORE UPDATE ON public.companies
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_jobs_updated_at
  BEFORE UPDATE ON public.jobs
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER handle_job_applications_updated_at
  BEFORE UPDATE ON public.job_applications
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
