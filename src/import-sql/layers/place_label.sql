CREATE OR REPLACE VIEW place_label_z3 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 2
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z4 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 4
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z5 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 7
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z6toz7 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 10
      AND type IN ('city', 'town')
);

CREATE OR REPLACE VIEW place_label_z8 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('city', 'town')
);

CREATE OR REPLACE VIEW place_label_z9 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town')
);

CREATE OR REPLACE VIEW place_label_z10 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town', 'village')
);

CREATE OR REPLACE VIEW place_label_z11toz12 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town', 'village', 'suburb')
);

CREATE OR REPLACE VIEW place_label_z13 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town', 'village', 'suburb', 'hamlet')
);

CREATE OR REPLACE VIEW place_label_z14 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
);

CREATE OR REPLACE FUNCTION normalize_scalerank(scalerank INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN scalerank >= 9 THEN 9
        ELSE scalerank
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION place_label_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 128;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_place_geometry'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_place_geometry
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
    );
END;
$$ LANGUAGE plpgsql;
