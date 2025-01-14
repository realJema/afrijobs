-- Function to get or create a company
CREATE OR REPLACE FUNCTION get_or_create_company(company_name TEXT)
RETURNS UUID AS $$
DECLARE
    v_company_id UUID;
BEGIN
    -- Try to get existing company
    SELECT id INTO v_company_id
    FROM public.companies
    WHERE name = company_name;

    -- If not found, create new company
    IF v_company_id IS NULL THEN
        INSERT INTO public.companies (name, created_at, updated_at)
        VALUES (company_name, NOW(), NOW())
        RETURNING id INTO v_company_id;
    END IF;

    RETURN v_company_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create a job
CREATE OR REPLACE FUNCTION create_job(
    title TEXT,
    description TEXT,
    company_id UUID,
    requirements TEXT DEFAULT NULL,
    contact_email TEXT DEFAULT NULL,
    contact_phone TEXT DEFAULT NULL,
    min_salary INTEGER DEFAULT NULL,
    max_salary INTEGER DEFAULT NULL,
    town_id UUID DEFAULT NULL,
    status TEXT DEFAULT 'published',
    application_deadline TIMESTAMPTZ DEFAULT NULL,
    tag_names TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS UUID AS $$
DECLARE
    v_job_id UUID;
BEGIN
    INSERT INTO public.jobs (
        title,
        description,
        requirements,
        contact_email,
        contact_phone,
        min_salary,
        max_salary,
        company_id,
        town_id,
        status,
        application_deadline,
        created_at,
        updated_at,
        tag_names,
        posted_by,
        is_remote
    ) VALUES (
        title,
        description,
        requirements,
        contact_email,
        contact_phone,
        min_salary,
        max_salary,
        company_id,
        town_id,
        status,
        application_deadline,
        NOW(),
        NOW(),
        tag_names,
        auth.uid(),
        false
    )
    RETURNING id INTO v_job_id;

    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get or create a tag
CREATE OR REPLACE FUNCTION get_or_create_tag(tag_name TEXT)
RETURNS UUID AS $$
DECLARE
    v_tag_id UUID;
BEGIN
    -- Try to get existing tag
    SELECT id INTO v_tag_id
    FROM public.tags
    WHERE name = tag_name;

    -- If not found, create new tag
    IF v_tag_id IS NULL THEN
        INSERT INTO public.tags (name, created_at, updated_at)
        VALUES (tag_name, NOW(), NOW())
        RETURNING id INTO v_tag_id;
    END IF;

    RETURN v_tag_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to link a tag to a job
CREATE OR REPLACE FUNCTION link_tag_to_job(job_id UUID, tag_id UUID)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.job_tags (job_id, tag_id, created_at, updated_at)
    VALUES (job_id, tag_id, NOW(), NOW())
    ON CONFLICT (job_id, tag_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
