-- Add unique constraints
ALTER TABLE public.companies ADD CONSTRAINT companies_name_key UNIQUE (name);
ALTER TABLE public.tags ADD CONSTRAINT tags_name_key UNIQUE (name);
ALTER TABLE public.job_tags ADD CONSTRAINT job_tags_job_id_tag_id_key UNIQUE (job_id, tag_id);
