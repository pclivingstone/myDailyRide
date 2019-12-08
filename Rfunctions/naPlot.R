#' Show a dot chart of the proportion of NAs per column
#'
#' Description paragraph.
#'
#' Details paragraph.
#'
#' More details paragraphs.
#'
#' @param dat The data.frame or data.table to plot
#' @param cols The number of columns to include in the plot
#' @param show Whether to draw the plot, or just return it invisibly
#' @return NULL
#' @seealso \code{\link{dotchart}}
#' @examples naPlot(nycflights13::flights, 15)
#' naPlot(airquality)

naPlot <- function(
  dat
  , cols = 10
  , show = TRUE
  , prnt = TRUE
  ) {
  # require(ggplot2)
  # dotchart(tail(sort(apply(is.na(dat),2,mean)),cols))
  # grid()
    x <- data.frame(
      column = names(dat)
      ,NAs = apply(is.na(dat), 2, mean)
      ,class = sapply(dat, function(x) class(x)[1])
      )
    p <- ggplot2::qplot(
        x = NAs
        , y = stats::reorder(column, NAs)
        , data = utils::head(x, cols)
        , geom = 'point'
        , size = NAs
        , col = class
        , shape = class
        , ylab = 'Columns'
    )
    if (show)
        print(p)
    if (prnt) {
      x <- x[order(-x$NAs),]
      print(head(x, cols))
    }
    invisible(p)
}

# naPlot(nycflights13::flights, 15)
