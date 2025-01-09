# Afrijob API

A Node.js/Express API for the Afrijob job board application.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file with your database configuration:
```env
DB_HOST=localhost
DB_USER=root
DB_PASS=
DB_NAME=afrijob_db
PORT=3000
```

3. Make sure your MySQL database is running and import the database schema:
```bash
mysql -u root < ../complete_database.sql
```

4. Start the development server:
```bash
npm run dev
```

## API Endpoints

### Jobs

- `GET /api/jobs` - Get all jobs with company and tag information
- `GET /api/jobs/:id` - Get a single job by ID

## Response Format

Success Response:
```json
{
  "status": "success",
  "data": [...]
}
```

Error Response:
```json
{
  "status": "error",
  "message": "Error message here"
}
```
