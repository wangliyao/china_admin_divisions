# China Admin Divisions

中国行政区划数据 gem，提供省/市/区县/乡镇街道四级联动查询功能。

## 数据来源

数据来自 [province-city-china](https://github.com/uiwjs/province-city-china) npm 包，原始数据源自：
- 民政部
- 国家统计局
- 腾讯地图行政区划
- 高德地图行政区划

**最新数据版本: 2025年**

## 数据统计

- 省/直辖市/自治区/特别行政区: **34**
- 市/自治州/地区: **337**
- 区/县/县级市: **3285**
- 乡镇/街道: **41278**

## 安装

```ruby
gem "china_admin_divisions", path: "https://github.com/wangliyao/china_admin_divisions"
```

## 使用方法

### 下载最新数据

```bash
rake download
```

### 查询接口

```ruby
require "china_admin_divisions"

# 获取所有省份
ChinaAdminDivisions::Query.provinces
# => [{ code: "110000", name: "北京市", short_code: "11" }, ...]

# 获取某省份下的城市 (支持2位短码或6位完整代码)
ChinaAdminDivisions::Query.cities("13")  # 河北省
# => [{ code: "130100", name: "石家庄市", province_code: "13", city_code: "01" }, ...]

# 获取某城市下的区县 (支持4位短码或6位完整代码)
ChinaAdminDivisions::Query.districts("1301")  # 石家庄市
# => [{ code: "130102", name: "长安区", ... }, ...]

# 获取某区县下的乡镇街道 (使用6位区县代码)
ChinaAdminDivisions::Query.towns("110101")  # 北京市东城区
# => [{ code: "110101001000", name: "东华门街道", ... }, ...]

# 根据代码获取完整地址链 (12位乡镇街道代码)
ChinaAdminDivisions::Query.chain("110101001000")
# => {
#   province: { code: "110000", name: "北京市" },
#   district: { code: "110101", name: "东城区" },
#   town: { code: "110101001000", name: "东华门街道" }
# }

# 搜索地址 (模糊匹配名称)
ChinaAdminDivisions::Query.search("朝阳", limit: 10)
# => [{ level: :city, code: "211300", name: "朝阳市" }, { level: :district, code: "110105", name: "朝阳区" }, ...]

# 根据名称查找代码
ChinaAdminDivisions::Query.find_code("朝阳区", level: :district)
# => "110105"

# 验证代码是否存在
ChinaAdminDivisions::Query.valid?("110101")
# => true

# 获取统计信息
ChinaAdminDivisions::Query.stats
# => { provinces: 34, cities: 337, districts: 3285, towns: 41278 }
```

## 行政区划代码说明

中国行政区划代码采用数字编码：

| 层级 | 代码位数 | 示例 |
|------|----------|------|
| 省/直辖市/自治区/特别行政区 | 6位 (后4位为0000) | 110000 (北京市) |
| 市/自治州/地区 | 6位 (后2位为00) | 130100 (石家庄市) |
| 区/县/县级市 | 6位 | 110101 (东城区) |
| 乡镇/街道 | 12位 | 110101001000 (东华门街道) |

**注意:** 直辖市（北京、天津、上海、重庆）没有市级中间层级，区县直接归属省级。

## 文件结构

```
china_admin_divisions/
├── lib/
│   ├── china_admin_divisions.rb          # 主入口
│   └── china_admin_divisions/
│       ├── version.rb                    # 版本号
│       ├── query.rb                      # 查询服务
│       └── downloader.rb                 # 数据下载服务
├── data/
│   ├── provinces.json                    # 省份数据
│   ├── cities.json                       # 城市数据
│   ├── districts.json                    # 区县数据
│   ├── towns.json                        # 乡镇街道数据
│   └── version.json                      # 版本信息
├── china_admin_divisions.gemspec
└── README.md
```

## 数据格式示例

### provinces.json
```json
[
  { "code": "110000", "name": "北京市", "province": "11" },
  { "code": "130000", "name": "河北省", "province": "13" }
]
```

### cities.json
```json
[
  { "code": "130100", "name": "石家庄市", "province": "13", "city": "01" },
  { "code": "130200", "name": "唐山市", "province": "13", "city": "02" }
]
```

### districts.json
```json
[
  { "code": "110101", "name": "东城区", "province": "11", "city": "01", "area": "01" },
  { "code": "110105", "name": "朝阳区", "province": "11", "city": "01", "area": "05" }
]
```

### towns.json
```json
[
  { "code": "110101", "name": "东华门街道", "province": "11", "city": "01", "area": "01", "town": "001000" }
]
```

## License

MIT License
