-- ############################################################
-- LEVEL 3: Combining tables
-- Concepts: JOIN (INNER), LEFT JOIN, table aliases, joining the
--           same table twice, UNION vs UNION ALL
--
-- Run: docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/exercises/level3_joins.sql
--
-- Reminder: trips_raw.pulocationid = pickup zone,
--           trips_raw.dolocationid = dropoff zone,
--           both match zones.locationid.
-- ############################################################


-- ============================================================
-- 3.1  Pickups per borough (the original question)
-- ------------------------------------------------------------
-- Task:     Number of pickups per borough, most first.
-- Concepts: JOIN + GROUP BY
-- Think:    1) What are the "Unknown" and "N/A" rows? Should they
--              be in a report for a manager? How would you
--              exclude them?
--           2) Does the order of steps (JOIN, then WHERE,
--              then GROUP BY) matter for the answer here?
-- ============================================================
\echo '--- 3.1'



-- ============================================================
-- 3.2  Top 10 pickup zones
-- ------------------------------------------------------------
-- Task:     The 10 zones with the most pickups. Show the zone name,
--           its borough and the number of trips.
-- Concepts: JOIN, GROUP BY on more than one column, ORDER BY, LIMIT
-- Think:    You GROUP BY the zone name. What would go wrong if two
--           different zones had the same name? What's safer to
--           group by?
-- ============================================================
\echo '--- 3.2'



-- ============================================================
-- 3.3  Short aliases
-- ------------------------------------------------------------
-- Task:     Rewrite 3.2 using short table aliases (e.g. trips_raw
--           becomes t, zones becomes z), and prefix every column
--           with its alias.
-- Concepts: table aliases (FROM trips_raw t ...)
-- ============================================================
\echo '--- 3.3'



-- ============================================================
-- 3.4  From where to where
-- ------------------------------------------------------------
-- Task:     For 10 trips, show the pickup zone NAME and the
--           dropoff zone NAME side by side.
-- Concepts: joining the SAME table twice, with two different aliases
-- Think:    Both copies of zones have a column called "zone".
--           How do you tell them apart in SELECT, and how do you
--           give them different names in the output?
-- ============================================================
\echo '--- 3.4'



-- ============================================================
-- 3.5  The most popular routes
-- ------------------------------------------------------------
-- Task:     The 10 most common (pickup zone -> dropoff zone) pairs,
--           with names and the number of trips.
-- Concepts: double join + GROUP BY two columns
-- Think:    Are some of the top routes from a zone to ITSELF?
--           What kind of trip is that?
-- ============================================================
\echo '--- 3.5'



-- ============================================================
-- 3.6  Crossing borough lines
-- ------------------------------------------------------------
-- Task:     For trips that start and end in DIFFERENT boroughs,
--           count trips per (pickup borough, dropoff borough) pair.
--           Most common first.
-- Concepts: double join, WHERE comparing columns from two aliases
-- ============================================================
\echo '--- 3.6'



-- ============================================================
-- 3.7  Zones nobody leaves from
-- ------------------------------------------------------------
-- Task:     Find the zones that have ZERO pickups in the data.
--           Show locationid, borough, zone.
-- Concepts: LEFT JOIN + IS NULL ("anti-join")
-- Check:    3 rows.
-- Think:    Why is this impossible with a normal (INNER) JOIN?
--           Draw the students/classes example: which rows does an
--           INNER JOIN drop?
-- ============================================================
\echo '--- 3.7'



-- ============================================================
-- 3.8  Counting with a LEFT JOIN, the classic trap
-- ------------------------------------------------------------
-- Task:     Number of pickups for EVERY zone, including zones with
--           zero. The 3 zones from 3.7 must show 0.
-- Concepts: LEFT JOIN + GROUP BY + COUNT
-- Think:    Try COUNT(*) first. What do the 3 empty zones show?
--           Why? Then fix it by counting something else.
--           This mistake is extremely common in real reports.
-- ============================================================
\echo '--- 3.8'



-- ============================================================
-- 3.9  UNION vs UNION ALL
-- ------------------------------------------------------------
-- Task:     Make a single list of every locationid that was used
--           as a pickup OR as a dropoff. Count how many there are.
--           Then do it again with UNION ALL instead of UNION.
-- Concepts: UNION, UNION ALL, using a query as a table (or COUNT
--           over the combined list)
-- Think:    Why are the two counts so different? Which one is
--           more expensive for the database to compute, and why?
-- ============================================================
\echo '--- 3.9'


