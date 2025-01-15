-- Create function to apply for job
CREATE OR REPLACE FUNCTION apply_for_job(
    p_job_id UUID,
    p_user_id UUID,
    p_application_type TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Check if user has already applied
    IF EXISTS (
        SELECT 1 FROM job_applications 
        WHERE job_id = p_job_id AND user_id = p_user_id
    ) THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Already applied',
            'already_applied', true
        );
    END IF;

    -- Insert application
    INSERT INTO job_applications (
        job_id,
        user_id,
        status,
        created_at,
        updated_at
    )
    VALUES (
        p_job_id,
        p_user_id,
        'pending',
        NOW(),
        NOW()
    );

    -- Increment applicants count
    UPDATE jobs
    SET applicants = COALESCE(applicants, 0) + 1
    WHERE id = p_job_id
    RETURNING json_build_object(
        'success', true,
        'message', 'Application submitted successfully',
        'already_applied', false,
        'applicants', applicants
    ) INTO v_result;

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM,
            'already_applied', false
        );
END;
$$;
