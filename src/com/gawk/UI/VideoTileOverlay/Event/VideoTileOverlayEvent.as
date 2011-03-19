package com.gawk.UI.VideoTileOverlay.Event {
	import flash.events.Event;
	
	public class VideoTileOverlayEvent extends Event {
		
		protected var data:Object;
		
		public function VideoTileOverlayEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}