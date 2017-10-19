package modules 
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.StageVideoAvailability;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class PostVideo extends Sprite
	{
		
		private var ns:NetStream;
		private var obj:Object;
		private var sv:StageVideo;
		private var videoWidth:Number;
		private var videoHeight:Number;
		private var VH:Number=768;
		private var videoPath:String;
		
		//Toggel vars
		private var stageVideoInUse:Boolean = false;
		private var classicVideoInUse:Boolean = false;
		private var IS_IPAD_UNO:Boolean = false;
		private var played:Boolean = false;
		private var IS_STAGE_VIDEO:Boolean = false;
		private var video:Video;
		private var stageVideo:StageVideo;
		private var rc:Rectangle;
		private var Cover:BigBlackBack = new BigBlackBack();
		private var BOSS_NUM:Number=0;
		public var sfx_fanfare:Sound = new Sfx_Fanfare();
		private var bossOutro:BossVictory_Screen = new BossVictory_Screen();
		
	{
		
		public function PostVideo(s:String) 
		{
			

			BOSS_NUM = n+1;			
			//videoPath = new File(new File( "intro_videos/intro_video.mp4" ).nativePath).url; 
			var fPath:String =  s;
			
			videoPath = s;
			
			
			// trace("Setting up "+videoPath);

			videoWidth = 1024;
			videoHeight = VH;
			
			
		 }
		
		 public function InitVideo():void {
			 addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		 }
		 
		 //stage is ready
		 private function onAddedToStage(e:Event):void{
		   GlobalVarContainer.MainStage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);		   
		 		   
		 } 
		 
		 private function SetupVideo():void {
			 trace("Setting up VIDEO");

		      var nc:NetConnection = new NetConnection() ;

			  nc.connect(null) ;

			  ns = new NetStream(nc) ;

			  ns.client = this ;

			  //var video:StageVideo = stage.stageVideos[0] ;
			  stageVideo = stage.stageVideos[0] ;

			 // video.viewPort = new Rectangle( 0, 0, 1024 , VH ) ;
			  stageVideo.viewPort = new Rectangle( 0, 0, 1024 , VH ) ;



			 // video.attachNetStream( ns ) ;
			  stageVideo.attachNetStream( ns ) ;
				ns.play(videoPath) ;
			
											
			  
			
			this.addChild(Cover);
			//Cover.addEventListener(MouseEvent.CLICK, onSkipVideo);
			  
		  /* //trace("Trying to play video! " + GlobalVarContainer.MainStage.stageVideos.length);
		    testText.title_txt.htmlText="Trying to play video! "
		   sv = stage.stageVideos[0];
		   sv.viewPort = new Rectangle(0, 0, 1024 , 500 );
		   sv.attachNetStream(ns);*/
			
		   //playVideo();
		 }
		 
		 public function onSkipVideo(e:MouseEvent):void 
		 {
			ns.pause();
			if (BOSS_NUM == 4) bossOutro.body.title.gotoAndStop(2);
			bossOutro.hero.gotoAndStop(GlobalVarContainer.PLAYER.ICON);
		//	bossOutro.title.gotoAndStop(GlobalVarContainer.PLAYER.ICON));
			bossOutro.alpha = 0;
			bossOutro.congrats.scaleX = bossOutro.congrats.scaleY = .2;
			bossOutro.congrats.alpha = 0;			 
			bossOutro.btn_menu.visible = false;			 
			bossOutro.btn_menu.alpha = 0;			 
		    bossOutro.plaque.gotoAndStop(BOSS_NUM);	 
			bossOutro.plaque.y = 788;
			addChild(bossOutro);
			TweenMax.to(bossOutro, .6, { alpha:1, ease:Strong.easeOut, onComplete:SetIntroEvents } );
		 }
		 
		 //************** BOSS INSTRUCTION EVENTS *********************//
		 private function SetIntroEvents():void 
		 {			 
			 
			TweenMax.to(bossOutro.congrats, .4, { scaleX:1, scaleY:1, alpha:1, ease:Bounce.easeOut, delay:.4 } );
			TweenMax.to(bossOutro.hero, .4, { y:42, ease:Strong.easeIn } );
			TweenMax.to(bossOutro.plaque, .4, { y:113, ease:Strong.easeIn, delay:.8 } );
			TweenMax.to(bossOutro.btn_menu, .4, { autoAlpha:1, ease:Strong.easeIn, delay:1.4 } );
			TweenMax.to(bossOutro.body, .4, { frame:bossOutro.body.totalFrames, ease:Strong.easeOut, delay:1.6 } );
			sfx_fanfare.play();
			GlobalVarContainer.PLAYER.GoYell();
			stopVideo();
			bossOutro.btn_menu.addEventListener(MouseEvent.CLICK, onReturnToMenu);
		 }
		 
		 
		 private function onReturnToMenu(e:MouseEvent):void 
		 {
			 GlobalVarContainer.MainBase.sfx_select.play();
			 GlobalVarContainer.MainBase.CloseVictoryVideo();
		 }
		 
		 
		 
		public function playVideo():void{
			   ns.play( videoPath );
			   ns.addEventListener(NetStatusEvent.NET_STATUS, videoStatus);
		}
  
		 //required metadata for stagevideo, even if not used
		 private function MetaData(info:Object):void { } 
					 
	    private function videoStatus(e:NetStatusEvent):void{

		   switch(e.info.code){
					 case "NetStream.Play.StreamNotFound":
							   //do something
							   break;
					 case "NetStream.Play.Start":
							   //do something
							   break
					 case "NetStream.Play.Stop":
								onSkipVideo(null);
							  // stopVideo();
							   break;
					 case "NetStream.Buffer.Empty":
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

		 //stop and clear the video
		 //public, can be called externally
		 public function stopVideo():void{
			   ns.close();			  
			   ns.dispose();
			   if(!IS_STAGE_VIDEO){
					removeChild(video);
					video = null;
			   }else {
				    stageVideo.attachNetStream(null);
			   }
			   //TweenMax.to(btn_Skip, .5, { alpha:0, ease:Strong.easeOut } );
			  
		 } 
		 
		 private function onStageVideoState(event:StageVideoAvailabilityEvent):void { 
			var available:Boolean = (event.availability == StageVideoAvailability.AVAILABLE); 
		//	trace("AVAILABILITY: " + available);
			toggleStageVideo(available);
			//SetupVideo();
		 }
		 
		 private function toggleStageVideo(on:Boolean):void { 
		 // if StageVideo is available, attach the NetStream to StageVideo 
			IS_STAGE_VIDEO = on;
			 if (on) { 
				 SetupVideo();
				 /*stageVideoInUse = true; 
				 if ( sv == null ) { 
					 sv = stage.stageVideos[0]; 
					 sv.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange); 
				 } 
				 sv.attachNetStream(ns); 
					 if (classicVideoInUse) { 
						 trace("Removing Video");
						 // If using StageVideo, just remove the Video object from // the display list to avoid covering the StageVideo object // (always in the background) 
						 this.removeChild ( video ); 
						 classicVideoInUse = false; 
					} */
			} else { 
				
					// Otherwise attach it to a Video object 
					if (stageVideoInUse) stageVideoInUse = false; 
		//			trace("creating video");
					video = new Video(1024,VH);
					//addChild(video);
					classicVideoInUse = true; 
					var nc:NetConnection = new NetConnection();
					nc.connect(null);

					ns =  new NetStream(nc);
					video.attachNetStream(ns); 
					this.addChild(video); 
					video.y = 0;
			} 
				
			if ( !played ) { 
				
				obj = new Object();

				ns.client = obj; 
				ns.bufferTime = 2;
				ns.client = obj;

				obj.onMetaData = MetaData;
				played = true; 
		//		trace("Playing");
				//ns.play(videoPath); 
				playVideo();
				if(!on)
				this.addChild(video); 
			} 
			
			
			this.addChild(Cover);
			Cover.addEventListener(MouseEvent.CLICK, onSkipVideo);
			/*if(on){
				testText.title_txt.htmlText = "true";
			}else {
				testText.title_txt.htmlText = "false";
			}*/
		} 
		
		private function stageVideoStateChange(event:StageVideoEvent):void { 
			var status:String = event.status; resize(); 
		}
		
		
		private function resize ():void { 
	//		trace("RESIZING");
			 rc = new Rectangle(0,50, 1024, 668); 
			 sv.viewPort = rc; 
		}
	}

	}

}