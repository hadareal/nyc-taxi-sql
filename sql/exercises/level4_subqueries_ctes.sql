-- ############################################################
-- LEVEL 4: Structuring bigger queries
-- Concepts: subqueries (in WHERE, in FROM), IN (subquery),
--           WITH ... AS (...) (CTEs), multi-step CTEs
--
-- Run: docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/exercises/level4_subqueries_ctes.sql
-- ############################################################


-- ============================================================
-- 4.1  Above-average fares
-- ------------------------------------------------------------
-- Task:     How many trips have a fare_amount higher than the
--           average fare_amount of all trips?
-- Concepts: a subquery that returns ONE value, used in WHERE
-- Think:    Why can't you write WHERE fare_amount > AVG(fare_amount)?
--           (Remember when WHERE runs and when aggregates run.)
-- ============================================================
\echo '--- 4.1'
SELECT COUNT(*) AS num_above_average
FROM trips_raw
WHERE fare_amount > (SELECT AVG(fare_amount) FROM trips_raw);


-- ============================================================
-- 4.2  Same thing, as a CTE
-- ------------------------------------------------------------
-- Task:     Rewrite 4.1 using WITH: first a step that computes the
--           average, then the main query that uses it.
-- Concepts: WITH name AS (...) SELECT ...
-- Think:    Which version is easier to read? Which would be
--           easier to change if the business asked for
--           "above the average for that payment type"?
-- ============================================================
\echo '--- 4.2'
WITH avg_fare AS (
    SELECT AVG(fare_amount) AS value FROM trips_raw
)
SELECT COUNT(*) AS num_above_average
FROM trips_raw
WHERE fare_amount > (SELECT value FROM avg_fare);


-- ============================================================
-- 4.3  Airport pickups, two ways
-- ------------------------------------------------------------
-- Task:     Count trips picked up in any airport zone.
--           a) using IN (subquery on zones)
--           b) using a JOIN
-- Concepts: IN (SELECT ...), JOIN
-- Check:    a) and b) must give the same number.
-- Think:    Can you think of a case where IN and JOIN would give
--           DIFFERENT counts? (Hint: what if the subquery or the
--           joined table had duplicate rows?)
-- ============================================================
\echo '--- 4.3'
SELECT COUNT(*) AS num_airport_pickups_in
FROM trips_raw
WHERE pulocationid IN (
    SELECT locationid FROM zones WHERE zone LIKE '%Airport%'
);

SELECT COUNT(*) AS num_airport_pickups_join
FROM trips_raw AS t
JOIN zones AS z ON t.pulocationid = z.locationid
WHERE z.zone LIKE '%Airport%';


-- ============================================================
-- 4.4  Average trips per day
-- ------------------------------------------------------------
-- Task:     What's the average number of trips per day?
--           Step 1: count trips per day.
--           Step 2: average those daily counts.
-- Concepts: subquery in FROM (or a CTE), turning a timestamp
--           into a date (look up ::date or DATE_TRUNC)
-- Think:    Why is this not the same as COUNT(*) / 90?
--           (Look at 1.11. Which days are in the data?)
-- ============================================================
\echo '--- 4.4'
SELECT AVG(num_trips) AS avg_trips_per_day
FROM (
    SELECT tpep_pickup_datetime::date AS pickup_date, COUNT(*) AS num_trips
    FROM trips_raw
    GROUP BY pickup_date
) AS daily_counts;


-- ============================================================
-- 4.5  Busier than average zones
-- ------------------------------------------------------------
-- Task:     List the zones (by name) whose number of pickups is
--           above the average number of pickups per zone.
-- Concepts: a CTE with two steps: per-zone counts, then the
--           average of those counts
-- Think:    How many of the 265 zones are "above average"?
--           What does that tell you about how the trips are
--           distributed?
-- ============================================================
\echo '--- 4.5'
WITH zone_counts AS (
    SELECT z.zone, z.locationid, COUNT(*) AS num_pickups
    FROM trips_raw AS t
    JOIN zones AS z ON t.pulocationid = z.locationid
    GROUP BY z.zone, z.locationid
),
avg_pickups AS (
    SELECT AVG(num_pickups) AS value FROM zone_counts
)
SELECT zone, num_pickups
FROM zone_counts
WHERE num_pickups > (SELECT value FROM avg_pickups)
ORDER BY num_pickups DESC;


-- ============================================================
-- 4.6  A clean step first
-- ------------------------------------------------------------
-- Task:     Write a CTE named clean_trips that keeps only "sane"
--           trips. You decide the rules, for example: fare > 0,
--           distance > 0, dropoff after pickup, pickup within
--           Jan to Mar 2026. Write your rules as comments.
--           Then compute pickups per borough from clean_trips and
--           compare with your answer to 3.1.
-- Concepts: multi-step CTE, data cleaning rules
-- Think:    How many trips did your rules remove? Is any rule too
--           aggressive (does it drop real trips)? This is exactly
--           the "T" in ETL. You'll make it permanent in 6.4.
-- ============================================================
\echo '--- 4.6'
WITH clean_trips AS (
    SELECT *
    FROM trips_raw
    WHERE fare_amount > 0
      AND trip_distance > 0
      AND tpep_dropoff_datetime > tpep_pickup_datetime
      AND tpep_pickup_datetime >= '2026-01-01'::date
      AND tpep_pickup_datetime < '2026-04-01'::date
)
SELECT z.borough, COUNT(*) AS num_pickups
FROM clean_trips AS t
JOIN zones AS z ON t.pulocationid = z.locationid
GROUP BY z.borough
ORDER BY num_pickups DESC;

