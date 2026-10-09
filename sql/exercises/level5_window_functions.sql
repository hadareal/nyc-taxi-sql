-- ############################################################
-- LEVEL 5: Analytics
-- Concepts: EXTRACT, DATE_TRUNC, window functions: OVER,
--           PARTITION BY, ORDER BY inside OVER, ROW_NUMBER, RANK,
--           DENSE_RANK, LAG, running totals with SUM() OVER
--
-- Run: docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/exercises/level5_window_functions.sql
--
-- The key idea: GROUP BY collapses rows into one per group.
-- A window function computes across a group of rows BUT KEEPS
-- every row. Keep that difference in mind for every exercise.
-- ############################################################


-- ============================================================
-- 5.1  Rush hour
-- ------------------------------------------------------------
-- Task:     Number of trips per hour of the day (0 to 23), using
--           the pickup time. Sort by hour.
-- Concepts: EXTRACT(HOUR FROM ...)
-- Think:    Which hour is busiest? Is it what you expected?
-- ============================================================
\echo '--- 5.1'
SELECT EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
       COUNT(*) AS num_pickups
FROM trips_raw
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- ============================================================
-- 5.2  Day of the week
-- ------------------------------------------------------------
-- Task:     Number of trips per day of the week (Sunday..Saturday).
-- Concepts: EXTRACT(DOW FROM ...)  (or TO_CHAR for the day name)
-- Think:    A quarter doesn't have exactly the same number of
--           Mondays as Saturdays. Is "total trips per weekday" a
--           fair comparison? What would be fairer?
-- ============================================================
\echo '--- 5.2'
SELECT EXTRACT(DOW FROM tpep_pickup_datetime) AS pickup_dow,
       COUNT(*) AS num_pickups
FROM trips_raw
GROUP BY pickup_dow
ORDER BY pickup_dow;


-- ============================================================
-- 5.3  Number every row
-- ------------------------------------------------------------
-- Task:     Take the 10 zones with the most pickups (like 3.2) and
--           add a column with their position 1..10.
-- Concepts: ROW_NUMBER() OVER (ORDER BY ...)
-- ============================================================
\echo '--- 5.3'
SELECT z.zone, z.borough, COUNT(*) AS num_pickups,
       ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rank
FROM trips_raw AS t
JOIN zones AS z ON t.pulocationid = z.locationid
GROUP BY z.zone, z.borough
ORDER BY num_pickups DESC
LIMIT 10;


-- ============================================================
-- 5.4  Top 3 zones in EACH borough
-- ------------------------------------------------------------
-- Task:     For every borough, the 3 zones with the most pickups.
--           Show borough, zone, trips, rank.
-- Concepts: RANK() OVER (PARTITION BY ... ORDER BY ...), then
--           filter on the rank in an outer query or CTE
-- Think:    Why can't you filter the rank in the same query's
--           WHERE? (The order clauses run in, again.)
--           This "top N per group" pattern is one of the most
--           common in analytics SQL.
-- ============================================================
\echo '--- 5.4'
SELECT borough, zone, num_pickups, rank
FROM (
    SELECT z.borough, z.zone, COUNT(*) AS num_pickups,
           RANK() OVER (PARTITION BY z.borough ORDER BY COUNT(*) DESC) AS rank
    FROM trips_raw AS t
    JOIN zones AS z ON t.pulocationid = z.locationid
    GROUP BY z.borough, z.zone
) AS ranked_zones
WHERE rank <= 3
ORDER BY borough, rank;


-- ============================================================
-- 5.5  ROW_NUMBER vs RANK vs DENSE_RANK
-- ------------------------------------------------------------
-- Task:     Take trips picked up at JFK Airport (locationid 132)
--           on 2026-01-15. Order them by trip_distance, longest
--           first, and show all three functions side by side.
--           LIMIT 30.
-- Concepts: ROW_NUMBER, RANK, DENSE_RANK on data with ties
-- Think:    Find a spot in the output where the three columns
--           disagree. Explain each one in one sentence. When would
--           you want each one?
-- ============================================================
\echo '--- 5.5'
SELECT tpep_pickup_datetime, trip_distance,
       ROW_NUMBER() OVER (ORDER BY trip_distance DESC) AS row_number,
       RANK() OVER (ORDER BY trip_distance DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY trip_distance DESC) AS dense_rank
FROM trips_raw
WHERE pulocationid = 132 AND tpep_pickup_datetime::date = '2026-01-15'
ORDER BY trip_distance DESC
LIMIT 30;


-- ============================================================
-- 5.6  Each zone's share of its borough
-- ------------------------------------------------------------
-- Task:     For every zone: its pickups, its borough's total
--           pickups, and the zone's percentage of that total.
--           Sort by borough, then by percentage descending.
-- Concepts: SUM(...) OVER (PARTITION BY ...) on top of a GROUP BY
-- Think:    You're using an aggregate inside a window function
--           (e.g. a SUM over COUNTs). Work out the order in which
--           Postgres computes them.
-- ============================================================
\echo '--- 5.6'
SELECT z.borough, z.zone, COUNT(*) AS num_pickups,
       SUM(COUNT(*)) OVER (PARTITION BY z.borough) AS borough_total,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY z.borough), 1) AS pct_of_borough
FROM trips_raw AS t
JOIN zones AS z ON t.pulocationid = z.locationid
GROUP BY z.borough, z.zone, z.locationid
ORDER BY z.borough, pct_of_borough DESC;


-- ============================================================
-- 5.7  Daily trips with a running total
-- ------------------------------------------------------------
-- Task:     For each day in the data: the number of trips and the
--           running total of trips since the first day.
-- Concepts: SUM(...) OVER (ORDER BY day)
-- Check:    The running total on the last day equals the total
--           row count (from 2.1).
-- ============================================================
\echo '--- 5.7'
SELECT tpep_pickup_datetime::date AS pickup_date,
       COUNT(*) AS num_trips,
       SUM(COUNT(*)) OVER (ORDER BY tpep_pickup_datetime::date) AS running_total
FROM trips_raw
GROUP BY pickup_date
ORDER BY pickup_date;


-- ============================================================
-- 5.8  Day-over-day change
-- ------------------------------------------------------------
-- Task:     For each day: trips, previous day's trips, and the
--           change in percent.
-- Concepts: LAG(...) OVER (ORDER BY ...)
-- Think:    What does LAG return for the first day? Find the
--           biggest drop in the quarter. Can you explain it?
--           (Look up NYC weather or holidays for that date.)
-- ============================================================
\echo '--- 5.8'
WITH daily_counts AS (
    SELECT tpep_pickup_datetime::date AS pickup_date, COUNT(*) AS num_trips
    FROM trips_raw
    WHERE tpep_pickup_datetime >= '2026-01-01' AND tpep_pickup_datetime < '2026-04-01'
    GROUP BY pickup_date
)
SELECT pickup_date, num_trips,
       LAG(num_trips) OVER (ORDER BY pickup_date) AS prev_day_trips,
       ROUND((num_trips - LAG(num_trips) OVER (ORDER BY pickup_date)) * 100.0 / LAG(num_trips) OVER (ORDER BY pickup_date), 1) AS pct_change
FROM daily_counts
ORDER BY pickup_date;


-- ============================================================
-- 5.9  Monthly report
-- ------------------------------------------------------------
-- Task:     Per month: number of trips, total revenue
--           (total_amount), and the percent change of both versus
--           the previous month. Exclude the out-of-range trips
--           from 1.11.
-- Concepts: DATE_TRUNC('month', ...), LAG, CTE
-- Think:    This is a real deliverable a data analyst would
--           send. What would you double-check before sending it?
-- ============================================================
\echo '--- 5.9'
WITH monthly_counts AS (
    SELECT DATE_TRUNC('month', tpep_pickup_datetime) AS month,
           COUNT(*) AS num_trips,
           SUM(total_amount) AS total_revenue
    FROM trips_raw
    WHERE tpep_pickup_datetime >= '2026-01-01' AND tpep_pickup_datetime < '2026-04-01'
    GROUP BY month
)
SELECT month, num_trips, total_revenue,
       LAG(num_trips) OVER (ORDER BY month) AS prev_month_trips,
       ROUND((num_trips - LAG(num_trips) OVER (ORDER BY month)) * 100.0 / LAG(num_trips) OVER (ORDER BY month), 1) AS pct_change_trips,
       LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY month)) * 100.0 / LAG(total_revenue) OVER (ORDER BY month), 1) AS pct_change_revenue
FROM monthly_counts
ORDER BY month;

