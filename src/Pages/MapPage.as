package Pages 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import utilities.LoadedImage;
	import utilities.LoadedImageEvent;
	import flash.ui.MultitouchInputMode;
	import flash.events.*;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class MapPage extends Sprite
	{
		
		private var header:SectionHeader = new SectionHeader();
		private var map:MovieClip= new MovieClip();
		private var img:LoadedImage;
		private var cover:LoadingCover = new LoadingCover();
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		
		//private var OrigW:Number;
		//private var OrigH:Number;
		private var MinSc:Number;
		private var MaxSc:Number;
		
		private var xtraW:Number;
		public var ds:Number = 12;
		public var BoundsLeft:Number=sw;
		public var BoundsRight:Number=0;
		public var BoundsTop:Number=0;
		public var BoundsBottom:Number=sh;
		private var Xfinal:Number;
		private var Yfinal:Number;
		private var drag:Boolean = false;
		private var vy:Number;
		private var vx:Number;
		private var yd:Number;
		private var xd:Number;
		private var bounce:Number = -0.8;
		
		public function MapPage() 
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			
			header.title_txt.autoSize = "center";
			
			header.width = sw;
			header.scaleY = header.scaleX;
			GlobalVarContainer.HEADER_HEIGHT = header.height;
			
			header.title_txt.htmlText = "Map";
			header.title_txt.x = header.back.width / 2- header.title_txt.width/2
			
			header.btn_menu.x = sw - header.btn_menu.width -10;
			header.btn_menu.buttonMode = true;
			header.btn_back.buttonMode = true;
			header.btn_back.addEventListener(MouseEvent.MOUSE_DOWN, onBack);
			
			header.btn_menu.addEventListener(MouseEvent.MOUSE_DOWN, onShowMenu);
			
			cover.back.width = sw;
			cover.back.height = sh;
			cover.y = header.height;
			cover.loader.x = sw / 2;
			cover.loader.y = sh / 2;
			
			
			cover.title_txt.autoSize = "center";
			cover.title_txt.htmlText = "Loading Map";
			cover.title_txt.x=sw / 2- cover.title_txt.width/2;
			cover.title_txt.y = cover.loader.y + cover.loader.height / 2 + 5;
			
			this.addChild(header);
			addChild(cover);
			
			
		
		}
		
		private function onShowMenu(e:MouseEvent):void 
		{
			GlobalVarContainer.MainBase.ShowMenu();
		}
		
		private function onBack(e:MouseEvent):void 
		{
			header.btn_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBack);
			
			map.removeEventListener(MouseEvent.MOUSE_DOWN, onEvent);
			map.removeEventListener(MouseEvent.DOUBLE_CLICK, onEvent);
			GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_UP, onEvent);
			this.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			
			TweenMax.to(this, 1, {alpha:0, ease:Strong.easeOut, onComplete:ResetMap});
		}
		
		
		public function init():void
		{
			img = new LoadedImage(GlobalVarContainer.MAIN_MAP_PATH);
			img.addEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			img.loadImage();
		}
		
		private function onImgComplete(e:LoadedImageEvent):void 
		{
			
			img.removeEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			
			this.addChild(map);
			map.addChild(img);
			img.x = 0- img.width / 2;
			img.y = 0 - img.height / 2;
			
			
			var sc:Number;
			
			var scw:Number =sw/ img.width ;
			var sch:Number = (sh-header.height)/img.height;
			
			if (scw > sch) {
				sc = scw;
			}else {
				sc = sch;
			}
			map.scaleX = map.scaleY = MinSc=sc;
			
			
			map.x = sw / 2 ;
			map.y = header.height+map.height/2; 
			
			MaxSc = MinSc * 2.5;
			BoundsTop = header.height;
			
			map.alpha = 0;
			TweenMax.to(map, 1, {alpha:1, ease:Strong.easeOut, onComplete:EnableMap});
			
			
			this.addChild(header);
			
		}
		
		private function EnableMap():void{
			
			if (GlobalVarContainer.SHOW_TUTORIAL && GlobalVarContainer.TUTORIAL_ARRAY[5] == 0)
			GlobalVarContainer.MainBase.ShowTutorial(5)
			
			trace("TUT ARRAY: " + GlobalVarContainer.TUTORIAL_ARRAY);
			map.doubleClickEnabled = true;
			map.mouseChildren = false;
			
			map.addEventListener(MouseEvent.DOUBLE_CLICK, onEvent);
			map.addEventListener(MouseEvent.MOUSE_DOWN, onEvent);
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_UP, onEvent);
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_OUT, onEvent);
			this.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
			
			if(this.getChildByName(cover.name)){
				removeChild(cover);
				cover = null;
			}
		}
		
		private function onEvent(e:MouseEvent):void {
					
			switch (e.type) {
				case "mouseDown":
						
					trace("Trying to drag");
					DragHolder();
					break;
				
				case "mouseOut":	
				case "mouseUp":										
					
						map.addEventListener(MouseEvent.MOUSE_DOWN, onEvent);
					
						GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_UP, onEvent);
						GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_OUT, onEvent);
				
						drag = false;
						Xfinal = this.mouseX;
						Yfinal = this.mouseY;
					break;
					
				case "doubleClick":
					trace("DOUBLE CLICK");
					var goY:Number=header.height+map.height/2;
					
					if (map.scaleX == MinSc){
						TweenMax.to(map, .5, { scaleX:MaxSc, scaleY:MaxSc, x:sw/2, y:goY, ease:Strong.easeOut, onComplete:RemoveDrag, onCompleteParams:[goY]});
					}else{
						
						TweenMax.to(map, .5, { scaleX:MinSc, scaleY:MinSc, x:sw/2, y:goY, ease:Strong.easeOut, onComplete:RemoveDrag, onCompleteParams:[goY]});
					}
					
					break;
			}
		}
		
		private function RemoveDrag(goY:Number):void 
		{
			
			Xfinal = sw / 2;
			Yfinal = goY;
		}
		
		private function onZoom(e:TransformGestureEvent):void {
			
			//var mc:MovieClip = e.currentTarget as MovieClip;
			//trace("MC= " + mc);
			map.scaleY = map.scaleX *= e.scaleX;
			if (map.scaleY < MinSc) {
				map.scaleY = map.scaleX = MinSc;
			}else if(map.scaleY > MaxSc) {
				map.scaleY = map.scaleX = MaxSc;
			}
			
			
			trace("ZOOOOMING= "+map.width+" : "+map.height+" : "+map.width*map.height );
		}
		
		
		private function DragHolder():void
		{
			
		
			map.removeEventListener(MouseEvent.MOUSE_DOWN, onEvent);
			map.addEventListener(Event.ENTER_FRAME, GoDrag);
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_UP, onEvent);
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_OUT, onEvent);
			//tf.addEventListener(MouseEvent.MOUSE_OUT, DragStop);
			
			drag = true;
			xd = map.x - this.mouseX;
			yd = map.y - this.mouseY;
			
			BoundsRight =sw;
			
		}
		
		private function DragStop(e:MouseEvent):void
		{
		
			map.addEventListener(MouseEvent.MOUSE_DOWN, onEvent);
			GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_UP, DragStop);
			GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_OUT, onEvent);
			//tf.removeEventListener(Event.ENTER_FRAME, GoDrag);
			
			
				drag = false;
				Xfinal = this.mouseX;
				Yfinal = this.mouseY;
		}
		
		private function GoDrag(e:Event):void 
		{
				
				if (drag) {
					vx = this.mouseX + xd;
					vy = this.mouseY + yd;
				} else {
					vx = Xfinal + xd;
					vy = Yfinal + yd;
					
					var diffX:Number = (vx - map.x) / ds;
					var diffY:Number = (vy - map.y) / ds;
					//trace("Dragging Bars "+ diff+ " : "+ map.x);
					
					if (Math.abs(diffX) < .2 && Math.abs(diffY)<.2) {					
					//	trace("Dragging Bars Stopping " + vy);
						map.removeEventListener(Event.ENTER_FRAME, GoDrag);
						
					}
				}
				// change value here to change speed
				
				trace("MOVEMENT= " + map.x + " / " + map.y);
				
				map.x += (vx - map.x) / ds;
				map.y += (vy - map.y) / ds;
				
				
				/*if(map.width<sw*2){
					BoundsLeft = 0;
					BoundsRight = sw;
				}else {
					BoundsLeft = 0 - (map.width/2-sw);
					BoundsRight = map.width/2;
				}
				
				if(map.height<sh*2){
					BoundsTop = 0;
					BoundsBottom = sh;
				}else {
					BoundsTop = 0 - (map.height/2-sh);
					BoundsBottom = map.height/2;
				}*/
				
				BoundsLeft = 0 - (map.width/2-sw);
				BoundsRight = map.width/2;
				
				BoundsTop = 0-(map.height/2-sh);
				BoundsBottom = map.height/2+header.height;
				
				if (map.x < BoundsLeft)
				map.x = BoundsLeft;
			
				if (map.x > BoundsRight)
				map.x = BoundsRight;
				
				if (map.y > BoundsBottom)
				map.y = BoundsBottom;
				
				if (map.y < BoundsTop)
				map.y = BoundsTop;
				
				//trace("POS= " + tf.x + " : " + tf.y);
		}
		
		
		
		public function ResetMap():void 
		{
			map.removeEventListener(Event.ENTER_FRAME, GoDrag);			
			
			
			this.dispatchEvent(new MoreEvent(MoreEvent.UNLOAD_PAGE));
						
		}
		
		public function closeMap():void {
			
			map.removeEventListener(Event.ENTER_FRAME, GoDrag);
		}
	}

}