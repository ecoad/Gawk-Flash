package com.gawk.Member {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.Member.Event.MemberEvent;
	import com.utils.JSON;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	public class Member extends EventDispatcher{
		
		protected var engine:Engine;
		protected var id:int = 0;
		protected var memberData:Object = {
			alias: "",
			emailAddress: "",
			facebookId: null,
			firstName: "",
			lastName: "",
			secureId: "",
			token: ""
		}
		
		public function Member(engine:Engine) {
			this.engine = engine;
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Member object init");
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
			this.memberData.secureId = "";
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
			this.memberData = event.data.member;
			
			this.engine.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_LOGGED_IN));
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Member logged in: " + JSON.serialize(event.data.member));
		}
		
		protected function mapMemberData(memberData:Object):void {
			this.setId(memberData.id);
		}
		
		public function getId():int {
			return this.id;
		}
		
		public function setId(id:*):void {
			this.id = parseInt(id);
		}
	}
}