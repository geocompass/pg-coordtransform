CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84_multipolygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    single_polygon  geometry;
    single_polygon_trans  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_MultiPolygon' THEN
        RETURN null;
    END IF;
    FOR single_polygon IN SELECT (ST_Dump($1)).geom LOOP
        single_polygon_trans := geoc_bd09towgs84_polygon(single_polygon); 
        target_parts := array_append(target_parts,single_polygon_trans);
    END LOOP;
    
    SELECT st_multi(ST_Union(target_parts)) INTO final_geom;
    RETURN final_geom;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84_polygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    source_npoints  integer;
    single_line     geometry;
    single_line_trans geometry;
    single_polygon  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_Polygon' THEN
        RETURN null;
    END IF;

    FOR single_polygon IN SELECT ST_ExteriorRing ((st_dumprings($1)).geom) as geom LOOP				
        source_npoints := ST_NPoints(single_polygon); 
        single_line  := ST_RemovePoint(single_polygon, source_npoints - 1);  
        single_line_trans := geoc_bd09towgs84_line(single_line);  
        target_parts := array_append(target_parts, ST_AddPoint(single_line_trans, ST_PointN(single_line_trans, 1)));  
    END LOOP;
    SELECT ST_MakePolygon(target_parts[1], target_parts[2:array_upper(target_parts, 1)]) INTO final_geom; 
    RETURN final_geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
CREATE OR REPLACE FUNCTION "public"."geoc_cgcs2000togcj02"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' THEN
        RETURN null;
end if;
return geoc_wgs84togcj02(st_transform(st_setsrid(geom,4490),4326));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_delta"("lon" numeric, "lat" numeric)
  RETURNS "pg_catalog"."jsonb" AS $BODY$
DECLARE
    ret             varchar;
    dLon            numeric;
    dlat            numeric;
    radLat          numeric;
    magic           numeric;
    sqrtMagic       numeric;
    ee              numeric;
    a               numeric;
BEGIN
    ee := 0.006693421622965823;
    a  := 6378245;
    dLon := geoc_transform_lon(lon - 105, lat - 35);
    dLat := geoc_transform_lat(lon - 105, lat - 35);
    radLat := lat / 180 * pi();
    magic = sin(radLat);

    magic = 1 - ee * magic * magic;

    sqrtMagic := sqrt(magic);
    dLon = (dLon * 180) / (a / sqrtMagic * cos(radLat) * pi());
    dLat = (dLat * 180) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi());
    ret :='['||dLon||','||dLat||']';
	return ret::jsonb;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
end if;
case ST_GeometryType(geom)
    when 'ST_LineString' then 
			return geoc_gcj02tobd09_line(geom);
	when 'ST_MultiLineString' then 
		return geoc_gcj02tobd09_multiline(geom);
	when 'ST_Point' then 
		return geoc_gcj02tobd09_point(geom);
	when 'ST_MultiPoint' then 
			return geoc_gcj02tobd09_multipoint(geom);
	when 'ST_Polygon' then 
			return geoc_gcj02tobd09_polygon(geom);
	when 'ST_MultiPolygon' then
		return geoc_gcj02tobd09_multipolygon(geom); 
	ELSE
    	RETURN null;
END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09_line"("geom" "public"."geometry")
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
		p_t := geoc_gcj02tobd09_point(p_p);
		geom:=st_setpoint(geom,i-1,p_t);
		i:=i+1;
	end LOOP;
	return geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09_multiline"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom  $Q$ using geom LOOP
	  	transform_i :=geoc_gcj02tobd09_line(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09_multipoint"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom  $Q$ using geom LOOP
	  	transform_i :=geoc_gcj02tobd09_point(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09_multipolygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    single_polygon  geometry;
    single_polygon_trans  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_MultiPolygon' THEN
        RETURN null;
    END IF;
        FOR single_polygon IN SELECT (ST_Dump($1)).geom LOOP
                single_polygon_trans := geoc_gcj02tobd09_polygon(single_polygon); 
                target_parts := array_append(target_parts,single_polygon_trans);
        END LOOP;
				
        SELECT st_multi(ST_Union(target_parts)) INTO final_geom;
        RETURN final_geom;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09_polygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    source_npoints  integer;
    single_line     geometry;
    single_line_trans geometry;
    single_polygon  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_Polygon' THEN
        RETURN null;
    END IF;

    FOR single_polygon IN SELECT ST_ExteriorRing ((st_dumprings($1)).geom) as geom LOOP				
        source_npoints := ST_NPoints(single_polygon); 
        single_line  := ST_RemovePoint(single_polygon, source_npoints - 1);  
        single_line_trans := geoc_gcj02tobd09_line(single_line);  
        target_parts := array_append(target_parts, ST_AddPoint(single_line_trans, ST_PointN(single_line_trans, 1)));  
    END LOOP;
    SELECT ST_MakePolygon(target_parts[1], target_parts[2:array_upper(target_parts, 1)]) INTO final_geom;
    RETURN final_geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tocgcs2000"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' THEN
        RETURN null;
end if;
return st_transform(st_setsrid(geoc_gcj02towgs84(geom),4326),4490);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
end if;
case ST_GeometryType(geom)
    when 'ST_LineString' then 
			return geoc_gcj02towgs84_line(geom);
	when 'ST_MultiLineString' then 
		return geoc_gcj02towgs84_multiline(geom);
	when 'ST_Point' then 
		return geoc_gcj02towgs84_point(geom);
	when 'ST_MultiPoint' then 
			return geoc_gcj02towgs84_multipoint(geom);
	when 'ST_Polygon' then 
			return geoc_gcj02towgs84_polygon(geom);
	when 'ST_MultiPolygon' then
		return geoc_gcj02towgs84_multipolygon(geom); 
	ELSE
    	RETURN null;
END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84_multipoint"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom  $Q$ using geom LOOP
	  	transform_i :=geoc_gcj02towgs84_point(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84_multipolygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    single_polygon  geometry;
    single_polygon_trans  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_MultiPolygon' THEN
        RETURN null;
    END IF;
        FOR single_polygon IN SELECT (ST_Dump($1)).geom LOOP
                single_polygon_trans := geoc_gcj02towgs84_polygon(single_polygon); 
                target_parts := array_append(target_parts,single_polygon_trans);
        END LOOP;
				
        SELECT st_multi(ST_Union(target_parts)) INTO final_geom;
        RETURN final_geom;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
CREATE OR REPLACE FUNCTION "public"."geoc_gcj02towgs84_polygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    source_npoints  integer;
    single_line     geometry;
    single_line_trans geometry;
    single_polygon  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_Polygon' THEN
        RETURN null;
    END IF;

    FOR single_polygon IN SELECT ST_ExteriorRing ((st_dumprings($1)).geom) as geom LOOP				
        source_npoints := ST_NPoints(single_polygon); 
        single_line  := ST_RemovePoint(single_polygon, source_npoints - 1);  
        single_line_trans := geoc_gcj02towgs84_line(single_line);  
        target_parts := array_append(target_parts, ST_AddPoint(single_line_trans, ST_PointN(single_line_trans, 1)));  
    END LOOP;
    SELECT ST_MakePolygon(target_parts[1], target_parts[2:array_upper(target_parts, 1)]) INTO final_geom; 
    RETURN final_geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_is_in_china_bbox"("lon" numeric, "lat" numeric)
  RETURNS "pg_catalog"."bool" AS $BODY$
DECLARE
BEGIN
    
    return lon >= 72.004 and lon <= 137.8347 and lat >= 0.8293 and lat <= 55.8271;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_transform_lat"("x" numeric, "y" numeric)
  RETURNS "pg_catalog"."numeric" AS $BODY$
DECLARE
ret   numeric;
BEGIN
    ret := -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret := ret + (20 * sin(6 * x * PI()) + 20 * sin(2 * x * PI())) * 2 / 3;
    ret := ret +(20 * sin(y * PI()) + 40 * sin(y / 3 * PI())) * 2 / 3;
    ret := ret +(160 * sin(y / 12 * PI()) + 320 * sin(y * PI() / 30)) * 2 / 3;
    return ret;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_transform_lon"("x" numeric, "y" numeric)
  RETURNS "pg_catalog"."numeric" AS $BODY$
DECLARE
    ret   numeric;
BEGIN
    ret := 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    ret :=ret + (20 * sin(6 * x * pi()) + 20 * sin(2 * x * pi())) * 2 / 3;
    ret :=ret + (20 * sin(x * pi()) + 40 * sin(x / 3 * pi())) * 2 / 3;
    ret :=ret + (150 * sin(x / 12 * pi()) + 300 * sin(x / 30 * pi())) * 2 / 3;
    return ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
end if;
case ST_GeometryType(geom)
  when 'ST_LineString' then 
		return geoc_wgs84tobd09_line(geom);
	when 'ST_MultiLineString' then 
		return geoc_wgs84tobd09_multiline(geom);
	when 'ST_Point' then 
		return geoc_wgs84tobd09_point(geom);
	when 'ST_MultiPoint' then 
		return geoc_wgs84tobd09_multipoint(geom);
	when 'ST_Polygon' then 
		return geoc_wgs84tobd09_polygon(geom);
	when 'ST_MultiPolygon' then
		return geoc_wgs84tobd09_multipolygon(geom); 
	ELSE
    	RETURN null;
END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09_line"("geom" "public"."geometry")
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
		p_t := geoc_wgs84tobd09_point(p_p);
		geom:=st_setpoint(geom,i-1,p_t);
		i:=i+1;
	end LOOP;
	return geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09_multiline"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom  $Q$ using geom LOOP
	  	transform_i :=geoc_wgs84tobd09_line(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09_multipoint"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom  $Q$ using geom LOOP
	  	transform_i :=geoc_wgs84tobd09_point(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09_multipolygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    single_polygon  geometry;
    single_polygon_trans  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_MultiPolygon' THEN
        RETURN null;
    END IF;
        FOR single_polygon IN SELECT (ST_Dump($1)).geom LOOP
                single_polygon_trans := geoc_wgs84tobd09_polygon(single_polygon); 
                target_parts := array_append(target_parts,single_polygon_trans);
        END LOOP;
				
        SELECT st_multi(ST_Union(target_parts)) INTO final_geom;
        RETURN final_geom;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09_polygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    source_npoints  integer;
    single_line     geometry;
    single_line_trans geometry;
    single_polygon  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_Polygon' THEN
        RETURN null;
    END IF;

    FOR single_polygon IN SELECT ST_ExteriorRing ((st_dumprings($1)).geom) as geom LOOP				
        source_npoints := ST_NPoints(single_polygon); 
        single_line  := ST_RemovePoint(single_polygon, source_npoints - 1);  
        single_line_trans := geoc_wgs84tobd09_line(single_line);  
        target_parts := array_append(target_parts, ST_AddPoint(single_line_trans, ST_PointN(single_line_trans, 1)));  
    END LOOP;
    SELECT ST_MakePolygon(target_parts[1], target_parts[2:array_upper(target_parts, 1)]) INTO final_geom;  
    RETURN final_geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
end if;
 	CASE ST_GeometryType(geom)
    	when 'ST_LineString' then 
			return geoc_wgs84togcj02_line(geom);
		when 'ST_MultiLineString' then 
			return geoc_wgs84togcj02_multiline(geom);
		when 'ST_Point' then 
			return geoc_wgs84togcj02_point(geom);
		when 'ST_MultiPoint' then 
			return geoc_wgs84togcj02_multipoint(geom);
		when 'ST_Polygon' then 
			return geoc_wgs84togcj02_polygon(geom);
		when 'ST_MultiPolygon' then
			return geoc_wgs84togcj02_multipolygon(geom);
		ELSE
     		RETURN null;
	END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02_line"("geom" "public"."geometry")
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
    	p_t := geoc_wgs84togcj02_point(p_p);
		geom:=st_setpoint(geom,i-1,p_t);
		i:=i+1;
	end LOOP;
	return geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02_multiline"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom $Q$ using geom LOOP
	  	transform_i :=geoc_wgs84togcj02_line(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02_multipoint"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom $Q$ using geom LOOP
	  	transform_i :=geoc_wgs84togcj02_point(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02_multipolygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    single_polygon  geometry;
    single_polygon_trans  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_MultiPolygon' THEN
        RETURN null;
    END IF;
    FOR single_polygon IN SELECT (ST_Dump($1)).geom LOOP
        single_polygon_trans := geoc_wgs84togcj02_polygon(single_polygon); 
        target_parts := array_append(target_parts,single_polygon_trans);
    END LOOP;
    
    SELECT st_multi(ST_Union(target_parts)) INTO final_geom;
    RETURN final_geom;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02_polygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    source_npoints  integer;
    single_line     geometry;
    single_line_trans geometry;
    single_polygon  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_Polygon' THEN
        RETURN null;
    END IF;

    FOR single_polygon IN SELECT ST_ExteriorRing ((st_dumprings($1)).geom) as geom LOOP				
        source_npoints := ST_NPoints(single_polygon); 
        single_line  := ST_RemovePoint(single_polygon, source_npoints - 1);  
        single_line_trans := geoc_wgs84togcj02_line(single_line);  
        target_parts := array_append(target_parts, ST_AddPoint(single_line_trans, ST_PointN(single_line_trans, 1)));  
    END LOOP;
    SELECT ST_MakePolygon(target_parts[1], target_parts[2:array_upper(target_parts, 1)]) INTO final_geom; 
    RETURN final_geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09tocgcs2000"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' THEN
        RETURN null;
end if;
return st_transform(st_setsrid(geoc_bd09towgs84(geom),4326),4490);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09togcj02"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
	end if;
 	CASE ST_GeometryType(geom)
    	when 'ST_LineString' then 
			return geoc_bd09togcj02_line(geom);
		when 'ST_MultiLineString' then 
			return geoc_bd09togcj02_multiline(geom);
		when 'ST_Point' then 
			return geoc_bd09togcj02_point(geom);
		when 'ST_MultiPoint' then 
			return geoc_bd09togcj02_multipoint(geom);
		when 'ST_Polygon' then 
			return geoc_bd09togcj02_polygon(geom);
		when 'ST_MultiPolygon' then
			return geoc_bd09togcj02_multipolygon(geom);
		ELSE
     		RETURN null;
	END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09togcj02_line"("geom" "public"."geometry")
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
    	p_t := geoc_bd09togcj02_point(p_p);
		geom:=st_setpoint(geom,i-1,p_t);
		i:=i+1;
	end LOOP;
	return geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09togcj02_multiline"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom $Q$ using geom LOOP
	  	transform_i :=geoc_bd09togcj02_line(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09togcj02_multipoint"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom $Q$ using geom LOOP
	  	transform_i :=geoc_bd09togcj02_point(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09togcj02_multipolygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    single_polygon  geometry;
    single_polygon_trans  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_MultiPolygon' THEN
        RETURN null;
    END IF;
    FOR single_polygon IN SELECT (ST_Dump($1)).geom LOOP
        single_polygon_trans := geoc_bd09togcj02_polygon(single_polygon); 
        target_parts := array_append(target_parts,single_polygon_trans);
    END LOOP;
    
    SELECT st_multi(ST_Union(target_parts)) INTO final_geom;
    
    RETURN final_geom;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
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
CREATE OR REPLACE FUNCTION "public"."geoc_bd09togcj02_polygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    source_npoints  integer;
    single_line     geometry;
    single_line_trans geometry;
    single_polygon  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_Polygon' THEN
        RETURN null;
    END IF;

    FOR single_polygon IN SELECT ST_ExteriorRing ((st_dumprings($1)).geom) as geom LOOP				
        source_npoints := ST_NPoints(single_polygon); 
        single_line  := ST_RemovePoint(single_polygon, source_npoints - 1);  
        single_line_trans := geoc_bd09togcj02_line(single_line);  
        target_parts := array_append(target_parts, ST_AddPoint(single_line_trans, ST_PointN(single_line_trans, 1)));  
    END LOOP;
    SELECT ST_MakePolygon(target_parts[1], target_parts[2:array_upper(target_parts, 1)]) INTO final_geom;  

    RETURN final_geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
	IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
	end if;
 	CASE ST_GeometryType(geom)
    	when 'ST_LineString' then 
			return geoc_bd09towgs84_line(geom);
		when 'ST_MultiLineString' then 
			return geoc_bd09towgs84_multiline(geom);
		when 'ST_Point' then 
			return geoc_bd09towgs84_point(geom);
		when 'ST_MultiPoint' then 
			return geoc_bd09towgs84_multipoint(geom);
		when 'ST_Polygon' then 
			return geoc_bd09towgs84_polygon(geom);
		when 'ST_MultiPolygon' then
			return geoc_bd09towgs84_multipolygon(geom);
		ELSE
     		RETURN null;
	END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84_line"("geom" "public"."geometry")
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
    	p_t := geoc_bd09towgs84_point(p_p);
		geom:=st_setpoint(geom,i-1,p_t);
		i:=i+1;
	end LOOP;
	return geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84_multiline"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom $Q$ using geom LOOP
	  	transform_i :=geoc_bd09towgs84_line(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84_multipoint"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
    multiArr:='{}'::geometry[];
	for i in EXECUTE $Q$ select (st_dump($1)).geom $Q$ using geom LOOP
	  	transform_i :=geoc_bd09towgs84_point(i);
		multiArr := array_append(multiArr, transform_i);
	end LOOP;
	return st_multi(ST_Union(multiArr));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
