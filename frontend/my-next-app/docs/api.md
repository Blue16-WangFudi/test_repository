# 环境监控看板接口文档

## 获取环境监控看板数据

用于一次性返回页面渲染所需的设备状态、关键指标、阈值、趋势数据和告警列表。前端可直接用该接口渲染 ECharts 趋势图、指标卡、设备健康状态和最近告警。

请求方式：GET  
接口地址：`/api/dashboard/overview`

### 请求参数

| 参数 | 类型 | 必填 | 示例 | 说明 |
|---|---|---|---|---|
| `deviceId` | string | 是 | `1001` | 设备 ID |
| `range` | string | 否 | `24h` | 时间范围，可选：`1h`、`6h`、`24h`、`7d` |
| `interval` | string | 否 | `1h` | 聚合粒度，可选：`1m`、`5m`、`1h`、`1d` |

请求示例：

```http
GET /api/dashboard/overview?deviceId=1001&range=24h&interval=1h
```

### 成功返回示例

```json
{
  "code": 200,
  "message": "success",
  "traceId": "req_20260507_001",
  "serverTime": "2026-05-07T10:30:00+08:00",
  "data": {
    "device": {
      "deviceId": "1001",
      "name": "一号温湿度传感器",
      "location": "实验室 A 区",
      "status": "online",
      "lastHeartbeat": "2026-05-07T10:29:42+08:00",
      "batteryPercent": 86
    },
    "summary": {
      "temperature": {
        "current": 25.8,
        "avg": 25.1,
        "min": 22.4,
        "max": 29.6,
        "unit": "°C"
      },
      "humidity": {
        "current": 61.2,
        "avg": 58.7,
        "min": 45.3,
        "max": 72.8,
        "unit": "%"
      },
      "onlineRate": 99.2,
      "alertCount": 3,
      "sampleCount": 24
    },
    "thresholds": {
      "temperature": {
        "normalMin": 18,
        "normalMax": 28,
        "warningMin": 15,
        "warningMax": 32
      },
      "humidity": {
        "normalMin": 40,
        "normalMax": 70,
        "warningMin": 30,
        "warningMax": 80
      }
    },
    "timeSeries": [
      {
        "time": "2026-05-07T00:00:00+08:00",
        "temperature": 23.8,
        "humidity": 55.2,
        "status": "online",
        "alertLevel": "normal"
      },
      {
        "time": "2026-05-07T01:00:00+08:00",
        "temperature": 24.1,
        "humidity": 56.8,
        "status": "online",
        "alertLevel": "normal"
      },
      {
        "time": "2026-05-07T02:00:00+08:00",
        "temperature": 29.6,
        "humidity": 72.8,
        "status": "online",
        "alertLevel": "warning"
      },
      {
        "time": "2026-05-07T03:00:00+08:00",
        "temperature": 26.2,
        "humidity": 63.4,
        "status": "online",
        "alertLevel": "normal"
      }
    ],
    "alerts": [
      {
        "id": "alert_001",
        "time": "2026-05-07T02:00:00+08:00",
        "level": "warning",
        "type": "temperature_high",
        "title": "温度偏高",
        "value": 29.6,
        "threshold": 28,
        "resolved": true
      },
      {
        "id": "alert_002",
        "time": "2026-05-07T02:00:00+08:00",
        "level": "warning",
        "type": "humidity_high",
        "title": "湿度偏高",
        "value": 72.8,
        "threshold": 70,
        "resolved": true
      }
    ]
  }
}
```

### 字段说明

| 字段 | 说明 |
|---|---|
| `device` | 当前设备基础信息、在线状态、最后心跳和电量 |
| `summary.temperature` | 温度当前值、平均值、最小值、最大值和单位 |
| `summary.humidity` | 湿度当前值、平均值、最小值、最大值和单位 |
| `summary.onlineRate` | 当前时间范围内设备在线率 |
| `summary.alertCount` | 当前时间范围内告警数量 |
| `summary.sampleCount` | 当前时间范围内趋势采样点数量 |
| `thresholds` | 正常区间和预警区间，用于 ECharts `markLine` / `markArea` |
| `timeSeries` | 趋势图数据源 |
| `alerts` | 最近告警列表 |

### ECharts 渲染建议

- `timeSeries[].time` 作为横轴。
- `timeSeries[].temperature` 和 `timeSeries[].humidity` 分别作为两条折线。
- `thresholds.temperature.normalMin/normalMax` 用于温度正常区间参考线。
- `thresholds.humidity.normalMin/normalMax` 用于湿度正常区间参考线。
- `summary` 用于顶部指标卡。
- `alerts` 用于底部最近告警列表。

### 错误返回示例

参数错误：

```json
{
  "code": 400,
  "message": "invalid deviceId",
  "traceId": "req_20260507_002",
  "data": null
}
```

设备不存在：

```json
{
  "code": 404,
  "message": "device not found",
  "traceId": "req_20260507_003",
  "data": null
}
```
