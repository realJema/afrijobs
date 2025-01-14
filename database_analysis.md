# Database Schema Analysis

## Current Schema

### companies

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| founded_year | integer | YES |  |  |
| size | text | YES |  |  |
| industry | text | YES |  |  |
| description | text | YES |  |  |
| website | text | YES |  |  |
| logo_url | text | YES |  |  |
| name | text | NO |  |  |
| id | uuid | NO | uuid_generate_v4() |  |
| updated_at | timestamp with time zone | NO | timezone('utc'::text, now()) |  |
| created_at | timestamp with time zone | NO | timezone('utc'::text, now()) |  |
| created_by | uuid | YES |  |  |

### job_applications

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| created_at | timestamp with time zone | NO | timezone('utc'::text, now()) |  |
| resume_url | text | YES |  |  |
| cover_letter | text | YES |  |  |
| status | text | YES | 'pending'::text |  |
| job_id | uuid | YES |  | jobs(id) |
| id | uuid | NO | uuid_generate_v4() |  |
| user_id | uuid | YES |  | profiles(id) |
| review_notes | text | YES |  |  |
| reviewed_by | uuid | YES |  | profiles(id) |
| updated_at | timestamp with time zone | NO | timezone('utc'::text, now()) |  |

### job_details

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| id | uuid | YES |  |  |
| title | character varying | YES |  |  |
| company | character varying | YES |  |  |
| logo_url | text | YES |  |  |
| description | text | YES |  |  |
| requirements | text | YES |  |  |
| contact_email | character varying | YES |  |  |
| contact_phone | character varying | YES |  |  |
| created_at | timestamp with time zone | YES |  |  |
| updated_at | timestamp with time zone | YES |  |  |
| town_id | uuid | YES |  |  |
| min_salary | integer | YES |  |  |
| max_salary | integer | YES |  |  |
| company_logo | text | YES |  |  |
| applicants | integer | YES |  |  |
| job_type_id | uuid | YES |  |  |
| job_type | character varying | YES |  |  |
| tag_names | ARRAY | YES |  |  |

### job_tags

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| created_at | timestamp with time zone | YES | CURRENT_TIMESTAMP |  |
| tag_id | uuid | NO |  | tags(id) |
| job_id | uuid | NO |  | jobs(id) |

### job_types

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| created_at | timestamp with time zone | YES | CURRENT_TIMESTAMP |  |
| name | character varying | NO |  |  |
| id | uuid | NO | uuid_generate_v4() |  |

### jobs

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| applicants | integer | YES | 0 |  |
| job_type_id | uuid | YES |  | job_types(id) |
| is_remote | boolean | YES | false |  |
| posted_by | uuid | YES |  | profiles(id) |
| company_id | uuid | YES |  | companies(id) |
| status | text | YES | 'published'::text |  |
| application_deadline | timestamp with time zone | YES |  |  |
| id | uuid | NO | uuid_generate_v4() |  |
| title | character varying | NO |  |  |
| company | character varying | NO |  |  |
| logo_url | text | YES |  |  |
| description | text | NO |  |  |
| requirements | text | YES |  |  |
| contact_email | character varying | YES |  |  |
| created_at | timestamp with time zone | YES | CURRENT_TIMESTAMP |  |
| contact_phone | character varying | YES |  |  |
| updated_at | timestamp with time zone | YES | CURRENT_TIMESTAMP |  |
| town_id | uuid | YES |  | towns(id) |
| min_salary | integer | YES |  |  |
| max_salary | integer | YES |  |  |
| company_logo | text | YES |  |  |

### profiles

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| company_id | uuid | YES |  | companies(id) |
| role | text | YES | 'job_seeker'::text |  |
| updated_at | timestamp with time zone | NO | timezone('utc'::text, now()) |  |
| created_at | timestamp with time zone | NO | timezone('utc'::text, now()) |  |
| resume_url | text | YES |  |  |
| bio | text | YES |  |  |
| location | text | YES |  |  |
| phone_number | text | YES |  |  |
| avatar_url | text | YES |  |  |
| full_name | text | YES |  |  |
| email | text | NO |  |  |
| id | uuid | NO |  |  |

### saved_jobs

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| id | uuid | NO | uuid_generate_v4() |  |
| user_id | uuid | YES |  | profiles(id) |
| job_id | uuid | YES |  | jobs(id) |
| created_at | timestamp with time zone | NO | timezone('utc'::text, now()) |  |

### tags

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| id | uuid | NO | uuid_generate_v4() |  |
| name | character varying | NO |  |  |
| created_at | timestamp with time zone | YES | CURRENT_TIMESTAMP |  |

### towns

| Column | Type | Nullable | Default | References |
|--------|------|----------|----------|------------|
| id | uuid | NO | uuid_generate_v4() |  |
| name | character varying | NO |  |  |
| region | character varying | NO |  |  |
| created_at | timestamp with time zone | YES | CURRENT_TIMESTAMP |  |


## Suggested Improvements

### 1. Merge Duplicate Tables
- `jobs` and `job_details` tables appear to store similar information
- Recommendation: Merge these tables into a single `jobs` table
- Migration steps:
  1. Create a migration to merge unique columns from `job_details` into `jobs`
  2. Migrate the data
  3. Remove the `job_details` table

### 2. Index Recommendations
- Add indexes on frequently queried columns and foreign keys
- Specific recommendations:
  - Add indexes on foreign keys in `job_applications`: job_id, user_id, reviewed_by
  - Add indexes on foreign keys in `job_tags`: tag_id, job_id
  - Add indexes on foreign keys in `jobs`: job_type_id, posted_by, company_id, town_id
  - Add indexes on foreign keys in `profiles`: company_id
  - Add indexes on foreign keys in `saved_jobs`: user_id, job_id

### 3. Timestamp Management
