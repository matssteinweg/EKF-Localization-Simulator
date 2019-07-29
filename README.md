# EKF Localization - Simulator

In this repository you find a simulation of a robot localization algorithm based on the *Extended Kalman Filter* (EKF). The simulator comes with a GUI that allows for exploring the performance of the algorithm under different parameter settings. The project is inspired by the course *Applied Estimation* at *KTH Royal Institute of Technology, Stockholm*.

<p align="center"> 
<img height="400px" src="/images/simulator_gui.png">
</p>

## Implementation Details

The motivation behind the development of this simulator is to create an intuitive understanding of the EKF and how it is applied in the context of robot localization. This is facilitated by allowing for adjusting filter parameters during the localization and being able to observe the effect on the algorithm's performance directly. Furthermore, by providing characteristically different datasets, a wide range of localization scenarios can be explored.

### Sensor Data

The robot localization is performed on simulated sensor data. The data includes distance and bearing measurements from a laser range finder as well as odometry information in the form of wheel-encoders. The layout of the environment is defined by the location of observable landmarks.

### Simulation Settings

In order to explore the full capabilities of the EKF, characteristically different and challenging datasets are used which require a wide range of parameter settings to accurately track the robot's trajectory.

#### Simulation Mode
* **Batch Update:** In Batch Mode the EKF performs one update step for all measurements available at a certain timestep. Thus, the influence of bad measurements can be reduced and more robust updates can be performed. 
* **Sequential Update:** Using the sequential update, the state estimate is updated for each new measurement coming in. In case of noisy measurements, this can easily lead to an inconsistent estimate of the robot's location. However, the sequential update comes at a reduced computational complexity in comparison to the batch update.

#### Simulation Parameters
* **Uncertainties:** The underlying models of the sensor modalities and the robot motion are based on the assumption of normally distributed noise with zero mean. The standard deviation of the distributions can be adapted to the circumstances during the simulation. The relation between the uncertainties of the motion model and the sensor model influence the *Kalman Gain* which determines how much the update is based on the odometry information and sensor information, respectively. Consequently, it is important to properly assess the uncertainties required for specific tracking problems.
* **Data Association:** Data Association is concerned with assigning the available laser readings to the corresponding landmark. This step is performed by computing the likelihood of every landmark for all available measurements based on the underlying sensor model and selecting the maximum likelihood association. By disabling the data association, ground truth information about the correct landmark is used instead of calculating the likelihoods. Thus, the performance of the Particle Filter can be assessed under perfect sensory conditions.
* **Outlier Detection:** In case of noisy measurements or false observations, it can be beneficial to disregard certain measurements in the update step. This step is referred to as outlier detection. The threshold for the detection is based on the mahalanobis distance of the predicted measurement and the actual measurement. Since the mahalanobis distance follows the *inverted-chi-square distribution* the threshold can be given in terms of a probability. It can be interpreted as the likelihood of the observation to belong to the distribution represented by the sensor model. The threshold can be varied on a scale from 0% (outlier detection disabled) to 100%.

## How-To Use the Simulator

The simulator can be opened by running: ```ekf_gui.mlapp```
In order to start a simulation, select a dataset from the drop-down menu at the top of the application.
By selecting a dataset, the simulation parameters are automatically set to default values that work well for the given problem. However, in order to explore the capabilites and shortcomings of the EKF, all mentioned parameters can be changed. 
With all simulation parameters set to the desired values, the simulation can now be started. Widgets for parameters that cannot be changed anymore during the simulation will be disabled during the simulation, all other parameters can be changed while the simulation is running.
After the full simulation, error statistics will be displayed below the figure that shows a zoomed-in plot of the ground truth position and the current estimate. However, if you wish to stop the simulation before that, the "Stop"-Button can be used. This takes you back to the initial screen and a new simulation can be started.

## Datasets

The simulator comes with three datasets specifically designed for testing robot localization algorithms. In this Section I would like to give a brief overview of the datasets' characteristics and sketch a few possiblly insightful simulation scenarions along with some illustrations.

### Dataset 1

The first dataset comes with an environment that is fairly easy to navigate. There is a large number of observable landmarks which are sufficiently far away from each other in order not to lead to misassociations. Furthermore, highly accurate sensor readings are available. Consequently, the default settings for the uncertainties in motion model and sensor model are comparably small. The outlier detection is set to only discard highly unlikely observations. With these settings the robot can be tracked accurately accross the whole trajectory. A screenshot of the simulation is displayed in the figure below. We can observe that despite realtively inaccurate odometry information (blue), the large number of observations allow for an accurate estimate of the robot pose with a high certainty.

<p align="center"> 
<img height="250px" src="/images/dataset_1_illustration.png">
</p>

### Dataset 2

The second dataset is designed to test the outlier detection. The environment consists of ten landmarks that are arranged in the form on an ellipse. Compared to the first dataset, the distance between the two measurements is substantially longer. This simplifies the data association. However, the landmarks are so far apart that the robot occasionally only observes one measurement at a time. Furthermore, the sensor readings display much greater variance compared to the first dataset. Consequently, the algorithm has to deal with very few and inaccurate observations, requiring a much larger sensor model uncertainty in the default settings. Thus, the filter update relies much more heavily on the motion model than the sensor readings. The figure below displays two scenarios taken from a simulation. In the left image we can observe a situation in which both available measurements are regarded as outliers (yellow lines) due to the offset between the beam endpoint and the location of the landmark. Consequently, the EKF performs the update only based on the odometry information.
In the right image a scenario is displayed in which the robot only observes one landmark. This situation is undesirable since the algorithm has to rely on merely one, potentially inaccurate, sensor reading and cannot incorporate any measurement in the update step in case this observation is classified as an outlier.

<p align="center"> 
<img height="250px" src="/images/dataset_2_illustration.png">
</p>

### Dataset 3

In contrast to the two first dataset, the third dataset doesn't contain odometry information and the localization has to be performed purely based on the measurements of the laser range finder. The layout of the environment is highly similar to the second dataset. However, a much larger number of landmarks exist. The purpose of this dataset is to illustrate the advantages of the batch update compared to the sequential update. In order to account for the missing odometry information, the underlying motion model is subject to a large uncertainty on all state dimensions. The outlier detection is disabled in order to incorporate all available sensor information into the state estimate. Scenarios taken from two simulations are displayed in the figure below. The left image is taken from a simulation performing sequential state updates while the image on the right features a simulation based on batch updates. In the left image we can observe that the EKF loses track of the robot early on in the simulation. This can be explained by the shortcomings of the sequential update and the layout of the network. With an update based on an incorrect association, the state estimate is off and cannot recover due to the equally spaced landmarks across the area. Subsequent observations are constantly associated with the wrong landmark, however, display a high likelihood due to the presence of a different landmark at the expected location. Consequently, the EKF is certain of its incorrect estimate, a situation that is referred to as inconsistency of the filter. This problem is adressed by the batch update that introduces more robustness into the estimate. The filter is updated less frequently but makes more reasonable update steps and can thus suppress the influence of a bad measurement in the presence of a number of accurate sensor readings.

<p align="center"> 
<img height="250px" src="/images/dataset_3_illustration.png">
</p>
