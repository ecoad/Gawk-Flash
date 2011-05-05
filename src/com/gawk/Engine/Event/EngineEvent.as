/**
 * @copyright Clock Limited 2010
 * @package engine
 * @subpackage event
 */
package com.gawk.Engine.Event {
	import flash.events.Event;
	
	/**
	 * Custom Engine events
	 * 
	 * @author Elliot Coad (Clock Ltd) {@link mailto:elliot.coad@clock.co.uk}
	 * @copyright Clock Limited 2010
	 */
	public class EngineEvent extends Event {
		
		public static const WALL_CONFIG_LOADED:String = "wallConfigLoaded";
		public static const WALL_CONFIG_UPDATE_LOADED:String = "wallConfigUpdateLoaded";
		public static const MEMBER_LOADED:String = "memberLoaded";
		public static const VIDEO_SAVED:String = "videoSaved";
		
		public var data:*;
		
		public function EngineEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
	}
}