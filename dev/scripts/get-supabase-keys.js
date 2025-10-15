#!/usr/bin/env node
/**
 * Retrieve Supabase project API keys using Management API
 */

const PROJECT_REF = 'ctxhmgmeflnemjfzyabr';
const MANAGEMENT_API_TOKEN = 'sbp_v0_87b722372a98c7d6c8b61ac040cb527f57fbb19a';
const BASE_URL = 'https://api.supabase.com/v0';

async function getProjectDetails() {
  try {
    // Try to get project details
    const response = await fetch(
      `${BASE_URL}/projects/${PROJECT_REF}`,
      {
        headers: {
          'Authorization': `Bearer ${MANAGEMENT_API_TOKEN}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Error getting project details:', response.status, errorText);
      return;
    }

    const project = await response.json();
    console.log('\n='.repeat(80));
    console.log('PROJECT DETAILS');
    console.log('='.repeat(80));
    console.log(JSON.stringify(project, null, 2));

  } catch (error) {
    console.error('Failed to get project details:', error.message);
  }
}

async function listProjects() {
  try {
    // List all projects to understand the structure
    const response = await fetch(
      `${BASE_URL}/projects`,
      {
        headers: {
          'Authorization': `Bearer ${MANAGEMENT_API_TOKEN}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Error listing projects:', response.status, errorText);
      return;
    }

    const projects = await response.json();
    console.log('\n='.repeat(80));
    console.log('ALL PROJECTS');
    console.log('='.repeat(80));
    console.log(JSON.stringify(projects, null, 2));

  } catch (error) {
    console.error('Failed to list projects:', error.message);
  }
}

async function main() {
  console.log('Supabase Management API - Project Information Retrieval');
  console.log('Using token:', MANAGEMENT_API_TOKEN.substring(0, 20) + '...');
  console.log('Project ref:', PROJECT_REF);

  await listProjects();
  await getProjectDetails();
}

main().catch(console.error);
