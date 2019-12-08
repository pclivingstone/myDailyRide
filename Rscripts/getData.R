# get data ----------------------------------------------------------------

myData <- fread(config$fileName)

p <- naPlot(myData, show = config$doPlots)
ggsave('1-naPlot.png', p, dpi = config$dpi)
# see plot - there are only 2 columns with any mising data, duration & end station, <1%


# date and time -----------------------------------------------------------

# create datetime fields for stand & end
myData[, startDT := make_datetime(start_year + 2000, start_month, start_date, hour = start_hour, min = start_minute)]
myData[, endDT := make_datetime(end_year + 2000, end_month, end_date, hour = end_hour, min = end_minute)]
# calc the range of date dates
diff(range(myData$startDT))  # ~50 days, doco says 'last month'.  must have been a very long month
min(myData$startDT)
max(myData$startDT)

# delete the fields we no longer need
for (prefix in c('start','end')) {
  myCols <- paste0(
    prefix
    , '_'
    , c(
      'date'
      ,'month'
      ,'year'
      ,'hour'
      ,'minute'
    )
  )
  myData[, (myCols) := NULL ]
}

myData[, diff := endDT - startDT]

if (F) {
  qplot(journey_duration, as.numeric(diff), data = na.omit(sample_n(myData, 100)))
  # just to check, journey duration is time difference in seconds, end-time minus start-time
  hist(myData$journey_duration - as.numeric(myData$diff))
  summary(myData$journey_duration - as.numeric(myData$diff))
  # with a small number of records out by +/- < 1 minute
}
myData[, mins := journey_duration/60]
myData[, dow := lubridate::wday(startDT, label = T)]  # day of week
myData[, tod := hour(startDT)]                        # time of day

counts <- xtabs(~ dow  + tod , data = myData, subset = T)
if (config$doPlots) {
  mosaicplot(counts, shade = T, main = 'Occurence of Rides')
  savePng('2-mosaic.png')
}
# see plot - this is a mosiac plot, shows those combinations of day-of-week & hour-of-day
# that are over represented as blue, and under represented as red.
# let's call the dark blue combinations "peak"
# this shows weekday peak hour am (6:9) & pm (17:19) - commute
# weekend day peak (10:16)                           - recreation?

# aggregate date by dow & tod
aggData <- myData[, .(counts = .N, aveDurn = mean(mins, na.rm = T)), by = .(dow, tod)]

p <- qplot(
  tod, counts, data = aggData, colour = dow, size = counts
  ) + geom_line(
  aes(size = 1)
  ) + scale_color_brewer(type = 'qual', palette = 2)
if (config$doPlots) 
  print(p)
ggsave('3-profile.png', p, dpi = config$dpi)
# see plot - size of circles represent count of trips
# same info plot 2, but a different view
# am & pm peaks clealy visible for week days
# Wed is lower through the middle of the day than other weekdays
# Sat & Sun higher through the middle of the day than weekdays


# feature engineering -----------------------------------------------------

# cut time of day into 5 distinct periods
myData[, peak := cut(
  tod
  , c(0,5,9,16,19,23)
  , c('early','amPeak','day','pmPeak','late')
  , ordered_result = T
  , include.lowest = T
)]
table(myData$tod,myData$peak, useNA = 'always') # check

# cut day of week into weekday and weekend
myData[, week := 'wkDay']
myData[dow %in% c('Sat','Sun') , week := 'wkEnd'] 

# combine the 2 categories into time-of-week, with 5 x 2 = 10 levels
myData[, tow := paste0(week,'-',peak)]

# cut the duration in mins into quintiles, n = 5 chosen arbitrarily
# could use deciles or percentiles, starting with 5 to keep it simple
myData[, length := cut_number(round(mins), 5, labels = c('vShort','short','med','long','vLong'))]


# various plots looking for interesting patterns between length of journey and when it was taken
if (config$doPlots) {
  
  counts <- xtabs( ~ week + peak, data = myData, subset = T)
  mosaicplot(counts, shade = T, main = 'week by peak')
  savePng('4-weekXpeak.png')
  # see plot - shows weekday am & pm peaks, weekend is the reverse
  
  
  counts <- xtabs( ~ peak  + length, data = myData, subset = T)
  mosaicplot(counts, shade = T, main = 'peak by length')
  savePng('5-peakXlength.png')
  # see plot - am peak journeys are shorter (blue at top) than pm peak journeys (blue not at top)
  # day journeys are the longest (blue at bottom) - recreation?
  # late trips are the shortest (blue at top) - traffic?
  # late different to early, this is a bit unexpected, thought they might be similar
  
  counts <- xtabs( ~ week  + length, data = myData, subset = T)
  mosaicplot(counts, shade = T, main = 'week by length')
  savePng('6-weekXlength.png')
  # see plot - weekday trips are short, weekend trips are longer
  
  counts <- xtabs( ~ tow + length, data = myData, subset = T)
  mosaicplot(counts, shade = T, main = 'tow by length', las = 2)
  savePng('7-towXlength.png')
  # see plot - a bit hard to unpack
  # time of day patterns change between weekday and weekend, not consistent

}


