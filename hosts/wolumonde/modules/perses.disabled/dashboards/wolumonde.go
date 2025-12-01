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
	"github.com/perses/perses/go-sdk/panel/gauge"
	"github.com/perses/perses/go-sdk/panel/stat"
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

	var diskPanel = panels.AddPanel("disk usage /",
		timeSeries.Chart(
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "bytes",
					},
					Max: 38000000000,
				},
			),
		),
		panel.AddQuery(
			query.PromQL(
				`node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_free_bytes{mountpoint="/"}`,
				query.SeriesNameFormat("disk usage"),
			),
		),
	)

	// Gauge versions (percent unit)
	var loadGaugePanel = panels.AddPanel("load over 5 min",
		gauge.Chart(
			gauge.Format(common.Format{Unit: "percent"}),
			gauge.Max(100),
			gauge.Calculation(common.MeanCalculation),
		),
		panel.AddQuery(
			query.PromQL(
				"node_load5 * 100 / count(count(node_cpu_seconds_total) by (cpu))",
				query.SeriesNameFormat("load %"),
			),
		),
	)
	var cpuGaugePanel = panels.AddPanel("cpu usage",
		gauge.Chart(
			gauge.Format(common.Format{Unit: "percent"}),
			gauge.Max(100),
			gauge.Calculation(common.MeanCalculation),
		),
		panel.AddQuery(
			query.PromQL(
				`sum by (cpu) (rate(node_cpu_seconds_total{mode=~"user|system"}[1m])) * 100`,
				query.SeriesNameFormat("cpu {{cpu}}"),
			),
		),
	)
	var memoryGaugePanel = panels.AddPanel("memory usage",
		gauge.Chart(
			gauge.Format(common.Format{Unit: "percent"}),
			gauge.Max(100),
			gauge.Calculation(common.MeanCalculation),
		),
		panel.AddQuery(
			query.PromQL(
				"(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) * 100 / node_memory_MemTotal_bytes",
				query.SeriesNameFormat("memory usage %"),
			),
		),
	)
	var diskGaugePanel = panels.AddPanel("disk usage /",
		gauge.Chart(
			gauge.Format(common.Format{Unit: "percent"}),
			gauge.Max(100),
		),
		panel.AddQuery(
			query.PromQL(
				`(node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_free_bytes{mountpoint="/"}) * 100 / node_filesystem_size_bytes{mountpoint="/"}`,
				query.SeriesNameFormat("disk usage %"),
			),
		),
	)

	var resPanels = dash.AddPanelGroup("resource usage",
		panels.PanelsPerLine(4),
		loadGaugePanel, cpuGaugePanel, memoryGaugePanel, diskGaugePanel,
		loadPanel, cpuPanel, memoryPanel, diskPanel,
	)

	var nginxPanel = panels.AddPanel("nginx requests / min",
		timeSeries.Chart(
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "decimal",
					},
				},
			),
			timeSeries.WithVisual(timeSeries.Visual{
				Display: timeSeries.BarDisplay,
				Palette: timeSeries.Palette{
					Mode: timeSeries.CategoricalMode,
				},
				Stack: timeSeries.AllStack,
			}),
			timeSeries.WithLegend(timeSeries.Legend{
				Position: timeSeries.BottomPosition,
				Size:     timeSeries.SmallSize,
			}),
		),
		panel.AddQuery(
			query.PromQL(
				"nginx_request_count",
				query.SeriesNameFormat("{{res.statusCode}}"),
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
			timeSeries.WithYAxis(
				timeSeries.YAxis{
					Format: &common.Format{
						Unit: "decimal",
					},
				},
			),
			timeSeries.WithVisual(timeSeries.Visual{
				Display: timeSeries.BarDisplay,
				Palette: timeSeries.Palette{
					Mode: timeSeries.CategoricalMode,
				},
				Stack: timeSeries.AllStack,
			}),
			timeSeries.WithLegend(timeSeries.Legend{
				Position: timeSeries.BottomPosition,
				Size:     timeSeries.SmallSize,
			}),
		),
		panel.AddQuery(
			query.PromQL(
				"pds_request_count",
				query.SeriesNameFormat("{{res.statusCode}}"),
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

	var gazesys_visit_panel = panels.AddPanel("gazesys visits",
		bar.Chart(),
		panel.AddQuery(
			query.PromQL(
				"gazesys_visit_real_total + gazesys_visit_fake_total",
				query.SeriesNameFormat("total visits"),
			),
		),
		panel.AddQuery(
			query.PromQL(
				"gazesys_visit_fake_total",
				query.SeriesNameFormat("(ai) bot visits"),
			),
		),
		panel.AddQuery(
			query.PromQL(
				"gazesys_visit_real_total",
				query.SeriesNameFormat("real visits"),
			),
		),
	)

	var gazesys_pet_panel = panels.AddPanel("gazesys pet",
		stat.Chart(
			stat.Format(common.Format{
				Unit:          "decimal",
				ShortValues:   true,
				DecimalPlaces: 0,
			}),
		),
		panel.AddQuery(
			query.PromQL(
				"gazesys_pet_bounce_total",
				query.SeriesNameFormat("bounce count"),
			),
		),
		panel.AddQuery(
			query.PromQL(
				"gazesys_pet_distance_total",
				query.SeriesNameFormat("distance travelled"),
			),
		),
	)

	var gazesys_panels = dash.AddPanelGroup("gazesys",
		panels.PanelsPerLine(3),
		gazesys_visit_panel, gazesys_pet_panel,
	)

	builder, buildErr := dash.New("wolumonde",
		dash.ProjectName("private-infra"),
		dash.Duration(30*time.Minute),
		dash.RefreshInterval(time.Minute),
		resPanels, nginxPanels, pdsPanels, gazesys_panels, forgejoPanels,
	)
	exec.BuildDashboard(builder, buildErr)
}
