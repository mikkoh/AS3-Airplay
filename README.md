What is this AS3 Airplay:
=========================
This library is an implementation of Airplay for Adobe Air Applications. Currently the library is fully written in AS3
with no Native Extensions. There are two major parts to the library:

The Device-
The device is what you use to connect and control an Apple tv or another Airplay device.

The WebServer-
The webserver implementation is very basic currently and really only properly streams videos using "206 Partial Content"
on Safari browsers (desktop and mobile). The WebServer is only really used when you want to stream videos to an Apple TV
for instance. You can send images to the apple tv just by using device you do not need the Web Server. You can also play
MP4s that are formatted for iDevices from an external url using just the device.



To Do:
-Create Web Servers as Native Extensions so Mobile Devices can serve up video content
-Implement Bonjour, in AS3 or as an NAE, to be able to discover Airplayable devices



Inspiration:
AS3 Airplay is based on the Node JS implementation of Airplay. Those who have
used it will find the architecture to be very similar but more AS3ishy.
 
Check out the Node JS implementation of Airplay here:
https://github.com/benvanik/node-airplay

