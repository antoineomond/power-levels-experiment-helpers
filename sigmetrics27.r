source("power-states.r")

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

combined_df <- combined_df %>%
	mutate(
		clock_source = factor(clock_source, levels = c("HSI", "HSE", "PLL", "XOSC", "ROSC", "LPOSC", "PLL96", "PLL64", "RC_FAST", "XTAL")),
		vreg_output = factor(vreg_output, levels = c("1.10V", "1.00V", "0.90V", "0.85V", "0.80V", "Range1", "Range2", "Range3"))
	)

cp <- get_plot(combined_df,
	summary_cols = c("clock_source", "vreg_output", "clock_freq", "benchmark_name"),
	group_cols = c("clock_source", "vreg_output", "clock_freq", "benchmark_name"),
	facet_cols = c("clock_source", "vreg_output", "clock_freq"),
	benchmark_name = c("prime", "prime_multicores", "mat_mul", "mat_mul_float", "mat_mul_double"),
	color_col = "benchmark_name",
	labeller = selective_labeller,
	max_iterations = 20,
	discard_samples = 10,
	x_label = "Timestamp in seconds",
	y_label = "Power usage in mW",
	value_format = "%.2f mW"
)
n_facets <- nrow(distinct(combined_df, clock_source, vreg_output, clock_freq))
pdf(paste(folder, "combined-test.pdf", sep=""), width = 4, height = 2.5*n_facets)
print(cp)
dev.off()


