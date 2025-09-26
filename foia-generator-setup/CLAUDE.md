# THE HOLE FOUNDATION - TRANSPARENCY PROJECT

## Project Overview
Complete US transparency laws database with AI-powered FOIA generator and analytics platform.

## Custom Commands

### /export-transparency
Export the complete 51-jurisdiction transparency database to various formats for deployment and analysis.

```bash
python scripts/simple_transparency_export.py ${1:-summary}
```

**Usage**: `/export-transparency [format]`

**Formats**:
- `supabase` - Generate SQL INSERT statements for Supabase deployment
- `api` - Create API-ready JSON format for REST endpoints
- `csv` - Export to CSV for Excel/Google Sheets analysis
- `markdown` - Generate human-readable documentation
- `summary` - Display dataset overview and statistics
- `all` - Generate all formats simultaneously

**Examples**:
- `/export-transparency supabase` - Deploy to production database
- `/export-transparency csv` - Export for research analysis
- `/export-transparency api` - Create REST API data
- `/export-transparency all` - Complete export package

**Output**: Files saved to `exports/` directory with timestamped metadata.

## Project Structure

```
Statute-Project/
├── data/                           # Complete 51-jurisdiction database
│   ├── federal/                    # Federal FOIA agencies and templates
│   ├── states/                     # All 50 states + DC agency data
│   └── consolidated/               # Master database and tracking
├── foia-generator-setup/           # AI-powered FOIA generator
│   ├── data/examples/              # High-quality training examples
│   ├── scripts/                    # Export and utility scripts
│   └── docs/                       # Technical documentation
├── documentation/                  # Professional project documentation
└── scripts/                        # Development and deployment tools
```

## Data Quality Standards
- All statutory citations verified from official government sources
- Attorney-reviewed legal accuracy and compliance
- Professional organization with consistent naming conventions
- Integration-ready format for immediate deployment

## Development Guidelines
- Follow professional language guidelines (analytical rather than adversarial)
- Maintain unified mission statement across all repositories
- Ensure community standards and contributor guidelines compliance
- Focus on empowering transparency advocacy through professional tools

## Mission Statement
Empower citizens, journalists, and advocates to effectively exercise their rights under transparency laws through comprehensive data, analytical tools, and strategic guidance.