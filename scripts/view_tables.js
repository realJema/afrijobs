const { PrismaClient } = require('@prisma/client')

async function main() {
  const prisma = new PrismaClient()

  try {
    // Get all tables from the public schema
    const tables = await prisma.$queryRaw`
      SELECT table_name, 
             (SELECT count(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
      FROM information_schema.tables t
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `
    console.log('\nAll Tables in Database:')
    console.log('=======================')
    tables.forEach(table => {
      console.log(`${table.table_name} (${table.column_count} columns)`)
    })

  } catch (error) {
    console.error('Error:', error)
  } finally {
    await prisma.$disconnect()
  }
}

main()
