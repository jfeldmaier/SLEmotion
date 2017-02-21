# Name of the Project: 

SLEmotion

An affective appraisal module for Extended Kalman Filter Simultaneous Localization approaches (EKF-SLAM).

# Institution:

Chair of data processing @ Technical University of Munich

# Contributors:

Johannes Feldmaier <johannes.feldmaier@tum.de>, 
Martin Stimpfl

The EKF SLAM simulator bases on the work of Tim Bailey (2004) https://openslam.org/bailey-slam.html

# Description:

Emotions are a fundamental part of everyday life and an important topic in the development of artificial intelligence. In this project a Simultaneous Localization and Mapping algorithm is combined with an emotion model to improve the agent’s evaluation of its current situation. 

A corresponding alt.HRI paper (http://humanrobotinteraction.org/2017/authors/alt-hri/) reports on the result of affective evaluation of an autonomous agent’s path finding process.

Written in Matlab 2015b.
 
# Getting Started:

1. Clone the repository and add the folder and its subfolders to the search path of Matlab.

2. Load an example map e.g.: load('/SLEmotion/EmotionMaps/CorrMap_TestMap.mat')

3. Run the EKF_SLAM simulation: data = ekfslam_sim(lm, wp, object, wall, oi, 0)

4. The appraisal data are now contained in the data structure as a SLEmotion object. 

5. The pleasure data can e.g. be plotted by: 'plot(data.SLEmotion.PA.p)'

The configuration of SLEmotion is done via the configuration file "SLEmotionConfig.m". In this file the various parameters can be adjusted and the GUI can be turned on or off. Alse a recoding feature can be enabled. 