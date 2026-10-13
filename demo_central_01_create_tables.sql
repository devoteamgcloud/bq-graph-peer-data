-- ============================================================================
-- DEMO STEP 1: CREATE PHYSICAL RELATIONAL TABLES
-- ============================================================================
-- Client Presentation Talking Points:
-- 1. BigQuery Graph is a LOGICAL METADATA LAYER over standard relational tables.
--    There is no separate, proprietary graph database to purchase or manage.
-- 2. We create tables for:
--    - Entity Tables (will become Graph NODES)
--    - Relationship/Junction Tables (will become Graph EDGES)
-- ============================================================================

-- ----------------------------------------------------
-- DOMAIN 1: academic_editorial
-- ----------------------------------------------------

-- Node Candidate: Paper
CREATE OR REPLACE TABLE `academic_editorial.Paper` (
  paper_id INT64 NOT NULL,
  title STRING NOT NULL,
  abstract STRING,
  publish_date DATE NOT NULL,
  citations_count INT64,
  PRIMARY KEY (paper_id) NOT ENFORCED
);

-- Node Candidate: Subject (Research taxonomy / field)
CREATE OR REPLACE TABLE `academic_editorial.Subject` (
  subject_id INT64 NOT NULL,
  name STRING NOT NULL,
  PRIMARY KEY (subject_id) NOT ENFORCED
);

-- Edge Candidate: Cites (Paper -> Paper citation network)
CREATE OR REPLACE TABLE `academic_editorial.Cites` (
  citing_id INT64 NOT NULL,
  cited_id INT64 NOT NULL,
  PRIMARY KEY (citing_id, cited_id) NOT ENFORCED,
  FOREIGN KEY (citing_id) REFERENCES `academic_editorial.Paper`(paper_id) NOT ENFORCED,
  FOREIGN KEY (cited_id) REFERENCES `academic_editorial.Paper`(paper_id) NOT ENFORCED
);

-- Edge Candidate: HasSubject (Paper -> Subject taxonomy mapping)
CREATE OR REPLACE TABLE `academic_editorial.HasSubject` (
  paper_id INT64 NOT NULL,
  subject_id INT64 NOT NULL,
  PRIMARY KEY (paper_id, subject_id) NOT ENFORCED,
  FOREIGN KEY (paper_id) REFERENCES `academic_editorial.Paper`(paper_id) NOT ENFORCED,
  FOREIGN KEY (subject_id) REFERENCES `academic_editorial.Subject`(subject_id) NOT ENFORCED
);

-- ----------------------------------------------------
-- DOMAIN 2: peer_review
-- ----------------------------------------------------

-- Node Candidate: Author (Researchers, reviewers, editors)
CREATE OR REPLACE TABLE `peer_review.Author` (
  author_id INT64 NOT NULL,
  name STRING NOT NULL,
  email STRING NOT NULL,
  orcid STRING,
  h_index INT64,
  PRIMARY KEY (author_id) NOT ENFORCED
);

-- Node Candidate: Institution (Universities, research centers)
CREATE OR REPLACE TABLE `peer_review.Institution` (
  institution_id INT64 NOT NULL,
  name STRING NOT NULL,
  country STRING,
  PRIMARY KEY (institution_id) NOT ENFORCED
);

-- Edge Candidate: Writes (Author -> Paper co-authorship)
CREATE OR REPLACE TABLE `peer_review.Writes` (
  author_id INT64 NOT NULL,
  paper_id INT64 NOT NULL,
  PRIMARY KEY (author_id, paper_id) NOT ENFORCED,
  FOREIGN KEY (author_id) REFERENCES `peer_review.Author`(author_id) NOT ENFORCED
);

-- Edge Candidate: Affiliated (Author -> Institution affiliation)
CREATE OR REPLACE TABLE `peer_review.Affiliated` (
  author_id INT64 NOT NULL,
  institution_id INT64 NOT NULL,
  PRIMARY KEY (author_id, institution_id) NOT ENFORCED,
  FOREIGN KEY (author_id) REFERENCES `peer_review.Author`(author_id) NOT ENFORCED,
  FOREIGN KEY (institution_id) REFERENCES `peer_review.Institution`(institution_id) NOT ENFORCED
);

-- Edge Candidate: SpecializesIn (Author -> Subject expertise profile)
CREATE OR REPLACE TABLE `peer_review.SpecializesIn` (
  author_id INT64 NOT NULL,
  subject_id INT64 NOT NULL,
  PRIMARY KEY (author_id, subject_id) NOT ENFORCED,
  FOREIGN KEY (author_id) REFERENCES `peer_review.Author`(author_id) NOT ENFORCED,
  FOREIGN KEY (subject_id) REFERENCES `academic_editorial.Subject`(subject_id) NOT ENFORCED
);
