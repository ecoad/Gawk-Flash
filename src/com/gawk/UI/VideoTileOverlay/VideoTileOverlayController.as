package com.gawk.UI.VideoTileOverlay {
	import com.gawk.Engine.Engine;
	import com.gawk.Graphics.VideoTileOverlay;
	import com.gawk.Graphics.VideoTileOverlay.*;
	import com.gawk.Tile.VideoTile;
	import com.gawk.UI.TileButton;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class VideoTileOverlayController extends EventDispatcher {
		
		protected var panel:VideoTileOverlay;
		protected var parentTile:VideoTile;
		protected var favouriteButton:TileButton;
		protected var hateButton:TileButton;
		protected var removeButton:TileButton;
		
		protected var profileVideo:ProfileVideo;
		protected var engine:Engine;
		
		public function VideoTileOverlayController(parentTile:VideoTile, engine:Engine)	{
			this.parentTile = parentTile;
			this.engine = engine;
			this.panel = new VideoTileOverlay();
			this.panel.visible = false;
			
			this.addUiEventListners();
			this.setName(this.parentTile.getVideoData().getMember().alias);
			this.setProfileVideo(this.parentTile.getVideoData().getMember().profileVideoLocation);
		}
		
		protected function addUiEventListners():void {
			this.parentTile.addEventListener(MouseEvent.MOUSE_OVER, function (event:MouseEvent):void {
				panel.visible = true;
				profileVideo.loadVideo();
			});
			this.parentTile.addEventListener(MouseEvent.MOUSE_OUT, function (event:MouseEvent):void {
				panel.visible = false;
			});
		}
		
		protected function setName(name:String):void {
			this.panel.profile.aliasText.text = name;
		}
		
		protected function setProfileVideo(profileVideoLocation:String):void {
			this.profileVideo = new ProfileVideo(this, this.engine, profileVideoLocation);
			this.panel.profile.addChild(this.profileVideo.getVideo());
		}
		
		protected function onLogin():void {
		}
		
		protected function onLogout():void {
		}
		
		public function enableRateUpButton():void {
		}
		public function disableRateUpButton():void {
		}
		
		public function enableDeleteButton():void {
		}
		public function disableDeleteButton():void {
		}
		
		public function onRateUpClick():void {
		}
		public function onRateDownClick():void {
		}
		
		public function onProfileClick():void {
		}
		
		public function onViewGawkClick():void {
		}
		
		public function onFavouriteClick():void {
		}
		
		public function onDeleteClick():void {
		}
		
		/*
		public function addButtons():void {
			this.addFavouriteButton();
			this.addHateButton();
			if (this.parentTile.getVideoData().getMemberSecureId() == this.parentTile.getParentTile().getEngine().getMemberControl().getMemberData().secureId) {
				this.addRemoveButton();
			}
		}
		
		public function addFavouriteButton():void {
			this.favouriteButton = new TileButton(50, 30, "Fav", 5);
			this.favouriteButton.x = 5;
			this.favouriteButton.y = 5;
			this.panel.addChild(this.favouriteButton);
			this.favouriteButton.addEventListener(MouseEvent.CLICK, this.onFavouriteButtonClick);
		}
		
		protected function onFavouriteButtonClick(event:MouseEvent):void {
			
			var action:Action = new Action({
				action: "GawkPositiveRating", 
				videoSecureId: this.parentTile.getVideoData().getSecureId(),
				memberSecureId: this.parentTile.getParentTile().getEngine().getMemberControl().getMemberData().secureId
			});
			
			this.parentTile.getParentTile().getEngine().dispatchEvent(new VideoTileOverlayEvent(VideoTileOverlayEvent.TILE_MEMBER_PANEL_ACTION, action));
		}
		
		public function addHateButton():void {
			this.hateButton = new TileButton(50, 30, "Hate", 5);
			this.hateButton.x = 5;
			this.hateButton.y = 40;
			this.panel.addChild(this.hateButton);
			this.hateButton.addEventListener(MouseEvent.CLICK, this.onHateButtonClick);
		}
		
		protected function onHateButtonClick(event:MouseEvent):void {
			var action:Action = new Action({
				action: "GawkNegativeRating", 
				videoSecureId: this.parentTile.getVideoData().getSecureId(),
				memberSecureId: this.parentTile.getParentTile().getEngine().getMemberControl().getMemberData().secureId
			});
			
			this.parentTile.getParentTile().getEngine().dispatchEvent(new VideoTileOverlayEvent(VideoTileOverlayEvent.TILE_MEMBER_PANEL_ACTION, action));
		}
		
		public function addRemoveButton():void {
			this.removeButton = new TileButton(50, 30, "Remove", 5);
			this.removeButton.x = 5;
			this.removeButton.y = 90;
			this.panel.addChild(this.removeButton);
			this.removeButton.addEventListener(MouseEvent.CLICK, this.onRemoveButtonClick);
		}
		
		protected function onRemoveButtonClick(event:MouseEvent):void {
			var action:Action = new Action({
				action: "GawkRemove", 
				videoSecureId: this.parentTile.getVideoData().getSecureId(),
				memberSecureId: this.parentTile.getParentTile().getEngine().getMemberControl().getMemberData().secureId
			});
			
			this.parentTile.getParentTile().getEngine().dispatchEvent(new VideoTileOverlayEvent(VideoTileOverlayEvent.TILE_MEMBER_PANEL_ACTION, action));
		}
		
		public function showRemoveButton():void {
			this.removeButton.visible = true;
		}
		
		public function hideRemoveButton():void {
			this.removeButton.visible = false;
		}
		*/
		public function getPanel():VideoTileOverlay {
			return this.panel;
		}
		
		public function getParentTile():VideoTile {
			return this.parentTile;
		}
	}
}