CREATE OR REPLACE FUNCTION public.create_job_procedure(
  p_title TEXT,
  p_description TEXT,
  p_company_name TEXT,
  p_requirements TEXT DEFAULT NULL,
  p_contact_email TEXT DEFAULT NULL,
  p_contact_phone TEXT DEFAULT NULL,
  p_min_salary INTEGER DEFAULT NULL,
  p_max_salary INTEGER DEFAULT NULL,
  p_location TEXT DEFAULT NULL,
  p_status TEXT DEFAULT 'published',
  p_application_deadline TIMESTAMPTZ DEFAULT NULL,
  p_tags TEXT[] DEFAULT ARRAY[]::TEXT[]
) RETURNS UUID AS $$
DECLARE
  v_company_id UUID;
  v_job_id UUID;
  v_tag_id UUID;
  v_tag_name TEXT;
  v_town_id UUID;
  v_status TEXT;
BEGIN
  -- Start transaction
  BEGIN
    -- Validate and set status
    IF p_status NOT IN ('draft', 'published', 'closed', 'archived', 'active') THEN
      v_status := 'published';
    ELSE
      v_status := p_status;
    END IF;
    
    -- Get existing company or create new one
    SELECT id INTO v_company_id
    FROM public.companies
    WHERE name = p_company_name;

    IF v_company_id IS NULL THEN
      INSERT INTO public.companies (
        name,
        created_at,
        updated_at
      )
      VALUES (
        p_company_name,
        NOW(),
        NOW()
      )
      RETURNING id INTO v_company_id;
    END IF;

    -- Get or create town
    IF p_location IS NOT NULL THEN
      SELECT id INTO v_town_id
      FROM public.towns
      WHERE name = p_location;
    END IF;

    -- Create job
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
      p_title,
      p_description,
      p_requirements,
      p_contact_email,
      p_contact_phone,
      p_min_salary,
      p_max_salary,
      v_company_id,
      v_town_id,
      v_status,
      p_application_deadline,
      NOW(),
      NOW(),
      CASE 
        WHEN p_location IS NOT NULL AND v_town_id IS NULL 
        THEN array_append(p_tags, 'location:' || p_location)
        ELSE p_tags
      END,
      auth.uid(),
      false
    ) RETURNING id INTO v_job_id;

    -- Handle tags
    IF p_tags IS NOT NULL AND array_length(p_tags, 1) > 0 THEN
      FOREACH v_tag_name IN ARRAY p_tags
      LOOP
        -- Get existing tag or create new one
        SELECT id INTO v_tag_id
        FROM public.tags
        WHERE name = v_tag_name;

        IF v_tag_id IS NULL THEN
          INSERT INTO public.tags (
            name,
            created_at,
            updated_at
          )
          VALUES (
            v_tag_name,
            NOW(),
            NOW()
          )
          RETURNING id INTO v_tag_id;
        END IF;

        -- Link tag to job if not already linked
        IF NOT EXISTS (
          SELECT 1 FROM public.job_tags
          WHERE job_id = v_job_id AND tag_id = v_tag_id
        ) THEN
          INSERT INTO public.job_tags (
            job_id,
            tag_id,
            created_at,
            updated_at
          )
          VALUES (
            v_job_id,
            v_tag_id,
            NOW(),
            NOW()
          );
        END IF;
      END LOOP;
    END IF;

    RETURN v_job_id;
  EXCEPTION 
    WHEN check_violation THEN
      RAISE EXCEPTION 'Invalid status value. Must be one of: draft, published, closed, archived, active';
    WHEN OTHERS THEN
      RAISE;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
