-- ============================================================================
-- DEMO STEP 4: QUERY & VERIFY WITH NATIVE GQL (GRAPH_TABLE)
-- ============================================================================
-- Client Presentation Talking Points:
-- 1. Now that the Property Graph is defined, we can query it directly using GQL (ISO/IEC 39075)
--    via BigQuery's `GRAPH_TABLE` operator inside standard SQL!
-- 2. No messy 5-table JOIN chains with repeated conditions.
--    Instead, we write intuitive ASCII-art style pattern matches:
--    (a:Author)-[:SpecializesIn]->(s:Subject)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1: Researcher Expertise & Institutional Directory
-- Demonstrates multi-edge matching originating from a single node
-- ----------------------------------------------------------------------------
SELECT *
FROM GRAPH_TABLE(
  `academic_editorial.ScholarlyCentralGraph`
  MATCH (a:Author)-[:SpecializesIn]->(s:Subject)
  MATCH (a)-[:Affiliated]->(i:Institution)
  RETURN
    a.name AS author_name,
    a.email AS author_email,
    s.name AS specialty,
    i.name AS institution_name,
    i.country AS country
)
ORDER BY author_name, specialty;


-- ----------------------------------------------------------------------------
-- QUERY 2: Discovering Citation Paths
-- Demonstrates Paper -> Cites -> Paper relationship traversal
-- ----------------------------------------------------------------------------
SELECT *
FROM GRAPH_TABLE(
  `academic_editorial.ScholarlyCentralGraph`
  MATCH (citing:Paper)-[:Cites]->(cited:Paper)
  RETURN
    citing.title AS citing_paper,
    citing.publish_date AS citing_date,
    cited.title AS cited_paper,
    cited.citations_count AS cited_paper_total_citations
);


-- ----------------------------------------------------------------------------
-- QUERY 3: Springer Nature Core Use-Case — Reviewer Match & COI Detection
-- "Find qualified reviewers for Alice's Paper (Paper 10) who specialize in
--  its subject, excluding co-authors and shared institutions"
-- ----------------------------------------------------------------------------
WITH TargetPaper AS (
  -- Identify the target paper's subject and authors
  SELECT *
  FROM GRAPH_TABLE(
    `academic_editorial.ScholarlyCentralGraph`
    MATCH (author:Author)-[:Writes]->(p:Paper)-[:HasSubject]->(s:Subject)
    WHERE p.paper_id = 10
    RETURN
      p.paper_id AS paper_id,
      p.title AS paper_title,
      author.author_id AS author_id,
      author.name AS author_name,
      s.subject_id AS subject_id,
      s.name AS subject_name
  )
),
CandidateReviewers AS (
  -- Find all researchers with matching specialization
  SELECT *
  FROM GRAPH_TABLE(
    `academic_editorial.ScholarlyCentralGraph`
    MATCH (candidate:Author)-[:SpecializesIn]->(s:Subject)
    MATCH (candidate)-[:Affiliated]->(inst:Institution)
    RETURN
      candidate.author_id AS candidate_id,
      candidate.name AS candidate_name,
      candidate.h_index AS candidate_h_index,
      s.subject_id AS subject_id,
      inst.institution_id AS institution_id,
      inst.name AS institution_name
  )
)
SELECT DISTINCT
  c.candidate_name,
  c.candidate_h_index,
  c.institution_name,
  tp.paper_title,
  tp.subject_name AS required_expertise,
  CASE 
    WHEN c.candidate_id = tp.author_id THEN 'DISQUALIFIED: Paper Author'
    WHEN c.candidate_id IN (
      -- Check for co-authorship on any paper
      SELECT c2.author_id
      FROM GRAPH_TABLE(
        `academic_editorial.ScholarlyCentralGraph`
        MATCH (a1:Author)-[:Writes]->(p:Paper)<-[:Writes]-(c2:Author)
        WHERE a1.author_id = tp.author_id
        RETURN c2.author_id AS author_id
      )
    ) THEN 'DISQUALIFIED: Co-Author Conflict'
    WHEN c.institution_id IN (
      -- Check for institutional conflict
      SELECT i.institution_id
      FROM GRAPH_TABLE(
        `academic_editorial.ScholarlyCentralGraph`
        MATCH (a1:Author)-[:Affiliated]->(i:Institution)
        WHERE a1.author_id = tp.author_id
        RETURN i.institution_id AS institution_id
      )
    ) THEN 'DISQUALIFIED: Institutional Affiliation Conflict'
    ELSE 'APPROVED: Clean Reviewer Candidate'
  END AS review_eligibility_status
FROM CandidateReviewers c
CROSS JOIN TargetPaper tp
WHERE c.subject_id = tp.subject_id;
