-- 01_create_database.sql
-- Creates the retail_analytics database. Run while connected to ANY other database (e.g. postgres):
--
--   psql -U postgres -d postgres -f 01_create_database.sql
--
-- PostgreSQL cannot create a database and its tables in one connection: CREATE DATABASE makes the
-- database, but you are still connected to the old one. So 02–05 are run separately, connected to
-- retail_analytics (see README.md, "Setting up").
--
-- Safe to re-run: CREATE DATABASE has no IF NOT EXISTS, so this checks first. In psql, \gexec runs
-- the statement only when the SELECT returns a row.

SELECT 'CREATE DATABASE retail_analytics'
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'retail_analytics')\gexec

-- If you use pgAdmin or DBeaver instead of psql (no \gexec), run just this line once:
-- CREATE DATABASE retail_analytics;
