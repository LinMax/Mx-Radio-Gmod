This is MX Radio
I no longer am supporting this; Feel free to do what you want with this code.

**Note*
This is an older project of mine, and is crap... You have been warned!

DESCRIPTION
Mx Radio is an internet radio streamer. It plays the streams in 3D space, so the sound appears to be coming from the radio itself. It comes with 12 default radio stations, and players can enter a valid custom internet station link and it will play it for all players. Admins can add and remove stations from the station list, making it 100% customizable. It is pretty simple, but it works. 

Features 
-Plays stations in 3d directional sound 
-Players can play a custom radio stream of their choosing without it being added to everyone's radio list 
-Admins can Add and Remove any station to/from the main radio list 
-station changes save with server restart 
-Multiple radios can be playing at once 
-Vehicles have radios 
-Server keeps track of radios and their stations, so players can hear the radio even if the joined after it was created 
-Clients have the option to change from 3d sound, to non-3d, which plays the station in both ears equally, and changes the volume based on your distance to the radio, This fixes the issue with radios being very quiet, but while removing the cool 3d sound system... 
-Settings file to change the model of the radio, edit "mxradio_settings.txt" file in 'garrysmod/data' 

*Bind +mx_menu to a key, and use it in a vehicle, no need to spawn a radio! 

Facepunch Thread: 
http://facepunch.com/showthread.php?t=1293649&p=41608580#post41608580 

*Note* 
Not all stations work, the problem is 'sound.PlayURL' it can only stream a few file types. this can only be fixed by garry, or by using external modules, which I do not want to do to keep things simple for people, so they can just download everything from the workshop. 



**************If you see a red error***************************** 
it is because you dont have css installed... 
go to "garrysmod/data" and open "mxradio_settings.txt" 
change 
Model=models/props/cs_office/radio.mdl 
to 
Model=models/props_lab/citizenradio.mdl