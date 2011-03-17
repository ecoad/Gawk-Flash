package com.gawk.Member {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.Member.Event.MemberEvent;
	import com.utils.JSON;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	public class MemberControl extends EventDispatcher{
		
		protected var engine:Engine;
		protected var memberData:Member;
		
		public function MemberControl(engine:Engine) {
			this.engine = engine;
			
			this.memberData = new Member();
			
			this.addEventListeners();
		}
		
		public function addEventListeners():void {
			ExternalInterface.addCallback("logInFromExternal", this.onLogInFromExternal);
			ExternalInterface.addCallback("logOutFromExternal", this.onLogOutFromExternal);
		}
		
		protected function onLogInFromExternal():void {
			this.retrieveLoggedInMember();
		}
		
		protected function onLogOutFromExternal():void {
			this.memberData = new Member();
			this.engine.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_LOGGED_OUT));
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Member logged out");
		}
		
		public function retrieveLoggedInMember():void {
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Retrieve Logged in member initiated");
			this.engine.getLoggedInMember();
			this.engine.addEventListener(EngineEvent.MEMBER_LOADED, this.onMemberLoaded);
		}
		
		protected function onMemberLoaded(event:EngineEvent):void {
			this.engine.removeEventListener(EngineEvent.MEMBER_LOADED, this.onMemberLoaded);
			this.memberData = new Member(event.data.member);
			
			this.engine.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_LOGGED_IN));
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Member logged in: " + JSON.serialize(event.data.member));
		}
		
		public function getMemberData():Member {
			return this.memberData;
		}
	}
}