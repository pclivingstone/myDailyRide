# myDailyRide
This repo contains R code.  To run it, you will need:
- to have installed R and RStudio,
- cloned this repo,
- have a copy of the data downloaded and stored it locally (it is NOT in the repo)
- run the code in main.R

This will create some png files in the project directory, print some stuff to screen
and draw an interactive network graph.

NOTE:
- I use a combination of base and ggplot graphics.  If this code was being productionised, I'd make sure most
of the graphics were ggplot.
- If the data set was bigger, I'd have a debug switch in the config list, to sample right down and make the code run
faster.  At this size, it isn't really necessary.
- Same with timings and email notifications.  Not really necessary for a task like this, but if it was bigger & getting
productionised, I'd set it up.
- And of course, I still have answered the original question.  I still haven't constructed a data set that could be used 
to build a model.
