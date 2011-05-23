package com.gawk.Tile {
	import com.gawk.Engine.Engine;
	import com.gawk.Logger.Logger;
	import com.gawk.MediaServer.Event.MediaServerEvent;
	import com.gawk.Tile.Event.TileEvent;
	import com.gawk.Video.VideoObject;
	import com.gawk.Wall.Wall;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	
	public class Tile	extends EventDispatcher {
		public static var tileWidth:int = 175; //Main
		public static var tileHeight:int = 131;
//		public static var tileWidth:int = 320; //Booth
//		public static var tileHeight:int = 230;
		
		public var tileIndex:int;
		
		protected var stageIndex:int = 0;
		
		public var movieClip:MovieClip;
		
		protected var videoTile:VideoTile;
		
		protected var engine:Engine;
		protected var wall:Wall;
		
		public function Tile(engine:Engine, wall:Wall, videoObject:VideoObject = null, stageIndex:int = 0) {
			this.engine = engine;
			this.wall = wall;
			
			this.stageIndex = stageIndex;
			
			this.createTile();
			
			if (videoObject !== null) {
				this.createVideoTile(videoObject);
			}
		}
		
		public function createVideoTile(videoObject:VideoObject = null, newlySubmitted:Boolean = false):void {
			this.removeChildren();
			
			if (videoObject !== null) {
				this.videoTile = new VideoTile(this, videoObject, newlySubmitted);
			}
			
			if (this.videoTile !== null) {
				this.movieClip.addChild(this.videoTile);
			}
		}
		
		public function createCameraTile(autoRecord:Boolean = false):void {
			this.removeChildren();
			
			var cameraTile:CameraTile = this.wall.getCameraTile();
			cameraTile.setParentTile(this);
			
			this.movieClip.addChild(cameraTile);
			this.engine.getMediaServer().addEventListener(MediaServerEvent.PUBLISHING_COMPLETE, this.onPublishingComplete);
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Camera tile created");
			
			if (autoRecord) {
				cameraTile.startRecording();
			}
		}
		
		protected function removeChildren():void {
			try {
				this.movieClip.removeChild(this.videoTile);
			} catch (error:Error) {	}
			
			try {
				this.movieClip.removeChild(this.wall.getCameraTile());
			} catch (error:Error) {	}
		}
		
		protected function createTile():void {
			this.movieClip = new MovieClip();
		}
		
		public function queueVideo():void {
			if (this.videoTile is VideoTile) {
				this.videoTile.loadVideo(this.stageIndex);
			} else {
				dispatchEvent(new TileEvent(TileEvent.TILE_LOADED, null));
			}
		}
		
		public static function getWidth():int {
			return tileWidth; 
		}
		
		public static function getHeight():int {
			return tileHeight;
		}
		
		public function isVideoAssigned():Boolean {
			return (this.videoTile != null);
		}
		
		public function pause():void {
			if (this.isVideoAssigned()) {
				this.videoTile.pauseVideo();
			}
		}
		
		public function resume():void {
			if (this.isVideoAssigned()) {
				this.videoTile.resumeVideo();
			}
		}
		
		protected function onPublishingComplete(event:MediaServerEvent):void {
			this.engine.getMediaServer().removeEventListener(MediaServerEvent.PUBLISHING_COMPLETE, this.onPublishingComplete);
			try {
				this.movieClip.removeChild(this.wall.getCameraTile());
			} catch (error:Error) {
			}
			this.createVideoTile(new VideoObject({filename: event.data}), true);
			this.videoTile.loadVideo();
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Load recorded video");
		}
		
		public function getEngine():Engine {
			return this.engine;
		} 
	}
}
