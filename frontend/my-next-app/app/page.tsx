import EchartsBasicChart from "./components/EchartsBasicChart";

export default function Home() {
  return (
    <main className="min-h-screen bg-zinc-50 px-6 py-10 text-zinc-950">
      <section className="mx-auto flex w-full max-w-5xl flex-col gap-6">
        <div className="flex flex-col gap-2">
          <p className="text-sm font-medium text-blue-700">
            ECharts + 接口数据流
          </p>
          <h1 className="text-3xl font-semibold tracking-normal">
            温湿度监控看板
          </h1>
          <p className="max-w-2xl text-base leading-7 text-zinc-600">
            页面请求聚合看板接口，接收 JSON 后渲染关键指标、设备状态、阈值趋势图和最近告警。
          </p>
        </div>

        <EchartsBasicChart />
      </section>
    </main>
  );
}
