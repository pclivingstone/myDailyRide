# byStation.R
# written by Paul
# to consider the different start stations
# last updated Dec 2019

# by start station --------------------------------------------------------------

head(myData)

# aggregate by start station id and time of week
aggData <- myData[
  !is.na(mins)
  , .(
    tripsPerDay = .N/50
    , aveMins = mean(mins)
    , minMins = min(mins)
  )
  , by = .(start_station_id, tow)
  ]
setorder(aggData, start_station_id)  # sort by station id
head(aggData)
str(aggData)
 
print(aggData[start_station_id <= 5])  # first 5 stations, just to inspect the results 

byStation <- dcast(
   aggData
   , start_station_id ~ tow
   , value.var = 'tripsPerDay'
   , fill = 0
)
print(byStation)

# principal components analysis -------------------------------------------

# convert the number of trips per day (by station) into a matrix and move station id to row label
x <- as.matrix(byStation[, -1])  
rownames(x) <- byStation$start_station_id
min(x)
max(x)
table(is.na(x))

pc <- princomp(x)
head(pc$scores)

# declare a little plotting function on the fly for the loadings of the principal components
loadPlot <- function(pc, i = 1, filename = NA) {
  dotchart(sort(pc$loadings[, i]))
  title(paste0('Loadings PC',i))
  grid()
  abline(
    v = 0
    , col = 'red'
    )
  if (!is.na(filename))
    savePng(filename)
}


if (config$doPlots) {
  screeplot(pc)       
  savePng('8-scree.png')
  # see plot - only 3 dimensions
  biplot(pc)     # pc1 vs pc2
  biplot(pc, choices = c(1,3))
  biplot(pc, choices = c(2,3))
  loadPlot(pc, 1, '9-loadings1.png')
  # all positive - pc1 is a proxy for size of station, overall number of trips that start from there
  loadPlot(pc, 2, '10-loadings2.png')
  # week day am peak vs week day pm peak - pc2 is a proxy for time of day
  loadPlot(pc, 3, '11-loadings3.png')
  # week day pm peak vs week end day peak - pc2 is a proxy for day of week
}
  
# so let's define some new variables, like pc1, pc2 and pc3, but with more meaningful values  

# trips per day
byStation[, tripsPerDay := rowSums(byStation[, -1])]
hist(byStation$tripsPerDay)  
# highly skewed, could take log?

# log(pm peak trips/am peak trips)
# add 1 to numerator and denominator to avoid log(0) errors
byStation[, amToPm := +log1p(`wkDay-amPeak`) - log1p(`wkDay-pmPeak`)]
hist(byStation$amToPm)  
# reasonably symmetrical and normal

# log(weekday trips/weekend trips)
byStation[, wkdayToWkend := +log1p(`wkDay-pmPeak`) - log1p(`wkEnd-day`)]
hist(byStation$wkdayToWkend)
# reasonably symmetrical and normal

setorder(byStation, -tripsPerDay)
print(head(byStation[, .(start_station_id, tripsPerDay, amToPm, wkdayToWkend)], 10))

p <- qplot(
  amToPm, wkdayToWkend
  , data = byStation[tripsPerDay > 125]
  , size = tripsPerDay
  , label = start_station_id
)
p <- p + geom_text(
  size = 5
  , vjust = 0, nudge_y = 0.1
  # check_overlap = T
)
if (config$doPlots)
  print(p)
ggsave(
  '12-stations.png'
  , p, dpi = config$dpi
  )
# see plot - biggest stations only
# stations 191, 303, 307 & 248 are all big, have more trips starting in the am & weekdays
# perhaps they are near the CBD / commercial area
# stations 154 & 14 are big and have more trips starting in the pm & on weekends
# perhaps they are near residential area or a park


# cluster analysis --------------------------------------------------------

# k <- 10      # small number, easy to see what is going on
# k <- 20
# k <- 200
k <- 779  # full set of start station ids

byCluster <- byStation[
  seq(k)
  , .(
    tripsPerDay
    , amToPm
    , wkdayToWkend
    )
  ]
setDF(byCluster)
rownames(byCluster) <- byStation$start_station_id[seq(k)]

hc <- hclust(dist(byCluster[, c(
  'amToPm'
  ,'wkdayToWkend'
  # ,'tripsPerDay'    # treat trips per day as a size variable rather than part of the segmentation
  )]))
if (config$doPlots) {
  plot(hc)
  savePng('13-dendrogram.png')
}

byCluster$clust <- as.factor(cutree(hc, k = 5))  # on full set, I think we can use 5 clusters

p <- qplot(amToPm, wkdayToWkend, data = byCluster, size = tripsPerDay, col = clust, pch = clust)
ggsave(
  '14-clusters.png'
  , p, dpi = config$dpi
  )
if (config$doPlots)
  print(p)
# see plot - start stations have been separated into 5 categories, could possibly do 6
# very few stations in the high pm cluster, well differentiated
# other cluster appear contiguous

print(sort(table(byCluster$clust)))
# cluster 5 is the most highly populated, followed by 1
# cluster 3 could be broken into 2 distinct clusters
