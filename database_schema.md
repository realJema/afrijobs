# AfriJob Database Schema

## Overview
This document contains the current database schema for the AfriJob application, generated from Prisma's introspection on 2025-01-14.

## Database Structure

### Public Schema Tables

#### Jobs Table Constraints
```sql
- jobs_salary_check
- jobs_status_check
- salary_range_check
```

#### Job Applications Table Constraints
```sql
- job_applications_status_check
```

#### Companies Table Constraints
```sql
- companies_size_check
```

#### Profiles Table Constraints
```sql
- profiles_role_check
```

### Key Tables and Fields

#### Jobs
```prisma
model jobs {
  id                   String             @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  title                String             @db.VarChar(255)
  description          String
  requirements         String?
  contact_email        String?            @db.VarChar(255)
  contact_phone        String?            @db.VarChar(50)
  min_salary          Int?
  max_salary          Int?
  town_id             String?            @db.Uuid
  job_type_id         String?            @db.Uuid
  is_remote           Boolean?           @default(false)
  posted_by           String?            @db.Uuid
  company_id          String?            @db.Uuid
  status              String?            @default("published")
  application_deadline DateTime?          @db.Timestamptz(6)
  tag_names           String[]           @default([])
  created_at          DateTime?          @default(now()) @db.Timestamptz(6)
  updated_at          DateTime?          @default(now()) @db.Timestamptz(6)
  applicants          Int?               @default(0)
}
```

#### Job Applications
```prisma
model job_applications {
  id           String    @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  user_id      String?   @db.Uuid
  job_id       String?   @db.Uuid
  status       String?   @default("pending")
  cover_letter String?
  resume_url   String?
  reviewed_by  String?   @db.Uuid
  review_notes String?
  created_at   DateTime  @default(dbgenerated("timezone('utc'::text, now())")) @db.Timestamptz(6)
  updated_at   DateTime  @default(dbgenerated("timezone('utc'::text, now())")) @db.Timestamptz(6)
}
```

#### Companies
```prisma
model companies {
  id           String    @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  name         String
  logo_url     String?
  website      String?
  description  String?
  industry     String?
  size         String?
  founded_year Int?
  created_by   String?   @db.Uuid
  created_at   DateTime  @default(dbgenerated("timezone('utc'::text, now())")) @db.Timestamptz(6)
  updated_at   DateTime  @default(dbgenerated("timezone('utc'::text, now())")) @db.Timestamptz(6)
}
```

#### Tags
```prisma
model tags {
  id         String    @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  name       String    @unique @db.VarChar(100)
  created_at DateTime? @default(dbgenerated("timezone('utc'::text, now())")) @db.Timestamptz(6)
  updated_at DateTime? @default(dbgenerated("timezone('utc'::text, now())")) @db.Timestamptz(6)
}
```

### Important Relationships

1. Jobs to Companies: Many-to-One
   - jobs.company_id -> companies.id

2. Jobs to Job Applications: One-to-Many
   - job_applications.job_id -> jobs.id

3. Jobs to Tags: Many-to-Many through job_tags
   - job_tags.job_id -> jobs.id
   - job_tags.tag_id -> tags.id

4. Jobs to Towns: Many-to-One
   - jobs.town_id -> towns.id

### Key Constraints and Defaults

1. Job Status:
   - Default: "published"
   - Valid values enforced by check constraint

2. Job Application Status:
   - Default: "pending"
   - Valid values enforced by check constraint

3. Company Size:
   - Enforced by check constraint

4. Profile Role:
   - Default: "job_seeker"
   - Valid values enforced by check constraint

5. Salary Range:
   - Enforced by check constraint (min_salary <= max_salary)

### Indexes
Important indexes are in place for:
- Job searches (title, status)
- Company relationships
- Job applications
- Tags
- Towns

This schema reflects the current state of your database as pulled from Prisma's introspection. Let me know if you need any specific part explained in more detail!
