package com.gawk.Engine {
	import com.gawk.Engine.Event.VideoLoaderEvent;
	import com.gawk.Logger.Logger;
	import com.gawk.Video.VideoObject;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoLoader extends EventDispatcher{
		protected var engine:Engine;
		protected var netStream:NetStream;
		protected var videoObject:VideoObject;
		
		public function VideoLoader(engine:Engine) {
			this.engine = engine;
			 
			var netConnection:NetConnection = new NetConnection();
			netConnection.connect(null); 
			
			this.netStream = new NetStream(netConnection);
			this.netStream.soundTransform = new SoundTransform(0);
			this.netStream.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatus);
			this.netStream.bufferTime = 1;
			var infoClient:Object = new Object();
			infoClient.onMetaData = function():void {}; // Container for video MetaData
			this.netStream.client = infoClient;
		}
		
		protected function onNetStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetStream.Play.Start":
					this.dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.VIDEO_LOADED));
					break;
				case "NetStream.Play.Stop":
					netStream.seek(0); // Loop video playback
					break;
				case "NetStream.Play.StreamNotFound":
					this.engine.logger.addLog(Logger.LOG_ERROR, "VideoLoader: NetStream.Play.StreamNotFound");
					this.dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.VIDEO_LOADED));
					break;
				case "NetStream.Play.NoSupportedTrackFound":
					this.engine.logger.addLog(Logger.LOG_ERROR, "VideoLoader: NetStream.Play.NoSupportedTrackFound");
				default:
					//this.parentTile.getEngine().logger.addLog(Logger.LOG_ACTIVITY, this.videoLocation + ": " + event.info.code); 
			}
		}
		
		public function getNetStream():NetStream {
			return this.netStream;
		}
	}
}