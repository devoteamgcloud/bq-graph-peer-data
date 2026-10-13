-- ============================================================================
-- DEMO STEP 3: CREATE THE CENTRAL PROPERTY GRAPH
-- ============================================================================
-- Client Presentation Talking Points:
-- 1. This DDL statement is purely a METADATA CATALOG definition (like a View).
--    It takes seconds to run, requires NO data movement, and zero extra storage costs.
-- 2. Unified Graph over a Data Mesh: Notice how the graph seamlessly spans across
--    both `academic_editorial` and `peer_review` datasets into one unified property graph.
-- 3. Node Tables:
--    - KEY (col): Unique identifier of the node entity.
--    - LABEL: How the node is matched in GQL queries (e.g. (a:Author)).
--    - PROPERTIES: Attributes exposed to graph queries.
-- 4. Edge Tables:
--    - KEY (col1, col2): Composite or single key identifying the relationship.
--    - SOURCE KEY: Origin node foreign key.
--    - DESTINATION KEY: Target node foreign key.
--    - LABEL: Relationship name in GQL (e.g. -[:Writes]->, -[:SpecializesIn]->).
-- ============================================================================

CREATE OR REPLACE PROPERTY GRAPH `academic_editorial.ScholarlyCentralGraph`
-- ----------------------------------------------------
-- 1. Register Node Tables
-- ----------------------------------------------------
NODE TABLES (
  `peer_review.Author` AS Author 
    KEY (author_id) 
    LABEL Author 
    PROPERTIES (author_id, name, email, orcid, h_index),

  `academic_editorial.Paper` AS Paper 
    KEY (paper_id) 
    LABEL Paper 
    PROPERTIES (paper_id, title, abstract, publish_date, citations_count),

  `academic_editorial.Subject` AS Subject 
    KEY (subject_id) 
    LABEL Subject 
    PROPERTIES (subject_id, name),

  `peer_review.Institution` AS Institution 
    KEY (institution_id) 
    LABEL Institution 
    PROPERTIES (institution_id, name, country)
)
-- ----------------------------------------------------
-- 2. Register Edge Tables (Directed Relationships)
-- ----------------------------------------------------
EDGE TABLES (
  -- Author -> Writes -> Paper
  `peer_review.Writes` AS Writes
    KEY (author_id, paper_id)
    SOURCE KEY (author_id) REFERENCES Author (author_id)
    DESTINATION KEY (paper_id) REFERENCES Paper (paper_id)
    LABEL Writes,

  -- Paper -> Cites -> Paper (Self-referential / recursive edge)
  `academic_editorial.Cites` AS Cites
    KEY (citing_id, cited_id)
    SOURCE KEY (citing_id) REFERENCES Paper (paper_id)
    DESTINATION KEY (cited_id) REFERENCES Paper (paper_id)
    LABEL Cites,

  -- Paper -> HasSubject -> Subject
  `academic_editorial.HasSubject` AS HasSubject
    KEY (paper_id, subject_id)
    SOURCE KEY (paper_id) REFERENCES Paper (paper_id)
    DESTINATION KEY (subject_id) REFERENCES Subject (subject_id)
    LABEL HasSubject,

  -- Author -> Affiliated -> Institution
  `peer_review.Affiliated` AS Affiliated
    KEY (author_id, institution_id)
    SOURCE KEY (author_id) REFERENCES Author (author_id)
    DESTINATION KEY (institution_id) REFERENCES Institution (institution_id)
    LABEL Affiliated,

  -- Author -> SpecializesIn -> Subject
  `peer_review.SpecializesIn` AS SpecializesIn
    KEY (author_id, subject_id)
    SOURCE KEY (author_id) REFERENCES Author (author_id)
    DESTINATION KEY (subject_id) REFERENCES Subject (subject_id)
    LABEL SpecializesIn
);
