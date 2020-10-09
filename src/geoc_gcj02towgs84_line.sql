CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84_line"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		p_p     geometry;
		p_t     geometry;
		z_t     geometry;
		i       int;
BEGIN
    i:=1;
	while i <= st_npoints(geom) LOOP
		p_p := st_pointn(geom,i);
		p_t := geoc_gcj02towgs84_point(p_p);
		geom:=st_setpoint(geom,i-1,p_t);
		i:=i+1;
	end LOOP;
	return geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;