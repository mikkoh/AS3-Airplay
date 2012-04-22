package com.mikkoh.airplay.device
{
	import com.mikkoh.airplay.Client;
	import com.mikkoh.airplay.ClientResponse;
	import com.mikkoh.airplay.data.DeviceInfo;
	import com.mikkoh.airplay.data.ServerInfo;
	import com.mikkoh.airplay.data.returnvalues.DataPosition;
	import com.mikkoh.plist.PList;
	
	import flash.utils.ByteArray;

	public class Device
	{
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
		
		public function Device(info:DeviceInfo, readyCallBack:Function=null)
		{
			this._serverInfo=null;
			
			this.info=info;
			this.readyCallBack=readyCallBack;
			this.ready=false;
			
			this.client=new Client(info.ip, info.port, onClientConnet);
		}
		
		public function get serverInfo():ServerInfo
		{
			return _serverInfo;
		}
		
		public function close():void
		{
			this.client.close();
		}
		
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
		
		public function play(content:String, startLocation:Number, callBack:Function=null):void
		{
			var body:String='Content-Location: '+content+'\n' +
							'Start-Position: '+startLocation+'\n';
			
			doPost('/play', body, callBack);
		}
		
		public function stop(callBack:Function=null):void
		{
			doPost('/stop', null, callBack);
		}
		
		public function pause(callBack:Function=null):void
		{
			rate(0, callBack);
		}
		
		public function resume(callBack:Function=null):void
		{
			rate(1, callBack);
		}
		
		public function rate(rate:Number, callBack:Function=null):void
		{
			doPost('/rate?value='+rate, null, callBack);
		}
		
		public function getPosition(callBack:Function):void
		{
			doGet("/scrub", callBack, DataPosition.ID);
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