package com.gawk.MediaServer {
	import com.gawk.Engine.Engine;
	import com.gawk.Logger.Logger;
	import com.gawk.MediaServer.Event.MediaServerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class MediaServer extends EventDispatcher {
		
		protected var engine:Engine;
		protected var camera:Camera;
		protected var netConnection:NetConnection = null;
		protected var nsPublish:NetStream = null;             
		protected var nsPlay:NetStream = null;
		
		protected var currentFileName:String;
		
		protected var maximumVideoLength:int = 3;
		protected var currentVideoLength:int = 0;
		protected var videoLengthTimer:Number = 0;
		
		protected var flushVideoBufferTimer:Number = 0;
		
		protected var connected:Boolean = false;
		
		public function MediaServer(engine:Engine) {
			this.engine = engine;
		}
		
		public function setCamera(camera:Camera):void {
			this.camera = camera;
		}
		
		public function connectToMediaServer():void {
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			netConnection.connect(engine.getServerLocation());
			
			dispatchEvent(new MediaServerEvent(MediaServerEvent.CONNECTING));
		}
		
		/**
		 * On NetConnection status
		 */
		protected function onNetConnectionStatus(infoObject:NetStatusEvent):void {
			
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, infoObject.info.code+" ("+infoObject.info.description+")");
			if (infoObject.info.code == "NetConnection.Connect.Failed") {
				this.engine.logger.addLog(Logger.LOG_ERROR, "Cannot connect to Media Server: " + engine.getServerLocation()); 
			} else if (infoObject.info.code == "NetConnection.Connect.Success") {
				this.engine.dispatchEvent(new MediaServerEvent(MediaServerEvent.CONNECTED));
				this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Connected to Media Server");
			} else if (infoObject.info.code == "NetConnection.Connect.Rejected") {
				this.engine.logger.addLog(Logger.LOG_ERROR, "NetConnection.Connect.Rejected");
			}
		}
		
		public function startPublishing():void {
			
			this.currentFileName = this.engine.getUniqueFileName();
			
			if (netConnection.connected) {
				if (!this.camera.muted) {
					this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Publishing started");
					nsPublish = new NetStream(netConnection);
					
					var nsPublishClient:Object = new Object();
					nsPublish.client = nsPublishClient;
				
					nsPublish.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStreamPublishStatus);
					
					nsPublish.publish(this.currentFileName, "record");
					
					var metaData:Object = new Object();
					metaData["description"] = "Gawk";
					nsPublish.send("@setDataFrame", "onMetaData", metaData);
				
					nsPublish.attachCamera(this.camera);
					
					// set the buffer time to 20 seconds to buffer 20 seconds of video
					// data for better performance and higher quality video
					nsPublish.bufferTime = 20;
					
					dispatchEvent(new MediaServerEvent(MediaServerEvent.PUBLISHING_STARTED));
					
					this.videoLengthTimer = setInterval(this.onVideoTimer, 1000);
				} else {
					this.engine.logger.addLog(Logger.LOG_ERROR, "Camera is muted");
				}
			}
		}
		
		protected function onVideoTimer():void {
			if (currentVideoLength == maximumVideoLength) {
				stopPublishing();
			} else {
				currentVideoLength++;
			}
			
			dispatchEvent(new MediaServerEvent(MediaServerEvent.TIME_REMAINING_TICK, currentVideoLength));
		}
		
		public function stopPublishing():void	{
			
			// stop streaming video and audio to the publishing
			// NetStream object
			nsPublish.attachAudio(null);
			nsPublish.attachCamera(null);
			
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "Publishing stopped");
			dispatchEvent(new MediaServerEvent(MediaServerEvent.PUBLISHING_STOPPED));
		
			// After stopping the publishing we need to check if there is
			// video content in the NetStream buffer. If there is data
			// we are going to monitor the video upload progress by calling
			// flushVideoBuffer every 250ms.  If the buffer length is 0
			// we close the recording immediately.
			var buffLen:Number = nsPublish.bufferLength;
			if (buffLen > 0) {
				flushVideoBufferTimer = setInterval(flushVideoBuffer, 250);
				dispatchEvent(new MediaServerEvent(MediaServerEvent.PUBLISHING_WAIT_FOR_BUFFER));
			}	else {
				//TODO: not sure if this is needed
				closePublished();
			}
			
			clearInterval(videoLengthTimer);
			videoLengthTimer = 0;
			currentVideoLength = 0;
		}
		
		protected function closePublished():void {
			// after we have hit "Stop" recording and after the buffered video data has been
			// sent to the Wowza Media Server close the publishing stream
			nsPublish.publish("null");
		}
		
		// this function gets called every 250 ms to monitor the
		// progress of flushing the video buffer. Once the video
		// buffer is empty we close publishing stream
		protected function flushVideoBuffer():void	{
			var buffLen:Number = nsPublish.bufferLength;
			if (buffLen == 0)	{
				dispatchEvent(new MediaServerEvent(MediaServerEvent.PUBLISHING_STOPPED));
				clearInterval(flushVideoBufferTimer);
				flushVideoBufferTimer = 0;
				closePublished();
			}
		}
		
		protected function onNetStreamPublishStatus(infoObject:NetStatusEvent):void {
			this.engine.logger.addLog(Logger.LOG_ACTIVITY, "NS Publish: " + 
				infoObject.info.code+" ("+infoObject.info.description+")");
			
			// After calling nsPublish.publish(false); we wait for a status event of "NetStream.Unpublish.Success" which 
			// tells us all the video and audio data has been written to the flv file. It is at this time
			// that we can start playing the video we just recorded.
			if (infoObject.info.code == "NetStream.Unpublish.Success") {
				this.engine.dispatchEvent(new MediaServerEvent(MediaServerEvent.PUBLISHING_COMPLETE, this.currentFileName + ".flv"));
			}
		
			if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed") {
				this.engine.logger.addLog(Logger.LOG_ERROR, "NS Publish: " + infoObject.info.code);
			}
		}
	}
}