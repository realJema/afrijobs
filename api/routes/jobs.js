const express = require('express');
const router = express.Router();
const db = require('../config/db');

// Get all jobs with company and tag information
router.get('/', async (req, res) => {
  try {
    const { search, type, minSalary, maxSalary, tags } = req.query;
    
    // Build the WHERE clause
    let whereConditions = ['j.status = "active"'];
    let params = [];

    if (search) {
      whereConditions.push('(j.title LIKE ? OR j.description LIKE ? OR c.name LIKE ?)');
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    if (type) {
      whereConditions.push('j.job_type = ?');
      params.push(type);
    }

    if (minSalary) {
      whereConditions.push('j.salary_min >= ?');
      params.push(parseInt(minSalary));
    }

    if (maxSalary) {
      whereConditions.push('j.salary_max <= ?');
      params.push(parseInt(maxSalary));
    }

    let query = `
      SELECT DISTINCT
        j.id,
        j.title,
        j.description,
        j.salary_min,
        j.salary_max,
        j.job_type as type,
        j.location,
        j.applicants_count as applicants,
        c.name as company_name,
        c.logo_url
      FROM jobs j
      LEFT JOIN companies c ON j.company_id = c.id
    `;

    if (tags) {
      const tagList = tags.split(',');
      query += `
        LEFT JOIN job_tags jt ON j.id = jt.job_id
        LEFT JOIN tags t ON jt.tag_id = t.id
      `;
      whereConditions.push('t.name IN (?)');
      params.push(tagList);
    }

    if (whereConditions.length > 0) {
      query += ' WHERE ' + whereConditions.join(' AND ');
    }

    query += ' ORDER BY j.created_at DESC';

    const [jobs] = await db.query(query, params);

    // Format jobs data
    const formattedJobs = jobs.map(job => ({
      id: job.id,
      title: job.title || '',
      company_name: job.company_name || '',
      logo_url: job.logo_url,
      location: job.location || '',
      salary: `$${job.salary_min/1000}k-$${job.salary_max/1000}k`,
      type: job.type || 'Full-time',
      applicants: job.applicants || 0,
      description: job.description || '',
      tags: [] // Will be populated below
    }));

    // Get tags for each job
    for (let job of formattedJobs) {
      const [tags] = await db.query(`
        SELECT t.name
        FROM tags t
        JOIN job_tags jt ON t.id = jt.tag_id
        WHERE jt.job_id = ?
      `, [job.id]);

      job.tags = tags.map(tag => tag.name);
    }

    res.json({
      status: 'success',
      data: formattedJobs
    });
  } catch (error) {
    console.error('Error fetching jobs:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch jobs'
    });
  }
});

// Get available job types
router.get('/types', async (req, res) => {
  try {
    const [types] = await db.query(`
      SELECT DISTINCT job_type
      FROM jobs
      WHERE status = 'active'
      ORDER BY job_type
    `);
    
    res.json({
      status: 'success',
      data: types.map(t => t.job_type)
    });
  } catch (error) {
    console.error('Error fetching job types:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch job types'
    });
  }
});

// Get available tags
router.get('/tags', async (req, res) => {
  try {
    const [tags] = await db.query(`
      SELECT DISTINCT t.name
      FROM tags t
      JOIN job_tags jt ON t.id = jt.tag_id
      JOIN jobs j ON jt.job_id = j.id
      WHERE j.status = 'active'
      ORDER BY t.name
    `);
    
    res.json({
      status: 'success',
      data: tags.map(t => t.name)
    });
  } catch (error) {
    console.error('Error fetching tags:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch tags'
    });
  }
});

// Get available towns
router.get('/towns', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM towns_by_region');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching towns:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get a single job by ID
router.get('/:id', async (req, res) => {
  try {
    const [jobs] = await db.query(`
      SELECT 
        j.id,
        j.title,
        j.description,
        j.salary_min,
        j.salary_max,
        j.job_type as type,
        j.location,
        j.applicants_count as applicants,
        c.name as company_name,
        c.logo_url
      FROM jobs j
      LEFT JOIN companies c ON j.company_id = c.id
      WHERE j.id = ? AND j.status = 'active'
    `, [req.params.id]);

    if (jobs.length === 0) {
      return res.status(404).json({
        status: 'error',
        message: 'Job not found'
      });
    }

    const job = {
      id: jobs[0].id,
      title: jobs[0].title || '',
      company_name: jobs[0].company_name || '',
      logo_url: jobs[0].logo_url,
      location: jobs[0].location || '',
      salary: `$${jobs[0].salary_min/1000}k-$${jobs[0].salary_max/1000}k`,
      type: jobs[0].type || 'Full-time',
      applicants: jobs[0].applicants || 0,
      description: jobs[0].description || '',
      tags: []
    };

    // Get tags for the job
    const [tags] = await db.query(`
      SELECT t.name
      FROM tags t
      JOIN job_tags jt ON t.id = jt.tag_id
      WHERE jt.job_id = ?
    `, [job.id]);

    job.tags = tags.map(tag => tag.name);

    res.json({
      status: 'success',
      data: job
    });
  } catch (error) {
    console.error('Error fetching job:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch job'
    });
  }
});

module.exports = router;
