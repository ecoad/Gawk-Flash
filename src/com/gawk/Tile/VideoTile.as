package com.gawk.Tile {
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.Tile.Event.TileEvent;
	import com.gawk.Tile.VideoData.VideoData;
	import com.gawk.UI.TileButton;
	import com.gawk.UI.VideoTileOverlay.VideoTileOverlayController;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoTile extends MovieClip {
		protected var parentTile:Tile;
		protected var videoData:VideoData;
		
		protected var loader:Loader;
		protected var netStream:NetStream;
		protected var video:Video;
		
		protected var newlySubmitted:Boolean;
		
		protected var reRecordButton:TileButton;
		protected var saveButton:TileButton;
		
		protected var videoTileOverlayController:VideoTileOverlayController;
		
		public function VideoTile(parentTile:Tile, videoData:VideoData, newlySubmitted:Boolean = false) {
			this.parentTile = parentTile;
			this.setVideoData(videoData.getMember());
			this.newlySubmitted = newlySubmitted;
		}
		
		public function loadVideo():void {
			this.initialiseLoadVideo();
			
			this.addVideoTileOverlay();
			
//			if (this.newlySubmitted) {
//				this.addRecordUI();
//			}
			
//			this.parentTile.getEngine().addEventListener(MemberEvent.MEMBER_LOGGED_IN, function (event:MemberEvent):void {
//				allowVideoTileOverlayEvents();
//			});
//			this.parentTile.getEngine().addEventListener(MemberEvent.MEMBER_LOGGED_OUT, function (event:MemberEvent):void {
//				disallowVideoTileOverlayEvents();
//			});
			
			this.playVideo();
		}
		
		protected function initialiseLoadVideo():void {
			//TODO: Can we share this net connection?
			var netConnection:NetConnection = new NetConnection(); 
			netConnection.connect(null); 
			
			this.netStream = new NetStream(netConnection);
			this.netStream.soundTransform = new SoundTransform(0);
			this.netStream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatus);
			this.netStream.bufferTime = 1;
			var infoClient:Object = new Object();
			infoClient.onMetaData = function():void {}; // Container for video MetaData
			this.netStream.client = infoClient;
			
			this.video = new Video();
			this.addChild(this.video);
		}
		
		protected function playVideo():void {
			this.video.attachNetStream(this.netStream); 
			
			var fullVideoLocation:String = this.parentTile.getEngine().getBinaryLocation() + this.videoData.getFilename(); 
			
			this.netStream.play(fullVideoLocation);
			this.parentTile.getEngine().logger.addLog(Logger.LOG_ACTIVITY, "Loading video: " + fullVideoLocation);
		}
		
		public function pauseVideo():void {
			if (this.netStream !== null) {
				this.netStream.pause();
			}
		}
		
		public function resumeVideo():void {
			if (this.netStream !== null) {
				this.netStream.resume();
			}
		}
		/*
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
		*/
		
		protected function addVideoTileOverlay():void {
			this.videoTileOverlayController = new VideoTileOverlayController(this);
			this.addChild(this.videoTileOverlayController.getPanel());
		}
		
		/*
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
		*/
		
		protected function onNetStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetStream.Play.Start":
					this.onVideoLoaded();
					break;
				case "NetStream.Play.Stop":
					netStream.seek(0); // Loop video playback
					break;
				case "NetStream.Play.StreamNotFound":
					this.parentTile.getEngine().logger.addLog(Logger.LOG_ERROR, this.videoData.getFilename() + ": NetStream.Play.StreamNotFound");
					this.onVideoLoaded();
					break;					
				default:
					//this.parentTile.getEngine().logger.addLog(Logger.LOG_ACTIVITY, this.videoLocation + ": " + event.info.code); 
			}
		}
		
		protected function onVideoLoaded():void {
			this.video.width = Tile.tileWidth;
			this.video.height = Tile.tileHeight;
			
			this.parentTile.getEngine().dispatchEvent(new TileEvent(TileEvent.TILE_LOADED));
		}
		
		protected function onReRecordButtonClick(event:MouseEvent):void {
			this.parentTile.createCameraTile(true);
		}
		
		protected function onSaveButtonClick(event:MouseEvent):void {
			this.parentTile.getEngine().saveVideo(this.videoData.getFilename());
			this.parentTile.getEngine().addEventListener(EngineEvent.VIDEO_SAVED, onVideoSaved);
//			this.hideRecordControls();
		}
		
		protected function onVideoSaved(event:EngineEvent):void {
			this.parentTile.getEngine().removeEventListener(EngineEvent.VIDEO_SAVED, onVideoSaved);
			this.videoData.setSecureId(event.data.videoId);
			this.videoData.setMemberSecureId(event.data.memberSecureId);
//			if (this.parentTile.getEngine().getMemberControl().getMemberData().secureId != "") {
//				this.allowVideoTileOverlayEvents();
//			}
		}
		
		public function setVideoData(videoData:VideoData):void {
			this.videoData = videoData;
		}
		
		public function getVideoData():VideoData {
			return this.videoData;
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
		
		/*
		protected function showMemberUIControls():void {
			this.videoTileOverlayController.getPanel().visible = true;	
			
			if (this.parentTile.getEngine().getMemberControl().getMemberData().secureId == videoData.getMemberSecureId()) {
				this.videoTileOverlayController.showRemoveButton();
			} else {
				this.videoTileOverlayController.hideRemoveButton();
			}
		}
		*/
	}
}