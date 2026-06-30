ALTER TABLE "LocateIQ"
ADD COLUMN geom geometry(Point, 4326);
UPDATE "LocateIQ"
SET geom = ST_SetSRID(
  ST_MakePoint(longitude, latitude),
  4326
);

ALTER TABLE "poi"
ADD COLUMN IF NOT EXISTS geom geometry(Point, 4326);

UPDATE "poi"
SET geom = ST_SetSRID(
  ST_MakePoint("X"::double precision, "Y"::double precision),
  4326
)
WHERE geom IS NULL;

SELECT neighborhood, COUNT(*)
FROM "LocateIQ"
GROUP BY neighborhood
HAVING COUNT(*) > 1;


WITH counts AS (
  SELECT
    n.neighborhood AS neighborhood_key,

    COUNT(*) FILTER (
      WHERE
        p.amenity IN ('school','college','university','kindergarten',
                      'hospital','clinic','doctors','pharmacy',
                      'police','fire_station','townhall','courthouse',
                      'place_of_worship')
        OR p.tourism IN ('museum','attraction')
    ) AS services_count,

    COUNT(*) FILTER (
      WHERE
        p.amenity IN ('restaurant','cafe','fast_food','fuel')
        OR COALESCE(p.shop,'') <> ''
        OR p.tourism IN ('hotel','guest_house')
    ) AS competitors_count

  FROM "LocateIQ" n
  LEFT JOIN "poi" p
    ON ST_DWithin(n.geom::geography, p.geom::geography, 1000)
  GROUP BY n.neighborhood
)
UPDATE "LocateIQ" n
SET
  "servicesCount"    = c.services_count,
  "competitorsCount" = c.competitors_count
FROM counts c
WHERE n.neighborhood = c.neighborhood_key;

SELECT city, neighborhood, "servicesCount", "competitorsCount"
FROM "LocateIQ"
ORDER BY "servicesCount" DESC
LIMIT 20;



WITH counts AS (
  SELECT
    n.neighborhood AS neighborhood_key,
    COUNT(*) FILTER (
      WHERE
        p.amenity IN ('school','college','university','kindergarten',
                      'hospital','clinic','doctors','pharmacy',
                      'police','fire_station','townhall','courthouse',
                      'place_of_worship')
        OR p.tourism IN ('museum','attraction')
    ) AS services_count,

    COUNT(*) FILTER (
      WHERE
        p.amenity IN ('restaurant','cafe','fast_food','fuel')
        OR COALESCE(p.shop,'') <> ''
        OR p.tourism IN ('hotel','guest_house')
    ) AS competitors_count

  FROM "LocateIQ1" n
  LEFT JOIN "poi" p
    ON ST_DWithin(n.geom::geography, p.geom::geography, 3000)
  GROUP BY n.neighborhood
)
UPDATE "LocateIQ1" n
SET
  "servicesCount"    = c.services_count,
  "competitorsCount" = c.competitors_count
FROM counts c
WHERE n.neighborhood = c.neighborhood_key;

SELECT city, neighborhood, "servicesCount", "competitorsCount"
FROM "LocateIQ1"
ORDER BY "servicesCount" DESC






SELECT city, neighborhood, COUNT(*)
FROM "LocateIQ1"
GROUP BY city, neighborhood
HAVING COUNT(*) > 1;



ALTER TABLE "LocateIQ1"
ADD COLUMN IF NOT EXISTS locateiq_id BIGSERIAL;



DELETE FROM "LocateIQ1"
WHERE locateiq_id = 102;



ALTER TABLE "LocateIQ1"
ADD CONSTRAINT locateiq1_city_neighborhood_unique
UNIQUE (city, neighborhood);




SELECT column_name
FROM information_schema.columns
WHERE table_name = 'populated_places1';

ALTER TABLE "populated_places1"
ADD COLUMN geom geometry(Point, 4326);

UPDATE "populated_places1"
SET geom = ST_SetSRID(
  ST_MakePoint("X"::double precision, "Y"::double precision),
  4326
);




ALTER TABLE "LocateIQ1"
ADD COLUMN IF NOT EXISTS popplaces_within_5km integer,
ADD COLUMN IF NOT EXISTS population_within_5km numeric,
ADD COLUMN IF NOT EXISTS nearest_popplace_dist_m numeric;

WITH agg AS (
  SELECT
    n.neighborhood,
    n.city,

    COUNT(p.*) FILTER (
      WHERE ST_DWithin(n.geom::geography, p.geom::geography, 5000)
    ) AS popplaces_within_5km,

    SUM(
      NULLIF(p.population, '')::numeric
    ) FILTER (
      WHERE ST_DWithin(n.geom::geography, p.geom::geography, 5000)
    ) AS population_within_5km,

    MIN(
      ST_Distance(n.geom::geography, p.geom::geography)
    ) AS nearest_popplace_dist_m

  FROM "LocateIQ1" n
  LEFT JOIN "populated_places1" p
    ON TRUE
  GROUP BY n.neighborhood, n.city
)
UPDATE "LocateIQ1" n
SET
  popplaces_within_5km = a.popplaces_within_5km,
  population_within_5km = a.population_within_5km,
  nearest_popplace_dist_m = a.nearest_popplace_dist_m
FROM agg a
WHERE n.neighborhood = a.neighborhood
  AND n.city = a.city;

SELECT city, neighborhood, popplaces_within_5km, population_within_5km, nearest_popplace_dist_m
FROM "LocateIQ1"
LIMIT 10;


UPDATE "LocateIQ1"
SET "populationDensity" = 0
WHERE "populationDensity" IS NULL;






SELECT column_name
FROM information_schema.columns
WHERE table_name = 'LocateIQ1';




DROP TABLE IF EXISTS "LocateIQ_Dataset_Final";

CREATE TABLE "LocateIQ_Dataset_Final" AS
SELECT
  city,
  neighborhood,
  "populationDensity" AS population_density,
  "servicesCount" AS services_count,
  "competitorsCount" AS competitors_count,
  latitude,
  longitude
FROM "LocateIQ1";


SELECT *
FROM "LocateIQ_Dataset_Final"





ALTER TABLE "LocateIQ_Dataset_Final"
ADD COLUMN id SERIAL PRIMARY KEY;


create table public."LocateIQ" (
  city text null,
  neighborhood text not null,
  latitude double precision null,
  longitude double precision null,
  "populationDensity" bigint null,
  "competitorsCount" bigint null,
  "servicesCount" bigint null,
  geom geometry null,
  constraint LocateIQ_pkey primary key (neighborhood)
) TABLESPACE pg_default;

create index IF not exists idx_locateiq_geom on public."LocateIQ" using gist (geom) TABLESPACE pg_default;

SELECT COUNT(*) FROM "LocateIQ";