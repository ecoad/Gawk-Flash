package com.gawk.Member {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.Member.Event.MemberEvent;
	import com.utils.sha1Encrypt;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	public class Member extends EventDispatcher{
		
		protected var engine:Engine;
		protected var id:int = 0;
		
		public function Member(engine:Engine) {
			this.engine = engine;
			this.addEventListeners();
		}
		
		public function addEventListeners():void {
			ExternalInterface.addCallback("logInFromExternal", this.onLogInFromExternal);
			ExternalInterface.addCallback("logOutFromExternal", this.onLogOutFromExternal);
		}
		
		protected function retrieveLoggedInMember():void {
			this.engine.getLoggedInMember();
			this.engine.addEventListener(EngineEvent.MEMBER_LOADED, this.onMemberLoaded);
		}
		
		protected function onLogInFromExternal():void {
			this.retrieveLoggedInMember();
		}
		
		protected function onLogOutFromExternal():void {
			this.id = 0;
			this.engine.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_LOGGED_OUT));
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Member logged out");
		}
		
		protected function onMemberLoaded(event:EngineEvent):void {
			this.engine.removeEventListener(EngineEvent.MEMBER_LOADED, this.onMemberLoaded);
			var sha1EncryptClass:sha1Encrypt = new sha1Encrypt(true);
			var response:Object = event.data;
			var memberId:int = response.member.id
			
			if (response.key == sha1Encrypt.encrypt(memberId.toString() + "34 sangrita")) {
				this.mapMemberData(response.member);
				this.engine.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_LOGGED_IN));
				this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Member logged in: " + memberId);
			}
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