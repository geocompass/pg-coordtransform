CREATE OR REPLACE FUNCTION "public"."geoc_bd09togcj02_point"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
  x       numeric; 
	y       numeric; 
 	z       double precision; 
 	theta   double precision; 
 	x_pi    double precision:=3.14159265358979324 * 3000.0 / 180.0; 
	gcj_point  geometry;

BEGIN
    if st_geometrytype(geom) != 'ST_Point' then
        return null;
    end if;
    x := st_x(geom);
    y := st_y(geom);
    if (geoc_is_in_china_bbox(x, y) = false) then
        return geom;
    end if;
    x:= ST_X(geom) - 0.0065; 
    y:= ST_Y(geom) - 0.006; 
    z:=sqrt(power(x,2) + power(y,2)) - 0.00002 *sin(y * x_pi); 
    theta:= atan2(y, x) - 0.000003 * cos(x * x_pi); 
	  gcj_point:=ST_SetSRID(ST_MakePoint(z *cos(theta),z *sin(theta)),4326); 
	 return gcj_point;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;