package com.gawk.UI.TileMemberPanel.Event
{
	import com.gawk.Member.Action.Action;
	
	import flash.events.Event;
	
	public class TileMemberPanelEvent extends Event {
		
		public static const TILE_MEMBER_PANEL_ACTION:String = "tileMemberPanelAction";
		
		public var action:Action;
		
		public function TileMemberPanelEvent(type:String, action:Action = null, bubbles:Boolean = false, cancelable:Boolean = false)	{
			this.action = action;
			super(type, bubbles, cancelable);
		}
	}
}