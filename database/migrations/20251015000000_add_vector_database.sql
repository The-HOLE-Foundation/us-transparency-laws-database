-- ============================================================================
-- US Transparency Laws Database - Vector Database for AI Agent
-- ============================================================================
-- Project: The HOLE Foundation - US Transparency Laws Database
-- Version: v0.13 (Vector Database for RAG)
-- Date: 2025-10-07
-- Description: pgvector tables for FOIA AI agent with hybrid search
-- Documentation: /documentation/v0.13-VECTOR_DATABASE_DESIGN.md
-- ============================================================================

-- ============================================================================
-- PART 1: ENABLE EXTENSIONS
-- ============================================================================

-- Enable pgvector for vector storage and similarity search
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify uuid-ossp is enabled (should already be from initial schema)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PART 2: KNOWLEDGE BASE DOCUMENTS TABLE
-- ============================================================================
-- Stores curated high-yield documents for AI agent context
-- Includes statute text, exemption guidance, best practices, case law
-- ============================================================================

CREATE TABLE foia_knowledge_documents (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Document Metadata
    title TEXT NOT NULL,
    document_type TEXT NOT NULL CHECK (document_type IN (
        'statute_text',           -- Full statutory text
        'exemption_guidance',     -- How to navigate exemptions
        'right_of_access',        -- Affirmative rights explanation
        'successful_request',     -- Template/example of successful request
        'appeal_strategy',        -- How to appeal denials
        'fee_waiver_guidance',    -- How to request fee waivers
        'timing_strategy',        -- How to leverage response deadlines
        'agency_specific_tips',   -- Agency-specific advice
        'case_law_summary',       -- Relevant court decisions
        'best_practices'          -- General FOIA best practices
    )),

    -- Jurisdiction Linking
    jurisdiction_id UUID REFERENCES jurisdictions(id) ON DELETE CASCADE,
    jurisdiction_slug TEXT NOT NULL,
    jurisdiction_name TEXT NOT NULL,

    -- Document Content
    content TEXT NOT NULL,
    summary TEXT,
    key_points JSONB,

    -- Search Optimization: Full-Text Search (auto-generated tsvector)
    content_fts tsvector GENERATED ALWAYS AS (
        to_tsvector('english',
            coalesce(title, '') || ' ' ||
            coalesce(content, '') || ' ' ||
            coalesce(summary, '')
        )
    ) STORED,

    -- Search Optimization: Semantic Search (OpenAI embeddings)
    embedding vector(1536),  -- OpenAI text-embedding-3-small

    -- Metadata for AI Agent
    use_case_tags TEXT[],                     -- ['fee_waiver', 'expedited_processing']
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    citation TEXT,
    verified_by TEXT,
    verified_at TIMESTAMPTZ,

    -- Access Control
    is_public BOOLEAN NOT NULL DEFAULT true,
    owner_id UUID,                            -- For user-submitted examples

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments
COMMENT ON TABLE foia_knowledge_documents IS 'Curated knowledge base for FOIA AI agent - includes statute text, strategies, and best practices';
COMMENT ON COLUMN foia_knowledge_documents.embedding IS 'OpenAI text-embedding-3-small vector (1536 dimensions) for semantic search';
COMMENT ON COLUMN foia_knowledge_documents.content_fts IS 'Auto-generated tsvector for full-text keyword search';
COMMENT ON COLUMN foia_knowledge_documents.use_case_tags IS 'Tags for filtering by use case (e.g., fee_waiver, expedited)';

-- ============================================================================
-- PART 3: REQUEST TEMPLATES TABLE
-- ============================================================================
-- Stores proven FOIA request templates with placeholders
-- ============================================================================

CREATE TABLE foia_request_templates (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Template Metadata
    template_name TEXT NOT NULL,
    description TEXT,

    -- Jurisdiction Linking
    jurisdiction_id UUID REFERENCES jurisdictions(id) ON DELETE CASCADE,
    jurisdiction_slug TEXT NOT NULL,

    -- Template Content
    template_text TEXT NOT NULL,              -- Full template with {{placeholders}}
    required_fields JSONB,                    -- {'requester_name': 'string', 'agency_name': 'string'}
    optional_fields JSONB,

    -- Search Optimization: Full-Text Search
    template_fts tsvector GENERATED ALWAYS AS (
        to_tsvector('english',
            coalesce(template_name, '') || ' ' ||
            coalesce(description, '')
        )
    ) STORED,

    -- Search Optimization: Semantic Search
    embedding vector(1536),

    -- Template Metadata
    use_cases TEXT[],
    difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    success_rate DECIMAL(3,2) CHECK (success_rate >= 0 AND success_rate <= 1),
    usage_count INTEGER DEFAULT 0,

    -- Example Requests
    example_filled TEXT,
    example_response TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments
COMMENT ON TABLE foia_request_templates IS 'Proven FOIA request templates with placeholders for AI-assisted generation';
COMMENT ON COLUMN foia_request_templates.template_text IS 'Template with {{placeholders}} for dynamic field insertion';
COMMENT ON COLUMN foia_request_templates.success_rate IS 'Success rate based on user feedback (0.00-1.00)';

-- ============================================================================
-- PART 4: EXEMPTION STRATEGIES TABLE
-- ============================================================================
-- Links to existing exemptions table with strategic guidance
-- ============================================================================

CREATE TABLE foia_exemption_strategies (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Link to existing exemption (from v0.11.1)
    exemption_id UUID REFERENCES exemptions(id) ON DELETE CASCADE,
    jurisdiction_slug TEXT NOT NULL,

    -- Strategy Content
    exemption_name TEXT NOT NULL,
    strategy_title TEXT NOT NULL,
    strategy_content TEXT NOT NULL,

    -- Search Optimization: Full-Text Search
    strategy_fts tsvector GENERATED ALWAYS AS (
        to_tsvector('english',
            coalesce(strategy_title, '') || ' ' ||
            coalesce(strategy_content, '')
        )
    ) STORED,

    -- Search Optimization: Semantic Search
    embedding vector(1536),

    -- Strategy Metadata
    success_rate DECIMAL(3,2) CHECK (success_rate >= 0 AND success_rate <= 1),
    alternative_approaches TEXT[],
    case_law_citations TEXT[],

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments
COMMENT ON TABLE foia_exemption_strategies IS 'Strategic guidance for navigating and overcoming FOIA exemptions';
COMMENT ON COLUMN foia_exemption_strategies.exemption_id IS 'Foreign key to exemptions table (v0.11.1)';

-- ============================================================================
-- PART 5: SUCCESSFUL EXAMPLES TABLE
-- ============================================================================
-- Anonymized successful FOIA requests for learning and inspiration
-- ============================================================================

CREATE TABLE foia_successful_examples (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Request Details
    request_subject TEXT NOT NULL,
    jurisdiction_slug TEXT NOT NULL,
    agency_name TEXT,

    -- Request and Response
    request_text TEXT NOT NULL,
    response_summary TEXT,
    timeline_days INTEGER,

    -- Search Optimization: Full-Text Search
    content_fts tsvector GENERATED ALWAYS AS (
        to_tsvector('english',
            coalesce(request_subject, '') || ' ' ||
            coalesce(request_text, '') || ' ' ||
            coalesce(response_summary, '')
        )
    ) STORED,

    -- Search Optimization: Semantic Search
    embedding vector(1536),

    -- Metadata
    challenges_faced TEXT[],
    strategies_used TEXT[],
    lessons_learned TEXT,

    -- Privacy
    anonymized BOOLEAN NOT NULL DEFAULT true,
    contributed_by UUID,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Comments
COMMENT ON TABLE foia_successful_examples IS 'Anonymized examples of successful FOIA requests for learning and inspiration';
COMMENT ON COLUMN foia_successful_examples.anonymized IS 'Must be true for public access; false only for contributor access';

-- ============================================================================
-- PART 6: INDEXES FOR PERFORMANCE
-- ============================================================================

-- ============================================================================
-- 6.1: HNSW Indexes for Vector Similarity Search
-- ============================================================================
-- Using HNSW (Hierarchical Navigable Small World) algorithm
-- m=16, ef_construction=64 are optimal for most use cases

CREATE INDEX idx_knowledge_docs_embedding
ON foia_knowledge_documents
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

CREATE INDEX idx_templates_embedding
ON foia_request_templates
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

CREATE INDEX idx_strategies_embedding
ON foia_exemption_strategies
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

CREATE INDEX idx_examples_embedding
ON foia_successful_examples
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- ============================================================================
-- 6.2: GIN Indexes for Full-Text Search
-- ============================================================================

CREATE INDEX idx_knowledge_docs_fts
ON foia_knowledge_documents
USING GIN (content_fts);

CREATE INDEX idx_templates_fts
ON foia_request_templates
USING GIN (template_fts);

CREATE INDEX idx_strategies_fts
ON foia_exemption_strategies
USING GIN (strategy_fts);

CREATE INDEX idx_examples_fts
ON foia_successful_examples
USING GIN (content_fts);

-- ============================================================================
-- 6.3: Compound Indexes for Filtering
-- ============================================================================

-- Jurisdiction filtering
CREATE INDEX idx_knowledge_docs_jurisdiction
ON foia_knowledge_documents(jurisdiction_slug, document_type);

CREATE INDEX idx_templates_jurisdiction
ON foia_request_templates(jurisdiction_slug);

CREATE INDEX idx_strategies_jurisdiction
ON foia_exemption_strategies(jurisdiction_slug);

CREATE INDEX idx_examples_jurisdiction
ON foia_successful_examples(jurisdiction_slug);

-- Use case filtering
CREATE INDEX idx_knowledge_docs_tags
ON foia_knowledge_documents
USING GIN (use_case_tags);

CREATE INDEX idx_templates_use_cases
ON foia_request_templates
USING GIN (use_cases);

-- ============================================================================
-- PART 7: HYBRID SEARCH FUNCTION
-- ============================================================================
-- Combines semantic search (pgvector) with keyword search (tsvector)
-- Uses Reciprocal Rank Fusion (RRF) for result ranking
-- ============================================================================

CREATE OR REPLACE FUNCTION search_foia_knowledge(
    query_text TEXT,
    query_embedding vector(1536),
    target_jurisdiction TEXT DEFAULT NULL,
    limit_results INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    document_type TEXT,
    content TEXT,
    jurisdiction_name TEXT,
    relevance_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    WITH semantic_search AS (
        -- Semantic search using cosine similarity
        SELECT
            d.id,
            1 - (d.embedding <=> query_embedding) AS semantic_score,
            ROW_NUMBER() OVER (ORDER BY d.embedding <=> query_embedding) AS semantic_rank
        FROM foia_knowledge_documents d
        WHERE target_jurisdiction IS NULL OR d.jurisdiction_slug = target_jurisdiction
        ORDER BY d.embedding <=> query_embedding
        LIMIT limit_results * 2
    ),
    keyword_search AS (
        -- Keyword search using full-text search
        SELECT
            d.id,
            ts_rank(d.content_fts, websearch_to_tsquery('english', query_text)) AS keyword_score,
            ROW_NUMBER() OVER (
                ORDER BY ts_rank(d.content_fts, websearch_to_tsquery('english', query_text)) DESC
            ) AS keyword_rank
        FROM foia_knowledge_documents d
        WHERE d.content_fts @@ websearch_to_tsquery('english', query_text)
          AND (target_jurisdiction IS NULL OR d.jurisdiction_slug = target_jurisdiction)
        ORDER BY ts_rank(d.content_fts, websearch_to_tsquery('english', query_text)) DESC
        LIMIT limit_results * 2
    ),
    -- Reciprocal Rank Fusion (RRF): 1 / (k + rank)
    -- k=60 is standard from research literature
    combined AS (
        SELECT
            COALESCE(s.id, k.id) AS doc_id,
            (COALESCE(1.0 / (60 + s.semantic_rank), 0.0) +
             COALESCE(1.0 / (60 + k.keyword_rank), 0.0)) AS rrf_score
        FROM semantic_search s
        FULL OUTER JOIN keyword_search k ON s.id = k.id
    )
    SELECT
        d.id,
        d.title,
        d.document_type,
        d.content,
        d.jurisdiction_name,
        c.rrf_score AS relevance_score
    FROM combined c
    JOIN foia_knowledge_documents d ON c.doc_id = d.id
    ORDER BY c.rrf_score DESC
    LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON FUNCTION search_foia_knowledge IS 'Hybrid search combining semantic (pgvector) and keyword (tsvector) search using Reciprocal Rank Fusion';

-- ============================================================================
-- PART 8: ROW-LEVEL SECURITY (RLS)
-- ============================================================================

-- ============================================================================
-- 8.1: Enable RLS on All Tables
-- ============================================================================

ALTER TABLE foia_knowledge_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE foia_request_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE foia_exemption_strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE foia_successful_examples ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 8.2: Public Read Policies
-- ============================================================================

-- Public documents are readable by anyone
CREATE POLICY "Public documents are viewable by everyone"
    ON foia_knowledge_documents FOR SELECT
    USING (is_public = true);

-- User-contributed documents are only viewable by owner or if public
CREATE POLICY "Users can view their own documents"
    ON foia_knowledge_documents FOR SELECT
    USING (auth.uid() = owner_id OR is_public = true);

-- Users can insert their own documents
CREATE POLICY "Users can create their own documents"
    ON foia_knowledge_documents FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

-- Templates are always public
CREATE POLICY "Templates are viewable by everyone"
    ON foia_request_templates FOR SELECT
    USING (true);

-- Strategies are always public
CREATE POLICY "Strategies are viewable by everyone"
    ON foia_exemption_strategies FOR SELECT
    USING (true);

-- Anonymized examples are public, non-anonymized only to contributor
CREATE POLICY "Anonymized examples are viewable by everyone"
    ON foia_successful_examples FOR SELECT
    USING (anonymized = true OR auth.uid() = contributed_by);

-- ============================================================================
-- PART 9: TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Create trigger function (if not exists)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all vector tables
CREATE TRIGGER update_foia_knowledge_documents_updated_at
    BEFORE UPDATE ON foia_knowledge_documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_foia_request_templates_updated_at
    BEFORE UPDATE ON foia_request_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_foia_exemption_strategies_updated_at
    BEFORE UPDATE ON foia_exemption_strategies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_foia_successful_examples_updated_at
    BEFORE UPDATE ON foia_successful_examples
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- PART 10: UTILITY VIEWS
-- ============================================================================

-- ============================================================================
-- 10.1: Vector Database Statistics View
-- ============================================================================

CREATE OR REPLACE VIEW vector_database_stats AS
SELECT
    'foia_knowledge_documents' AS table_name,
    COUNT(*) AS total_documents,
    COUNT(embedding) AS documents_with_embeddings,
    COUNT(DISTINCT jurisdiction_slug) AS jurisdictions_covered,
    ARRAY_AGG(DISTINCT document_type) AS document_types
FROM foia_knowledge_documents
UNION ALL
SELECT
    'foia_request_templates' AS table_name,
    COUNT(*) AS total_documents,
    COUNT(embedding) AS documents_with_embeddings,
    COUNT(DISTINCT jurisdiction_slug) AS jurisdictions_covered,
    NULL AS document_types
FROM foia_request_templates
UNION ALL
SELECT
    'foia_exemption_strategies' AS table_name,
    COUNT(*) AS total_documents,
    COUNT(embedding) AS documents_with_embeddings,
    COUNT(DISTINCT jurisdiction_slug) AS jurisdictions_covered,
    NULL AS document_types
FROM foia_exemption_strategies
UNION ALL
SELECT
    'foia_successful_examples' AS table_name,
    COUNT(*) AS total_documents,
    COUNT(embedding) AS documents_with_embeddings,
    COUNT(DISTINCT jurisdiction_slug) AS jurisdictions_covered,
    NULL AS document_types
FROM foia_successful_examples;

-- Comments
COMMENT ON VIEW vector_database_stats IS 'Statistics view for monitoring vector database population and embedding coverage';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Next Steps:
-- 1. Verify migration: SELECT * FROM vector_database_stats;
-- 2. Test vector search: SELECT * FROM search_foia_knowledge('fee waiver', ...);
-- 3. Begin data curation (see v0.13-VECTOR_DATABASE_DESIGN.md)
-- 4. Set up Edge Function for embedding generation
-- ============================================================================
