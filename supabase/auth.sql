-- Create profiles table with role
CREATE TABLE public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  full_name text,
  avatar_url text,
  phone_number text,
  location text,
  bio text,
  resume_url text,
  role text check (role in ('job_seeker', 'employer', 'admin')) default 'job_seeker',
  company_id uuid references public.companies(id),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create companies table
CREATE TABLE public.companies (
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

-- Update jobs table to link with profiles and companies
CREATE TABLE public.jobs (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text not null,
  requirements text[],
  responsibilities text[],
  salary_range_min integer,
  salary_range_max integer,
  job_type text references public.job_types(id),
  location text,
  is_remote boolean default false,
  experience_level text check (experience_level in ('entry', 'junior', 'mid', 'senior', 'lead')),
  posted_by uuid references public.profiles(id) on delete set null,
  company_id uuid references public.companies(id) on delete cascade,
  status text check (status in ('draft', 'published', 'closed', 'archived')) default 'published',
  application_deadline timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create saved_jobs table for bookmarking jobs
CREATE TABLE public.saved_jobs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  job_id uuid references public.jobs(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, job_id)
);

-- Create job_applications table
CREATE TABLE public.job_applications (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  job_id uuid references public.jobs(id) on delete cascade,
  status text check (status in ('pending', 'reviewed', 'shortlisted', 'rejected', 'accepted')) default 'pending',
  cover_letter text,
  resume_url text,
  reviewed_by uuid references public.profiles(id),
  review_notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, job_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

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
      AND company_id = NEW.company_id
    )
  );

CREATE POLICY "Job creators can update their jobs" ON public.jobs
  FOR UPDATE USING (posted_by = auth.uid());

-- Create policies for saved jobs
CREATE POLICY "Users can view their saved jobs" ON public.saved_jobs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can save jobs" ON public.saved_jobs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unsave jobs" ON public.saved_jobs
  FOR DELETE USING (auth.uid() = user_id);

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

CREATE POLICY "Users can update their applications" ON public.job_applications
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Employers can review applications for their jobs" ON public.job_applications
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.jobs j
      WHERE j.id = job_id AND j.posted_by = auth.uid()
    )
  );

-- Create function to handle user creation
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

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN new;
END;
$$;

-- Create triggers for updating timestamps
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
