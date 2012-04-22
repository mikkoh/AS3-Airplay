package com.mikkoh.webserver.mimetype
{
	import org.osmf.net.StreamingURLResource;

	public class MimeType
	{
		private static const ICO:String="image/x-icon";
		private static const HTML:String="text/html";
		private static const JPG:String="image/jpeg";
		private static const PNG:String="image/png";
		private static const GIF:String="image/gif";
		private static const MP4:String="video/mp4";
		
		private static const LOOK_UP:Object={};
		
		{
			LOOK_UP["jpg"]=JPG;
			LOOK_UP["jpeg"]=JPG;
			LOOK_UP["png"]=PNG;
			LOOK_UP["gif"]=GIF;
			
			LOOK_UP["htm"]=HTML;
			LOOK_UP["html"]=HTML;
			
			LOOK_UP["mp4"]=MP4;
			
			LOOK_UP["ico"]=ICO;
		}
		
		private var allowedTypes:Object={ico: true};
		
		public function MimeType(types:Array=null)
		{
			if(types!=null)
			{
				for(var i:int=0;i<types.length;i++) 
				{
					enable(types[i]);
				}
				
			}
		}
		
		public function getMimeType(type:String):String
		{
			var rVal:String=null;
			
			if(allowedTypes[type])
				rVal=LOOK_UP[type];
			
			return rVal;
		}
		
		public function enable(type:String):void
		{
			if(LOOK_UP[type]!=null)
				allowedTypes[type]=true;
			else
				throw new Error("For this file type ("+type+") a mime type is not defined");
		}
	}
}