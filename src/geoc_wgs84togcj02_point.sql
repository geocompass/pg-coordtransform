CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02_point"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    lon     numeric;
    lat     numeric;
    d       jsonb;
    dlon    numeric;
    dlat    numeric;
BEGIN
    if st_geometrytype(geom) != 'ST_Point' then
        return null;
    end if;
    lon := st_x(geom);
    lat := st_y(geom);
    if (geoc_is_in_china_bbox(lon, lat) = false) then
        return geom;
    end if;
    d := geoc_delta(lon, lat);
    dlon := d->0;
    dlat := d->1;
    return st_makepoint(lon + dlon,lat + dlat);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;