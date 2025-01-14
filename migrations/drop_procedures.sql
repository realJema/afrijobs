-- Drop all existing job creation procedures
DROP FUNCTION IF EXISTS public.create_job_procedure(
    p_title TEXT,
    p_description TEXT,
    p_company_name TEXT,
    p_requirements TEXT,
    p_contact_email TEXT,
    p_contact_phone TEXT,
    p_min_salary INTEGER,
    p_max_salary INTEGER,
    p_location TEXT,
    p_status TEXT,
    p_application_deadline TIMESTAMPTZ,
    p_tags TEXT[]
);

DROP FUNCTION IF EXISTS public.create_job_procedure(
    p_title TEXT,
    p_description TEXT,
    p_requirements TEXT,
    p_contact_email TEXT,
    p_contact_phone TEXT,
    p_min_salary INTEGER,
    p_max_salary INTEGER,
    p_location TEXT,
    p_company_name TEXT,
    p_status TEXT,
    p_application_deadline TIMESTAMPTZ,
    p_tags TEXT[]
);
