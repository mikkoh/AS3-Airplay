package
{
	import com.mikkoh.airplay.client.ClientResponse;
	import com.mikkoh.airplay.data.DeviceInfo;
	import com.mikkoh.airplay.data.returnvalues.DataPosition;
	import com.mikkoh.airplay.device.Device;
	import com.mikkoh.webserver.WebServer;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;

	public class AirPlayVideoExample extends Sprite
	{
		private static const APPLE_TV_IP:String="192.170.1.105"; //this should be the ip address to your apple tv
		private static const WEB_SERVER_FOLDER:String="/Users/mikkohaapoja/Documents/Work/AirPlay/exampleAssets/"; //this should be a path to a folder where your video is
		private static const YOUR_IP:String="192.170.1.107"; //ip address to the computer running this application
		private static const YOUR_VIDEO_FILE_NAME:String="vid.mp4"; //file name that you want to play
		
		private var server:WebServer;
		private var device:Device;
		private var paused:Boolean=false;
		
		public function AirPlayVideoExample()
		{
			//Remember to modify WEB_SERVER_FOLDER above and other static variables
			//This will create a web server that will serve up video files to an apple tv
			server=new WebServer(new File(WEB_SERVER_FOLDER), 8080);
			
			//Apple tv's right now are always port 7000
			//Create the device that will be used to communicate with the apple tv
			device=new Device(new DeviceInfo(APPLE_TV_IP, 7000, ""), onConnected);
		}
	
		/**
		 * This function will be called once we're connected to the apple tv.
		 * Once we are connected we'll start playing the video that is defined in the
		 * static variables above. 
		 */		
		private function onConnected():void
		{
			//play the video defined above
			device.play("http://"+YOUR_IP+":8080/"+YOUR_VIDEO_FILE_NAME, 0, onVideoPlaying);
			
			//This is just a nice thing to do
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onAppExit);
		}
		
		/**
		 * This function will be called once the video starts playing.
		 *  
		 * @param data You can get information back from the apple tv from the data variable
		 * 
		 */		
		private function onVideoPlaying(data:ClientResponse):void
		{
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
			
			trace("VIDEO PLAYING");
			
			trace("----STATUS----");
			trace(data.statusCode);
		}
		
		/**
		 * This function is called when the stage is clicked and will pause and resume the video
		 * that is playing.
		 * 
		 * @param ev
		 * 
		 */		
		private function onStageClick(ev:MouseEvent):void
		{
			paused=!paused;
			
			if(paused)
				device.pause();
			else
				device.resume();
		}
		
		private function onAppExit(ev:Event):void
		{
			device.close();
			server.close();
		}
	}
}