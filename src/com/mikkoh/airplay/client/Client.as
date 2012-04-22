package com.mikkoh.airplay.client
{
	import com.mikkoh.airplay.data.returnvalues.DataPosition;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	//https://github.com/benvanik/node-airplay/blob/master/lib/airplay/client.js
	
	public class Client
	{
		private var socket:Socket;
		private var curCallBack:Function;
		
		public function Client(ip:String, port:int, callBack:Function=null)
		{
			this.curCallBack=callBack;
			
			socket=new Socket(ip, port);
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		public function get(path:String, callback:Function=null):void
		{
			var req:Object={
				method: "GET",
				path: path
			};
			
			this.issue(req, null, callback);
		}
		
		public function post(path:String, body:String=null, callback:Function=null):void
		{
			var req:Object={
				method: "POST",
				path: path
			};
			
			this.issue(req, body, callback);
		}
		
		public function put(path:String, req:Object, body:ByteArray, callBack:Function=null):void
		{
			req.method="PUT";
			req.path=path;
				
			this.issue(req, body, callBack);
		}
		
		public function close():void
		{
			socket.close();
		}
		
		private function issue(req:Object, body:Object=null, callback:Function=null):void
		{
			var bodyByte:ByteArray;
			var allHeaders:String;
			
			//Setup Headers to combine later
			req.headers=req.headers || {};
			req.headers["User-Agent"] = "MediaControl/1.0";
			req.headers["Connection"] = "keep-alive";
			
			if(body!=null && body is String)
			{
				var bodyLengthCheck:ByteArray=new ByteArray();
				bodyLengthCheck.writeUTFBytes(String(body));
				req.headers["Content-Length"]=bodyLengthCheck.length;
			}
			else if(body!=null && body is ByteArray)
			{
				bodyByte=ByteArray(body);
				req.headers["Content-Length"]=bodyByte.length;
			}
			else
			{
				req.headers["Content-Length"]=0;
			}
				
			//start creating the headers as a string
			allHeaders=req.method+" "+req.path+" HTTP/1.1\n";
			
			for(var key:String in req.headers)
			{
				allHeaders+=key+": "+req.headers[key]+"\n";
			}
			
			allHeaders+="\n";
			
			//Now write the body
			if(body!=null && body is String) 
			{
				socket.writeUTFBytes(allHeaders+body); //write the combined header and body
			}
			else if(body!=null && body is ByteArray)
			{
				socket.writeUTFBytes(allHeaders); //write the header
				
				bodyByte=ByteArray(body);
				bodyByte.position=0;
				
				socket.writeBytes(bodyByte); //write the content
			}
			else
			{
				socket.writeUTFBytes(allHeaders); //write just the header since there is no body
			}
			
			socket.flush();
			
			curCallBack=callback;
		}
		
		private function parseResponse(response:String):ClientResponse
		{
			var bodyText:String="";
			
			//replace \r\n to \n
			response=response.replace(/\r\n/g, "\n");
			
			var bodyHeaderSplit:int=response.indexOf("\n\n");
			
			if(bodyHeaderSplit!=-1) 
			{
				bodyText=response.substr(bodyHeaderSplit);
				response=response.substr(0, bodyHeaderSplit);
			}
			
			//Pull out status
			var status:String=response.substr(0, response.indexOf("\n"));
			var statusMatch:Array=status.match(/HTTP\/1.1 ([0-9]+) (.+)/);
			
			response=response.substr(status.length);
			
			//Parse headers
			var allHeaders:Object={};
			var headerLines:Array=response.split("\n");
			
			for (var i:int=0;i<headerLines.length;i++)
			{
				var headerLine:String=headerLines[i];
				var key:String=headerLine.substr(0, headerLine.indexOf(":"));
				var value:String=headerLine.substr(key.length);
				
				allHeaders[key]=value;
			}
			
			return new ClientResponse(parseInt(statusMatch[1]), //statusCode
									  statusMatch[2], //statusReason
									  allHeaders, //headers
									  bodyText); //body
		}
		
		private function onConnect(ev:Event):void
		{
			var data:String="GET /playback-info HTTP/1.1\n" +
							"User-Agent: MediaControl/1.0\n" +
							"Content-Length: 0\n" +
							"\n";
			
			socket.writeUTFBytes(data);
			socket.flush();
		}
		
		private function onSocketData(ev:ProgressEvent):void
		{
			var data:ByteArray=new ByteArray();
			
			socket.readBytes(data);
			
			var response:ClientResponse=parseResponse(data.toString());
			
			if(curCallBack!=null)
				curCallBack.call(null, response);
		}
		
		private function onIOError(ev:IOErrorEvent):void
		{
			trace("IO ERROR");
		}
	}
}