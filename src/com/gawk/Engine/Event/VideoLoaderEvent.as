/**
 * @copyright Clock Limited 2010
 * @package engine
 * @subpackage event
 */
package com.gawk.Engine.Event {
	import flash.events.Event;
	
	/**
	 * VideoLoader Events
	 * 
	 * @author Elliot Coad (Clock Ltd) {@link mailto:elliot.coad@clock.co.uk}
	 * @copyright Clock Limited 2010
	 */
	public class VideoLoaderEvent extends Event {
		
		public static const VIDEO_LOADED:String = "videoLoaded";
		
		public var data:*;
		
		public function VideoLoaderEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
	}
}