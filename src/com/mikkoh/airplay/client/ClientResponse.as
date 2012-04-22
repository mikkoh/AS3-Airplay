package com.mikkoh.airplay.client
{
	public class ClientResponse
	{
		public var statusCode:int;
		public var statusReason:String;
		public var headers:Object;
		public var body:Object;
		public var bodyType:String=null
		
		public function ClientResponse(statusCode:int, statusReason:String, headers:Object, body:Object, bodyType:String=null)
		{
			this.statusCode=statusCode;
			this.statusReason=statusReason;
			this.headers=headers;
			this.body=body;
			this.bodyType=bodyType;
		}
	}
}