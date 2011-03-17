package com.gawk.Tile.Event
{
	import flash.events.Event;
	
	public class TileEvent extends Event {
		
		public static const TILE_LOADED:String = "tileLoaded";
		public static const VIDEO_LOADED:String = "videoLoaded";
		public static const CAMERA_ADDED:String = "cameraAdded";
		public static const CAMERA_CANCELLED:String = "cameraCancelled";
		
		public var data:*;
		
		public function TileEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.data = data;
			super(type, bubbles, cancelable);
		}

	}
}