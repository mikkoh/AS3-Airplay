package com.mikkoh.airplay.data
{
	public class DeviceInfo
	{
		public var ip:String;
		public var port:int;
		public var serviceName:String;
		
		public function DeviceInfo(ip:String, port:int, serviceName:String)
		{
			this.ip=ip;
			this.port=port;
			this.serviceName=serviceName;
		}
	}
}