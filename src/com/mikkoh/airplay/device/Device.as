package com.mikkoh.airplay.device
{
	import com.mikkoh.airplay.client.Client;
	import com.mikkoh.airplay.client.ClientResponse;
	import com.mikkoh.airplay.data.DeviceInfo;
	import com.mikkoh.airplay.data.ServerInfo;
	import com.mikkoh.airplay.data.returnvalues.DataPosition;
	import com.mikkoh.plist.PList;
	
	import flash.utils.ByteArray;

	/**
	 * The device is the heart of Airplay. It is used to connect to an Airplay end point
	 * such as an Apple TV. After this you can use the device to control the Apple TV
	 *  
	 * @author mikkohaapoja
	 * 
	 */	
	public class Device
	{
		/**
		 * The following are transitions you can pass in when displaying images on the
		 * device you are sending the images to 
		 */		
		public static const TRANSITION_NONE:String="None";
		public static const TRANSITION_SLIDE_LEFT:String="SlideLeft";
		public static const TRANSITION_SLIDE_RIGHT:String="SlideRight";
		public static const TRANSITION_DISSOLVE:String="Dissolve";
		
		private static const VALID_TRANSITIONS:Object={};
		
		{
			VALID_TRANSITIONS[TRANSITION_NONE]=true;
			VALID_TRANSITIONS[TRANSITION_SLIDE_LEFT]=true;
			VALID_TRANSITIONS[TRANSITION_SLIDE_RIGHT]=true;
			VALID_TRANSITIONS[TRANSITION_DISSOLVE]=true;
		}
		
		private var _serverInfo:ServerInfo;
		
		private var info:DeviceInfo;
		private var readyCallBack:Function;
		private var ready:Boolean;
		private var client:Client;
		private var curCallBack:Function;
		private var curCallBackType:String;
		
		/**
		 * The device is the heart of Airplay. It is used to connect to an Airplay end point
	 	 * such as an Apple TV. After this you can use the device to control the Apple TV.
		 *  
		 * @param info This is will be a simple instance of DeviceInfo which contains the ip and port of the airplay device you want to control
		 * @param readyCallBack This function will called when we have connected to the device (ie Apple TV). Nothing will be passed to this function.
		 * 
		 */		
		public function Device(info:DeviceInfo, readyCallBack:Function=null)
		{
			this._serverInfo=null;
			
			this.info=info;
			this.readyCallBack=readyCallBack;
			this.ready=false;
			
			this.client=new Client(info.ip, info.port, onClientConnet);
		}
		
		/**
		 *  
		 * @return This is the ServerInfo for the current device you are connected to 
		 * 
		 */		
		public function get serverInfo():ServerInfo
		{
			return _serverInfo;
		}
		
		/**
		 * Close the connection to the device you are connected to 
		 * 
		 */		
		public function close():void
		{
			this.client.close();
		}
		
		/**
		 * Use this function to send images to be displayed on the iDevice you are connected to.
		 *  
		 * @param image This should be a jpg, or png image as a ByteArray
		 * @param transition You can define how the image will transition in. All possible transitions are defined as static variables within this class definition.
		 * @param callBack This function will be called when the image is displayed on the device we are connected to. A ClientResponse will be passed back.
		 * 
		 */		
		public function showImage(image:ByteArray, transition:String=TRANSITION_NONE, callBack:Function=null):void
		{
			var req:Object={};
			
			req.headers={};
			
			if(VALID_TRANSITIONS[transition])
				req.headers["X-Apple-Transition"]=transition;
			else
				req.headers["X-Apple-Transition"]=TRANSITION_DISSOLVE;
			
			doPut('/photo', image, req, callBack); 
		}
		
		/**
		 * Play will tell the device you are connected to play video from a specific url.
		 *  
		 * @param url This is the url to the mp4 formatted for iDevices
		 * @param startLocation Start location where the video should start playing
		 * @param callBack This function will be called when the video starts playing. A ClientResponse will be passed back.
		 * 
		 */		
		public function play(url:String, startLocation:Number=0, callBack:Function=null):void
		{
			var body:String='Content-Location: '+url+'\n' +
							'Start-Position: '+startLocation+'\n';
			
			doPost('/play', body, callBack);
		}
		
		/**
		 * This function will stop the current video that the device we're connected to
		 * is playing.
		 *  
		 * @param callBack This function will be called when the video stops playing. A ClientResponse will be passed back.
		 * 
		 */		
		public function stop(callBack:Function=null):void
		{
			doPost('/stop', null, callBack);
		}
		
		/**
		 * Call this function to pause the video that is currently playing 
		 * 
		 * @param callBack This function will be called when the video we're playing is paused. A ClientResponse will be passed back.
		 * 
		 */		
		public function pause(callBack:Function=null):void
		{
			rate(0, callBack);
		}
		
		/**
		 * Call this function to resume playing a video from a paused state
		 * 
		 * @param callBack This function will be called when the video we're playing is resumed. A ClientResponse will be passed back.
		 * 
		 */		
		public function resume(callBack:Function=null):void
		{
			rate(1, callBack);
		}
		
		/**
		 * Using this function you can set the rate at which the video is playing on the device we're
		 * connected to. Currently it seems that only rates of 0 (not playing) and 1 (regular speed)
		 * are supported
		 *  
		 * @param rate The rate at which the current video is playing at (currently the Apple TV only supports 0 and 1)
		 * @param callBack This function will be called once the rate of the video has changed. A ClientResponse will be passed back.
		 * 
		 */		
		public function rate(rate:Number, callBack:Function=null):void
		{
			doPost('/rate?value='+rate, null, callBack);
		}
		
		/**
		 * Call this function to find out the current position and duration of the video.
		 *  
		 * @param callBack This function will be called once we've received the position and duration from the device we're connected to.
		 * A ClientResponse will be passed back. You can cast the body of the ClientResponse to a DataPosition object for ease of use.
		 * 
		 */		
		public function getPosition(callBack:Function):void
		{
			doGet("/scrub", callBack, DataPosition.ID);
		}
		
		/**
		 * Using seek you can scrub or seek to a specific position in the video playing.
		 *  
		 * @param position Position in seconds we want to seek to.
		 * @param callBack This callback function will be called once we have attempted to seek to the position. A ClientResponse will be passed back. 
		 * 
		 */		
		public function seek(position:Number, callBack:Function):void
		{
			doPost("/scrub?position="+position, null, callBack);
		}
		
		private function onClientConnet(resp:ClientResponse):void
		{
			this.client.get('/server-info', onServerInfo);
		}
		
		private function doPost(path:String, body:String, callBack:Function, callBackType:String=null):void
		{
			this.curCallBack=callBack;
			this.curCallBackType=callBackType;
			
			if(callBack!=null)
				this.client.post(path, body, onParseCallBack);
			else
				this.client.post(path, body);
		}
		
		private function doGet(path:String, callBack:Function, callBackType:String=null):void
		{
			this.curCallBack=callBack;
			this.curCallBackType=callBackType;
			
			if(callBack!=null)
				this.client.get(path, onParseCallBack);
			else
				this.client.get(path);
		}
		
		private function doPut(path:String, data:ByteArray, req:Object, callBack:Function, callBackType:String=null):void
		{
			this.curCallBack=callBack;
			this.curCallBackType=callBackType;
			
			if(callBack!=null)
				this.client.put(path, req, data, onParseCallBack);
			else
				this.client.put(path, req, data);
		}
		
		private function onServerInfo(resp:ClientResponse):void
		{
			var plist:PList=new PList(String(resp.body))
			
			var el:Object=plist[0];	
				
			_serverInfo=new ServerInfo();
			serverInfo.deviceId=el.deviceid;
			serverInfo.features=el.features;
			serverInfo.model=el.model;
			serverInfo.protocolVersion=el.protovers;
			serverInfo.sourceVersion=el.srcvers;
			
			if(readyCallBack!=null)
				readyCallBack();
		}
		
		private function onParseCallBack(resp:ClientResponse):void
		{
			switch(curCallBackType)
			{
				case DataPosition.ID:
					resp.body=new DataPosition(String(resp.body));
					resp.bodyType=DataPosition.ID;
				break;
			}
			
			curCallBack.call(null, resp);
		}
	}
}