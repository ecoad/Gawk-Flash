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
	import flash.events.TimerEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	public class Engine	extends EventDispatcher {
		
		public var logger:Logger;
		protected var memberControl:MemberControl;
		protected var mediaServer:MediaServer;
		
		protected var config:Object;
		
		protected var wallSecureId:String;
		protected var profileSecureId:String;
		protected var mediaServerLocation:String;
		protected var apiLocation:String;
		protected var binaryLocation:String;
		protected var randomWallId:String;
		protected var useStageVideo:Boolean;
		protected var useDebugOverlay:Boolean;
		
		protected var videos:Array = new Array();
		protected var previousRunTime:int = 0;
		
		protected var testSettings:Boolean;
		
		protected var retrievingLoggedInMember:Boolean = false;
		protected var wallConfigUpdateTimer:Timer;
		
		public function Engine(apiLocation:String, wallSecureId:String, loggedInAtInit:Boolean, profileSecureId:String, useDebugOverlay:Boolean) {
			this.logger = new Logger(this);
			this.mediaServer = new MediaServer(this);
			this.memberControl = new MemberControl(this);
			
			this.useDebugOverlay = useDebugOverlay;
			
			this.wallConfigUpdateTimer = new Timer(10000);
			this.wallConfigUpdateTimer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void {
				retrieveWallConfig();
			});
			
			this.apiLocation = apiLocation;
			this.wallSecureId = wallSecureId;
			this.profileSecureId = profileSecureId;
			this.testSettings = testSettings;
			
			if (loggedInAtInit) {
				this.addEventListener(EngineEvent.WALL_CONFIG_LOADED, function (event:EngineEvent):void {
					this.memberControl.retrieveLoggedInMember();
				});
			}
			
			this.retrieveWallConfig();
		}
		
		protected function retrieveWallConfig():void {
			if (this.config === null) {
				this.logger.addLog(Logger.LOG_ACTIVITY, "Retrieving Wall Config from " + this.apiLocation);
			}
			var variables:URLVariables = new URLVariables();
			if (this.isWallSecureIdSet()) {
				variables.WallSecureId = this.getWallSecureId();
			}
			
			if (this.isProfileSecureIdSet()) {
				variables.ProfileSecureId = this.getProfileSecureId();
			}
			
			variables.Action = "Flash.InitApplication";
			if (this.previousRunTime !== 0) {
				variables.PreviousRunTime = this.previousRunTime;
			}
			
			var urlLoader:CustomURLLoader = new CustomURLLoader(this.apiLocation);
			urlLoader.addEventListener(Event.COMPLETE, this.onWallConfigLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			urlLoader.loadRequest(URLRequestMethod.GET, variables); 
		}
		
		protected function onWallConfigLoaded(event:Event):void {
			var configLoadedPreviously:Boolean = this.config !== null;  
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
			this.previousRunTime = this.config.previousRunTime;
			
			if (this.config.videos.length > 0) {
				this.setVideos(this.config.videos);
			}
			
			if (!configLoadedPreviously) {
				//TODO: Connect to Media Server on demand
				this.logger.addLog(Logger.LOG_ACTIVITY, "Wall Config loaded. Video count: " + this.videos.length);
				this.dispatchEvent(new EngineEvent(EngineEvent.WALL_CONFIG_LOADED));
			} else {
				if (this.config.videos.length > 0) {
					this.logger.addLog(Logger.LOG_ACTIVITY, "Videos changed. New videos: " + this.config.videos.length);
					this.dispatchEvent(new EngineEvent(EngineEvent.WALL_CONFIG_UPDATE_LOADED));
				}
			}
			
			this.wallConfigUpdateTimer.stop();
			this.wallConfigUpdateTimer.delay = this.config.updatePollLength;
			this.wallConfigUpdateTimer.start();
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
			
			var urlLoader:CustomURLLoader = new CustomURLLoader(this.apiLocation);
			urlLoader.addEventListener(Event.COMPLETE, this.onSaveVideoResponse);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOError);
			urlLoader.loadRequest(URLRequestMethod.POST, variables); 
		}
		
		protected function onSaveVideoResponse(event:Event):void {
			try {
				var response:Object = JSON.deserialize(event.target.data);
				
				if (response.success) {
					this.dispatchEvent(new EngineEvent(EngineEvent.VIDEO_SAVED, response));
					this.videos.push(new VideoObject(response.video));
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
		
		public function getLoggedInMember():void {
			if (!retrievingLoggedInMember) {
				this.logger.addLog(Logger.LOG_ACTIVITY, "Retrieving logged in Member");
				retrievingLoggedInMember = true;
				var variables:URLVariables = new URLVariables();
				variables.Action = "Member.GetLoggedInMember";
				
				var urlLoader:CustomURLLoader = new CustomURLLoader(this.apiLocation);
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
		
		public function onIOError(event:IOErrorEvent):void {
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
		
		public function getUniqueFileName():String {
			var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345679";
			var num:int = chars.length;

			var fileName:String = "";

			for (var i:int = 0; i < 10; i++) {
				fileName += chars.substr(Math.floor(Math.random() * num), 1);
			}
			
			return "gk-" + fileName;
		}
		
		public function getWallSecureId():String {
			return this.wallSecureId;
		}
		
		protected function isWallSecureIdSet():Boolean {
			return (this.getWallSecureId() != null) && (this.getWallSecureId() != ""); 
		}
		
		public function getProfileSecureId():String {
			return this.profileSecureId;
		}
		
		protected function isProfileSecureIdSet():Boolean {
			return this.getProfileSecureId() != ""; 
		}
		
		public function getMemberControl():MemberControl {
			return this.memberControl;
		}
	
		protected function setVideos(newVideos:Array):void {
			newVideos.every(function(videoData:Object, index:int, array:Array):Boolean {
				var videoObject:VideoObject = new VideoObject(videoData);
				if (!isVideoIdAlreadyInCollection(videoObject.secureId)) {
					videos.push(videoObject);
				}
				return true;
			});
			
			if (this.videos.length > 30) {
				this.videos = this.videos.slice(this.videos.length - 30);
			}
		}
		
		protected function getVideoBySecureId(secureId:String):VideoObject {
			var videosLength:int = this.videos.length;
			for (var i:int = 0; i < videosLength; i++) {
				var videoObject:VideoObject = this.videos[i];
				if (videoObject.secureId == secureId) {
					return videoObject;
				}
			}
			
			return null;
		}
		
		protected function isVideoIdAlreadyInCollection(secureId:String):Boolean {
			var videoObject:VideoObject = this.getVideoBySecureId(secureId);
			if (videoObject) {
				this.logger.addLog(Logger.LOG_ACTIVITY, "Video: " + secureId + " duplicate");
				return true;
			}
			
			return false;
		}
		
		public function allowStageVideo():Boolean {
			return this.useStageVideo;
		}
		
		public function allowDebugOverlay():Boolean {
			return this.useDebugOverlay;
		}
		
		public function getApiLocation():String {
			return this.apiLocation;
		}
		
		public function setLocalVideoRating(videoSecureId:String, positiveRating:Boolean):void {
			var videoObject:VideoObject = this.getVideoBySecureId(videoSecureId);
			if (videoObject) {
				videoObject.member.videoPositiveRated = positiveRating;
			}
		}
	}
}
