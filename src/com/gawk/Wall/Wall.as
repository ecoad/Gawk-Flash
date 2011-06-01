package com.gawk.Wall {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.MediaServer.Event.MediaServerEvent;
	import com.gawk.Tile.CameraTile;
	import com.gawk.Tile.Event.TileEvent;
	import com.gawk.Tile.Tile;
	import com.gawk.Tile.VideoTile;
	import com.gawk.UI.Main.Shroud;
	import com.gawk.Video.VideoObject;
	import com.utils.FPSMonitor;
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	
	public class Wall	extends MovieClip {
		protected var tile:Tile;
		protected var tiles:Array = new Array();
		
		protected var engine:Engine;
		
		protected var tilePositions:Array = new Array();
		protected var cameraTile:CameraTile;
		protected var waitingTiles:Array = new Array();
		protected var lastVideoTile:VideoTile;
		
		public var wallWidth:int;
		public var wallHeight:int;
//		public const WALL_WIDTH:int = 1920; //booth
//		public const WALL_HEIGHT:int = 1150;
//		public const WALL_WIDTH:int = 1920; //booth short
//		public const WALL_HEIGHT:int = 920; 
		public static const WALL_WIDTH:int = 1050; //main
		public static const WALL_HEIGHT:int = 655;
//		public const WALL_WIDTH:int = 1050; //recent
//		public const WALL_HEIGHT:int = 131;
//		public const WALL_WIDTH:int = 175; //profile
//		public const WALL_HEIGHT:int = 131;
		
		protected var shroud:Shroud;
		
		public function Wall(engine:Engine) {
			this.engine = engine;

			this.engine.addEventListener(EngineEvent.VIDEO_SAVED, onVideoSaved);
			this.engine.addEventListener(EngineEvent.WALL_CONFIG_UPDATE_LOADED, this.onWallConfigUpdate);

			this.cameraTile = new CameraTile();
			this.engine.addEventListener(TileEvent.CAMERA_CANCELLED, this.onCameraCancelled);
			this.engine.addEventListener(TileEvent.CAMERA_ADDED, this.onCameraAdded);

			this.createWall();
			this.addShroud();
			this.setupRecordNewVideoClick();
		}
		
		protected function createWall():void {
			this.createTilePositions();
			this.assignTilesRandomly();
			
			this.loadNextWaitingTileFromConfig();
		}
		
		protected function createTilePositions():void {
			var x:int = 0;
			var y:int = 0;
			
			var tileIndex:int = 0;
			
			while (y <= (WALL_HEIGHT - Tile.getHeight())) {
				while (x <= (WALL_WIDTH - Tile.getWidth())) {
					this.tilePositions.push(new Array(x, y));
					x += Tile.getWidth();
				}
				x = 0;
				y += Tile.getHeight();
			}
		}
		
		protected function assignTilesRandomly():void {
			var videos:Array = this.engine.getVideos();

			var tileIndex:int = 0;
			
			while (this.tilePositions.length > 0) {
				var index:int = Math.round(Math.random() * (this.tilePositions.length - 1));
				var tilePosition:Array = this.tilePositions.splice(index, 1)[0];

				var tile:Tile = new Tile(this.engine, this,	videos[tileIndex] ? videos[tileIndex] : null, tileIndex);
				
				this.engine.addEventListener(TileEvent.TILE_LOADED, onVideoLoaded);
				tile.movieClip.x = tilePosition[0];
				tile.movieClip.y = tilePosition[1];
				
				this.addChild(tile.movieClip);
				
				this.tiles.push(tile);
				this.waitingTiles.push(tile);
				
				tileIndex++;
			}
			if (this.engine.allowDebugOverlay()) {
				this.addChild(new FPSMonitor());
			}
		}
		
		protected function onWallConfigUpdate(event:EngineEvent):void {
			this.engine.getVideos().every(function(video:VideoObject, index:int, array:Array):Boolean {
				if (!video.newVideoAfterInit) {
					return true; //Continue
				}
				
				engine.logger.addLog(Logger.LOG_ACTIVITY, "Video: " + video.secureId + " assigning to tile");
				var tile:Tile = getWaitingTile();
				tile.createVideoTile(video);
				tile.queueVideo();
				video.newVideoAfterInit = false;
				return false; //Break loop
			});
		}
		
		protected function onVideoLoaded(event:TileEvent):void {
			this.loadNextWaitingTileFromConfig();
		}
		
		protected function loadNextWaitingTileFromConfig():void {
			var nextTile:Tile = this.waitingTiles.shift();
			
			if (nextTile) {
				nextTile.queueVideo();
			}
		}
		
		protected function onRecordNewButtonClick():void {
			if (!this.getCameraTile().isMuted()) {
				this.addCameraToTile(this.getWaitingTile());
			}
		}
		
		protected function addCameraToTile(forceTile:Tile = null):void {
			if (forceTile != null) {
				forceTile.createCameraTile();
			} else {
				for each(var myTile:Tile in this.tiles) {
					if (!myTile.isVideoAssigned()) {
						myTile.createCameraTile();
						break;
					}
				}
			}
		}
		
		public function getCameraTile():CameraTile {
			return this.cameraTile;
		}
		
		protected function addShroud():void {
			this.shroud = new Shroud(this, this.engine, WALL_WIDTH, WALL_HEIGHT);
			this.addChild(this.shroud);
			
			this.shroud.visible = false;
		}
		
		protected function onCameraCancelled(event:TileEvent):void {
			this.replaceWaitingTile();
			this.toggleWallPause(false);
		}
		
		protected function getWaitingTile():Tile {
			var tile:Tile = this.tiles.pop();
			this.tiles.unshift(tile);
			return tile;
		}
		
		/**
		 * When a camera cancels
		 */
		protected function replaceWaitingTile():void {
			var tile:Tile = this.tiles.shift();
			this.tiles.push(tile);
		}
		
		protected function toggleWallPause(pause:Boolean):void {
			for each(var myTile:Tile in this.tiles) {
				if (pause) {
					myTile.pause();
				} else {
					myTile.resume();
				}
			}
		}
		
		protected function onCameraAdded(event:TileEvent):void {
			this.toggleWallPause(true);
		}
		
		protected function onVideoSaved(event:EngineEvent):void {
			this.toggleWallPause(false);
		}
		
		protected function setupRecordNewVideoClick(event:EngineEvent = null):void {
			ExternalInterface.addCallback("recordNewFromExternal", this.onRecordNewButtonClick);
		}
		
		public function setLastVideoTile(videoTile:VideoTile):void {
			this.lastVideoTile = videoTile;
		}
	}
}
