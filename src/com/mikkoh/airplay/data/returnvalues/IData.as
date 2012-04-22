package com.mikkoh.airplay.data.returnvalues
{
	public interface IData
	{
		function get id():String;
		function get position():Number;
		function get duration():Number;
		function parse(data:String):void;
	}
}