# main.R
# written by Paul
# to do some exporatory data analysis
# last saved: Dec 2019


# setup -------------------------------------------------------------------
# clean up the working environment and free up memory
# make sure we have loaded all the libraries we need
# declare some custom functions (that would usually be in a custom library)
# and configure the parameters for this run
# (put your cursor in the green text below and hit F2 to open the sub-script)
source('Rscripts/setup.R')

# get data ----------------------------------------------------------------
# load the data
# do some feature engineering with date and time values
source('Rscripts/getData.R')

# by station --------------------------------------------------------------
# aggregate the data by station and look for similarities & differences between stations
# do a principal components analysis
source('Rscripts/byStation.R')

# network graph -----------------------------------------------------------
# construct edges and nodes
# draw a network graph
# based on average journey duration as a proxy for (Euclidean) distance
# this is to approximate a physical map
source('Rscripts/network.R')

# next step would be to use journey frequency as a proxy for probability
# build some kind of probabilistic model (logistic regression or xgboost model)
# based on whatever inputs can be constructed
# start with a min viable product, eg flat probability
# add a feature at a time, eg time of day, day of week, start station cluster, then id


