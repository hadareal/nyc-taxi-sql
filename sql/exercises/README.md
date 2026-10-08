# SQL exercises

One file per level. Each exercise has a task, the concepts it needs, and an
empty space under it for your query. Answers are not included.

| File | Level | Topics |
|------|-------|--------|
| [level1_single_table.sql](level1_single_table.sql) | 1 | SELECT, WHERE, ORDER BY, LIMIT, LIKE, IN, BETWEEN, NULL, DISTINCT, AS |
| [level2_aggregation.sql](level2_aggregation.sql) | 2 | COUNT/SUM/AVG/MIN/MAX, GROUP BY, HAVING, CASE, ROUND |
| [level3_joins.sql](level3_joins.sql) | 3 | JOIN, LEFT JOIN, joining a table twice, UNION |
| [level4_subqueries_ctes.sql](level4_subqueries_ctes.sql) | 4 | Subqueries, WITH (CTEs) |
| [level5_window_functions.sql](level5_window_functions.sql) | 5 | Dates, OVER, PARTITION BY, RANK, LAG, running totals |
| [level6_building_and_performance.sql](level6_building_and_performance.sql) | 6 | EXPLAIN, indexes, CREATE TABLE AS, views, INSERT/UPDATE/DELETE |

## How to work

1. Open a level file and write your query under an exercise's `\echo` line.
2. Run the whole file from the project root:

   ```bash
   docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/exercises/level1_single_table.sql
   ```

3. Each result is printed under its `--- 1.x` label, so you can tell them apart.

The file runs every query in it each time. When an exercise is done and you
don't want it to run again (some queries on 11M rows take a few seconds), wrap
it in a block comment: `/* ... */`.

## Tables

- `trips_raw`: one row per taxi trip, January to March 2026 (about 11 million rows)
- `zones`: one row per taxi zone (265 rows)

Inside psql, `\d trips_raw` and `\d zones` show the columns.
