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



-- ============================================================
-- 5.3  Number every row
-- ------------------------------------------------------------
-- Task:     Take the 10 zones with the most pickups (like 3.2) and
--           add a column with their position 1..10.
-- Concepts: ROW_NUMBER() OVER (ORDER BY ...)
-- ============================================================
\echo '--- 5.3'



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


