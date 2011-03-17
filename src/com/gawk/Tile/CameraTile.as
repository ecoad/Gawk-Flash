package com.gawk.Tile {
	import com.gawk.MediaServer.Event.MediaServerEvent;
	import com.gawk.Tile.Event.TileEvent;
	import com.gawk.UI.TileButton;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Video;
	
	public class CameraTile extends MovieClip {
		protected var parentTile:Tile;
		
		protected var video:Video;
		protected var camera:Camera;
		
		protected var recordButton:TileButton;
		protected var cancelButton:TileButton;
		
		public function CameraTile() {
		}
		
		public function setParentTile(parentTile:Tile):void {
			this.parentTile = parentTile;
			if (this.camera == null) {
				this.loadCamera();
				this.removePublishingEventListeners();
				
				this.parentTile.getEngine().addEventListener(MediaServerEvent.PUBLISHING_COMPLETE, this.onPublishingComplete);
				this.parentTile.getEngine().addEventListener(MediaServerEvent.PUBLISHING_STOPPED, this.onPublishingStopped);
			}
			this.recordButton.setLabelText("Record");
			this.video.visible = true;
			this.getParentTile().getEngine().dispatchEvent(new TileEvent(TileEvent.CAMERA_ADDED));
		}
		
		protected function removePublishingEventListeners():void {
			try {
				this.parentTile.getEngine().getMediaServer().removeEventListener(
					MediaServerEvent.PUBLISHING_COMPLETE, this.onPublishingComplete);
			} catch (error:Error) {}
			
			try {
				this.parentTile.getEngine().getMediaServer().removeEventListener(
					MediaServerEvent.PUBLISHING_STOPPED, this.onPublishingStopped);
			} catch (error:Error) {}
		}
		
		public function loadCamera():void {
			this.camera = Camera.getCamera();
			this.camera.setMode(Tile.getWidth(), Tile.getHeight(), 17, true);
			this.camera.setQuality(22500, 0);
			this.camera.setKeyFrameInterval(100);
			
			this.parentTile.getEngine().getMediaServer().setCamera(this.camera);
			
			this.video = new Video();
			this.video.attachCamera(this.camera);
			this.video.width = Tile.getWidth();
			this.video.height = Tile.getHeight();
			
			this.addChild(this.video);
			
			this.addUI();
		}
		
		protected function addUI():void {
			this.addRecordButton();
			this.addCancelButton();
		}
		
		protected function addRecordButton():void {
			this.recordButton = new TileButton(90, 20, "Record", -1);
			this.recordButton.y = Tile.getHeight() + 5;
			this.recordButton.x = 5;
			
			this.recordButton.addEventListener(MouseEvent.CLICK, this.onRecordButtonClick);
			
			this.addChild(this.recordButton);
		}
		
		protected function addCancelButton():void {
			this.cancelButton = new TileButton(90, 20, "Cancel", -1);
			this.cancelButton.y = this.recordButton.y + this.recordButton.height + 2;
			this.cancelButton.x = 5;
			
			this.cancelButton.addEventListener(MouseEvent.CLICK, this.onCancelButtonClick);
			
			this.addChild(this.cancelButton);			
		}
		
		protected function onRecordButtonClick(event:MouseEvent):void {
			this.recordButton.removeEventListener(MouseEvent.CLICK, this.onRecordButtonClick);
			this.startRecording();
		}
		
		public function startRecording():void {
			this.parentTile.getEngine().getMediaServer().startPublishing();
			this.recordButton.setLabelText("Recording...");
			this.cancelButton.visible = false;	
		}
		
		protected function onCancelButtonClick(event:MouseEvent):void {
			this.parentTile.createVideoTile();
			this.getParentTile().getEngine().dispatchEvent(new TileEvent(TileEvent.CAMERA_CANCELLED));
		}
		
		public function isMuted():Boolean {
			if (this.camera != null) {
				return this.camera.muted;
			}
			
			return false;
		}
		
		public function onPublishingComplete(event:MediaServerEvent):void {
			this.recordButton.addEventListener(MouseEvent.CLICK, this.onRecordButtonClick);
			this.cancelButton.visible = true;
		}
		
		public function onPublishingStopped(event:MediaServerEvent):void {
			this.video.visible = false;
			this.recordButton.setLabelText("Wait...");
		}
		
		public function getParentTile():Tile {
			return this.parentTile;
		}
	}
}