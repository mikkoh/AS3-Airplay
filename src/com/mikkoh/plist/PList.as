package com.mikkoh.plist
{
	import flash.xml.XMLNode;

	public dynamic class PList
	{
		private var _length:int;
		
		public function PList(xml:String)
		{
			var plist:XMLList=new XML(xml).child(0);
			
			_length=plist.length();
			
			var idx:int=0;
			
			for each (var node:XML in plist) 
			{
				this[idx]=doParse(node);
				
				idx++;
			}
		}
		
		public function get length():int
		{
			return _length;
		}
		
		private function doParse(node:XML):Object
		{
			var rVal:Object;
			
			switch(node.name().toString())
			{
				case "dict":
					rVal=parseDict(node);
				break;
				
				case "string":
					rVal=parseString(node);
				break;
				
				case "true":
				case "false":
					rVal=parseBool(node);
				break;
				
				case "real":
					rVal=parseReal(node);
				break;
				
				case "integer":
					rVal=parseIntiger(node);
				break;
				
				case "date":
					rVal=parseDate(node);
				break;
				
				case "data":
					rVal=parseData(node);
				break;
				
				case "array":
					rVal=parseArray(node);
				break;
				
				default:
					throw new Error("UNDEFINED TYPE "+node.name().toString());
				break;
			}
			
			return rVal;
		}
		
		private function parseDict(node:XML):Object
		{
			var rVal:Object={};
			
			var children:XMLList=node.children();
			var key:String;
			
			for each (var cNode:XML in node.children()) 
			{
				if(cNode.name()=="key")
					key=cNode.toString();
				else
					rVal[key]=doParse(cNode);
			}
			
			return rVal;
		}
		
		private function parseString(node:XML):String
		{
			return node;
		}
		
		private function parseBool(node:XML):Boolean
		{
			return node.name()=="true";
		}
		
		private function parseIntiger(node:XML):int
		{
			return parseInt(node.toString());
		}
		
		private function parseReal(node:XML):Number
		{
			return Number(node.toString());
		}
		
		private function parseDate(node:XML):Date
		{
			return null;
		}
		
		private function parseData(node:XML):String
		{
			return null;
		}
		
		private function parseArray(node:XML):Array
		{
			var rVal:Array=[];
			var idx:int=0;
			var numNodes:int=node.length();
			var children:XMLList=node.children();
			
			for each (var cNode:XML in node.children()) 
			{
				rVal[idx]=doParse(cNode);
				
				idx++;
			}
			
			return rVal;
		}
	}
}