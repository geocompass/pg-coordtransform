CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84_point"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
  x       numeric; 
	y       numeric; 
	gcj_point  geometry;
	wgs_point  geometry;

BEGIN
    if st_geometrytype(geom) != 'ST_Point' then
      return null;
    end if;
    x := st_x(geom);
    y := st_y(geom);
    if (geoc_is_in_china_bbox(x, y) = false) then
      return geom;
    end if;
    gcj_point = geoc_bd09togcj02_point(geom);
	  wgs_point = geoc_gcj02towgs84_point(gcj_point);
	  return wgs_point;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;