# BigQuery Graph Peer Review Data Demo

This repository contains SQL DDL, seed data, and property graph definitions for demonstrating **BigQuery Graph** modeling, cross-domain data mesh queries, and GQL pattern matching for academic peer review and editorial workflows.

---

## Architecture Overview

The demo models an academic editorial and peer review ecosystem split across two decoupled BigQuery datasets:

1. **`academic_editorial`** (Public / Editorial Domain):
   - **Nodes**: `Paper`, `Subject`
   - **Edges**: `Cites` (`Paper` &rarr; `Paper`), `HasSubject` (`Paper` &rarr; `Subject`)
2. **`peer_review`** (Sensitive Profile / Reviewer Domain):
   - **Nodes**: `Author`, `Institution`
   - **Edges**: `Writes` (`Author` &rarr; `Paper`), `Affiliated` (`Author` &rarr; `Institution`), `SpecializesIn` (`Author` &rarr; `Subject`)

A logical Property Graph catalog (`academic_editorial.ScholarlyCentralGraph`) is layered directly on top of these standard relational tables without data replication or proprietary graph infrastructure.

---

## Execution Workflow

Execute the SQL scripts in numerical order within BigQuery:

### 1. `demo_central_01_create_tables.sql`
Creates the underlying physical relational tables across both `academic_editorial` and `peer_review` datasets, including primary and foreign key constraints (not enforced).

### 2. `demo_central_02_seed_data.sql`
Populates entity nodes and relationship edges. Sets up a scenario featuring:
- Co-authorship and institutional relationships (Dr. Alice Smith and Dr. Bob Johnson at Harvard).
- Independent researcher with matching specialization (Dr. Charlie Brown at Cambridge).

### 3. `demo_central_03_create_property_graph.sql`
Defines the `CREATE OR REPLACE PROPERTY GRAPH academic_editorial.ScholarlyCentralGraph` DDL catalog entry, mapping relational tables to nodes and edges.

### 4. `demo_central_04_verify_queries.sql`
Executes native GQL queries using BigQuery's `GRAPH_TABLE` operator:
- **Query 1**: Multi-edge researcher expertise and institutional directory traversal.
- **Query 2**: Multi-hop citation network traversal (`Paper -[:Cites]-> Paper`).
- **Query 3**: Peer reviewer matching with Conflict of Interest (COI) elimination (excluding co-authors and institutional conflicts).
