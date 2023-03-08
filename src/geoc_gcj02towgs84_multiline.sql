CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84_multiline"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom  $Q$ using geom LOOP
	  	transform_i :=geoc_gcj02towgs84_line(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Collect(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
