package utilities 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.events.StageVideoEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class SimpleStageVideo extends Sprite
	{
		private var IS_STAGE_VIDEO:Boolean = false;
		private var VID_PATH:String;
		private var stageVideo:StageVideo;
		private var vid:Video;
		private var ns:NetStream;
		private var HH:Number;
		private var classicVideoInUse:Boolean = false;
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		public var VW:Number;
		public var VH:Number;
		public var FixedVH:Number;
		private var btnPlayCover:VideoPlayCover = new VideoPlayCover();
		private var nc:NetConnection = new NetConnection() ;
		private var VIDEO_STARTED:Boolean = false;
		private var pauseTimer:Timer = new Timer(100, 5);
		public function SimpleStageVideo(v:String, h:Number) 
		{
			VID_PATH = v;
			HH = h;
		}
		
		public function init():void{
			trace("INIT VIDEO");
			GlobalVarContainer.MainStage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
		}
		
		private function onStageVideoState(event:StageVideoAvailabilityEvent):void       
		{       
			var available:Boolean = (event.availability == StageVideoAvailability.AVAILABLE);    
			toggleStageVideo(available);
			trace("IS VIDEO AVAILABLE: "+available);
		}
		
		
		private function toggleStageVideo(on:Boolean):void       
		{              
				IS_STAGE_VIDEO = on;
			// if StageVideo is available, attach the NetStream to StageVideo       
			if (on)       
			{       
				if ( stageVideo == null )       
				{       
					// retrieve the first StageVideo object       
					SetupVideo();
				}              
			} else       
			{       
					vid = new Video();
					//addChild(video);
					classicVideoInUse = true; 
				
					nc.connect(null);
					ns =  new NetStream(nc);
					vid.attachNetStream(ns); 
					ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
					nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsynchError, false, 0, true);
					
					var netClient:Object = new Object();
			
					netClient.onMetaData = function(meta:Object):void
					{
						trace("META DUR+ "+meta.duration);
						trace("VW: " + meta.width + " /VH: " + meta.height);

						VW =  meta.width ;
						VH =  meta.height;
						
						if (VW > 1920){
							VW = GlobalVarContainer.ScreenW
							VH = GlobalVarContainer.ScreenW * .75;
						}
						VW=vid.width = GlobalVarContainer.ScreenW;
						vid.height = VH * (GlobalVarContainer.ScreenW / VW);
						VH = vid.height;

						var backBlack:BitmapData = new BitmapData(vid.width, vid.height, false, 0x000000);
						var bmc:Bitmap = new Bitmap(backBlack);
						var b_mc:MovieClip = new MovieClip();
						b_mc.addChild(bmc);
						addChild(b_mc);
						addChild(vid);
						
						btnPlayCover.back.width = vid.width;
						btnPlayCover.back.height = vid.height;
						addChild(btnPlayCover);
						
						
					    btnPlayCover.y = HH;
						
						//if (btnPlayCover.icon.height > vid.height){
						btnPlayCover.icon.height = vid.height / 2;
						btnPlayCover.icon.scaleX = btnPlayCover.icon.scaleY;
						//}
						
						btnPlayCover.icon.x = vid.width / 2 - btnPlayCover.icon.width / 2;
						btnPlayCover.icon.y = vid.height / 2 - btnPlayCover.icon.height / 2;
						btnPlayCover.addEventListener(MouseEvent.MOUSE_DOWN, playPause);
						dispatchEvent(new MoreEvent(MoreEvent.VIDEO_LOADED));
						//createBars();
						
						ns.pause();

					};
			
			
			        ns.client = netClient;
					ns.play(VID_PATH);       
			}       
		}
		

		
		public function MoveVideo(x:Number):void{
			if (IS_STAGE_VIDEO){
				stageVideo.viewPort = new Rectangle( x, HH, sw , VH ) ;
				btnPlayCover.x = x; 
			}
		}
		
		private function SetupVideo():void {
		


			  nc.connect(null) ;

			  ns = new NetStream(nc) ;

			ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsynchError, false, 0, true);
			var netClient:Object = new Object();
			
			netClient.onMetaData = function(meta:Object):void
			{
				trace("META DUR+ "+meta.duration);
				
				trace("VW: " + meta.width + " /VH: " + meta.height);

				//VW =  meta.width ;
				//VH =  meta.height;
				
				
				VW = GlobalVarContainer.ScreenW
				if (VW > 1920){
					VH = GlobalVarContainer.ScreenW * .75;
				}else{
				
					VH =  meta.height * (GlobalVarContainer.ScreenW / meta.width);
				}

				
				
				
				btnPlayCover.back.width = VW;
				btnPlayCover.back.height = VH;
				//btnPlayCover.back.alpha = 0;
				btnPlayCover.back.cacheAsBitmap = true;
				addChild(btnPlayCover);
				//btnPlayCover.y = HH;
				
				
				//if (btnPlayCover.icon.height > vid.height){
				btnPlayCover.icon.height = VH / 2;
				btnPlayCover.icon.scaleX = btnPlayCover.icon.scaleY;
				//}
				
				btnPlayCover.icon.x = VW / 2 - btnPlayCover.icon.width / 2;
				btnPlayCover.icon.y = VH / 2 - btnPlayCover.icon.height / 2;
				btnPlayCover.addEventListener(MouseEvent.MOUSE_DOWN, playPause);
				dispatchEvent(new MoreEvent(MoreEvent.VIDEO_LOADED));
				//createBars();
				
				stageVideo.viewPort = new Rectangle( 0, HH, sw , VH ) ;
				
				ns.pause();

			};
			
			
			ns.client = netClient;
			
			  //var video:StageVideo = stage.stageVideos[0] ;
			stageVideo = GlobalVarContainer.MainStage.stageVideos[0] ;
			//stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange);
			 // video.viewPort = new Rectangle( 0, 0, 1024 , VH ) ;



			 // video.attachNetStream( ns ) ;
			 stageVideo.attachNetStream( ns ) ;
			ns.play(VID_PATH) ;
			
											
			  
			
		
		}
		private function stageVideoStateChange(event:StageVideoEvent):void       
		{          
			var status:String = event.status;       
			//resize();       
		}
		
		private function resize():void 
		{
			VW =  stageVideo.videoWidth ;
			VH =  stageVideo.videoHeight;
			trace("VW: " + VW + " /VH: " + VH);
			VW= GlobalVarContainer.ScreenW;
			if (stageVideo.videoWidth > 1920){
								
				FixedVH = GlobalVarContainer.ScreenW * .75;
				
			}else{			
				
				FixedVH = VH * (GlobalVarContainer.ScreenW / stageVideo.videoWidth);
			}

			
			trace("FIXED- VW: " + VW + " /VH: " + FixedVH);
			
			btnPlayCover.back.width = VW;
			btnPlayCover.back.height = FixedVH;
			addChild(btnPlayCover);
			//btnPlayCover.y = HH;
			
			
			//if (btnPlayCover.icon.height > vid.height){
			btnPlayCover.icon.height = FixedVH / 2;
			btnPlayCover.icon.scaleX = btnPlayCover.icon.scaleY;
			//}
			
			btnPlayCover.icon.x = VW / 2 - btnPlayCover.icon.width / 2;
			btnPlayCover.icon.y = FixedVH / 2 - btnPlayCover.icon.height / 2;
			btnPlayCover.addEventListener(MouseEvent.MOUSE_DOWN, playPause);
			dispatchEvent(new MoreEvent(MoreEvent.VIDEO_LOADED));
			//createBars();
			
			stageVideo.viewPort = new Rectangle( 0, HH, sw , 768 ) ;
			
			ns.pause();
		}
		
		private function onPlayMovie(e:MouseEvent):void 
		{
			btnPlayCover.removeEventListener(MouseEvent.MOUSE_DOWN, onPlayMovie);
			btnPlayCover.addEventListener(MouseEvent.MOUSE_DOWN, playPause);
			btnPlayCover.alpha = 0;
		}
			
		private function playPause(e:MouseEvent):void
		{
		/*	btnPlayCover.back.height = 500;
			btnPlayCover.back.y = 100;*/
		  if (btnPlayCover.alpha != 0)
		  {
			  btnPlayCover.alpha = 0;
			 // movieButton.nextFrame();
			  ns.resume();
		  }else {
			  btnPlayCover.alpha = 1;
			 // movieButton.prevFrame();
			  ns.pause();
		  }
		}		 
		
		 public function goClear():void{ns.close();
				ns.dispose();
				nc.close();
			   if(!IS_STAGE_VIDEO){
					removeChild(vid);					
					vid.clear();
			   }else {
				    stageVideo.attachNetStream(null);
					
			   }
			   //TweenMax.to(btn_Skip, .5, { alpha:0, ease:Strong.easeOut } );
			  
		 } 	
		 
		 
		private function onNetStatus(e:NetStatusEvent):void{

		   switch(e.info.code){
					 case "NetStream.Play.StreamNotFound":
							   //do something
							   break;
					 case "NetStream.Play.Start":
						 if (!VIDEO_STARTED){
							 pauseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
							 pauseTimer.start();
							 VIDEO_STARTED = true;
						 }
							   //do something
							   break
						 
					 case "NetStream.Play.Stop":
								
								ns.seek(0);
								ns.pause();
								btnPlayCover.alpha = 1;
							   break;
					 case "NetStream.Buffer.Empty":
								/*ns.seek(0);
								ns.pause();
								btnPlayCover.alpha = 1;*/
							   //do something
							   break;
					 case "NetStream.Buffer.Full":
							   //do something
							   break;
					 case "NetStream.Buffer.Flush":
							   //do something
							   break;
		   }
		}
		
		private function onTimerComplete(e:TimerEvent):void 
		{
			ns.pause();
			pauseTimer.stop();
			pauseTimer = null;
		}
		
		private function onAsynchError(e:AsyncErrorEvent):void
		{
			trace(e.text);
		}
	}

}