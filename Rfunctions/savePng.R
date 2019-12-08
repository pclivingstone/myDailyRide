savePng <- function(filename = 'myPlot.png') {
  dev.copy(png,filename)
  dev.off()
}
