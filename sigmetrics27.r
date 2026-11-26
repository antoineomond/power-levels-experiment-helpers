source("experiment-helpers/power-states.r")

selective_labeller <- function(value) {
	labels <- stringr::str_split_fixed(value, "\\|", 3)
	freq_mhz <- as.numeric(labels[, 3])
	freq_string <- ifelse(
		freq_mhz/1000000 < 1,
		paste0(round(freq_mhz/1000, 2), "kHz"),
		paste0(round(freq_mhz/1000000, 2), "MHz")
	)
	paste0("Clk source: **", labels[, 1], "**, Freq: **", freq_string, "**, VREG: **", labels[, 2], "**")
}

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
pdf(paste(folder, "combined-test.pdf", sep=""), width = 4, height = 2.5*n_facets)
print(cp)
dev.off()


