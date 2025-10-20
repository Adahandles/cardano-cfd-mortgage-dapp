CREATE TABLE IF NOT EXISTS loans (
  loan_id TEXT PRIMARY KEY,
  policy_id TEXT,
  asset_name TEXT,
  tier TEXT,
  state TEXT,
  principal_c INTEGER,
  apr_bps INTEGER,
  next_due TEXT,
  owner TEXT,
  servicer TEXT,
  borrower TEXT
);

CREATE TABLE IF NOT EXISTS evidence (
  loan_id TEXT,
  kind TEXT,
  hash TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS events (
  loan_id TEXT,
  event TEXT,
  tx_hash TEXT,
  block_time TIMESTAMP,
  delta_json TEXT
);

CREATE TABLE IF NOT EXISTS priority_commits (
  loan_id TEXT,
  commit_hash TEXT,
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
