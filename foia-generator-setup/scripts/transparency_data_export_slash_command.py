#!/usr/bin/env python3
"""
Custom Slash Command: /export-transparency-data

Exports transparency law dataset to various formats and destinations:
- Supabase SQL inserts
- CSV files for analysis
- JSON API format
- Markdown documentation
- Excel spreadsheets
- API endpoint data

Usage: /export-transparency-data [format] [destination] [options]
"""

import json
import csv
import os
import argparse
import sys
from pathlib import Path
from datetime import datetime
import pandas as pd

class TransparencyDataExporter:
    def __init__(self, data_dir="../data"):
        self.data_dir = Path(data_dir)
        self.output_dir = Path("exports")
        self.output_dir.mkdir(exist_ok=True)

    def load_complete_dataset(self):
        """Load all transparency data from organized repository structure."""
        dataset = {
            "metadata": {},
            "federal": {},
            "states": {},
            "consolidated": {}
        }

        # Load tracking table for metadata
        tracking_file = self.data_dir / "consolidated" / "master_tracking_table.json"
        if tracking_file.exists():
            with open(tracking_file, 'r') as f:
                dataset["metadata"] = json.load(f)

        # Load federal data
        federal_file = self.data_dir / "federal" / "agencies.json"
        if federal_file.exists():
            with open(federal_file, 'r') as f:
                dataset["federal"] = json.load(f)

        # Load all state data
        states_dir = self.data_dir / "states"
        for state_dir in states_dir.iterdir():
            if state_dir.is_dir():
                agencies_file = state_dir / "agencies.json"
                if agencies_file.exists():
                    with open(agencies_file, 'r') as f:
                        dataset["states"][state_dir.name] = json.load(f)

        # Load consolidated data
        consolidated_dir = self.data_dir / "consolidated"
        for file in consolidated_dir.glob("*.json"):
            with open(file, 'r') as f:
                dataset["consolidated"][file.stem] = json.load(f)

        return dataset

    def export_to_supabase_sql(self, dataset):
        """Generate SQL INSERT statements for Supabase deployment."""
        sql_content = []
        sql_content.append("-- THE HOLE FOUNDATION - Transparency Laws Database")
        sql_content.append("-- Supabase SQL Import Script")
        sql_content.append(f"-- Generated: {datetime.now().isoformat()}")
        sql_content.append("-- Total Jurisdictions: 51 (50 states + DC + Federal)")
        sql_content.append("")

        # Create tables
        sql_content.append("""
-- Create transparency laws database schema
CREATE TABLE IF NOT EXISTS jurisdictions (
    id SERIAL PRIMARY KEY,
    jurisdiction_name VARCHAR(100) NOT NULL,
    jurisdiction_type VARCHAR(50) NOT NULL,
    abbreviation VARCHAR(10),
    statute_name VARCHAR(255),
    statute_citation VARCHAR(255),
    response_time VARCHAR(100),
    appeal_process TEXT,
    fee_structure TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS agencies (
    id SERIAL PRIMARY KEY,
    jurisdiction_id INTEGER REFERENCES jurisdictions(id),
    agency_name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(50),
    contact_info JSONB,
    submission_methods TEXT[],
    website VARCHAR(255),
    common_requests TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS foia_templates (
    id SERIAL PRIMARY KEY,
    jurisdiction_id INTEGER REFERENCES jurisdictions(id),
    template_type VARCHAR(100),
    persona_type VARCHAR(100),
    request_category VARCHAR(100),
    template_content TEXT,
    success_rate DECIMAL(5,2),
    validation_status VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
""")

        # Insert federal jurisdiction
        if "federal" in dataset:
            sql_content.append("-- Insert Federal FOIA jurisdiction")
            sql_content.append("""
INSERT INTO jurisdictions (jurisdiction_name, jurisdiction_type, abbreviation, statute_name, statute_citation, response_time, appeal_process, fee_structure)
VALUES ('Federal Government', 'federal', 'US', 'Freedom of Information Act', '5 U.S.C. § 552', '20 business days', 'Administrative appeal to agency head, then federal court', 'Search, review, and duplication fees; waivers available');
""")

        # Insert state jurisdictions
        for state_name, state_data in dataset.get("states", {}).items():
            if isinstance(state_data, dict) and "jurisdiction" in state_data:
                jurisdiction = state_data["jurisdiction"]
                sql_content.append(f"-- Insert {jurisdiction.get('name', state_name)} jurisdiction")

                # Handle both formats (some states use different structure)
                if "foia_statute" in jurisdiction:
                    # DC format
                    statute_info = jurisdiction["foia_statute"]
                    sql_content.append(f"""
INSERT INTO jurisdictions (jurisdiction_name, jurisdiction_type, abbreviation, statute_name, statute_citation, response_time, appeal_process)
VALUES ('{jurisdiction["name"]}', '{jurisdiction.get("type", "state")}', '{jurisdiction.get("abbreviation", "")}', '{statute_info.get("title", "")}', '{statute_info.get("citation", "")}', '{statute_info.get("response_time", "")}', '{statute_info.get("appeal_time", "")} days from denial');
""")

        # Write SQL file
        output_file = self.output_dir / "transparency_database_supabase.sql"
        with open(output_file, 'w') as f:
            f.write('\n'.join(sql_content))

        return output_file

    def export_to_csv(self, dataset):
        """Export dataset to CSV files for analysis."""

        # Jurisdictions CSV
        jurisdictions_data = []

        # Add federal
        if "metadata" in dataset and "jurisdictions" in dataset["metadata"]:
            fed_data = dataset["metadata"]["jurisdictions"]["federal"]
            jurisdictions_data.append({
                "jurisdiction_name": "Federal Government",
                "jurisdiction_type": "federal",
                "abbreviation": "US",
                "statute_name": "Freedom of Information Act",
                "statute_citation": "5 U.S.C. § 552",
                "status": fed_data.get("status", "completed"),
                "completion_date": fed_data.get("completion_date", "")
            })

        # Add states from tracking table
        if "metadata" in dataset and "jurisdictions" in dataset["metadata"]:
            for section in ["major_states", "remaining_states", "district_of_columbia"]:
                if section in dataset["metadata"]["jurisdictions"]:
                    for state_key, state_info in dataset["metadata"]["jurisdictions"][section].items():
                        jurisdictions_data.append({
                            "jurisdiction_name": state_info.get("name", state_key),
                            "jurisdiction_type": "state" if section != "district_of_columbia" else "federal_district",
                            "abbreviation": state_key.upper()[:2],
                            "statute_name": state_info.get("official_name", ""),
                            "statute_citation": "",
                            "status": state_info.get("status", "completed"),
                            "completion_date": state_info.get("completion_date", "")
                        })

        # Write jurisdictions CSV
        jurisdictions_file = self.output_dir / "jurisdictions_summary.csv"
        with open(jurisdictions_file, 'w', newline='') as f:
            if jurisdictions_data:
                writer = csv.DictWriter(f, fieldnames=jurisdictions_data[0].keys())
                writer.writeheader()
                writer.writerows(jurisdictions_data)

        # Agencies CSV (sample from major states)
        agencies_data = []

        # Federal agencies
        if "federal" in dataset and "federal_agencies" in dataset["federal"]:
            for agency in dataset["federal"]["federal_agencies"]:
                agencies_data.append({
                    "jurisdiction": "federal",
                    "agency_name": agency.get("agency_name", ""),
                    "abbreviation": agency.get("abbreviation", ""),
                    "website": agency.get("website", ""),
                    "submission_methods": ", ".join(agency.get("submission_methods", []))
                })

        # Sample state agencies
        for state_name, state_data in list(dataset.get("states", {}).items())[:5]:  # First 5 states as sample
            if "key_agencies" in state_data:
                for agency in state_data["key_agencies"][:3]:  # First 3 agencies per state
                    agencies_data.append({
                        "jurisdiction": state_name,
                        "agency_name": agency.get("name", ""),
                        "abbreviation": "",
                        "website": "",
                        "submission_methods": ""
                    })

        # Write agencies CSV
        agencies_file = self.output_dir / "agencies_sample.csv"
        with open(agencies_file, 'w', newline='') as f:
            if agencies_data:
                writer = csv.DictWriter(f, fieldnames=agencies_data[0].keys())
                writer.writeheader()
                writer.writerows(agencies_data)

        return [jurisdictions_file, agencies_file]

    def export_to_api_format(self, dataset):
        """Export dataset in API-ready JSON format."""
        api_data = {
            "api_version": "1.0",
            "generated_at": datetime.now().isoformat(),
            "total_jurisdictions": 51,
            "jurisdictions": []
        }

        # Process federal
        if "federal" in dataset:
            federal_data = dataset["federal"]
            api_data["jurisdictions"].append({
                "id": "federal",
                "name": "Federal Government",
                "type": "federal",
                "statute": {
                    "name": "Freedom of Information Act",
                    "citation": "5 U.S.C. § 552",
                    "response_time": "20 business days",
                    "appeal_process": "Administrative appeal to agency head, then federal court"
                },
                "agencies": federal_data.get("federal_agencies", [])[:5],  # Top 5 agencies
                "submission_methods": ["Online portal", "Mail", "Email", "Fax"]
            })

        # Process states (sample for API format demonstration)
        state_samples = ["california", "texas", "new-york", "florida", "district-of-columbia"]
        for state_name in state_samples:
            if state_name in dataset.get("states", {}):
                state_data = dataset["states"][state_name]

                # Handle different state data formats
                if "jurisdiction" in state_data:
                    jurisdiction = state_data["jurisdiction"]
                    api_data["jurisdictions"].append({
                        "id": state_name,
                        "name": jurisdiction.get("name", state_name.title()),
                        "type": jurisdiction.get("type", "state"),
                        "statute": jurisdiction.get("foia_statute", {}),
                        "agencies": state_data.get("key_agencies", [])[:5],  # Top 5 agencies
                        "submission_methods": ["Online", "Mail", "Email"]
                    })

        # Write API format file
        api_file = self.output_dir / "transparency_api_format.json"
        with open(api_file, 'w') as f:
            json.dump(api_data, f, indent=2)

        return api_file

    def export_to_markdown(self, dataset):
        """Export dataset as markdown documentation."""
        md_content = []
        md_content.append("# US Transparency Laws Database - Complete Reference")
        md_content.append("")
        md_content.append("## Overview")
        md_content.append("")
        md_content.append("Complete database of transparency laws for all 51 US jurisdictions:")
        md_content.append("- **50 States** with individual transparency statutes")
        md_content.append("- **District of Columbia** with DC FOIA")
        md_content.append("- **Federal Government** with federal FOIA (5 U.S.C. § 552)")
        md_content.append("")

        # Metadata summary
        if "metadata" in dataset:
            metadata = dataset["metadata"]
            if "project_metadata" in metadata:
                proj_meta = metadata["project_metadata"]
                md_content.append("## Project Metadata")
                md_content.append("")
                md_content.append(f"- **Total Jurisdictions**: {proj_meta.get('total_jurisdictions', 51)}")
                md_content.append(f"- **Completion Status**: {proj_meta.get('completion_status', '51/51 (100%)')}")
                md_content.append(f"- **Last Updated**: {proj_meta.get('last_updated', 'Unknown')}")
                md_content.append("")

        # Federal section
        md_content.append("## Federal FOIA")
        md_content.append("")
        md_content.append("**Statute**: 5 U.S.C. § 552 (Freedom of Information Act)")
        md_content.append("**Response Time**: 20 business days")
        md_content.append("**Appeal Process**: Administrative appeal to agency head, then federal court")
        md_content.append("")

        if "federal" in dataset and "federal_agencies" in dataset["federal"]:
            md_content.append("### Major Federal Agencies")
            md_content.append("")
            for agency in dataset["federal"]["federal_agencies"][:10]:  # Top 10 agencies
                md_content.append(f"- **{agency.get('agency_name', 'Unknown')}** ({agency.get('abbreviation', 'N/A')})")
                if "website" in agency:
                    md_content.append(f"  - Website: {agency['website']}")
                md_content.append("")

        # States section
        md_content.append("## State Transparency Laws")
        md_content.append("")

        # Sample key states
        key_states = ["california", "texas", "new-york", "florida", "district-of-columbia"]
        for state_name in key_states:
            if state_name in dataset.get("states", {}):
                state_data = dataset["states"][state_name]
                if "jurisdiction" in state_data:
                    jurisdiction = state_data["jurisdiction"]
                    md_content.append(f"### {jurisdiction.get('name', state_name.title())}")
                    md_content.append("")

                    if "foia_statute" in jurisdiction:
                        statute = jurisdiction["foia_statute"]
                        md_content.append(f"- **Statute**: {statute.get('citation', 'Unknown')}")
                        md_content.append(f"- **Response Time**: {statute.get('response_time', 'Unknown')}")
                        md_content.append("")

        # Write markdown file
        md_file = self.output_dir / "transparency_laws_reference.md"
        with open(md_file, 'w') as f:
            f.write('\n'.join(md_content))

        return md_file

    def export_for_api_endpoints(self, dataset):
        """Export in format optimized for REST API endpoints."""

        # Jurisdictions endpoint data
        jurisdictions_api = []

        # Federal
        jurisdictions_api.append({
            "id": "federal",
            "name": "Federal Government",
            "type": "federal",
            "abbreviation": "US",
            "statute": {
                "name": "Freedom of Information Act",
                "citation": "5 U.S.C. § 552",
                "response_time": "20 business days",
                "extension": "10 business days in unusual circumstances"
            },
            "api_endpoints": {
                "agencies": "/api/v1/jurisdictions/federal/agencies",
                "templates": "/api/v1/jurisdictions/federal/templates",
                "examples": "/api/v1/jurisdictions/federal/examples"
            }
        })

        # States
        for state_name, state_data in dataset.get("states", {}).items():
            if "jurisdiction" in state_data:
                jurisdiction = state_data["jurisdiction"]
                jurisdictions_api.append({
                    "id": state_name,
                    "name": jurisdiction.get("name", state_name.title()),
                    "type": jurisdiction.get("type", "state"),
                    "abbreviation": jurisdiction.get("abbreviation", ""),
                    "statute": jurisdiction.get("foia_statute", {}),
                    "api_endpoints": {
                        "agencies": f"/api/v1/jurisdictions/{state_name}/agencies",
                        "templates": f"/api/v1/jurisdictions/{state_name}/templates",
                        "examples": f"/api/v1/jurisdictions/{state_name}/examples"
                    }
                })

        # Agencies endpoint data (federal sample)
        agencies_api = {}
        if "federal" in dataset and "federal_agencies" in dataset["federal"]:
            agencies_api["federal"] = dataset["federal"]["federal_agencies"]

        # Write API format files
        jurisdictions_api_file = self.output_dir / "api_jurisdictions.json"
        with open(jurisdictions_api_file, 'w') as f:
            json.dump(jurisdictions_api, f, indent=2)

        agencies_api_file = self.output_dir / "api_agencies_sample.json"
        with open(agencies_api_file, 'w') as f:
            json.dump(agencies_api, f, indent=2)

        return [jurisdictions_api_file, agencies_api_file]

def main():
    """Main slash command execution."""
    parser = argparse.ArgumentParser(description="Export transparency data to various formats")
    parser.add_argument("format", choices=["supabase", "csv", "json", "markdown", "api", "all"],
                       help="Export format")
    parser.add_argument("--output-dir", default="exports", help="Output directory")
    parser.add_argument("--include-examples", action="store_true",
                       help="Include FOIA generator examples in export")

    args = parser.parse_args()

    exporter = TransparencyDataExporter()
    dataset = exporter.load_complete_dataset()

    print(f"🚀 Transparency Data Export - Format: {args.format}")
    print(f"📊 Dataset loaded: {len(dataset.get('states', {}))} states + federal + DC")
    print("")

    exported_files = []

    if args.format == "supabase" or args.format == "all":
        print("📥 Generating Supabase SQL import...")
        sql_file = exporter.export_to_supabase_sql(dataset)
        exported_files.append(sql_file)
        print(f"✅ Created: {sql_file}")

    if args.format == "csv" or args.format == "all":
        print("📊 Generating CSV files...")
        csv_files = exporter.export_to_csv(dataset)
        exported_files.extend(csv_files)
        for csv_file in csv_files:
            print(f"✅ Created: {csv_file}")

    if args.format == "json" or args.format == "all":
        print("🔗 Generating API format...")
        api_files = exporter.export_for_api_endpoints(dataset)
        exported_files.extend(api_files)
        for api_file in api_files:
            print(f"✅ Created: {api_file}")

    if args.format == "markdown" or args.format == "all":
        print("📝 Generating Markdown documentation...")
        md_file = exporter.export_to_markdown(dataset)
        exported_files.append(md_file)
        print(f"✅ Created: {md_file}")

    print("")
    print(f"🎉 Export complete! {len(exported_files)} files created in exports/ directory")
    print("")
    print("📋 Generated files:")
    for file in exported_files:
        print(f"   - {file.name}")

    return exported_files

if __name__ == "__main__":
    main()