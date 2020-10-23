<h1 align="center">Welcome to pg-coordtransform 👋</h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-1.0-blue.svg?cacheSeconds=2592000" />
</p>

> 基于PostgreSQL和PostGIS的坐标转换函数，支持点、线、面的WGS84和CGCS2000与GCJ02和BD09坐标系与之间互转。
## Example
```sql
-- 如果转换后结果为null，查看geom的srid是否为4326或者4490
WGS84转GCJ02
select geoc_wgs84togcj02(geom) from test_table
GCJ02转WGS84
select geoc_gcj02towgs84(geom) from test_table

WGS84转BD09
select geoc_wgs84tobd09(geom) from test_table
BD09转WGS84
select geoc_bd09towgs84(geom) from test_table

CGCS2000转GCJ02
select geoc_cgcs2000togcj02(geom) from test_table
GCJ02转CGCS2000
select geoc_gcj02tocgcs2000(geom) from test_table

CGCS2000转BD09
select geoc_cgcs2000tobd09(geom) from test_table
BD09转CGCS2000
select geoc_bd09tocgcs2000(geom) from test_table

GCJ02转BD09
select geoc_gcj02tobd09(geom) from test_table
BD09转GCJ02
select geoc_bd09togcj02(geom) from test_table
```

## How to use
```
PostgreSQL安装PostGIS扩展
复制geoc-pg-coordtansform.sql中代码，在数据库执行
```
# Who use/Who star

- 阿里巴巴（digoal,德哥）

- 国信司南（北京）地理信息技术有限公司（本库作者）

- [CTOLib码库](https://javascript.ctolib.com/geocompass-pg-coordtransform.html)

- 九天气象（lzuniujp08）

- 深圳普天宜通股份有限公司（ShareQiu1994）

- 中原百科（zhongyuanbaike）

- MonsterBOBO（hanrea）

- nocode（sanford）


## Author

👤 **LH  QQ:1016817543**

👤 **Wangsb  QQ:1017218804**

* Github: [@MrSmallLiu](https://github.com/MrSmallLiu)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/geocompass/pg-coordtransform/issues).
## 开发
修改src下的文件，使用linux相关命令将文件合并为一个

`find src/ -name "*.sql" | xargs sed 'a\' > geoc-pg-coordtransform.sql`
## Show your support

Give a ⭐️ if this project helped you!

***
