# NPKD-TECH Mobile Application

The application will serve as a platform extension for the NPKDTECH robot/system, which is designed for soil sampling and analyzing fertilizer levels by detecting nitrogen, phosphorus, and potassium. The app will display this data in real-time while also providing control features for the system.
## My App 
In order to develop the app, multiple revisions of the storyboard were made, which allowed me to get creative and understand what I am developing. 
The following picture is of the first storyboard with pen and paper. 

<img src="npk_application/images/Storyboardn_1.jpg" alt="drawing" width="200"/>
<div style="display: flex; flex-wrap: wrap; gap: 250px; justify-content: center;">

  <!-- Top row: 4 images -->
  <img src="./npk_application/images/signup.png" alt="Signup" style="width: 150px; height: auto;">
  <img src="./npk_application/images/login.png" alt="Login" style="width: 150px; height: auto;">
  <img src="./npk_application/images/home.png" alt="Home" style="width: 150px; height: auto;">
  <img src="./npk_application/images/soildata.png" alt="Soil Data" style="width: 150px; height: auto;">
</div>
<div style="display: flex; flex-wrap: wrap; gap: 25px; justify-content: center;">

  <!-- Bottom row: 3 images -->
  <img src="./npk_application/images/uwb.png" alt="UWB" style="width: 150px; height: auto;">
  <img src="./npk_application/images/gps.png" alt="GPS" style="width: 150px; height: auto;">
  <img src="./npk_application/images/status.png" alt="Status" style="width: 150px; height: auto;">

</div>


## Include A Section That Tells Developers How To Install The App

The initial storyboard of the design looks like the following I was aiming for a simple design and not making the app to clunky while showing the important information in a way which stands out. This storyboard gave me a good idea of what I was trying to build throughout the length of the development. 

The first two interfaces are a login and a signup page, which are used for authentication, allowing users to view their different pieces of data. Following that, there will be 4 pages. The first page shows general sensor data, such as the outside temperature on the robot, how quickly the robot is traveling, and the humidity. The following page will give some insights regarding the soil, it will show the NPK values along with the moisture of the soil. The third page will be used for location, we provide two ways for localizing the robot, one is using UWB, which provides precision, and the other is using GPS. The UWB interface will show a grid with regards to where the robot is. The GPS interface will useGoogle Maps API to show a pin at where the robot is currently. Finally, a status/control page which will show what the robot is currently doing, either sampling or travelling. It will also provide control over the linear actuator to move the robot up and down.  
Include a section that gives intructions on how to install the app or run it in Flutter.  What versions of the plugins are you assuming?  Maybe define a licence

##  Contact Details

Having Contact Details is also good as it shows people how to get in contact with you if they'd like to contribute to the app. 
