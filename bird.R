suppressPackageStartupMessages(library(dplyr))

plot <- function(trajectory, name, bg, fg) {
  png(name, units="px", width=1600, height=1600, res=200)
  
  ggplot2::ggplot(trajectory, ggplot2::aes(x, y)) +
      ggplot2::geom_point(color=fg, shape=46, alpha=.01) +
        cowplot::theme_nothing() + 
        ggplot2::scale_x_continuous(expand=c(0,0)) +
        ggplot2::scale_y_continuous(expand=c(0,0)) +
        ggplot2::labs(x=NULL, y=NULL) +
        ggplot2::theme(plot.background=ggplot2::element_rect(fill=bg, color=bg))
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
basename <- args[length(args)-2]
bg <- args[length(args)-1]
fg <- args[length(args)]

forecast <- owmr::get_forecast(basename) %>% owmr::owmr_as_tibble()

a = ((forecast $wind_speed %>% median) * -1) + 2.379
b = ((forecast $wind_speed %>% max) - (forecast $wind_speed %>% min)) - 1.1579
c = forecast $wind_speed %>% min
d = ((forecast $wind_speed %>% median) * 1.2938) - 2.2389028

name <- paste(paste("out/", basename, sep=""), forecast $dt_txt[1])
path <- gen_path(10000000, 0, 0, a, b, c, d)
plot(path, name, bg, fg)
