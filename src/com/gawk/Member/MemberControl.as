package com.gawk.Member {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.Member.Event.MemberEvent;
	import com.gawk.Member.VideoAction.MemberVideoRatingAction;
	import com.gawk.URLLoader.CustomURLLoader;
	import com.gawk.Video.VideoObject;
	import com.utils.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class MemberControl extends EventDispatcher{
		
		protected var engine:Engine;
		protected var memberData:Member;
		protected var loggedIn:Boolean = false;
		
		public function MemberControl(engine:Engine) {
			this.engine = engine;
			
			this.memberData = new Member();
			
			this.addEventListeners();
		}
		
		public function addEventListeners():void {
			ExternalInterface.addCallback("logInFromExternal", this.onLogInFromExternal);
			ExternalInterface.addCallback("logOutFromExternal", this.onLogOutFromExternal);
			
			this.addEventListener(MemberEvent.MEMBER_VIDEO_ADD_RATING_REQUEST, onVideoAddRatingRequest);
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
			this.loggedIn = true;
			this.engine.removeEventListener(EngineEvent.MEMBER_LOADED, this.onMemberLoaded);
			this.memberData = new Member(event.data.member);
			
			this.engine.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_LOGGED_IN));
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Member logged in: " + JSON.serialize(event.data.member));
		}
		
		protected function onVideoAddRatingRequest(event:MemberEvent):void {
			this.addMemberVideoRating(event.data);
		}
		
		public function addMemberVideoRating(action:MemberVideoRatingAction):void {
			if (!this.isLoggedIn()) {
				this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Not logged in");
				this.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, {
					success: false,
					errors: ["Must be logged in"]
				}));
				this.showRequireLoginFromExternal();
				return;
			}
			
			var positiveRating:String = action.isPositiveRating() ? "true" : "false";
			
			var variables:URLVariables = new URLVariables();
			variables.Action = "MemberRating.AddRating";
			variables.VideoSecureId = action.getVideoSecureId();
			variables.PositiveRating = positiveRating;
			variables.Token = this.engine.getMemberControl().getMemberData().token;
			
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, 
					"Adding member rating: " + action.getVideoSecureId() + " positive: " + positiveRating);
			
			var urlLoader:CustomURLLoader = new CustomURLLoader(this.engine.getApiLocation());
			urlLoader.addEventListener(Event.COMPLETE, this.onAddMemberVideoRatingResponse);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.engine.onIOError);
			urlLoader.loadRequest(URLRequestMethod.POST, variables); 
		}
		
		protected function onAddMemberVideoRatingResponse(event:Event):void {
			try {
				var response:Object = JSON.deserialize(event.target.data);
			} catch (error:Error) {
				this.engine.logger.addLog(Logger.LOG_ERROR, "Could not deserialize response"); 
			}
				
			if (response.success) {
				this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Rating added");
			} else {
				this.engine.logger.addLog(Logger.LOG_ERROR, "Rating not added");
				for each (var error:String in response.errors) {
					this.engine.logger.addLog(Logger.LOG_ERROR, error);
				}
			}
			this.dispatchEvent(new MemberEvent(MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, response));
		}
		
		public function getMemberData():Member {
			return this.memberData;
		}
		
		public function isLoggedIn():Boolean {
			return this.loggedIn;
		}
		
		public function showRequireLoginFromExternal():void {
			ExternalInterface.call("$(document).trigger", "GawkUILoginOverlayShow");
		}
	}
}