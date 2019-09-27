<h1 align="center">Welcome to pg-coordtransform 👋</h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-1.0-blue.svg?cacheSeconds=2592000" />
</p>

> 基于PostgreSQL和PostGIS的坐标转换函数，支持点、线、面的WGS84、GCJ02以及BD09坐标系之间互转。
## Example
```sql
GCJ02转WGS84
select geoc_gcj02towgs84(geom) from test_table
WGS84转GCJ02
select geoc_wgs84togcj02(geom) from test_table
WGS84转BD09
select geoc_wgs84tobd09(geom) from test_table
BD09转WGS84
select geoc_bd09towgs84(geom) from test_table
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

- [CTOLib码库](https://javascript.ctolib.com/geocompass-pg-coordtransform.html)

- 国信司南

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

## Show your support

Give a ⭐️ if this project helped you!

***
