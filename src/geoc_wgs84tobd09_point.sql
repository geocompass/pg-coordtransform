CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09_point"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
lon       numeric; 
lat       numeric; 
bd_point  geometry;
gcj_point  geometry;

BEGIN
    if st_geometrytype(geom) != 'ST_Point' then
      return null;
    end if;
    lon := st_x(geom);
    lat := st_y(geom);
    if geoc_is_in_china_bbox(lon, lat) = false THEN 
      return geom;
    end if;
    gcj_point = geoc_wgs84togcj02_point(geom);
		bd_point = geoc_gcj02tobd09_point(gcj_point);
	  return bd_point; 

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;