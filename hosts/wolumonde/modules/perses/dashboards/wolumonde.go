package main

import (
	"flag"
	"time"

	"github.com/perses/perses/go-sdk"
	"github.com/perses/perses/go-sdk/common"
	dash "github.com/perses/perses/go-sdk/dashboard"
	"github.com/perses/perses/go-sdk/panel"
	panels "github.com/perses/perses/go-sdk/panel-group"
	"github.com/perses/perses/go-sdk/panel/bar"
	"github.com/perses/perses/go-sdk/prometheus/query"

	timeSeries "github.com/perses/perses/go-sdk/panel/time-series"
	// promDs "github.com/perses/perses/go-sdk/prometheus/datasource"
)

func main() {
	flag.Parse()
	exec := sdk.NewExec()
	var loadPanel = panels.AddPanel("load over 5 min",
		timeSeries.Chart(
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Max: 2.0,
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				"node_load5",
				query.SeriesNameFormat("load"),
			),
		),
	)
	var cpuPanel = panels.AddPanel("cpu usage",
		timeSeries.Chart(
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "percent",
					},
					Max: 100.0,
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				`sum by (cpu) (rate(node_cpu_seconds_total{mode=~"user|system"}[1m])) * 100`,
				query.SeriesNameFormat("cpu {{cpu}}"),
			),
		),
	)
	var memoryPanel = panels.AddPanel("memory usage",
		timeSeries.Chart(
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "bytes",
					},
					Max: 4000000000,
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				"node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes",
				query.SeriesNameFormat("current memory usage"),
			),
		),
	)
	var resPanels = dash.AddPanelGroup("resource usage",
		panels.PanelsPerLine(4),
		loadPanel, cpuPanel, memoryPanel,
	)

	var nginxPanel = panels.AddPanel("nginx requests / min",
		timeSeries.Chart(
			timeSeries.WithQuerySettings(
				[]timeSeries.QuerySettingsItem{
					{
						QueryIndex: 0,
						ColorMode:  timeSeries.FixedMode,
						ColorValue: "#FF0000",
					},
				},
			),
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "decimal",
					},
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				"nginx_5xx_count",
				query.SeriesNameFormat("5xx errors"),
			),
		),
		panel.AddQuery(
			query.PromQL(
				"nginx_request_count",
				query.SeriesNameFormat("requests"),
			),
		),
	)

	var nginxLatencyPanel = panels.AddPanel("nginx latency / min",
		timeSeries.Chart(
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "seconds",
					},
					Max: 0.5,
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				"nginx_request_latency",
				query.SeriesNameFormat("{{stats_result}}"),
			),
		),
	)

	var nginxPanels = dash.AddPanelGroup("nginx metrics",
		panels.PanelsPerLine(3),
		nginxPanel,
		nginxLatencyPanel,
	)

	var pdsPanel = panels.AddPanel("pds requests / min",
		timeSeries.Chart(
			timeSeries.WithQuerySettings(
				[]timeSeries.QuerySettingsItem{
					{
						QueryIndex: 0,
						ColorMode:  timeSeries.FixedMode,
						ColorValue: "#FF0000",
					},
				},
			),
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "decimal",
					},
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				"pds_5xx_count",
				query.SeriesNameFormat("5xx errors"),
			),
		),
		panel.AddQuery(
			query.PromQL(
				"pds_request_count",
				query.SeriesNameFormat("requests"),
			),
		),
	)

	var pdsLatencyPanel = panels.AddPanel("pds latency / min",
		timeSeries.Chart(
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "milliseconds",
					},
					Max: 500,
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				"pds_response_latency",
				query.SeriesNameFormat("{{stats_result}}"),
			),
		),
	)

	var pdsPanels = dash.AddPanelGroup("pds metrics",
		panels.PanelsPerLine(3),
		pdsPanel,
		pdsLatencyPanel,
	)

	var anubisForgejoPanel = panels.AddPanel("anubis policy actions",
		bar.Chart(),
		panel.AddQuery(
			query.PromQL(
				"anubis_policy_results",
				query.SeriesNameFormat("{{action}}: {{rule}}"),
			),
		),
	)

	var forgejoPanels = dash.AddPanelGroup("forgejo",
		panels.PanelsPerLine(3),
		anubisForgejoPanel,
	)

	builder, buildErr := dash.New("wolumonde",
		dash.ProjectName("private-infra"),
		dash.Duration(30*time.Minute),
		dash.RefreshInterval(time.Minute),
		resPanels, nginxPanels, pdsPanels, forgejoPanels,
	)
	exec.BuildDashboard(builder, buildErr)
}
