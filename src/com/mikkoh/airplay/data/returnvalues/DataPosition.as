package com.mikkoh.airplay.data.returnvalues
{
	public class DataPosition
	{
		public static const ID:String="DataPosition";
		
		private var _position:Number;
		private var _duration:Number;
		
		public function DataPosition(data:String=null)
		{
			if(data!=null)
				parse(data);
		}
		
		public function get id():String
		{
			return ID;
		}
		
		public function get position():Number
		{
			return _position;
		}
		
		public function get duration():Number
		{
			return _duration;
		}

		public function parse(data:String):void
		{
			var dataLines:Array=data.split("\n");
			
			for(var i:int=0;i<dataLines.length;i++) 
			{
				var curLine:String=String(dataLines[i]);
				
				var idxSplitter:int=curLine.indexOf(": ");
				
				var key:String=curLine.substring(0, idxSplitter);
				
				if(key!="")
				{
					if(key=="duration")
					{
						_duration=Number(curLine.substr(idxSplitter+2));	
					}
					else if(key=="position")
					{
						_position=Number(curLine.substr(idxSplitter+2));
					}
					else
					{
						//throw new Error("Undefined key: ", key);
						trace("Undefined key: ", key);
					}
				}
			}
			
		}
	}
}