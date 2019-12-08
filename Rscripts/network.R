# network.R
# little script to produce a network graph
# written by Paul
# last updated: Nov 2019
# based on code taken from 
# https://www.jessesadler.com/post/network-analysis-with-r/


# parameters --------------------------------------------------------------
# the number of edges to display, you can turn this up or down
# nEdges <- 20
nEdges <- 50
# nEdges <- 200

# edges -------------------------------------------------------------------

# construct the edges of the network from myData
edges <- myData[
  !is.na(mins)
  , .(
    count = .N
    , aveMins = mean(mins)  # try min journey duration?
    , minMins = min(mins)
  )
  , by = .(start_station_id, end_station_id)
  ]

setorder(edges, -count)
edges <- edges[ start_station_id != end_station_id]  # remove those journeys that start and end at same station
edges <- head(edges, nEdges) # sample down to look at only the most frequent journeys or routes (start id -> end id)
edges[, weight := count/50]  # define weight to be the ave number of journeys per day, on that route
# print(edges)
str(edges)

# nodes -------------------------------------------------------------------

# combine start and end stations
temp <- rbind(
  edges[, .(station_id = start_station_id, count)]
  ,edges[, .(station_id = end_station_id, count)]
  )
nodes <- temp[, .(journeys = sum(count)), by = .(station_id)]  # cound the number of journeys, regardless of start or end
nodes[, id := .I]                                          # create an id variable
nodes[, label := as.character(station_id)]                 # station id as text label

# merge to get end station info
edges <- merge(
  edges
  , nodes[, .(station_id, id)]
  , by.x = 'end_station_id'
  , by.y = 'station_id'
  , all.x = T
  , all.y = F
  )
setnames(edges, 'id', 'to')

# merge to get start station info
edges <- merge(
  edges
  , nodes[, .(station_id, id)]
  , by.x = 'start_station_id'
  , by.y = 'station_id'
  , all.x = T
  , all.y = F
  )
setnames(edges, 'id', 'from')


p <- visNetwork(
  nodes = nodes[, .(id, label, value = journeys)]
  , edges = edges[, .(from, to, value = weight
                      # , length = aveMins
                      , length = minMins
  )]
  ) %>% visPhysics(
  solver = "repulsion"
  ) %>% visEdges(
  arrows = "to"
  ) 
print(p)
# interactive, not saved.  need a notebook, shiny webpage or something similar

# length of edes represent average journey duration 
# width or weight of edge repesents the frequency of the route
# size of node represents overall journeys (start & end)
# you can zoom in/out and move them around
# 191 appears to be in the middle of 300, 303, 307
# 14 appears to be relativley disconnected
# once you remove journeys that start and end at the same station, 154 is hardly seen

# at 200 edges, start to see lots of little subnetworks


# explored but not used ---------------------------------------------------

# library(networkD3)
# edges <- mutate(edges, width = weight/5 + 1)
# 
# nodes_d3 <- mutate(nodes, id = id - 1)
# edges_d3 <- mutate(edges, from = from - 1, to = to - 1)

# forceNetwork(
#   Links = edges_d3
#   , Nodes = nodes_d3
#   , Source = "from"
#   , Target = "to"
#   , NodeID = "label"
#   , Group = "id"
#   , Value = "weight"
#   , opacity = 1
#   , fontSize = 16
#   , zoom = TRUE
#   , arrows = T
#   )
# again, very cool, but can't seem to modify lenghts

# sankeyNetwork(Links = edges_d3, Nodes = nodes_d3, Source = "from", Target = "to", 
#               NodeID = "label", Value = "weight", fontSize = 16, unit = "Letter(s)")
# looks groovy, but not very helpful for 2 way paths
