package com.gawk.Engine {
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.MediaServer.MediaServer;
	import com.gawk.Member.MemberControl;
	import com.gawk.URLLoader.CustomURLLoader;
	import com.gawk.Video.VideoObject;
	import com.utils.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class Engine	extends EventDispatcher {
		
		public var logger:Logger;
		protected var memberControl:MemberControl;
		protected var mediaServer:MediaServer;
		
		protected var config:Object;
		
		protected var wallSecureId:String;
		protected var mediaServerLocation:String;
		protected var serviceLocation:String;
		protected var binaryLocation:String;
		protected var randomWallId:String;
		
		protected var videos:Array = new Array();
		
		protected var testSettings:Boolean;
		
		protected var retrievingLoggedInMember:Boolean = false;
		
		public function Engine(serviceLocation:String, wallSecureId:String, loggedInAtInit:Boolean, testSettings:Boolean) {
			this.logger = new Logger(this);
			this.mediaServer = new MediaServer(this);
			this.memberControl = new MemberControl(this);
			
			this.serviceLocation = serviceLocation;
			this.wallSecureId = wallSecureId;
			this.testSettings = testSettings;
			
			if (loggedInAtInit) {
				this.addEventListener(EngineEvent.WALL_CONFIG_LOADED, function (event:EngineEvent):void {
					this.memberControl.retrieveLoggedInMember();
				});
			}
			
			this.retrieveWallConfig();
		}
		
		protected function retrieveWallConfig():void {
			this.logger.addLog(Logger.LOG_ACTIVITY, "Retrieving Wall Config from " + this.serviceLocation);
			var variables:URLVariables = new URLVariables();
			if (this.isWallSecureIdSet()) {
				variables.WallSecureId = this.getWallSecureId();
			} else {
				variables.Action = "Flash.InitApplication";
			}
			
			var urlLoader:CustomURLLoader = new CustomURLLoader(this.serviceLocation);
			urlLoader.addEventListener(Event.COMPLETE, this.onWallConfigLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			urlLoader.loadRequest(URLRequestMethod.GET, variables); 
		}
		
		protected function onWallConfigLoaded(event:Event):void {
			try {
				this.config = JSON.deserialize(event.target.data);
			} catch (error:Error) {
				this.logger.addLog(Logger.LOG_ERROR, "Could not deserialize wall config: " + event.target.data);
				return;
			}
			if (!this.config.success) {
				this.logger.addLog(Logger.LOG_ERROR, "Wall config failure, errors: " + event.target.data);
				return;
			}
			
			this.mediaServerLocation = this.config.mediaServerLocation;
			this.binaryLocation = this.config.binaryLocation
			if (!this.mediaServerLocation || !this.binaryLocation) {
				throw new Error("Must provide mediaServerLocation and binaryLocation: " + event.target.data);
			}
			this.videos = this.config.videos;
			
			this.logger.addLog(Logger.LOG_ACTIVITY, "Wall Config loaded. Video count: " + this.videos.length);
			this.logger.addLog(Logger.LOG_ERROR, "TODO: Connect to Media Server on demand"); //TODO:
			this.mediaServer.connectToMediaServer();
			this.dispatchEvent(new EngineEvent(EngineEvent.WALL_CONFIG_LOADED));
		}
		
		public function saveVideo(filename:String):void {
			var video:VideoObject = new VideoObject();
			video.filename = filename;
			video.wallSecureId = this.getWallSecureId();
			video.uploadSource = "flash";
			video.hash = "unknown";
			video.memberSecureId = this.getMemberControl().getMemberData().secureId;
			
			var variables:URLVariables = new URLVariables();
			variables.Action = "Video.Save";
			variables.Video = JSON.serialize(video.toObject());
			variables.Token = this.memberControl.getMemberData().token;
			
			this.logger.addLog(Logger.LOG_ACTIVITY, "Saving video: " + variables.Video);
			
			var urlLoader:CustomURLLoader = new CustomURLLoader(this.serviceLocation);
			urlLoader.addEventListener(Event.COMPLETE, this.onSaveVideoResponse);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			urlLoader.loadRequest(URLRequestMethod.POST, variables); 
		}
		
		protected function onSaveVideoResponse(event:Event):void {
			try {
				var response:Object = JSON.deserialize(event.target.data);
				
				if (response.success) {
					this.dispatchEvent(new EngineEvent(EngineEvent.VIDEO_SAVED, response));
					this.logger.addLog(Logger.LOG_ACTIVITY, "Video saved");
				} else {
					this.logger.addLog(Logger.LOG_ERROR, "Video not saved");
					for each (var error:String in response.errors) {
						this.logger.addLog(Logger.LOG_ERROR, error);
					}
				}
			} catch (error:Error) {
				this.logger.addLog(Logger.LOG_ERROR, "Could not deserialize Video response"); 
			}
		}
		
		/*
		public function onMemberPanelAction(event:VideoTileOverlayEvent):void {
			var action:Action = event.action;
			
			var variables:URLVariables = new URLVariables();
			variables.Action = "Member.SendMemberPanelAction";
			variables.MemberAction = action.getAction();
			variables.VideoId = action.getId();
			variables.MemberId = action.getMemberId();
			
			var urlLoader:CustomURLLoader = new CustomURLLoader(this.serviceLocation);
			urlLoader.addEventListener(Event.COMPLETE, this.onSendMemberPanelActionResponse);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			urlLoader.loadRequest(URLRequestMethod.POST, variables);
			
			this.logger.addLog(Logger.LOG_ACTIVITY, "Requesting Member Panel Action: " + action.getAction());
		}
		
		protected function onSendMemberPanelActionResponse(event:Event):void {
			try {
				var response:Object = JSON.deserialize(event.target.data);
				
				if (response.success) {
					this.logger.addLog(Logger.LOG_ACTIVITY, "Member Panel Action success");
				} else {
					this.logger.addLog(Logger.LOG_ERROR, "Member Panel Action failed");
				}
			} catch (error:Error) {
				this.logger.addLog(Logger.LOG_ERROR, "Member Panel Action response: " + event.target.data); 
			}
		}
		*/
		
		public function getLoggedInMember():void {
			if (!retrievingLoggedInMember) {
				this.logger.addLog(Logger.LOG_ACTIVITY, "Retrieving logged in Member");
				retrievingLoggedInMember = true;
				var variables:URLVariables = new URLVariables();
				variables.Action = "Member.GetLoggedInMember";
				
				if (this.isTestSettings()) {
					variables.Token = "test1234";
				}
				
				var urlLoader:CustomURLLoader = new CustomURLLoader(this.serviceLocation);
				urlLoader.addEventListener(Event.COMPLETE, this.onLoggedInMemberResponse);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
				urlLoader.loadRequest(URLRequestMethod.GET, variables);
			}
		}
		
		protected function onLoggedInMemberResponse(event:Event):void {
			retrievingLoggedInMember = false;
			try {
				var response:Object = JSON.deserialize(event.target.data);
				
				if (response.success) {
					this.dispatchEvent(new EngineEvent(EngineEvent.MEMBER_LOADED, response));
					this.logger.addLog(Logger.LOG_ACTIVITY, "Member loaded success");
				} else {
					this.logger.addLog(Logger.LOG_ERROR, "Member loaded failed: " + event.target.data);
				}
			} catch (error:Error) {
				this.logger.addLog(Logger.LOG_ERROR, "Member Loaded response: " + event.target.data); 
			}			
		}
		
		protected function onIOError(event:IOErrorEvent):void {
			this.logger.addLog(Logger.LOG_ERROR, event.text);
		}
		
		public function getMediaServerLocation():String {
			return this.mediaServerLocation;
		}
		
		public function getBinaryLocation():String {
			return this.binaryLocation;
		}
		
		public function getMediaServer():MediaServer {
			return this.mediaServer;
		}
		
		public function getVideos():Array {
			return this.videos;
		}
		
		public function getWallSecureId():String {
			return this.wallSecureId;
		}
		
		public function isTestSettings():Boolean {
			return this.testSettings;
		}
		
		public function getUniqueFileName():String {
			var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345679";
			var num:int = chars.length;

			var fileName:String = "";

			for (var i:int = 0; i < 10; i++) {
				fileName += chars.substr(Math.floor(Math.random() * num), 1);
			}
			
			return "gk-" + fileName;
		}
		
		protected function isWallSecureIdSet():Boolean {
			return (this.getWallSecureId() != null) && (this.getWallSecureId() != ""); 
		}
		
		public function getMemberControl():MemberControl {
			return this.memberControl;
		}
	}
}