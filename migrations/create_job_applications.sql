-- Create job applications table
CREATE TABLE IF NOT EXISTS job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    application_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(job_id, user_id)
);

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
    -- Insert application
    INSERT INTO job_applications (job_id, user_id, application_type)
    VALUES (p_job_id, p_user_id, p_application_type);

    -- Increment applicants count
    UPDATE jobs
    SET applicants = COALESCE(applicants, 0) + 1
    WHERE id = p_job_id
    RETURNING json_build_object(
        'success', true,
        'message', 'Application submitted successfully',
        'applicants', applicants
    ) INTO v_result;

    RETURN v_result;
EXCEPTION
    WHEN unique_violation THEN
        RETURN json_build_object(
            'success', false,
            'message', 'You have already applied for this job'
        );
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$;
