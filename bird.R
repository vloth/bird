suppressPackageStartupMessages(library(dplyr))

plot <- function(trajectory, name) {
  canvas = ggplot2::theme(legend.position  = "none",
    panel.background = ggplot2::element_rect(fill="black"),
    axis.ticks = ggplot2::element_blank(),
    panel.grid = ggplot2::element_blank(),
    axis.title = ggplot2::element_blank(),
    axis.text = ggplot2::element_blank())

  str_path <- gsub(" ", "_", paste("out/", iconv(name, from = 'UTF-8', to = 'ASCII//TRANSLIT'), ".png", sep=""))
  str_path <- gsub("'", "_", gsub(":", "_", gsub("~", "", str_path)))
  png(str_path, units="px", width=1600, height=1600, res=200)
  ggplot2::ggplot(trajectory, ggplot2::aes(x, y)) +
      ggplot2::geom_point(color="white", shape=46, alpha=.01) +
   canvas
}

Rcpp::cppFunction('
  DataFrame gen_path(int n, double x0, double y0, 
    double a, double b, double c, double d) {
    NumericVector x(n); NumericVector y(n);
    x[0]=x0; y[0]=y0;
    for(int i = 1; i < n; ++i) {
      x[i] = sin(a*y[i-1])+c*cos(a*x[i-1]);
      y[i] = sin(b*x[i-1])+d*cos(b*y[i-1]);
    }
    return DataFrame::create(_["x"]= x, _["y"]= y);
  }
')

args <- commandArgs()
name <- tail(args, n=1)

forecast <- owmr::get_forecast(name) %>% owmr::owmr_as_tibble()

a = ((forecast $wind_speed %>% median) * -1) + 2.379
b = ((forecast $wind_speed %>% max) - (forecast $wind_speed %>% min)) - 2.379
c = forecast $wind_speed %>% min
d = ((forecast $wind_speed %>% median) * 1.2938) - 2.2389028

p <- gen_path(10000000, 0, 0, a, b, c, d)
plot(p, paste(name, forecast $dt_txt[1]))
