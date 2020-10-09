CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09_point"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
z         double precision; 
theta     double precision; 
x_pi      double precision:=3.14159265358979324 * 3000.0 / 180.0; 
lon       numeric; 
lat       numeric; 
bd_point  geometry;

BEGIN
    if st_geometrytype(geom) != 'ST_Point' then
      return null;
    end if;
    lon := st_x(geom);
    lat := st_y(geom);
    if geoc_is_in_china_bbox(lon, lat) = false THEN 
      return geom;
    end if;
    z:= sqrt(power(lon,2) + power(lat,2)) + 0.00002 * sin(lat * x_pi); 
    theta:= atan2(lat, lon) + 0.000003 * cos(lon * x_pi); 
	bd_point:=ST_SetSRID(ST_MakePoint(z * cos(theta) + 0.0065,z * sin(theta) + 0.006),4326); 
	  return bd_point; 

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;