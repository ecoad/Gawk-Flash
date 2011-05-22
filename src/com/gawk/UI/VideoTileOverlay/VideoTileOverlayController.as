package com.gawk.UI.VideoTileOverlay {
	import com.gawk.Engine.Engine;
	import com.gawk.Graphics.VideoTileOverlay;
	import com.gawk.Graphics.VideoTileOverlay.*;
	import com.gawk.Member.Event.MemberEvent;
	import com.gawk.Member.Member;
	import com.gawk.Member.VideoAction.MemberVideoRatingAction;
	import com.gawk.Tile.VideoTile;
	import com.gawk.UI.TileButton;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Mouse;
	
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
			
			this.addUiEventListeners();
			this.setName(this.parentTile.getVideoObject().member.alias);
		}
		
		protected function addUiEventListeners():void {
			this.parentTile.addEventListener(MouseEvent.MOUSE_OVER, function (event:MouseEvent):void {
				panel.visible = true;
				setProfileVideo();
			});
			this.parentTile.addEventListener(MouseEvent.MOUSE_OUT, function (event:MouseEvent):void {
				panel.visible = false;
			});
			this.panel.favouriteButton.addEventListener(MouseEvent.CLICK, onFavouriteClick);
		}
		
		protected function setName(name:String):void {
			this.panel.profile.aliasText.text = name;
		}
		
		protected function setProfileVideo():void {
			var profileVideoLocation:String = this.parentTile.getVideoObject().member.profileVideoLocation;
			if ((profileVideoLocation != "") && (this.profileVideo == null)) {
				this.profileVideo = new ProfileVideo(this, this.engine, profileVideoLocation);
				this.profileVideo.loadVideo();
				this.panel.profile.addChild(this.profileVideo.getVideo());
			}
		}
		
		public function onProfileClick():void {
			navigateToURL(new URLRequest("/u/" + this.parentTile.getVideoObject().member.alias), "_SELF");
		}
		
		public function onViewGawkClick():void {
			navigateToURL(
				new URLRequest(
					"/u/" + this.parentTile.getVideoObject().member.alias + "/gawk/" + this.parentTile.getVideoObject().secureId), 
				"_SELF");
		}
		
		protected function onFavouriteClick(event:MouseEvent):void {
			var action:MemberVideoRatingAction = new MemberVideoRatingAction();
			action.setVideoSecureId(this.parentTile.getVideoObject().secureId);
			action.setPositiveRating(true);
			this.engine.getMemberControl().addEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onFavouriteClickResponse);
			this.engine.getMemberControl().dispatchEvent(
				new MemberEvent(MemberEvent.MEMBER_VIDEO_ADD_RATING_REQUEST, action));
		}
		
		protected function onFavouriteClickResponse(event:MemberEvent):void {
			this.engine.getMemberControl().removeEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onFavouriteClickResponse);
			showFavouriteButtonIsActive();
		}
		
		protected function showFavouriteButtonIsActive():void {
			this.panel.favouriteButton.alpha = 1;
		}
		
		protected function onHateClick(event:MouseEvent):void {
			var action:MemberVideoRatingAction = new MemberVideoRatingAction();
			action.setVideoSecureId(this.parentTile.getVideoObject().secureId);
			action.setPositiveRating(false);
			this.engine.getMemberControl().addEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onHateClickResponse);
			this.engine.getMemberControl().dispatchEvent(
				new MemberEvent(MemberEvent.MEMBER_VIDEO_ADD_RATING_REQUEST, action));
		}
		
		protected function onHateClickResponse(event:MemberEvent):void {
			this.engine.getMemberControl().removeEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onHateClickResponse);
			showHateButtonIsActive();
		}
		
		protected function showHateButtonIsActive():void {
			this.panel.hateButton.alpha = 0.5;
		}
		
		protected function onDeleteClick(event:MouseEvent):void {
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