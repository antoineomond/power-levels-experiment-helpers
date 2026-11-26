source("power-states.r")

cp <- get_plot(combined_df,
	summary_cols = c("clock_source", "vreg_output", "clock_freq", "benchmark_name"),
	group_cols = c("clock_source", "vreg_output", "clock_freq", "benchmark_name"),
	facet_cols = c("clock_source", "vreg_output", "clock_freq"),
	color_col = "benchmark_name",
	labeller = selective_labeller,
	clock_source = factor(clock_source, levels = config$plot$levels$clock_source),
	vreg_output = factor(vreg_output, levels = config$plot$levels$vreg_output)
)
n_facets <- nrow(distinct(combined_df, clock_source, vreg_output, clock_freq))
pdf(paste(folder, "combined.pdf", sep=""), width = 4, height = 2.5*n_facets)
print(cp)
dev.off()


