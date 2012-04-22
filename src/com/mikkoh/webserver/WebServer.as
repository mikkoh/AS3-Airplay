package com.mikkoh.webserver
{
	import com.mikkoh.webserver.mimetype.MimeType;
	
	import flash.events.Event;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	public class WebServer
	{
		[Embed(source="../assets/favicon.ico", mimeType="application/octet-stream")]
		private static const ICO:Class;
		
		private static const DEFAULT_ICO:ByteArray=new ICO();
		
		private static const MAX_PACKET:int=1048576; //1048576==1mb
		
		private var root:File;
		private var server:ServerSocket;
		private var mimeType:MimeType;

		private var returnData:ByteArray;
		private var returnPos:int;
		private var returnMime:String;
		private var returnFile:String; 
		
		
		
		
		public function WebServer(rootDirectory:File, port:int=8080)
		{
			if(!rootDirectory.isDirectory)
				throw new Error("The file you are specifying as the root director is not a directory");
			
			this.root=rootDirectory;
			this.mimeType=new MimeType(["html", "htm", "png", "jpg", "jpeg", "png", "gif", "mp4"]);
			
			server=new ServerSocket();
			server.bind(port);
			server.addEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
			server.listen();
		}
		
		public function setMimeTypes(mimeTypes:MimeType):void
		{
			this.mimeType=mimeTypes;
		}
		
		public function close():void
		{
			server.close();
		}
		
		private function onConnect(ev:ServerSocketConnectEvent):void
		{
			var socket:Socket=ev.socket;
			
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketSendData);
			socket.addEventListener(Event.CLOSE, onSocketClose);
		}
		
		private function onSocketSendData(ev:ProgressEvent):void
		{
			var socket:Socket=Socket(ev.target);
		
			var headerData:ByteArray=new ByteArray();
			socket.readBytes(headerData);
			var header:String=headerData.toString();
			
			var headerSplit:Array=header.split("\n").join(": ").split(": ");
			headerSplit.length-=2; //-2 for the last \n\n chars
			
			var headerObj:Object={};
			var numHeader:int=(headerSplit.length-1)/2;
			
			for(var i:int=0;i<numHeader;i++) 
			{
				var keyIdx:int=i*2+1;
				var valueIdx:int=i*2+2;
				
				headerObj[headerSplit[keyIdx]]=headerSplit[valueIdx];
			}
			
			var requestType:String=headerSplit[0].substring(0, header.indexOf(" "));
			var connection:String=headerObj["Connection"];
			
			
			
			
			//GET, HEAD, POST, PUT, DELETE, OPTIONS, TRACE, CONNECT
			//http://www.scribd.com/doc/18171962/Making-the-Most-of-HTTP-In-Your-Apps
			switch(requestType)
			{
				case "GET":
					returnFile=header.substring(5, header.indexOf("HTTP/")-1);
					
					var range:Array;
					var rangeIdx:int=header.indexOf("Range: bytes=");
					
					if(rangeIdx!=-1)
					{
						rangeIdx+=13;
						
						range=header.substring(rangeIdx, header.indexOf("\n", rangeIdx)).split("-");
					}
					
					get(socket, returnFile, headerSplit, range);
					break;
				
				default:
					trace("OH NO DEFINE |"+requestType+"|");
				break;
			}
		}
		
		private function onSocketClose(ev:Event):void
		{
			var socket:Socket=Socket(ev.target);
		
			server.close();
		}
		
		private function get(socket:Socket, filePath:String, headers:Object, range:Array=null):void
		{
			returnFile=filePath;
			
			var file:File=root.resolvePath(returnFile.toLowerCase());
			var fileExtension:String=returnFile.substr(returnFile.lastIndexOf(".")+1);
			var fs:FileStream;
			
			returnMime=mimeType.getMimeType(fileExtension);
			
			if(file.exists && !file.isDirectory && returnMime!=null)
			{
				var returnHeader:String;
				
				returnData=new ByteArray();
				fs=new FileStream();
				fs.open(file, FileMode.READ);
				fs.readBytes(returnData);
				fs.close();
				
				//check if we should send in parts
				if(returnData.length>MAX_PACKET)
				{
					if(headers["User-Agent"]!=null && headers["User-Agent"].indexOf("QuickTime")!=-1)
					{
						returnHeader="HTTP/1.1 200 OK\r\n";
						returnHeader+="Accept-Ranges: bytes\r\n";
						returnHeader+="Connection: keep-alive\r\n";
						returnHeader+="Content-Length: "+returnData.length+"\r\n";
						returnHeader+="Content-Type: "+returnMime+"\r\n\r\n";
						socket.writeUTFBytes(returnHeader);
						socket.writeBytes(returnData);
						socket.flush();
						//socket.close();
					}
					else if(range==null)
					{
						returnHeader="HTTP/1.1 200 OK\r\n";
						returnHeader+="Accept-Ranges: bytes\r\n";
						returnHeader+="Connection: keep-alive\r\n";
						returnHeader+="Content-Length: "+returnData.length+"\r\n";
						returnHeader+="Content-Type: "+returnMime+"\r\n\r\n";
						socket.writeUTFBytes(returnHeader);
						socket.flush();
						socket.close();
					}
					else if(range!=null)
					{
						var sRange:int=parseInt(range[0]);
						var eRange:int=parseInt(range[1]);
						
						returnHeader="HTTP/1.1 206 Partial Content\r\n"+
							"Accept-Ranges: bytes\r\n"+
							"Content-Type: "+returnMime+"\r\n"+
							"Content-Range: bytes "+sRange+"-"+eRange+"/"+returnData.length+"\r\n"+
							"Content-Length: "+returnData.length+"\r\n\r\n";
						
						socket.writeUTFBytes(returnHeader);
						
						if(sRange!=eRange)
							socket.writeBytes(returnData, sRange, eRange-sRange);
						else
							socket.writeBytes(returnData, sRange);
						
						socket.flush();
						socket.close();
					}
				}
				else
				{
					returnHeader="HTTP/1.1 200 OK\r\n";
					returnHeader+="Content-Type: "+returnMime+"\r\n";
					returnHeader+="Content-Length: "+returnData.length+"\r\n\r\n";
					
					socket.writeUTFBytes(returnHeader);
					socket.writeBytes(returnData);
					socket.flush();	
					socket.close();
				}
			}
			else if(fileExtension=="ico")
			{
				DEFAULT_ICO.position=0;
				
				returnHeader="HTTP/1.1 200 OK\r\n";
				returnHeader+="Content-Type: "+returnMime+"\r\n";
				returnHeader+="Content-Length: "+DEFAULT_ICO.length+"\r\n\r\n";
				socket.writeBytes(DEFAULT_ICO);
				socket.flush();
			}
			else
			{
				returnHeader="HTTP/1.1 404 Not Found\r\n";
				returnHeader+="Content-Type: text/html\r\n\r\n";
				returnHeader+="<html><body><h1>DOH NO FILE FOUND</h1></body></html>";
				socket.flush();	
			}
		}
	}
}