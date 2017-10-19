package utilities{

	import com.greensock.TimelineLite;
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.*;
	import flash.media.Video;
	import flash.media.SoundTransform;
	import flash.net.ObjectEncoding;
	import flash.utils.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	
	public class SimpleVideoPlayer extends Sprite {
		private var nc:NetConnection;
		private var ns:NetStream;
		private var volume:Number;
		private var load_mc:MovieClip;
		private var back_mc:MovieClip;
		private var mask_mc:MovieClip;
		private  var vid:Video;
		private var dragBack:Rectangle;
		private var movieTime:Number;
		public var VW:Number;
		public var VH:Number;
		private var StartX:Number;
		private var playhead:Playhead;
		private var squished:Boolean;
		private var vidPlaying:Boolean = false;
		private var scrubbing:Boolean = false;
		private var IS_FULLSCREEN:Boolean = false;
		private var CHECK_VOL:Boolean = false;
		private var infoClient:Object;
		private var movieButton:MovieButtons = new MovieButtons();
		public var IS_SEEKING:Boolean=false;
		public var AFTER_SEEK:Boolean=false;
		public var MOVIE_PLAYING:Boolean=false;
		//public var btn_fs:Btn_FullScreen = new Btn_FullScreen();
		//public var btn_vol:Btn_VidVolume = new Btn_VidVolume();
		public var volSlider:VolSlider = new VolSlider();
		private var dragRect:Rectangle;
		public var afterTimer:Timer = new Timer(50, 1);
		private var btnPlayCover:VideoPlayCover = new VideoPlayCover();
		
		public function SimpleVideoPlayer(movie:String, c:Boolean=false):void
		{
			trace("MOVIE: " + movie);
			nc= new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			//  squished = c;
			infoClient = new Object();
			infoClient.onMetaData = onMetaData;
			ns.client = infoClient;
			
			ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsynchError, false, 0, true);
					
			/*VW = w;
			VH = h;
			  
			var backBlack:BitmapData = new BitmapData(w, h, false, 0x000000);
			var bmc:Bitmap = new Bitmap(backBlack);
			var b_mc:MovieClip = new MovieClip();
			b_mc.addChild(bmc);
			addChild(b_mc);*/
			 
			vid = new Video();
			vid.smoothing = true;
			this.addChild(vid);
			vid.attachNetStream(ns);
			//SetVideoVolume(GlobalVarContainer.VIDEO_VOL*10);
			ns.play(movie);
			var netClient:Object = new Object();
			
			netClient.onMetaData = function(meta:Object):void
			{
				trace("META DUR+ "+meta.duration);
				movieTime = meta.duration;
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
			ns.addEventListener(NetStatusEvent.NET_STATUS, netstat);
			//**SET UP THE BUTTONS
			//this.addChild(movieButton);
			movieButton.addEventListener(MouseEvent.CLICK, playPause);
			movieButton.x = 10;
			
			//movieButton.y = h - 20;
			
			movieButton.buttonMode = true;
			
			//****SET UP THE BARS*********
		//	this.createBars();
			
			
			afterTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onAfterSeekComplete);
		}
		
	
		
		private function onPlayMovie(e:MouseEvent):void 
		{
			btnPlayCover.removeEventListener(MouseEvent.MOUSE_DOWN, onPlayMovie);
			btnPlayCover.addEventListener(MouseEvent.MOUSE_DOWN, playPause);
			btnPlayCover.alpha = 0;
		}
			
			
			private function netstat(stats:NetStatusEvent):void
			{
				  trace(stats.info.code);
			};
	  
			 public function goClear():void
			 {
				 
				trace("Clearing Video");
				//afterTimer.reset();
				//this.removeEventListener(Event.ENTER_FRAME, goProgress);
				//this.removeChild(load_mc);
				//if (this.getChildByName("Play_Head")this.removeChild(playhead);
				//playhead.visible = false;
				ns.close();
				ns.dispose();
				nc.close();
				vid.clear();
			 }
		
			public function LoadMovie(movie:String):void {
				if (vidPlaying) {
					ns.close();
					ns.dispose();
					vid.attachNetStream(null);							
				}
				
				AddMovie(movie);
		
				
			}
			
			private function AddMovie(movie:String):void 
			{
				ns.play(movie);
				addChild(vid);
				
				vid.attachNetStream(ns);
			}
				  
			private function playPause(e:MouseEvent):void
			{
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

			public function SetSeek(n:Number):void {
			//  if (GlobalVarContainer.VIDEO_NAV == "RIGHT-LEFT") n *= -1;
				playhead.width = StartX- n;
				var navPoint:Number = playhead.width;
				if ((navPoint) > (back_mc.width * ns.bytesLoaded / ns.bytesTotal))
				navPoint = (back_mc.width * ns.bytesLoaded / ns.bytesTotal);
				var timeSeek:Number = (navPoint) * movieTime / back_mc.width;
				ns.seek(timeSeek);
			}

			/* private function fullScreenButtonHandler(event:MouseEvent) 
			{ 
			var screenRectangle:Rectangle = new Rectangle(this.x, this.y, this.width, this.height); 
			stage.fullScreenSourceRect = screenRectangle; 
			stage.displayState = StageDisplayState.FULL_SCREEN; 
			}*/

			private function SetVideoVolume(n:Number):void {
				var videoVolumeTransform:SoundTransform = new SoundTransform();
				GlobalVarContainer.VIDEO_VOL = videoVolumeTransform.volume = n / 10;
				trace("VOL: " + GlobalVarContainer.VIDEO_VOL);
				ns.soundTransform = videoVolumeTransform;
			}

			private function createBars():void
			{
				var lbar:BitmapData = new BitmapData(VW, 20, false, 0x4f4f4f);
				var loadBar:Bitmap = new Bitmap(lbar);
				var bbar:BitmapData = new BitmapData(VW, 20, false, 0x2c2c2c);
				var backBar:Bitmap = new Bitmap(bbar);
					

				back_mc = new MovieClip();
				load_mc = new MovieClip();
				load_mc.alpha = 0;
				playhead = new Playhead();
				playhead.height = 20;
				playhead.name = "Play_Head";
				this.addChild(back_mc);
				this.addChild(load_mc);
				load_mc.mouseEnabled = false;
				//playhead.addEventListener(MouseEvent.MOUSE_DOWN, startSeek);
				//GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_UP, startSeek);
				//playhead.addEventListener(MouseEvent.MOUSE_OUT, startSeek);

				back_mc.addChild(backBar);	
				back_mc.alpha = .6;
				back_mc.x = load_mc.x=playhead.x=0;
				back_mc.y = load_mc.y = VH - 20;	
				playhead.alpha = .2;
				playhead.width = 0;
				playhead.y= VH - 20;
				dragRect = new Rectangle(back_mc.x, playhead.y, back_mc.width, 0);
				this.addChild(playhead);
				
				//Full Screen Button
				/*this.addChild(btn_fs);
				btn_fs.y = movieButton.y;
				btn_fs.x = VW-20;
				btn_fs.addEventListener(MouseEvent.CLICK, onFullScreen);
				btn_fs.buttonMode = true;*/
				//this.addChild(btn_vol);
				
				
				//Volume Sliders
				//btn_vol.y = movieButton.y;
				//btn_vol.x = VW-40;
				//btn_vol.addEventListener(MouseEvent.CLICK, onMuteVol);
				/*btn_vol.back.addEventListener(MouseEvent.MOUSE_DOWN, onShowVolumeControls);
				
				volSlider.addEventListener(MouseEvent.MOUSE_DOWN, onUseSlider);
				volSlider.addEventListener(MouseEvent.MOUSE_UP, onUseSlider);
				volSlider.addEventListener(MouseEvent.MOUSE_OUT, onUseSlider);*/
				//btn_vol.buttonMode = true;
			//	btn_vol.addChild(volSlider);
				volSlider.x = 5;
				volSlider.y = 0 ;
				volSlider.visible = false;
				volSlider.gotoAndStop(GlobalVarContainer.VIDEO_VOL * 10+1);
				load_mc.addChild(loadBar);	
				this.addEventListener(Event.ENTER_FRAME, goProgress);
				this.dispatchEvent(new MoreEvent(MoreEvent.VIDEO_LOADED));
			}

		public function SetPause():void {
		  ns.togglePause();			  
		  
		}

		public function SetSeekTime():void {
		  StartX = playhead.width;
		}

		private function startSeek(e:MouseEvent):void 
		{
			switch (e.type) {
				case "mouseDown":
					playhead.startDrag(false,dragRect);
					IS_SEEKING = true;
					break;

			
				case "mouseUp":
					AFTER_SEEK = true;
					afterTimer.start();
					playhead.stopDrag();	
					IS_SEEKING = false;
					break;
					
				case "mouseOut":
					break;
			}
		}

		private function onAfterSeekComplete(e:TimerEvent):void 
		{
			afterTimer.reset();
			AFTER_SEEK = false;
		}
		//Click to seek - Depricated
		/*private function goSeek(e:MouseEvent):void {
			var navPoint:Number = this.mouseX;
			if ((navPoint - 30) > (back_mc.width * ns.bytesLoaded / ns.bytesTotal))
			navPoint = (back_mc.width * ns.bytesLoaded / ns.bytesTotal);
			ns.seek((navPoint- 30) * movieTime / back_mc.width);
		}*/

		private function onUseSlider(e:MouseEvent):void 
		{			  
		  switch(e.type) {
			case "mouseUp":
					CHECK_VOL = false;
					TweenMax.to(volSlider, 1, { autoAlpha:0, delay:2, ease:Strong.easeOut } );
					break;
			case "mouseDown":
					TweenMax.killTweensOf(volSlider);
					volSlider.visible = true;
					volSlider.alpha = 1;
					CHECK_VOL = true;
					break;
			case "mouseOut":
					if(CHECK_VOL){
						TweenMax.killTweensOf(volSlider);
						TweenMax.to(volSlider, 1, { autoAlpha:0, delay:2, ease:Strong.easeOut } );
						CHECK_VOL = false;
					}
					break;
		  }
		}

			  
		private function onHideVolumeControls(e:MouseEvent):void 
		{
		  volSlider.visible = false
		  CHECK_VOL = false;
		}

		private function onShowVolumeControls(e:MouseEvent):void 
		{
		  if(!volSlider.visible){
			  volSlider.visible = true;			  
			 // btn_vol.gotoAndStop(1);
			TweenMax.killTweensOf(volSlider);
			volSlider.visible = true;
			volSlider.alpha = 1;
			
			TweenMax.to(volSlider, 1, { autoAlpha:0, delay:2, ease:Strong.easeOut } );
		  }else {
			TweenMax.killTweensOf(volSlider);
			volSlider.alpha = 1;
			 volSlider.visible = false
			CHECK_VOL = false;
		  }
		}

		/*private function onFullScreen(e:MouseEvent):void 
		{
		  if (btn_fs.currentFrame==1) {
			  btn_fs.gotoAndStop(2);
			  trace("Going normal Mode");
			  GlobalVarContainer.VIDEO_PAGE.onFullscreenVideo();
		  }else {
			  btn_fs.gotoAndStop(1);
			  trace("Going normal Mode");
			  GlobalVarContainer.VIDEO_PAGE.onFullscreenVideo();			
		  }
			  
		}*/
		  
		


	  	private function createMask():void
		{			
			mask_mc = new MovieClip();
			
			var rct:BitmapData = new BitmapData(VW, VH, false, 0xFFFFFF);
			
			var rect:Bitmap = new Bitmap(rct);
			mask_mc.addChild(rect);
			this.addChild(mask_mc);
			mask_mc.x= 0;
			mask_mc.y = 10;
			vid.mask = mask_mc;
		}
		
		private function goProgress(e:Event):void
		{
			if(vidPlaying){
			//trace((ns.bytesLoaded / ns.bytesTotal));
			//load_mc.scaleX = Math.round((ns.bytesLoaded/ns.bytesTotal)*100)/100;
			load_mc.scaleX =ns.bytesLoaded/ns.bytesTotal;
			
				if (IS_SEEKING) {
					
					var navPoint:Number = playhead.width;
					if ((navPoint) > ((back_mc.width) * ns.bytesLoaded / ns.bytesTotal))
					navPoint = ((back_mc.width) * ns.bytesLoaded / ns.bytesTotal);
					var timeSeek:Number = (navPoint) * movieTime / (back_mc.width);
					ns.seek(timeSeek);
				
				}else {					
					if(!AFTER_SEEK){
							trace("NOT AFTER SEEKING");
						playhead.width = back_mc.x + (ns.time / movieTime) * (back_mc.width);					
						
						if (playhead.width < back_mc.x )
						{
							//trace("AFTER SEEKING");
							playhead.width=back_mc.x 
						}
					}else {
						trace("AFTER SEEKING");						
						//playhead.x += 2;
					}
				}
				
			
				
				if (CHECK_VOL) {
					var vDis:Number = volSlider.height / 11;
					var my:Number = 0-volSlider.mouseY;
					var vol:Number = Math.floor(my / vDis);
					if (vol > 10) vol = 10;
					volSlider.gotoAndStop(vol+1);
					
					SetVideoVolume(vol);
				}
			}
		}
		
		
		
		//*******VIDEO METADATA AND STATUS FUNCTIONS
		private function onMetaData(info:Object):void
		{
			trace(info.duration);
			trace("VW: " + info.width + " /VH: " + info.height);
			
			VW =  info.width ;
			VH =  info.height;
			  
			vid.width = GlobalVarContainer.ScreenW;
			vid.scaleY = vid.scaleX;
			
			var backBlack:BitmapData = new BitmapData(VW, VH, false, 0x000000);
			var bmc:Bitmap = new Bitmap(backBlack);
			var b_mc:MovieClip = new MovieClip();
			b_mc.addChild(bmc);
			addChild(b_mc);
			
			createBars();
			
			this.dispatchEvent(new MoreEvent(MoreEvent.VIDEO_LOADED));
			
		}
		
		private function onAsynchError(e:AsyncErrorEvent):void
		{
			trace(e.text);
		}
		
		private function onNetStatus(e:NetStatusEvent):void{
		//	trace("CODE: "+e.info.code);
		   switch(e.info.code){
					 case "NetStream.Play.StreamNotFound":
							   //do something
							   break;
					 case "NetStream.Play.Start":
								vidPlaying = true;
							   //do something
							   break
					 case "NetStream.Play.Stop":							
							//trace("Play Stopped");
								/*if (GlobalVarContainer.LOOP_VIDEO){
									ns.seek(0);
								}*/
							  // stopVideo();
							   break;
					 case "NetStream.Buffer.Empty":							
							//trace("Play Empty");				
								/*if (GlobalVarContainer.LOOP_VIDEO){
									ns.seek(0);
								}*/
							   //do something
							   break;
					 case "NetStream.Buffer.Full":					
						//	trace("Play Full");										
							   //do something
							   break;
					 case "NetStream.Buffer.Flush":
							   //do something
							   break;
		   }
		}

	}
}