/**
 * @copyright Clock Limited 2010
 * @package engine
 * @subpackage event
 */
package com.gawk.MediaServer.Event {
	import flash.events.Event;
	
	/**
	 * Custom Media Server events
	 * 
	 * @author Elliot Coad (Clock Ltd) {@link mailto:elliot.coad@clock.co.uk}
	 * @copyright Clock Limited 2010
	 */
	public class MediaServerEvent extends Event {
		
		public static const CONNECTING:String = "connecting";
		public static const CONNECTED:String = "connected";
		public static const CONNECTION_ERROR:String = "connectionError";
		public static const PUBLISHING_STARTED:String = "publishingStarted";
		public static const PUBLISHING_WAIT_FOR_BUFFER:String = "publishingWaitForBuffer";
		public static const PUBLISHING_STOPPED:String = "publishingStopped";
		public static const PUBLISHING_COMPLETE:String = "publishingComplete";
		public static const TIME_REMAINING_TICK:String = "timeRemaingTick";
		
		public var data:*;
		
		public function MediaServerEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
	}
}