package {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.UI.Main.*;
	import com.gawk.Wall.Wall;
	
	import flash.display.Sprite;
	//import flash.events.StageVideoAvailabilityEvent;
	//import flash.media.StageVideo;
	//import flash.media.StageVideoAvailability;
	import flash.external.ExternalInterface;
	import flash.system.Security;

	[SWF(backgroundColor="#111111", frameRate="15", width="1050", height="655")] //main
	//[SWF(backgroundColor="#111111", frameRate="15", width="175", height="131")] //profile gawk
	//[SWF(backgroundColor="#111111", frameRate="15", width="1050", height="131")] //recent profile
//	[SWF(backgroundColor="#111111", frameRate="15", width="1920", height="1150")] //booth
//	[SWF(backgroundColor="#111111", frameRate="15", width="1920", height="920")] //booth short
//	[SWF(backgroundColor="#111111", frameRate="15", width="1024", height="768")] //main
	public class GawkFlash extends Sprite {
		protected var wall:Wall;
		protected var engine:Engine;
		
		protected var wallId:String = "";
		protected var apiLocation:String = "";
		protected var profileSecureId:String = "";
		protected var loggedInAtInit:Boolean = false;
		protected var useStageVideo:Boolean = false;
		protected var useDebugOverlay:Boolean = false;
		
		
		public function GawkFlash() {
			Security.allowDomain("staging.gawkwall.com");
			
			this.assignStartupSettings();
		
			this.engine = new Engine(this.apiLocation, this.wallId, this.loggedInAtInit, this.profileSecureId, this.useStageVideo, this.useDebugOverlay);
			this.engine.addEventListener(EngineEvent.WALL_CONFIG_LOADED, this.onWallConfigLoaded);
			
		}
		
		protected function assignStartupSettings():void {
			this.apiLocation = this.loaderInfo.parameters.apiLocation;
			this.wallId = this.loaderInfo.parameters.wallId;
			this.loggedInAtInit = this.loaderInfo.parameters.loggedInAtInit;
			this.profileSecureId = this.loaderInfo.parameters.profileSecureId;

			if (this.loaderInfo.parameters.useStageVideo) {
				this.useStageVideo = this.loaderInfo.parameters.useStageVideo == "true"? true : false;
			}

			if (this.loaderInfo.parameters.useDebugOverlay) {
				this.useDebugOverlay = this.loaderInfo.parameters.useDebugOverlay == "true"? true : false;
			}
			
			if (!this.apiLocation) {
				throw new Error("Must provide API Location");
			} 
		}
		
		protected function onWallConfigLoaded(event:EngineEvent):void {
			this.addWall();
			ExternalInterface.call("$(document).trigger", "GawkUIFlashLoaded");
		}
		
		protected function addWall():void {
			this.wall = new Wall(engine);
			this.addChild(this.wall);
			
			/*
			try {
				var stageVideos:Vector.<StageVideo> = this.stage.stageVideos;
				this.engine.logger.addLog(Logger.LOG_ACTIVITY, "# of stageVideos: " + this.stage.stageVideos.length);
			} catch (error:Error) {
			}
			*/
		}
	}
}