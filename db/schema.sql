-- Raw storage only. Column names are the source names, lowercased.
-- No primary key, foreign keys or indexes on trips_raw on purpose.

CREATE TABLE IF NOT EXISTS trips_raw (
    vendorid              integer,
    tpep_pickup_datetime  timestamp,
    tpep_dropoff_datetime timestamp,
    passenger_count       bigint,
    trip_distance         numeric,
    ratecodeid            bigint,
    store_and_fwd_flag    text,
    pulocationid          integer,
    dolocationid          integer,
    payment_type          bigint,
    fare_amount           numeric,
    extra                 numeric,
    mta_tax               numeric,
    tip_amount            numeric,
    tolls_amount          numeric,
    improvement_surcharge numeric,
    total_amount          numeric,
    congestion_surcharge  numeric,
    airport_fee           numeric,
    cbd_congestion_fee    numeric
);

CREATE TABLE IF NOT EXISTS zones (
    locationid   integer PRIMARY KEY,
    borough      text,
    zone         text,
    service_zone text
);
