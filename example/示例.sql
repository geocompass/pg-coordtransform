--仅支持4326 4490坐标系的点、线、面
select ST_GeometryType(geom),st_srid(geom),st_asgeojson(geom),geoc_gcj02towgs84(geom),geoc_wgs84togcj02(geom) from jcb_cd	 limit 1 