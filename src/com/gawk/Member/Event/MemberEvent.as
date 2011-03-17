/**
 * @copyright Clock Limited 2010
 * @package engine
 * @subpackage event
 */
package com.gawk.Member.Event {
	import flash.events.Event;
	
	/**
	 * Member Events
	 * 
	 * @author Elliot Coad (Clock Ltd) {@link mailto:elliot.coad@clock.co.uk}
	 * @copyright Clock Limited 2010
	 */
	public class MemberEvent extends Event {
		
		public static const MEMBER_LOGGED_IN:String = "memberLoggedIn";
		public static const MEMBER_LOGGED_OUT:String = "memberLoggedOut";
		
		public var data:*;
		
		public function MemberEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
	}
}