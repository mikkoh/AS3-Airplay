package com.mikkoh.airplay.data
{
	public class ServerInfo
	{
		public var deviceId:String;
		public var features:String;
		public var model:String;
		public var protocolVersion:String;
		public var sourceVersion:String;
							
		public function ServerInfo()
		{
		}
		
		public function toString():String
		{
			return "device id: "+deviceId+"\n"+
				   "features: "+features+"\n"+
				   "model: "+model+"\n"+
				   "protocolVersion: "+protocolVersion+"\n"+
				   "sourceVersion: "+sourceVersion;
		}
	}
}