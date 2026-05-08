"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import * as echarts from "echarts";
import type { ECharts, EChartsOption } from "echarts";
import {
  fetchDashboardOverview,
  type DashboardAlert,
  type DashboardOverview,
  type MetricSummary,
} from "../lib/api";

const DEVICE_ID = "1001";
const RANGE = "24h";
const INTERVAL = "1h";

type LoadState = "loading" | "success" | "error";

type DashboardData = DashboardOverview & {
  refreshedAt: Date;
};

async function fetchDashboardData(): Promise<DashboardData> {
  return {
    ...(await fetchDashboardOverview({
      deviceId: DEVICE_ID,
      range: RANGE,
      interval: INTERVAL,
    })),
    refreshedAt: new Date(),
  };
}

function formatMetric(metric: MetricSummary) {
  return `${metric.current.toFixed(1)}${metric.unit}`;
}

function formatNumber(value: number, suffix = "") {
  return `${value.toFixed(1)}${suffix}`;
}

function formatDateTime(value: string | Date) {
  const date = value instanceof Date ? value : new Date(value);

  if (Number.isNaN(date.getTime())) {
    return String(value);
  }

  return new Intl.DateTimeFormat("zh-CN", {
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
}

function formatTimeLabel(value: string) {
  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat("zh-CN", {
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
}

function buildOption(data: DashboardData): EChartsOption {
  const points = [...data.timeSeries].sort(
    (left, right) => new Date(left.time).getTime() - new Date(right.time).getTime(),
  );
  const times = points.map((point) => point.time);
  const temperatureThreshold = data.thresholds.temperature;
  const humidityThreshold = data.thresholds.humidity;

  return {
    color: ["#2563eb", "#16a34a"],
    tooltip: {
      trigger: "axis",
      axisPointer: {
        type: "cross",
      },
      valueFormatter: (value) =>
        typeof value === "number" ? value.toFixed(1) : String(value),
    },
    legend: {
      top: 0,
      data: ["温度", "湿度"],
    },
    grid: {
      left: 52,
      right: 56,
      top: 58,
      bottom: 42,
    },
    xAxis: {
      type: "category",
      boundaryGap: false,
      data: times,
      axisLabel: {
        formatter: (value: string) => formatTimeLabel(value),
      },
    },
    yAxis: [
      {
        type: "value",
        name: "温度 °C",
        min: Math.floor(temperatureThreshold.warningMin - 2),
        max: Math.ceil(temperatureThreshold.warningMax + 2),
      },
      {
        type: "value",
        name: "湿度 %",
        min: Math.max(0, Math.floor(humidityThreshold.warningMin - 5)),
        max: Math.min(100, Math.ceil(humidityThreshold.warningMax + 5)),
      },
    ],
    series: [
      {
        name: "温度",
        type: "line",
        yAxisIndex: 0,
        smooth: true,
        connectNulls: false,
        data: points.map((point) => point.temperature),
        areaStyle: {
          opacity: 0.1,
        },
        markLine: {
          symbol: "none",
          lineStyle: {
            type: "dashed",
            color: "#2563eb",
            opacity: 0.55,
          },
          data: [
            { yAxis: temperatureThreshold.normalMin, name: "温度下限" },
            { yAxis: temperatureThreshold.normalMax, name: "温度上限" },
          ],
        },
      },
      {
        name: "湿度",
        type: "line",
        yAxisIndex: 1,
        smooth: true,
        connectNulls: false,
        data: points.map((point) => point.humidity),
        markLine: {
          symbol: "none",
          lineStyle: {
            type: "dashed",
            color: "#16a34a",
            opacity: 0.55,
          },
          data: [
            { yAxis: humidityThreshold.normalMin, name: "湿度下限" },
            { yAxis: humidityThreshold.normalMax, name: "湿度上限" },
          ],
        },
      },
    ],
  };
}

function StatusBadge({ status }: { status: string }) {
  const isOnline = status === "online";

  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ${
        isOnline
          ? "bg-green-50 text-green-700 ring-1 ring-green-200"
          : "bg-red-50 text-red-700 ring-1 ring-red-200"
      }`}
    >
      {status}
    </span>
  );
}

function MetricCard({
  title,
  metric,
  detail,
}: {
  title: string;
  metric: MetricSummary;
  detail: string;
}) {
  return (
    <div className="rounded-lg border border-zinc-200 bg-white p-5 shadow-sm">
      <div className="text-sm text-zinc-500">{title}</div>
      <div className="mt-2 text-3xl font-semibold text-zinc-950">
        {formatMetric(metric)}
      </div>
      <div className="mt-3 text-sm leading-6 text-zinc-600">{detail}</div>
    </div>
  );
}

function AlertRow({ alert }: { alert: DashboardAlert }) {
  const isCritical = alert.level === "critical";
  const isWarning = alert.level === "warning";

  return (
    <li className="flex items-center justify-between gap-4 border-t border-zinc-100 py-3 first:border-t-0">
      <div className="min-w-0">
        <div className="flex flex-wrap items-center gap-2">
          <span
            className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
              isCritical
                ? "bg-red-50 text-red-700"
                : isWarning
                  ? "bg-amber-50 text-amber-700"
                  : "bg-zinc-100 text-zinc-700"
            }`}
          >
            {alert.level}
          </span>
          <span className="font-medium text-zinc-950">{alert.title}</span>
          <span className="text-sm text-zinc-500">
            {alert.resolved ? "已恢复" : "处理中"}
          </span>
        </div>
        <div className="mt-1 text-sm text-zinc-500">
          {formatDateTime(alert.time)} · {alert.type}
        </div>
      </div>
      <div className="shrink-0 text-right text-sm text-zinc-700">
        <div>{formatNumber(alert.value)}</div>
        <div className="text-zinc-500">阈值 {formatNumber(alert.threshold)}</div>
      </div>
    </li>
  );
}

export default function EchartsBasicChart() {
  const chartRef = useRef<HTMLDivElement>(null);
  const chartInstanceRef = useRef<ECharts | null>(null);
  const [loadState, setLoadState] = useState<LoadState>("loading");
  const [dashboardData, setDashboardData] = useState<DashboardData | null>(null);
  const [errorMessage, setErrorMessage] = useState("");

  const loadDashboardData = useCallback(async () => {
    setLoadState("loading");
    setErrorMessage("");

    try {
      setDashboardData(await fetchDashboardData());
      setLoadState("success");
    } catch (error) {
      setDashboardData(null);
      chartInstanceRef.current?.clear();
      setErrorMessage(error instanceof Error ? error.message : "数据加载失败");
      setLoadState("error");
    }
  }, []);

  useEffect(() => {
    if (!chartRef.current) {
      return;
    }

    const chart = echarts.init(chartRef.current);
    chartInstanceRef.current = chart;

    const resizeChart = () => chart.resize();
    window.addEventListener("resize", resizeChart);

    return () => {
      window.removeEventListener("resize", resizeChart);
      chart.dispose();
      chartInstanceRef.current = null;
    };
  }, []);

  useEffect(() => {
    let isActive = true;

    void fetchDashboardData()
      .then((data) => {
        if (!isActive) {
          return;
        }

        setDashboardData(data);
        setLoadState("success");
      })
      .catch((error) => {
        if (!isActive) {
          return;
        }

        setDashboardData(null);
        chartInstanceRef.current?.clear();
        setErrorMessage(error instanceof Error ? error.message : "数据加载失败");
        setLoadState("error");
      });

    return () => {
      isActive = false;
    };
  }, []);

  useEffect(() => {
    if (!dashboardData || !chartInstanceRef.current) {
      return;
    }

    chartInstanceRef.current.setOption(buildOption(dashboardData), true);
  }, [dashboardData]);

  const isLoading = loadState === "loading";

  return (
    <div className="flex flex-col gap-5">
      <div className="grid gap-4 md:grid-cols-4">
        <div className="rounded-lg border border-zinc-200 bg-white p-5 shadow-sm md:col-span-2">
          <div className="flex items-start justify-between gap-4">
            <div>
              <div className="text-sm text-zinc-500">当前设备</div>
              <div className="mt-2 text-2xl font-semibold text-zinc-950">
                {dashboardData?.device.name ?? "设备加载中"}
              </div>
              <div className="mt-2 text-sm text-zinc-600">
                {dashboardData?.device.location ?? "等待接口返回设备位置"}
              </div>
            </div>
            <StatusBadge status={dashboardData?.device.status ?? "-"} />
          </div>
          <div className="mt-5 grid gap-3 text-sm text-zinc-600 sm:grid-cols-3">
            <div>
              <span className="block text-zinc-500">设备 ID</span>
              <span className="font-medium text-zinc-950">
                {dashboardData?.device.deviceId ?? DEVICE_ID}
              </span>
            </div>
            <div>
              <span className="block text-zinc-500">电量</span>
              <span className="font-medium text-zinc-950">
                {dashboardData
                  ? `${dashboardData.device.batteryPercent}%`
                  : "-"}
              </span>
            </div>
            <div>
              <span className="block text-zinc-500">最后心跳</span>
              <span className="font-medium text-zinc-950">
                {dashboardData
                  ? formatDateTime(dashboardData.device.lastHeartbeat)
                  : "-"}
              </span>
            </div>
          </div>
        </div>

        <MetricCard
          title="当前温度"
          metric={
            dashboardData?.summary.temperature ?? {
              current: 0,
              avg: 0,
              min: 0,
              max: 0,
              unit: "°C",
            }
          }
          detail={
            dashboardData
              ? `均值 ${formatNumber(dashboardData.summary.temperature.avg)}，范围 ${formatNumber(dashboardData.summary.temperature.min)}-${formatNumber(dashboardData.summary.temperature.max)}`
              : "等待接口返回"
          }
        />

        <MetricCard
          title="当前湿度"
          metric={
            dashboardData?.summary.humidity ?? {
              current: 0,
              avg: 0,
              min: 0,
              max: 0,
              unit: "%",
            }
          }
          detail={
            dashboardData
              ? `均值 ${formatNumber(dashboardData.summary.humidity.avg)}，范围 ${formatNumber(dashboardData.summary.humidity.min)}-${formatNumber(dashboardData.summary.humidity.max)}`
              : "等待接口返回"
          }
        />
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <div className="rounded-lg border border-zinc-200 bg-white p-4 shadow-sm">
          <div className="text-sm text-zinc-500">在线率</div>
          <div className="mt-2 text-2xl font-semibold text-zinc-950">
            {dashboardData
              ? formatNumber(dashboardData.summary.onlineRate, "%")
              : "-"}
          </div>
        </div>
        <div className="rounded-lg border border-zinc-200 bg-white p-4 shadow-sm">
          <div className="text-sm text-zinc-500">告警数</div>
          <div className="mt-2 text-2xl font-semibold text-zinc-950">
            {dashboardData?.summary.alertCount ?? "-"}
          </div>
        </div>
        <div className="rounded-lg border border-zinc-200 bg-white p-4 shadow-sm">
          <div className="text-sm text-zinc-500">采样点</div>
          <div className="mt-2 text-2xl font-semibold text-zinc-950">
            {dashboardData?.summary.sampleCount ?? "-"}
          </div>
        </div>
      </div>

      <div className="rounded-lg border border-zinc-200 bg-white p-4 shadow-sm">
        <div
          ref={chartRef}
          className="h-[420px] w-full"
          aria-label="温湿度趋势与阈值 ECharts 图表"
        />
      </div>

      <div className="rounded-lg border border-zinc-200 bg-white p-5 shadow-sm">
        <div className="flex items-center justify-between gap-4">
          <div>
            <h2 className="text-lg font-semibold text-zinc-950">最近告警</h2>
            <p className="mt-1 text-sm text-zinc-500">
              {dashboardData
                ? `服务时间 ${dashboardData.serverTime ? formatDateTime(dashboardData.serverTime) : "-"}`
                : "等待接口返回"}
            </p>
          </div>
          <button
            type="button"
            onClick={loadDashboardData}
            disabled={isLoading}
            className="rounded-md bg-zinc-950 px-4 py-2 text-sm font-medium text-white transition hover:bg-zinc-800 disabled:cursor-not-allowed disabled:bg-zinc-400"
          >
            {isLoading ? "加载中" : "重新加载"}
          </button>
        </div>

        <div className="mt-4 min-h-10 text-sm text-zinc-600">
          {isLoading && "正在请求 /api/dashboard/overview 并渲染看板..."}
          {loadState === "error" && (
            <span className="text-red-700">{errorMessage}</span>
          )}
          {loadState === "success" &&
            dashboardData &&
            `已加载 ${dashboardData.timeSeries.length} 个趋势点、${dashboardData.alerts.length} 条告警`}
        </div>

        {dashboardData && dashboardData.alerts.length > 0 ? (
          <ul>
            {dashboardData.alerts.map((alert, index) => (
              <AlertRow
                key={`${alert.id}-${alert.time}-${index}`}
                alert={alert}
              />
            ))}
          </ul>
        ) : (
          <div className="rounded-lg bg-zinc-50 p-4 text-sm text-zinc-500">
            暂无告警数据
          </div>
        )}
      </div>
    </div>
  );
}
