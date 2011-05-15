package com.gawk.Tile {
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Engine.Event.VideoLoaderEvent;
	import com.gawk.Engine.VideoLoader;
	import com.gawk.Logger.Logger;
	import com.gawk.Tile.Event.TileEvent;
	import com.gawk.UI.TileButton;
	import com.gawk.UI.VideoTileOverlay.VideoTileOverlayController;
	import com.gawk.Video.VideoObject;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	
	public class VideoTile extends MovieClip {
		protected var parentTile:Tile;
		protected var videoObject:VideoObject;
		
		protected var videoLoader:VideoLoader;
		
		protected var video:*;
		//protected var stageVideo:StageVideo;
		
		protected var newlySubmitted:Boolean;
		
		protected var reRecordButton:TileButton;
		protected var saveButton:TileButton;
		
		protected var videoTileOverlayController:VideoTileOverlayController;
		
		public function VideoTile(parentTile:Tile, videoObject:VideoObject, newlySubmitted:Boolean = false) {
			this.parentTile = parentTile;
			this.setVideoObject(videoObject);
			this.newlySubmitted = newlySubmitted;
			
			this.videoLoader = new VideoLoader(this.parentTile.getEngine());
		}
		
		public function loadVideo(stageIndex:int = -1):void {
			/*
			*/
			try {
				this.video = stage.stageVideos[stageIndex];
				this.video.addEventListener(StageVideoEvent.RENDER_STATE, onStageVideoStateChange);
				this.parentTile.getEngine().logger.addLog(Logger.LOG_ACTIVITY, "using StageVideo!");
			} catch (error:Error) {
				this.parentTile.getEngine().logger.addLog(Logger.LOG_ACTIVITY, "using Video");
				this.video = new Video();
				this.addChild(this.video);
			}
			
			if (this.getParentTile().getEngine().getMemberControl().isLoggedIn()) {
				this.addVideoTileOverlay();
			}
			
			if (this.newlySubmitted) {
				this.addRecordUI();
			}
			
			this.playVideo();
		}
		
		protected function playVideo():void {
			this.video.attachNetStream(this.videoLoader.getNetStream());
			this.videoLoader.addEventListener(VideoLoaderEvent.VIDEO_LOADED, this.onVideoLoaded); 
			
			var fullVideoLocation:String = this.parentTile.getEngine().getBinaryLocation() + this.videoObject.filename; 
			
			this.videoLoader.getNetStream().play(fullVideoLocation);
			this.parentTile.getEngine().logger.addLog(Logger.LOG_ACTIVITY, "Loading video: " + fullVideoLocation);
		}
		
		public function pauseVideo():void {
			if (this.videoLoader.getNetStream() !== null) {
				this.videoLoader.getNetStream().pause();
			}
		}
		
		public function resumeVideo():void {
			if (this.videoLoader.getNetStream() !== null) {
				this.videoLoader.getNetStream().resume();
			}
		}

		protected function addRecordUI():void {
			if (this.reRecordButton === null) {
				this.addReRecordButton();
				this.addSaveButton();
			} else {
				this.showRecordControls();
			}
		}
		
		protected function showRecordControls():void {
			this.reRecordButton.visible = true;
			this.saveButton.visible = true;
		}
		
		protected function hideRecordControls():void {
			this.reRecordButton.visible = false;
			this.saveButton.visible = false;
		}
		
		protected function addVideoTileOverlay():void {
			this.videoTileOverlayController = new VideoTileOverlayController(this, this.parentTile.getEngine());
			this.addChild(this.videoTileOverlayController.getPanel());
		}
		
		protected function addReRecordButton():void {
			this.reRecordButton = new TileButton(90, 20, "Re-Record", -1);
			this.reRecordButton.y = Tile.getHeight() + 5;
			this.reRecordButton.x = 5;
			
			this.reRecordButton.addEventListener(MouseEvent.CLICK, this.onReRecordButtonClick);
			
			this.addChild(this.reRecordButton);
		}
		
		protected function addSaveButton():void {
			this.saveButton = new TileButton(90, 20, "Save", -1);
			this.saveButton.y = this.reRecordButton.y + this.reRecordButton.height + 2;
			this.saveButton.x = 5;
			
			this.saveButton.addEventListener(MouseEvent.CLICK, this.onSaveButtonClick);
			
			this.addChild(this.saveButton);
		}
		
		protected function onVideoLoaded(event:VideoLoaderEvent):void {
			if (this.video is StageVideo) {
				//Stage video resizes onStageVideoStateChange
			} else {
				this.video.width = Tile.tileWidth;
				this.video.height = Tile.tileHeight;
			}
			
			this.parentTile.getEngine().dispatchEvent(new TileEvent(TileEvent.TILE_LOADED));
		}
		
		protected function onReRecordButtonClick(event:MouseEvent):void {
			this.parentTile.createCameraTile(true);
		}
		
		protected function onSaveButtonClick(event:MouseEvent):void {
			this.parentTile.getEngine().saveVideo(this.videoObject.filename);
			this.parentTile.getEngine().addEventListener(EngineEvent.VIDEO_SAVED, onVideoSaved);
			this.hideRecordControls();
		}
		
		protected function onVideoSaved(event:EngineEvent):void {
			this.parentTile.getEngine().removeEventListener(EngineEvent.VIDEO_SAVED, onVideoSaved);
			this.videoObject.secureId = event.data.videoId;
			this.videoObject.memberSecureId = event.data.memberSecureId;
		}
		
		public function setVideoObject(videoObject:VideoObject):void {
			this.videoObject = videoObject;
		}
		
		public function getVideoObject():VideoObject {
			return this.videoObject;
		}
		
		protected function onMouseRollOver(event:MouseEvent):void {
			this.videoTileOverlayController.getPanel().visible = true;
		}
		
		protected function onMouseRollOut(event:MouseEvent):void {
			this.videoTileOverlayController.getPanel().visible = false;
		}
		
		public function getParentTile():Tile {
			return this.parentTile;
		}
		
		protected function onStageVideoStateChange(event:StageVideoEvent):void {
			var rect:Rectangle = new Rectangle(this.parentTile.movieClip.x ,this.parentTile.movieClip.y ,320,230);
			this.video.viewPort = rect; 
		}
	}
}