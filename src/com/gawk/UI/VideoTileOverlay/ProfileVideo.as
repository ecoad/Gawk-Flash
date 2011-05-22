package com.gawk.UI.VideoTileOverlay {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.VideoLoaderEvent;
	import com.gawk.Engine.VideoLoader;
	import com.gawk.Logger.Logger;
	
	import flash.media.Video;
	
	public class ProfileVideo {
		protected var videoTileOverlayController:VideoTileOverlayController;
		protected var videoLocation:String;
		protected var engine:Engine;
		
		protected var videoLoader:VideoLoader;
		protected var video:Video;
		protected var videoInit:Boolean = false;
		
		public function ProfileVideo(videoTileOverlayController:VideoTileOverlayController, engine:Engine, videoLocation:String) {
			this.engine = engine;
			this.videoTileOverlayController = videoTileOverlayController;	
			this.videoLocation = videoLocation;
			
			this.video = new Video();
		}
		
		public function loadVideo():void {
			if (!this.videoInit && (this.videoLocation != "")) {
				this.videoInit = true;
				
				this.videoLoader = new VideoLoader(this.engine);
				this.video.attachNetStream(this.videoLoader.getNetStream());
				this.videoLoader.addEventListener(VideoLoaderEvent.VIDEO_LOADED, this.onVideoLoaded); 
				
				var fullVideoLocation:String = this.engine.getBinaryLocation() + this.videoLocation; 
				
				this.videoLoader.getNetStream().play(fullVideoLocation);
				this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Loading profie video: " + fullVideoLocation);
			}
		}
		
		protected function onVideoLoaded(event:VideoLoaderEvent):void {
			this.video.width = this.videoTileOverlayController.getPanel().profile.video.width;
			this.video.height = this.videoTileOverlayController.getPanel().profile.video.height;
			this.video.y = this.videoTileOverlayController.getPanel().profile.video.y;
		}
		
		public function getVideo():Video {
			return this.video;
		}
	}
}