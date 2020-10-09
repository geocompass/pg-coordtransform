CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02"("coord" _numeric)
  RETURNS "pg_catalog"."_numeric" AS $BODY$
DECLARE
    ret             numeric[];
    dLon            numeric;
    dlat            numeric;
		lon             numeric;
		lat             numeric;
		d								jsonb;
-- 		coord           ARRAY;
BEGIN
    lon := coord[1];
    lat := coord[2];
    if (geoc_is_in_china_bbox(lon, lat) = false) then
        return coord;
    end if;
    d := geoc_delta(lon, lat);
    dlon := d->0;
    dlat := d->1;
    ret := ARRAY[lon + dlon , lat + dlat];
    return ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;