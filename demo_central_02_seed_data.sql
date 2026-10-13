-- ============================================================================
-- DEMO STEP 2: SEED RELATIONAL DATA
-- ============================================================================
-- Client Presentation Talking Points:
-- 1. Ingestion is 100% standard SQL or BigQuery Batch/Streaming ingestion.
--    No special Cypher/GQL load commands, no ETL graph conversions needed.
-- 2. Scenario Storyline:
--    - Dr. Alice Smith (Harvard) & Dr. Bob Johnson (Harvard) co-author Paper 10 on CRISPR.
--    - Dr. Charlie Brown (Cambridge) also specializes in CRISPR and wrote Paper 40.
--    - CONFLICT OF INTEREST (COI) SCENARIO:
--      * Alice submits a paper for peer review.
--      * Bob CANNOT review it (Direct Co-Author conflict & Institutional conflict).
--      * Charlie IS an ideal reviewer candidate (Zero co-authorship, different institution, exact subject expertise).
-- ============================================================================

-- ----------------------------------------------------
-- 1. Seed Nodes (Entities)
-- ----------------------------------------------------

-- Seed Subjects
INSERT INTO `academic_editorial.Subject` (subject_id, name) VALUES
(101, 'CRISPR Gene Drives'),
(102, 'Quantum Computing'),
(103, 'Machine Learning');

-- Seed Institutions
INSERT INTO `peer_review.Institution` (institution_id, name, country) VALUES
(501, 'Harvard University', 'USA'),
(502, 'University of Cambridge', 'UK'),
(503, 'Max Planck Institute', 'Germany');

-- Seed Authors (Researchers / Reviewers)
INSERT INTO `peer_review.Author` (author_id, name, email, orcid, h_index) VALUES
(1, 'Dr. Alice Smith', 'alice.smith@harvard.edu', '0000-0001-1111-1111', 24),
(2, 'Dr. Bob Johnson', 'bob.johnson@harvard.edu', '0000-0002-2222-2222', 18),
(3, 'Dr. Charlie Brown', 'charlie.brown@cambridge.ac.uk', '0000-0003-3333-3333', 32);

-- Seed Papers
INSERT INTO `academic_editorial.Paper` (paper_id, title, abstract, publish_date, citations_count) VALUES
(10, 'Advanced CRISPR Gene Drives', 'A deep dive into CRISPR techniques and gene drive engineering.', '2026-01-15', 142),
(20, 'Applications of Gene Drives', 'An analysis of ecosystem-level impacts of genetic manipulation.', '2026-03-20', 85),
(30, 'Quantum Supremacy in Practice', 'Exploring physical implementations of error-corrected qubits.', '2026-05-10', 210),
(40, 'CRISPR Off-Target Effects', 'Methods to analyze and mitigate off-target cleavage in gene editing.', '2026-06-15', 95);

-- ----------------------------------------------------
-- 2. Seed Edges (Relationships & Foreign Keys)
-- ----------------------------------------------------

-- Author -> Writes -> Paper
-- Alice and Bob co-authored Paper 10
-- Alice wrote Paper 20
-- Charlie wrote Paper 30 and Paper 40
INSERT INTO `peer_review.Writes` (author_id, paper_id) VALUES
(1, 10),
(2, 10),
(1, 20),
(3, 30),
(3, 40);

-- Paper -> Cites -> Paper (Citation Network)
-- Paper 20 cites Paper 10
INSERT INTO `academic_editorial.Cites` (citing_id, cited_id) VALUES
(20, 10);

-- Paper -> HasSubject -> Subject (Taxonomy Mapping)
INSERT INTO `academic_editorial.HasSubject` (paper_id, subject_id) VALUES
(10, 101), -- Paper 10 is CRISPR
(20, 101), -- Paper 20 is CRISPR
(30, 102), -- Paper 30 is Quantum Computing
(40, 101); -- Paper 40 is CRISPR

-- Author -> Affiliated -> Institution (Institutional Conflict check)
-- Alice & Bob share Harvard affiliation (Conflict)
-- Charlie is at Cambridge (No conflict)
INSERT INTO `peer_review.Affiliated` (author_id, institution_id) VALUES
(1, 501),
(2, 501),
(3, 502);

-- Author -> SpecializesIn -> Subject (Expertise Match)
INSERT INTO `peer_review.SpecializesIn` (author_id, subject_id) VALUES
(1, 101), -- Alice specializes in CRISPR
(2, 101), -- Bob specializes in CRISPR
(3, 102), -- Charlie specializes in Quantum Computing
(3, 101); -- Charlie also specializes in CRISPR (Qualified reviewer!)
