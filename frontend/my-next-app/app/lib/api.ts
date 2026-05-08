export type DeviceStatus = "online" | "offline" | string;

export type DashboardDevice = {
  deviceId: string;
  name: string;
  location: string;
  status: DeviceStatus;
  lastHeartbeat: string;
  batteryPercent: number;
};

export type MetricSummary = {
  current: number;
  avg: number;
  min: number;
  max: number;
  unit: string;
};

export type DashboardSummary = {
  temperature: MetricSummary;
  humidity: MetricSummary;
  onlineRate: number;
  alertCount: number;
  sampleCount: number;
};

export type MetricThreshold = {
  normalMin: number;
  normalMax: number;
  warningMin: number;
  warningMax: number;
};

export type DashboardThresholds = {
  temperature: MetricThreshold;
  humidity: MetricThreshold;
};

export type TimeSeriesPoint = {
  time: string;
  temperature: number | null;
  humidity: number | null;
  status: DeviceStatus;
  alertLevel: "normal" | "warning" | "critical" | string;
};

export type DashboardAlert = {
  id: string;
  time: string;
  level: "info" | "warning" | "critical" | string;
  type: string;
  title: string;
  value: number;
  threshold: number;
  resolved: boolean;
};

export type DashboardOverview = {
  device: DashboardDevice;
  summary: DashboardSummary;
  thresholds: DashboardThresholds;
  timeSeries: TimeSeriesPoint[];
  alerts: DashboardAlert[];
  serverTime?: string;
  traceId?: string;
};

export type DashboardOverviewParams = {
  deviceId: string;
  range?: "1h" | "6h" | "24h" | "7d";
  interval?: "1m" | "5m" | "1h" | "1d";
};

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function buildApiUrl(path: string) {
  if (!API_BASE_URL) {
    throw new Error("缺少 NEXT_PUBLIC_API_BASE_URL 环境变量");
  }

  const baseUrl = API_BASE_URL.endsWith("/")
    ? API_BASE_URL
    : `${API_BASE_URL}/`;
  return new URL(path.replace(/^\//, ""), baseUrl).toString();
}

async function fetchJson(path: string): Promise<unknown> {
  const response = await fetch(buildApiUrl(path), {
    cache: "no-store",
  });

  if (!response.ok) {
    throw new Error(`请求失败：${response.status} ${response.statusText}`);
  }

  return response.json();
}

function readString(source: Record<string, unknown>, key: string, label: string) {
  const value = source[key];

  if (typeof value !== "string") {
    throw new Error(`${label}.${key} 不是字符串`);
  }

  return value;
}

function readNumber(
  source: Record<string, unknown>,
  key: string,
  label: string,
) {
  const value = source[key];

  if (typeof value !== "number" || Number.isNaN(value)) {
    throw new Error(`${label}.${key} 不是数字`);
  }

  return value;
}

function readBoolean(
  source: Record<string, unknown>,
  key: string,
  label: string,
) {
  const value = source[key];

  if (typeof value !== "boolean") {
    throw new Error(`${label}.${key} 不是布尔值`);
  }

  return value;
}

function readRecord(
  source: Record<string, unknown>,
  key: string,
  label: string,
) {
  const value = source[key];

  if (!isRecord(value)) {
    throw new Error(`${label}.${key} 不是对象`);
  }

  return value;
}

function parseMetricSummary(
  value: unknown,
  label: string,
): MetricSummary {
  if (!isRecord(value)) {
    throw new Error(`${label} 不是对象`);
  }

  return {
    current: readNumber(value, "current", label),
    avg: readNumber(value, "avg", label),
    min: readNumber(value, "min", label),
    max: readNumber(value, "max", label),
    unit: readString(value, "unit", label),
  };
}

function parseThreshold(value: unknown, label: string): MetricThreshold {
  if (!isRecord(value)) {
    throw new Error(`${label} 不是对象`);
  }

  return {
    normalMin: readNumber(value, "normalMin", label),
    normalMax: readNumber(value, "normalMax", label),
    warningMin: readNumber(value, "warningMin", label),
    warningMax: readNumber(value, "warningMax", label),
  };
}

function parseTimeSeries(data: unknown): TimeSeriesPoint[] {
  if (!Array.isArray(data)) {
    throw new Error("timeSeries 不是数组");
  }

  return data.map((item, index) => {
    const label = `timeSeries[${index}]`;

    if (!isRecord(item)) {
      throw new Error(`${label} 不是对象`);
    }

    return {
      time: readString(item, "time", label),
      temperature: readNullableNumber(item, "temperature", label),
      humidity: readNullableNumber(item, "humidity", label),
      status: readString(item, "status", label),
      alertLevel: readString(item, "alertLevel", label),
    };
  });
}

function readNullableNumber(
  source: Record<string, unknown>,
  key: string,
  label: string,
) {
  const value = source[key];

  if (value === null) {
    return null;
  }

  if (typeof value !== "number" || Number.isNaN(value)) {
    throw new Error(`${label}.${key} 不是数字或 null`);
  }

  return value;
}

function parseAlerts(data: unknown): DashboardAlert[] {
  if (!Array.isArray(data)) {
    throw new Error("alerts 不是数组");
  }

  return data.map((item, index) => {
    const label = `alerts[${index}]`;

    if (!isRecord(item)) {
      throw new Error(`${label} 不是对象`);
    }

    return {
      id: readString(item, "id", label),
      time: readString(item, "time", label),
      level: readString(item, "level", label),
      type: readString(item, "type", label),
      title: readString(item, "title", label),
      value: readNumber(item, "value", label),
      threshold: readNumber(item, "threshold", label),
      resolved: readBoolean(item, "resolved", label),
    };
  });
}

function parseDashboardOverview(payload: unknown): DashboardOverview {
  if (!isRecord(payload)) {
    throw new Error("看板接口返回格式不是对象");
  }

  const data = payload.data;

  if (!isRecord(data)) {
    throw new Error("看板接口 data 不是对象");
  }

  const device = readRecord(data, "device", "data");
  const summary = readRecord(data, "summary", "data");
  const thresholds = readRecord(data, "thresholds", "data");

  return {
    device: {
      deviceId: readString(device, "deviceId", "device"),
      name: readString(device, "name", "device"),
      location: readString(device, "location", "device"),
      status: readString(device, "status", "device"),
      lastHeartbeat: readString(device, "lastHeartbeat", "device"),
      batteryPercent: readNumber(device, "batteryPercent", "device"),
    },
    summary: {
      temperature: parseMetricSummary(summary.temperature, "summary.temperature"),
      humidity: parseMetricSummary(summary.humidity, "summary.humidity"),
      onlineRate: readNumber(summary, "onlineRate", "summary"),
      alertCount: readNumber(summary, "alertCount", "summary"),
      sampleCount: readNumber(summary, "sampleCount", "summary"),
    },
    thresholds: {
      temperature: parseThreshold(thresholds.temperature, "thresholds.temperature"),
      humidity: parseThreshold(thresholds.humidity, "thresholds.humidity"),
    },
    timeSeries: parseTimeSeries(data.timeSeries),
    alerts: parseAlerts(data.alerts),
    serverTime:
      typeof payload.serverTime === "string" ? payload.serverTime : undefined,
    traceId: typeof payload.traceId === "string" ? payload.traceId : undefined,
  };
}

export async function fetchDashboardOverview({
  deviceId,
  range = "24h",
  interval = "1h",
}: DashboardOverviewParams) {
  const searchParams = new URLSearchParams({
    deviceId,
    range,
    interval,
  });
  const payload = await fetchJson(`api/dashboard/overview?${searchParams}`);
  return parseDashboardOverview(payload);
}
