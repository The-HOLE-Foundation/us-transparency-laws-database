# The Hole Foundation - Launch Architecture
*Technical specifications for MVP launch components*

## Launch MVP: Three Core Components

### 1. Transparency Map (theholetruth.org/map)
### 2. FOIA Generator (theholetruth.org/generator)
### 3. FOIA Wiki (theholetruth.org/wiki)

---

## Component 1: Interactive Transparency Map

### Technical Stack
- **Frontend**: React/Next.js with TypeScript
- **Mapping**: Leaflet or D3.js for interactive US map
- **Styling**: Tailwind CSS for responsive design
- **Data Source**: Supabase via REST API

### Database Schema (Supabase)
```sql
-- Jurisdictions table
CREATE TABLE jurisdictions (
  id SERIAL PRIMARY KEY,
  code VARCHAR(2) UNIQUE NOT NULL,  -- 'CA', 'TX', 'NY', etc.
  name VARCHAR(100) NOT NULL,       -- 'California', 'Texas'
  type VARCHAR(20) NOT NULL,        -- 'state', 'federal', 'district'
  statute_name TEXT NOT NULL,
  statute_citation TEXT NOT NULL,
  response_time_days INTEGER,
  response_time_notes TEXT,
  fees JSONB,                       -- Complex fee structure
  exemptions TEXT[],
  appeal_process TEXT,
  official_portal_url TEXT,
  validation_date TIMESTAMP,
  source_urls TEXT[],
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Geographic data for map rendering
CREATE TABLE jurisdiction_geo (
  jurisdiction_id INTEGER REFERENCES jurisdictions(id),
  geojson JSONB,  -- State boundary data
  center_lat DECIMAL(10,8),
  center_lng DECIMAL(11,8)
);
```

### API Endpoints
```javascript
// GET /api/jurisdictions
// Returns all 51 jurisdictions with summary data

// GET /api/jurisdiction/{code}
// Returns detailed data for specific state

// GET /api/map-data
// Returns GeoJSON and summary data for map rendering
```

### Map Features
- **Interactive Hover**: Show response time, fees on hover
- **Color Coding**: States by response time (green=fast, red=slow)
- **Click Actions**: Navigate to detailed state page
- **Comparison Mode**: Select multiple states for side-by-side comparison
- **Search Filter**: Find states by name or response time range

---

## Component 2: FOIA Generator Tool

### Technical Stack
- **Frontend**: React forms with validation
- **Backend**: Node.js/Python API
- **PDF Generation**: jsPDF or Puppeteer
- **Email Integration**: SendGrid or similar
- **Template Engine**: Handlebars or similar

### Database Schema Extensions
```sql
-- Agency contact information
CREATE TABLE agencies (
  id SERIAL PRIMARY KEY,
  jurisdiction_id INTEGER REFERENCES jurisdictions(id),
  name TEXT NOT NULL,
  type VARCHAR(50),  -- 'state', 'county', 'municipal'
  contact_name TEXT,
  email TEXT,
  mailing_address JSONB,
  phone TEXT,
  fax TEXT,
  portal_url TEXT,
  notes TEXT
);

-- Request templates by jurisdiction
CREATE TABLE request_templates (
  id SERIAL PRIMARY KEY,
  jurisdiction_id INTEGER REFERENCES jurisdictions(id),
  template_type VARCHAR(50),  -- 'general', 'specific', 'appeal'
  subject_template TEXT,
  body_template TEXT,
  required_fields TEXT[],
  optional_fields TEXT[]
);
```

### Generator Features
- **State Selection**: Dropdown/map selection of jurisdiction
- **Agency Selection**: Dynamic list based on state selection
- **Smart Forms**: Required fields based on state requirements
- **Template Generation**: Pre-filled FOIA request letters
- **Fee Calculator**: Estimate costs based on request type
- **PDF Export**: Professional formatted request documents
- **Email Integration**: Direct submission to agencies (optional)
- **Tracking**: Request status and follow-up reminders

### Form Flow
```
1. Select State → 2. Select Agency → 3. Request Type →
4. Request Details → 5. Requester Info → 6. Review → 7. Generate/Send
```

---

## Component 3: FOIA Wiki (Knowledge Base)

### Technical Stack
- **Search Engine**: Algolia or Elasticsearch
- **Content Management**: Headless CMS (Strapi) or Git-based
- **Frontend**: Next.js with MDX for rich content
- **AI Search**: OpenAI embeddings for semantic search

### Database Schema
```sql
-- Wiki articles and guides
CREATE TABLE wiki_articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  slug VARCHAR(200) UNIQUE,
  content TEXT,  -- Markdown content
  category VARCHAR(100),
  tags TEXT[],
  jurisdiction_codes TEXT[],  -- Which states this applies to
  difficulty_level VARCHAR(20),  -- 'beginner', 'intermediate', 'advanced'
  last_updated TIMESTAMP,
  author TEXT,
  views INTEGER DEFAULT 0,
  helpful_votes INTEGER DEFAULT 0,
  search_vector tsvector  -- For full-text search
);

-- Case studies and success stories
CREATE TABLE case_studies (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  jurisdiction_code VARCHAR(2),
  request_type VARCHAR(100),
  outcome VARCHAR(50),  -- 'successful', 'denied', 'partial'
  timeline_days INTEGER,
  summary TEXT,
  full_case_study TEXT,
  lessons_learned TEXT[],
  tags TEXT[],
  submitted_by TEXT,
  verified BOOLEAN DEFAULT FALSE
);

-- Future: Agency accountability tracking
CREATE TABLE agency_performance (
  id SERIAL PRIMARY KEY,
  jurisdiction_id INTEGER REFERENCES jurisdictions(id),
  agency_id INTEGER REFERENCES agencies(id),
  response_rate DECIMAL(3,2),  -- 0.00 to 1.00
  avg_response_time DECIMAL(5,2),
  fee_compliance DECIMAL(3,2),
  citizen_rating DECIMAL(3,2),
  last_updated TIMESTAMP,
  report_period VARCHAR(20)  -- 'Q1-2025', etc.
);
```

### Wiki Categories
- **Getting Started**: Basic FOIA concepts and rights
- **State Guides**: Detailed guides for each jurisdiction
- **Request Types**: How to request different types of records
- **Common Issues**: Denials, delays, fees, appeals
- **Case Studies**: Real examples with outcomes
- **Legal Resources**: Laws, precedents, court cases
- **Tools & Templates**: Forms, letter templates, checklists
- **Agency Profiles**: Contact info, response patterns, tips
- **Name & Shame**: Accountability reporting (future feature)

### Search Features
- **Full-text Search**: Search all articles, case studies
- **Semantic Search**: AI-powered understanding of queries
- **Filter by State**: Show content relevant to user's jurisdiction
- **Filter by Topic**: Legal, practical, case studies, etc.
- **Difficulty Level**: Filter by beginner/intermediate/advanced
- **Recent Updates**: Show newly updated content

---

## Shared Infrastructure

### Authentication System
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  preferences JSONB,
  role VARCHAR(20) DEFAULT 'citizen'  -- 'citizen', 'admin', 'editor'
);

CREATE TABLE user_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  jurisdiction_code VARCHAR(2),
  agency_id INTEGER REFERENCES agencies(id),
  request_data JSONB,
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Analytics & Monitoring
- **Usage Tracking**: Page views, tool usage, search queries
- **Performance Monitoring**: API response times, error rates
- **User Feedback**: Satisfaction surveys, feature requests
- **Impact Metrics**: Successful requests, appeals won, time saved

### Content Management
- **Editorial Workflow**: Draft → Review → Publish
- **Version Control**: Track changes to wiki content
- **Community Contributions**: User submissions with moderation
- **Expert Review**: Legal accuracy validation

---

## Deployment Architecture

### Production Environment
```
CloudFlare CDN
    ↓
Load Balancer
    ↓
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Next.js   │  │   API       │  │  Supabase   │
│   Frontend  │  │   Backend   │  │  Database   │
│   (Vercel)  │  │  (Railway) │  │  (Hosted)   │
└─────────────┘  └─────────────┘  └─────────────┘
```

### Development Workflow
```
development → testing → main (protected)
     ↓            ↓         ↓
   Dev Deploy  Staging   Production
```

## Launch Checklist

### Pre-Launch (MVP Ready)
- [ ] Supabase schema deployed with statute data
- [ ] API endpoints tested and documented
- [ ] Interactive map with all 51 jurisdictions
- [ ] FOIA generator with state-specific templates
- [ ] Wiki with essential citizen guides (50+ articles)
- [ ] Search functionality across all components
- [ ] Basic user analytics implementation
- [ ] Mobile responsive design
- [ ] Performance optimization (< 3s load times)

### Post-Launch Iteration
- [ ] User feedback collection system
- [ ] A/B testing for conversion optimization
- [ ] Advanced search with AI recommendations
- [ ] Community contribution features
- [ ] Agency accountability tracking
- [ ] Appeal analyzer tool development
- [ ] Document repository planning

### Success Metrics
- **Transparency Map**: Monthly active users, state comparisons
- **FOIA Generator**: Requests generated, success rate tracking
- **Wiki**: Search queries, article engagement, user retention
- **Overall**: Government transparency improvement, citizen empowerment

---
*This architecture ensures scalable, maintainable, and impactful tools for government transparency and citizen empowerment, following The Hole Foundation's standards for accountability and excellence.*