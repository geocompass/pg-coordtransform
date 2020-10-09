CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84_point"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    tempPoint  numeric[];
    wgsLon     numeric;
    wgsLat     numeric;
    lon        numeric;
    lat        numeric;
BEGIN
    if st_geometrytype(geom) != 'ST_Point' then
      return null;
    end if;
    lon := st_x(geom);
    lat := st_y(geom);
    if geoc_is_in_china_bbox(lon, lat) = false THEN 
      return geom;
    end if;

    tempPoint := geoc_wgs84togcj02(ARRAY[lon, lat]);
    wgsLon := lon*2 - tempPoint[1];
    wgsLat := lat*2 - tempPoint[2];
    return st_makepoint(wgsLon,wgsLat);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;