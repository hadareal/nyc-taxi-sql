-- ############################################################
-- LEVEL 1: Reading one table
-- Concepts: SELECT, FROM, WHERE, AND/OR, comparisons, LIKE, IN,
--           BETWEEN, IS NULL, ORDER BY, LIMIT, DISTINCT, AS
--
-- Run: docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/exercises/level1_single_table.sql
--
-- Rule for this level: trips_raw has ~11 million rows.
-- Every query on it needs a LIMIT unless it returns very few rows.
-- ############################################################

\x auto


-- ============================================================
-- 1.1  Meet the data
-- ------------------------------------------------------------
-- Task:     Show the first 5 rows of trips_raw, all columns.
-- Concepts: SELECT *, LIMIT
-- Think:    Which columns do you understand? Which ones are a
--           mystery? Keep a list and look them up in the TLC
--           data dictionary (search "yellow trips data dictionary").
-- ============================================================
\echo '--- 1.1'
SELECT * FROM trips_raw LIMIT 5;



-- ============================================================
-- 1.2  Pick your columns
-- ------------------------------------------------------------
-- Task:     For 10 trips, show only: pickup time, dropoff time,
--           trip distance and total amount.
-- Concepts: SELECT with a column list
-- ============================================================
\echo '--- 1.2'
SELECT tpep_pickup_datetime, tpep_dropoff_datetime, trip_distance, total_amount
FROM trips_raw LIMIT 10;


-- ============================================================
-- 1.3  Manhattan, alphabetically
-- ------------------------------------------------------------
-- Task:     List the name of every zone in Manhattan, sorted A to Z.
-- Concepts: WHERE, ORDER BY
-- Check:    69 rows.
-- ============================================================
\echo '--- 1.3'
SELECT zone FROM zones WHERE borough = 'Manhattan' ORDER BY zone;


-- ============================================================
-- 1.4  Find the airports
-- ------------------------------------------------------------
-- Task:     Find every zone whose name contains the word "Airport".
--           Show locationid, borough and zone.
-- Concepts: LIKE and the % wildcard
-- Check:    3 rows.
-- Think:    Try searching for 'airport' in lowercase. What happens?
--           Postgres has a variant of LIKE that ignores case;
--           find its name.
-- ============================================================
\echo '--- 1.4'
SELECT locationid, borough, zone FROM zones WHERE zone LIKE '%Airport%';
SELECT locationid, borough, zone FROM zones WHERE zone ILIKE '%airport%';


-- ============================================================
-- 1.5  Pick by ID
-- ------------------------------------------------------------
-- Task:     Show the zones with locationid 1, 132, 138 and 264,
--           without writing "locationid = ..." four times.
-- Concepts: IN
-- ============================================================
\echo '--- 1.5'
SELECT * FROM zones WHERE locationid IN (1, 132, 138, 264);


-- ============================================================
-- 1.6  Suspicious long trips
-- ------------------------------------------------------------
-- Task:     Show 20 trips longer than 50 miles that cost less
--           than $20 in total. Show distance, total amount,
--           pickup time and dropoff time.
-- Concepts: WHERE with AND
-- Think:    Are these real trips? What could cause this data?
--           (This kind of question is the core of data cleaning.)
-- ============================================================
\echo '--- 1.6'
SELECT trip_distance, total_amount, tpep_pickup_datetime, tpep_dropoff_datetime
FROM trips_raw
WHERE trip_distance > 50 AND total_amount < 20
LIMIT 20;


-- ============================================================
-- 1.7  What values exist?
-- ------------------------------------------------------------
-- Task:     List each payment_type value that appears in the data,
--           once each. Then do the same for vendorid.
--           (Two queries.)
-- Concepts: DISTINCT, ORDER BY
-- Think:    This query reads all 11M rows. Was it fast or slow?
-- ============================================================
\echo '--- 1.7'
SELECT DISTINCT payment_type FROM trips_raw ORDER BY payment_type;
SELECT DISTINCT vendorid FROM trips_raw ORDER BY vendorid;
SELECT DISTINCT payment_type, vendorid FROM trips_raw ORDER BY payment_type, vendorid;

-- ============================================================
-- 1.8  Missing values
-- ------------------------------------------------------------
-- Task:     Show 10 trips where passenger_count is missing (NULL).
--           Include passenger_count, payment_type, ratecodeid and
--           total_amount.
-- Concepts: IS NULL
-- Think:    1) First try "passenger_count = NULL". It returns
--              0 rows, with no error. Why? Look up "three-valued logic".
--           2) Look at the payment_type of these rows. Notice anything?
-- ============================================================
\echo '--- 1.8'
SELECT passenger_count, payment_type, ratecodeid, total_amount
FROM trips_raw
WHERE passenger_count IS NULL
LIMIT 10;


-- ============================================================
-- 1.9  A Valentine's evening
-- ------------------------------------------------------------
-- Task:     Show 20 trips picked up on 14 February 2026 between
--           18:00 and 20:00. Show pickup time, distance, total.
--           Sort by pickup time.
-- Concepts: BETWEEN, timestamp literals like '2026-02-14 18:00'
-- Think:    Is BETWEEN inclusive or exclusive at the ends?
--           Would a trip at exactly 20:00:00 be included?
--           Would one at 20:00:30?
-- ============================================================
\echo '--- 1.9'
SELECT tpep_pickup_datetime, trip_distance, total_amount
FROM trips_raw
WHERE tpep_pickup_datetime BETWEEN '2026-02-14 18:00' AND '2026-02-14 20:00'
ORDER BY tpep_pickup_datetime
LIMIT 20;


-- ============================================================
-- 1.10  The most expensive trips
-- ------------------------------------------------------------
-- Task:     Show the 10 trips with the highest total_amount.
--           Rename the columns in the output to "distance_miles"
--           and "total_usd".
-- Concepts: ORDER BY ... DESC, LIMIT, AS
-- ============================================================
\echo '--- 1.10'
SELECT trip_distance AS distance_miles, total_amount AS total_usd
FROM trips_raw
ORDER BY total_amount DESC
LIMIT 10;


-- ============================================================
-- 1.11  Trips from the wrong time
-- ------------------------------------------------------------
-- Task:     The data is supposed to cover January to March 2026.
--           Find every trip whose pickup time is BEFORE 2026-01-01
--           OR on/after 2026-04-01.
-- Concepts: OR, comparing timestamps
-- Check:    A handful of rows (about 10).
-- Think:    If you combine AND and OR in one WHERE, what do
--           parentheses change? Write one example where
--           forgetting them gives a different answer.
-- ============================================================
\echo '--- 1.11'
SELECT tpep_pickup_datetime, trip_distance, total_amount
FROM trips_raw
WHERE tpep_pickup_datetime < '2026-01-01' OR tpep_pickup_datetime >= '2026-04-01'
ORDER BY tpep_pickup_datetime;


-- ============================================================
-- 1.12  Time travel
-- ------------------------------------------------------------
-- Task:     Find trips where the dropoff time is BEFORE the pickup time.
-- Concepts: comparing two columns of the same row
-- Check:    5 rows.
-- ============================================================
\echo '--- 1.12'
SELECT tpep_pickup_datetime, tpep_dropoff_datetime, trip_distance, total_amount
FROM trips_raw
WHERE tpep_dropoff_datetime < tpep_pickup_datetime
ORDER BY tpep_pickup_datetime;

