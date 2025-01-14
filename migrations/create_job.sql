CREATE OR REPLACE FUNCTION public.create_job(
    p_title TEXT,
    p_description TEXT,
    p_company_name TEXT,
    p_requirements TEXT DEFAULT NULL,
    p_contact_email TEXT DEFAULT NULL,
    p_contact_phone TEXT DEFAULT NULL,
    p_min_salary INTEGER DEFAULT NULL,
    p_max_salary INTEGER DEFAULT NULL,
    p_town_id UUID DEFAULT NULL,
    p_status TEXT DEFAULT 'published',
    p_application_deadline TIMESTAMPTZ DEFAULT NULL,
    p_tags TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_job_id UUID;
    v_tag_id UUID;
    v_tag TEXT;
BEGIN
    -- Insert the job directly
    INSERT INTO public.jobs (
        title,
        description,
        company_name,
        requirements,
        contact_email,
        contact_phone,
        min_salary,
        max_salary,
        town_id,
        status,
        application_deadline,
        created_at,
        updated_at,
        posted_by,
        tag_names
    ) VALUES (
        p_title,
        p_description,
        p_company_name,
        p_requirements,
        p_contact_email,
        p_contact_phone,
        p_min_salary,
        p_max_salary,
        p_town_id,
        COALESCE(p_status, 'published'),
        p_application_deadline,
        NOW(),
        NOW(),
        auth.uid(),
        p_tags
    )
    RETURNING id INTO v_job_id;

    -- Create and link tags if provided
    IF p_tags IS NOT NULL AND array_length(p_tags, 1) > 0 THEN
        FOREACH v_tag IN ARRAY p_tags
        LOOP
            -- Get or create tag
            INSERT INTO public.tags (name, created_at, updated_at)
            VALUES (v_tag, NOW(), NOW())
            ON CONFLICT (name) DO UPDATE SET updated_at = NOW()
            RETURNING id INTO v_tag_id;

            -- Link tag to job
            INSERT INTO public.job_tags (job_id, tag_id, created_at, updated_at)
            VALUES (v_job_id, v_tag_id, NOW(), NOW())
            ON CONFLICT (job_id, tag_id) DO NOTHING;
        END LOOP;
    END IF;

    RETURN v_job_id;
EXCEPTION
    WHEN others THEN
        RAISE;
END;
$$;
