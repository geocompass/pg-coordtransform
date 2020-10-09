CREATE OR REPLACE FUNCTION "public"."geoc_cgcs2000tobd09"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' THEN
        RETURN null;
end if;
return geoc_wgs84tobd09(st_transform(st_setsrid(geom,4490),4326));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;