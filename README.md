# Ships Shiny App

## Introduction

This app helps in the visualisation and the analysis of the ships dataset.

The main components are:
1. For each chosen ship name, find the maximum distance between two consecutive observations.
2. Show descriptive statistics of the current ship, regarding the movements, speed and time spent.
3. Show as well graphics for the visualisation of the current ship type"

## Usage

To use the app, just select first a ship type and then one ship among the ship names of that type. The app does not select any default ship type at the start. Use the table to switch between the map, the statistics for the current ship or the overall statistics.

### Map

![no map without outliers](https://github.com/osenan/ships/blob/master/map_nooutliers.png)

The map is the main element of the app. The goal is to find the max distance and show it in the map. The top panels show the exact value in meters of the distance plus other statistics of the max distance and the current ship data. 

Can assume that observations with more than one day of difference, although consecutive in the table might not be real consecutive observations? Probably they are not. That is why there is a check button to remove those outlier observations. It is fun to check and uncheck that button and see how results change.

![map with outliers](https://github.com/osenan/ships/blob/master/map_withoutliers.png)

The map itself has in red icons the beginning and end points of the max distance. Distance is computed using the [Haversine formula](http://www.movable-type.co.uk/scripts/gis-faq-5.1.html), which is very exact for the distances managed in the data. Also in red is shown the distance between the points. In grey it is also shown all other minor distances for all consecutive points of the selected ship. The map is interactive and the user can select or not to see all data.

### Current ship statistics

The second tab contains two plots that show statistics for the current ship selected. The first plot is a time series with the change in distance and in speed over time. It is interesting to see how changes are first in the speed and then they appear at the distance value.

The second plot is an histogram of all the distances for that ship (in consecutive observations). In general most of the observations do not imply a big change in the position and therefore in the distance made by the ship. If the user does not remove the outliers, they can be clearly seen in the histogram.

![ship statistics](https://github.com/osenan/ships/blob/master/ship_stats.png)

### Overall statistics

The tab for overall statistics is a barplot with the number of ships per ship type. The colour of the bar of the selected ship type is highlighted, to see how representative the selected ship type is of the total number of ships in the data.

![overall stats](https://github.com/osenan/ships/blob/master/overall_stats.png)
