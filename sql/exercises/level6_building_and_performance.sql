-- ############################################################
-- LEVEL 6: Building tables and performance
-- Concepts: EXPLAIN, EXPLAIN ANALYZE, CREATE INDEX,
--           CREATE TABLE ... AS SELECT, CREATE VIEW,
--           CREATE TABLE, INSERT, UPDATE, DELETE, DROP ... IF EXISTS
--
-- Run: docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/exercises/level6_building_and_performance.sql
--
-- These exercises CHANGE the database (new tables, indexes).
-- That's safe: trips_raw and zones are never modified, and you
-- can always reload with: docker compose run --rm loader
-- ############################################################


-- ============================================================
-- 6.1  Your first query plan
-- ------------------------------------------------------------
-- Task:     Put EXPLAIN in front of: count all trips in trips_raw.
--           Then run it again with EXPLAIN ANALYZE.
-- Concepts: EXPLAIN (the plan) vs EXPLAIN ANALYZE (actually runs
--           it and reports real times)
-- Think:    Find the words "Seq Scan", "Parallel" and "Workers".
--           What do you think they mean?
-- ============================================================
\echo '--- 6.1'



-- ============================================================
-- 6.2  Looking for one zone, without an index
-- ------------------------------------------------------------
-- Task:     EXPLAIN ANALYZE a query that counts trips picked up at
--           JFK (pulocationid = 132). Write down the execution time.
-- Concepts: EXPLAIN ANALYZE, Seq Scan, "Rows Removed by Filter"
-- ============================================================
\echo '--- 6.2'



-- ============================================================
-- 6.3  Add an index
-- ------------------------------------------------------------
-- Task:     Create an index on trips_raw(pulocationid). Then run
--           the exact EXPLAIN ANALYZE from 6.2 again.
-- Concepts: CREATE INDEX (IF NOT EXISTS), Index Scan,
--           Index Only Scan, Bitmap Heap Scan
-- Think:    1) Did the plan change? How much faster is it?
--           2) db/schema.sql says trips_raw has no indexes "on
--              purpose". Why might a table designed for bulk
--              loading avoid indexes? (What does an index cost
--              on every INSERT/COPY?)
--           3) Try the same with pulocationid = 1 (very few
--              trips) and with a very common zone. Does Postgres
--              always use the index? Why not?
-- ============================================================
\echo '--- 6.3'



-- ============================================================
-- 6.4  A clean table (ELT)
-- ------------------------------------------------------------
-- Task:     Turn your cleaning rules from 4.6 into a permanent
--           table called trips_clean, using CREATE TABLE ... AS
--           SELECT. Your script must be safe to run twice.
-- Concepts: CREATE TABLE AS, DROP TABLE IF EXISTS
-- Think:    1) "Safe to run twice" is called idempotency. Why does
--              every ETL step need it?
--           2) Compare row counts: trips_raw vs trips_clean.
--           3) Pros and cons of a stored table here vs the
--              view in 6.5?
-- ============================================================
\echo '--- 6.4'



-- ============================================================
-- 6.5  A view for daily stats
-- ------------------------------------------------------------
-- Task:     Create a view daily_stats with one row per day: date,
--           trips, total revenue, average distance (from
--           trips_clean). Then SELECT from it like a table.
-- Concepts: CREATE OR REPLACE VIEW
-- Think:    Does the view store data? Use EXPLAIN on
--           "SELECT * FROM daily_stats" and see what it really runs.
-- ============================================================
\echo '--- 6.5'



-- ============================================================
-- 6.6  Build a dimension table by hand
-- ------------------------------------------------------------
-- Task:     a) Create a table payment_types (code integer primary
--              key, name text).
--           b) INSERT the codes from the reference in level 2.
--           c) Rewrite exercise 2.4 using a JOIN to this table
--              instead of CASE.
--           d) UPDATE the name of code 0 to 'Flex Fare (no meter)'.
--           e) DELETE code 6, then check the result of c) again.
-- Concepts: CREATE TABLE, PRIMARY KEY, INSERT, UPDATE, DELETE
-- Think:    After e), did trips disappear from c)'s result? Would
--           a LEFT JOIN behave differently? This is the star-
--           schema idea: facts (trips) + dimensions (zones,
--           payment types).
-- ============================================================
\echo '--- 6.6'



-- ============================================================
-- 6.7  Read a join plan
-- ------------------------------------------------------------
-- Task:     EXPLAIN ANALYZE your pickups-per-borough query (3.1).
-- Concepts: Hash Join, HashAggregate / GroupAggregate,
--           reading a plan from the inside out
-- Think:    Which table did Postgres build the hash from, and
--           why that one? Where does most of the time go?
-- ============================================================
\echo '--- 6.7'


