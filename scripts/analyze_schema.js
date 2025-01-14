const { PrismaClient } = require('@prisma/client')

async function main() {
  const prisma = new PrismaClient()

  try {
    // Get tables, columns, and foreign keys
    const schema = await prisma.$queryRaw`
      WITH foreign_keys AS (
        SELECT
          tc.table_name,
          kcu.column_name,
          ccu.table_name AS foreign_table_name,
          ccu.column_name AS foreign_column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
          AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage ccu
          ON ccu.constraint_name = tc.constraint_name
          AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY'
          AND tc.table_schema = 'public'
      )
      SELECT 
        t.table_name,
        json_agg(
          json_build_object(
            'column_name', c.column_name,
            'data_type', c.data_type,
            'is_nullable', c.is_nullable,
            'column_default', c.column_default,
            'foreign_key', json_build_object(
              'references_table', fk.foreign_table_name,
              'references_column', fk.foreign_column_name
            )
          )
        ) as columns
      FROM information_schema.tables t
      JOIN information_schema.columns c 
        ON c.table_name = t.table_name 
        AND c.table_schema = t.table_schema
      LEFT JOIN foreign_keys fk 
        ON fk.table_name = t.table_name 
        AND fk.column_name = c.column_name
      WHERE t.table_schema = 'public'
      GROUP BY t.table_name
      ORDER BY t.table_name;
    `

    let output = '# Database Schema Analysis\n\n'
    output += '## Current Schema\n\n'

    // Document each table and its structure
    for (const table of schema) {
      output += `### ${table.table_name}\n\n`
      output += '| Column | Type | Nullable | Default | References |\n'
      output += '|--------|------|----------|----------|------------|\n'
      
      for (const column of table.columns) {
        const fk = column.foreign_key.references_table ? 
          `${column.foreign_key.references_table}(${column.foreign_key.references_column})` : 
          ''
        output += `| ${column.column_name} | ${column.data_type} | ${column.is_nullable} | ${column.column_default || ''} | ${fk} |\n`
      }
      output += '\n'
    }

    // Analyze potential improvements
    output += '\n## Suggested Improvements\n\n'

    // Check for duplicate tables (jobs and job_details)
    if (schema.find(t => t.table_name === 'jobs') && schema.find(t => t.table_name === 'job_details')) {
      output += '### 1. Merge Duplicate Tables\n'
      output += '- `jobs` and `job_details` tables appear to store similar information\n'
      output += '- Recommendation: Merge these tables into a single `jobs` table\n'
      output += '- Migration steps:\n'
      output += '  1. Create a migration to merge unique columns from `job_details` into `jobs`\n'
      output += '  2. Migrate the data\n'
      output += '  3. Remove the `job_details` table\n\n'
    }

    // Check for proper indexing on foreign keys
    output += '### 2. Index Recommendations\n'
    output += '- Add indexes on frequently queried columns and foreign keys\n'
    output += '- Specific recommendations:\n'
    for (const table of schema) {
      const fkColumns = table.columns.filter(c => c.foreign_key.references_table)
      if (fkColumns.length > 0) {
        output += `  - Add indexes on foreign keys in \`${table.table_name}\`: ${fkColumns.map(c => c.column_name).join(', ')}\n`
      }
    }

    // Check for timestamp columns
    output += '\n### 3. Timestamp Management\n'
    const tablesWithoutTimestamps = schema.filter(t => 
      !t.columns.some(c => ['created_at', 'updated_at'].includes(c.column_name))
    )
    if (tablesWithoutTimestamps.length > 0) {
      output += '- Add timestamp columns to track record creation and updates:\n'
      for (const table of tablesWithoutTimestamps) {
        output += `  - Add \`created_at\` and \`updated_at\` to \`${table.table_name}\`\n`
      }
    }

    // Write analysis to file
    require('fs').writeFileSync('database_analysis.md', output)
    console.log('Analysis complete! Check database_analysis.md for details.')

  } catch (error) {
    console.error('Error:', error)
  } finally {
    await prisma.$disconnect()
  }
}

main()
