-- Enable RLS
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_tags ENABLE ROW LEVEL SECURITY;

-- Companies policies
CREATE POLICY "Enable read access for all users" ON public.companies
    FOR SELECT USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON public.companies
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for users based on email" ON public.companies
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT id FROM public.profiles 
            WHERE company_id = companies.id
        )
    );

-- Jobs policies
CREATE POLICY "Enable read access for all users" ON public.jobs
    FOR SELECT USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON public.jobs
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for job owners" ON public.jobs
    FOR UPDATE USING (
        auth.uid() = posted_by OR 
        auth.uid() IN (
            SELECT id FROM public.profiles 
            WHERE company_id = jobs.company_id
        )
    );

-- Tags policies
CREATE POLICY "Enable read access for all users" ON public.tags
    FOR SELECT USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON public.tags
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Job tags policies
CREATE POLICY "Enable read access for all users" ON public.job_tags
    FOR SELECT USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON public.job_tags
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Grant necessary permissions
GRANT ALL ON public.companies TO authenticated;
GRANT ALL ON public.jobs TO authenticated;
GRANT ALL ON public.tags TO authenticated;
GRANT ALL ON public.job_tags TO authenticated;

-- Grant USAGE on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
