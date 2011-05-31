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
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	public class VideoTile extends MovieClip {
		protected var parentTile:Tile;
		protected var videoObject:VideoObject;
		
		protected var videoLoader:VideoLoader;
		
		protected var video:*;
		
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
			this.video = new Video();
			this.addChild(this.video);
			
			this.addVideoTileOverlay();
			
			if (this.newlySubmitted) {
				this.addReRecordUI();
				this.videoTileOverlayController.removeUiEventListeners();
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

		protected function addReRecordUI():void {
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
			this.video.width = Tile.tileWidth;
			this.video.height = Tile.tileHeight;
			
			this.parentTile.getEngine().dispatchEvent(new TileEvent(TileEvent.TILE_LOADED));
		}
		
		protected function onReRecordButtonClick(event:MouseEvent):void {
			this.parentTile.createCameraTile(true);
		}
		
		protected function onSaveButtonClick(event:MouseEvent):void {
			this.saveButton.removeEventListener(MouseEvent.CLICK, this.onSaveButtonClick);
			
			this.parentTile.getEngine().saveVideo(this.videoObject.filename);
			this.parentTile.getEngine().addEventListener(EngineEvent.VIDEO_SAVED, onVideoSaved);
		}
		
		protected function onVideoSaved(event:EngineEvent):void {
			this.hideRecordControls();
			
			this.parentTile.getEngine().removeEventListener(EngineEvent.VIDEO_SAVED, onVideoSaved);
			var savedVideo:VideoObject = new VideoObject(event.data.video);
			this.videoObject.secureId = savedVideo.secureId;
			this.videoObject.memberSecureId = savedVideo.memberSecureId;
			this.videoObject.member = savedVideo.member;
			
			this.videoTileOverlayController.updateView();
			this.videoTileOverlayController.addUiEventListeners();
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
	}
}
