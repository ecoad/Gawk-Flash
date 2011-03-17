/**
 * @copyright Clock Limited 2010
 * @package Logger
 * @subpackage event
 */
package com.gawk.Logger.Event {
	import flash.events.Event;
	
	/**
	 * Custom Logger events
	 * 
	 * @author Elliot Coad (Clock Ltd) {@link mailto:elliot.coad@clock.co.uk}
	 * @copyright Clock Limited 2010
	 */
	public class LoggerEvent extends Event {
		
		public static const LOG_ADDED:String = "logAdded";
		
		public var data:*;
		
		public function LoggerEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
	}
}