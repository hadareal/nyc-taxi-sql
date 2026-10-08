-- ############################################################
-- LEVEL 2: Summarizing
-- Concepts: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING,
--           ROUND, CASE, COALESCE
--
-- Run: docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/exercises/level2_aggregation.sql
--
-- Before this file: finish the warm-up in sql/01_zones_per_borough.sql
-- (number of zones per borough).
--
-- Code reference used below (from the TLC data dictionary):
--   payment_type: 0 = Flex Fare, 1 = Credit card, 2 = Cash,
--                 3 = No charge, 4 = Dispute, 5 = Unknown, 6 = Voided
--   ratecodeid:   1 = Standard, 2 = JFK, 3 = Newark,
--                 4 = Nassau/Westchester, 5 = Negotiated,
--                 6 = Group ride, 99 = Unknown
-- ############################################################


-- ============================================================
-- 2.1  COUNT(*) vs COUNT(column)
-- ------------------------------------------------------------
-- Task:     In ONE query, show three numbers:
--             - the total number of trips
--             - COUNT(passenger_count)
--             - COUNT(ratecodeid)
-- Concepts: COUNT(*) vs COUNT(column)
-- Think:    Why are the numbers different? What exactly does
--           COUNT(column) count? Connect this to exercise 1.8.
-- ============================================================
\echo '--- 2.1'
SELECT COUNT(*) AS total_trips,
       COUNT(passenger_count) AS count_passenger_count,
       COUNT(ratecodeid) AS count_ratecodeid
FROM trips_raw;


-- ============================================================
-- 2.2  Fare statistics
-- ------------------------------------------------------------
-- Task:     Show the minimum, maximum and average fare_amount
--           across all trips. Round the average to 2 decimals.
-- Concepts: MIN, MAX, AVG, ROUND
-- Think:    The minimum is negative. What could a negative fare
--           mean? Does it change how much you trust the average?
-- ============================================================
\echo '--- 2.2'
SELECT MIN(fare_amount) AS min_fare,
       MAX(fare_amount) AS max_fare,
       ROUND(AVG(fare_amount), 2) AS avg_fare
FROM trips_raw;


-- ============================================================
-- 2.3  How do people pay?
-- ------------------------------------------------------------
-- Task:     Number of trips per payment_type, most common first.
-- Concepts: GROUP BY, ORDER BY on an aggregate
-- ============================================================
\echo '--- 2.3'
SELECT payment_type, COUNT(*) AS num_trips
FROM trips_raw
GROUP BY payment_type
ORDER BY num_trips DESC;


-- ============================================================
-- 2.4  Readable labels
-- ------------------------------------------------------------
-- Task:     Same as 2.3, but show the name ("Credit card", "Cash", ...)
--           instead of the code number. Use the code reference at
--           the top of this file.
-- Concepts: CASE WHEN ... THEN ... ELSE ... END
-- Think:    You will build a better solution to this in level 6
--           (6.6). What's the downside of hard-coding names in
--           a CASE in every query?
-- ============================================================
\echo '--- 2.4'
SELECT CASE payment_type
           WHEN 0 THEN 'Flex Fare'
           WHEN 1 THEN 'Credit card'
           WHEN 2 THEN 'Cash'
           WHEN 3 THEN 'No charge'
           WHEN 4 THEN 'Dispute'
           WHEN 5 THEN 'Unknown'
           WHEN 6 THEN 'Voided'
           ELSE 'Other'
       END AS payment_type_name,
       COUNT(*) AS num_trips
FROM trips_raw
GROUP BY payment_type
ORDER BY num_trips DESC;


-- ============================================================
-- 2.5  Who tips?
-- ------------------------------------------------------------
-- Task:     Average tip_amount per payment_type, rounded to 2 decimals.
-- Concepts: AVG with GROUP BY
-- Think:    Cash trips have an average tip near zero. Do cash
--           passengers really not tip? (Hint: how would the
--           taxi's meter know about a cash tip?)
--           This is a classic case of data that looks like it
--           means one thing but means another.
-- ============================================================
\echo '--- 2.5'
SELECT payment_type, ROUND(AVG(tip_amount), 2) AS avg_tip
FROM trips_raw
GROUP BY payment_type
ORDER BY avg_tip DESC;


-- ============================================================
-- 2.6  Big vendors only
-- ------------------------------------------------------------
-- Task:     Number of trips per vendorid, but show only the
--           vendors with more than 100,000 trips.
-- Concepts: HAVING
-- Think:    Why can't you write this condition in WHERE?
--           (Remember the order the clauses run in.)
-- ============================================================
\echo '--- 2.6'
SELECT vendorid, COUNT(*) AS num_trips
FROM trips_raw
GROUP BY vendorid
HAVING COUNT(*) > 100000
ORDER BY num_trips DESC;


-- ============================================================
-- 2.7  How many passengers?
-- ------------------------------------------------------------
-- Task:     Number of trips per passenger_count, sorted by
--           passenger_count.
-- Concepts: GROUP BY on a column that has NULLs
-- Think:    1) Where does the NULL group show up in the sort?
--           2) Trips with 0 passengers exist. What could they be?
--           3) Show NULL as the text 'unknown' instead. Which
--              function replaces NULL with a default?
--              (There's a catch: the column is a number, and
--              'unknown' is text. Read the error if you get one.)
-- ============================================================
\echo '--- 2.7'
SELECT passenger_count, COUNT(*) AS num_trips
FROM trips_raw
GROUP BY passenger_count
ORDER BY passenger_count;


-- ============================================================
-- 2.8  Tip percentage
-- ------------------------------------------------------------
-- Task:     For credit-card trips only, compute the average tip
--           as a percentage of the fare (tip_amount / fare_amount
--           * 100). Only include trips with fare_amount > 0.
--           Round to 1 decimal.
-- Concepts: arithmetic inside an aggregate, WHERE + AVG
-- Think:    What would happen without "fare_amount > 0"?
--           Try it and read the error.
-- ============================================================
\echo '--- 2.8'
SELECT ROUND(AVG(tip_amount / fare_amount * 100), 1) AS avg_tip_pct
FROM trips_raw
WHERE payment_type = 1 AND fare_amount > 0;


-- ============================================================
-- 2.9  A data-quality report in one row
-- ------------------------------------------------------------
-- Task:     In ONE query that returns ONE row, count:
--             - trips with a negative fare_amount
--             - trips with trip_distance = 0
--             - trips with dropoff before pickup
--           as three separate columns.
-- Concepts: SUM or COUNT combined with CASE, one pass over the data
-- Think:    You could write three separate queries. Why is one
--           query better on an 11M-row table?
-- ============================================================
\echo '--- 2.9'
SELECT SUM(CASE WHEN fare_amount < 0 THEN 1 ELSE 0 END) AS num_negative_fares,
       SUM(CASE WHEN trip_distance = 0 THEN 1 ELSE 0 END) AS num_zero_distance,
       SUM(CASE WHEN tpep_dropoff_datetime < tpep_pickup_datetime THEN 1 ELSE 0 END) AS num_dropoff_before_pickup
FROM trips_raw;


-- ============================================================
-- 2.10  Rate codes with long trips
-- ------------------------------------------------------------
-- Task:     Per ratecodeid: number of trips and average distance
--           (rounded to 1 decimal). Keep only rate codes whose
--           average distance is above 5 miles.
-- Concepts: GROUP BY + HAVING on an aggregate other than COUNT
-- Think:    Do the rate codes that remain make sense, given the
--           code reference at the top of the file?
-- ============================================================
\echo '--- 2.10'
SELECT ratecodeid, COUNT(*) AS num_trips, ROUND(AVG(trip_distance), 1) AS avg_distance
FROM trips_raw
GROUP BY ratecodeid
HAVING AVG(trip_distance) > 5
ORDER BY avg_distance DESC;
