package modules 
{
	import content.Exhibit;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class ExhibitsSlider extends MovieClip
	{
		private var imgArray:Array;
		private var exArray:Array;
		private var cnt:Number = 0;
		public var CURR_SLIDE:Number = 0;
		private var slide:ExhibitSlide;
		private var slideHolder:Sprite= new Sprite();
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var navtabLeft:NavTab;
		private var navtabRight:NavTab
		
		private var slideMask:Btn_Black = new Btn_Black();
		public var Min_Height:Number = 2000;
		private var StartX:Number = 100;
		private var THRESH:Number = 100;
		private var dragRect:Rectangle;
		
		public function ExhibitsSlider() 
		{
			exArray = GlobalVarContainer.EXHIBITS;
			addChild(slideHolder);
		}
		
		public function LoadExhibits():void{
			addChild(slideMask);
			slideMask.width = sw;
			slideHolder.mask = slideMask;
			var ex:Exhibit = exArray[cnt];
		//	trace("ORDER: " + ex.SORT_ORDER);
			slide = new ExhibitSlide(ex.IMAGE, ex.TITLE);
			slide.addEventListener(MoreEvent.SLIDE_LOADED, onSlideLoaded);
		}
		
		private function onSlideLoaded(e:MoreEvent):void 
		{			
			slide.removeEventListener(MoreEvent.SLIDE_LOADED, onSlideLoaded);
			slideHolder.addChild(slide);
			slide.alpha = 0;
			TweenMax.to(slide, 1, {alpha:1, ease:Strong.easeOut});
			slide.x = sw * cnt
			if (slide.height < Min_Height){
				slideMask.height=Min_Height = slide.height;
			}
			
			if (cnt < 1) this.dispatchEvent(new MoreEvent(MoreEvent.INIT_SLIDE_LOADED));
			
			cnt++;
			
			if (cnt < exArray.length){
				LoadExhibits();
			}else{
				
				if(exArray.length>1){
					addTabs();
					SetupDragging();
				}
				
				var len:Number = (exArray.length - 1) * sw;
				dragRect = new Rectangle(0 - len, 0, len, 0);
				this.dispatchEvent(new MoreEvent(MoreEvent.SLIDER_LOADED));
				trace("Slides Loaded");
			}
		}
		
		private function SetupDragging():void 
		{
			slideHolder.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
		}
		
		private function onStartDrag(e:MouseEvent):void 
		{
			StartX = this.mouseX;
			slideHolder.startDrag(false, dragRect);
			this.addEventListener(Event.ENTER_FRAME, DragHome);
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_UP, onStopDrag);
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_OUT, onStopDrag);
		}
		
		private function addTabs():void 
		{
		//	trace("EX SLIDER HEIGHT: " + this.height+" / "+Min_Height);
			var sc:Number = sh / GlobalVarContainer.SCALE_HEIGHT;
			
			navtabLeft = new NavTab();
			navtabLeft.buttonMode = true;
			navtabLeft.addEventListener(MouseEvent.MOUSE_DOWN, onGoPrev);			
		
			navtabRight = new NavTab();
			navtabRight.buttonMode = true;
			navtabRight.addEventListener(MouseEvent.MOUSE_DOWN, onGoNext);
			
			navtabLeft.scaleX = navtabLeft.scaleY = navtabRight.scaleX = navtabRight.scaleY = sc;
			
			navtabRight.x = sw - navtabRight.width;
			navtabRight.y = Min_Height-70-navtabLeft.height;
			
			
			navtabLeft.scaleX *=-1;
			navtabLeft.x = navtabLeft.width;
			navtabLeft.y = Min_Height-70-navtabLeft.height;
			
			navtabLeft.visible = false;
			
			addChild(navtabLeft);
			addChild(navtabRight);
			
		}
		
		private function DragHome(e:Event):void 
		{
			 var mov:Number = StartX - this.mouseX;
			
		//		 trace("MOV: " + mov);
			if(Math.abs(mov)>10){
				 var mx:Number = 0 - (CURR_SLIDE*sw) - mov;
		//		 trace("MX: " + mx + " / Len: " +(CURR_SLIDE*sw));
				 
				 if (mx<0&&mx>0-(slideHolder.width-sw))
				 slideHolder.x = mx;
				 var goX:Number= 0;
				if (Math.abs(mov) > THRESH) {
					slideHolder.stopDrag();				
					GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);
					this.removeEventListener(Event.ENTER_FRAME, DragHome);
					
					if (mov < 0) {
						if (CURR_SLIDE > 0) { 
							onGoPrev(null);
						}
					}else {
						if (CURR_SLIDE < exArray.length - 1) {
							
							onGoNext(null);
							//ChangeDot();
						}
					}
				}
			}
			
		}
		
		/*
		private function ChangeDot():void 
		{
			for (var i:uint = 0; i < dotArray.length;++i) {
				dot = dotArray[i];
				dot.gotoAndStop(1);
			}
			
			dotArray[CURR_SLIDE].gotoAndStop(2);
		}
		*/
		private function onStopDrag(e:MouseEvent):void 
		{			
			slideHolder.stopDrag();
			TweenMax.to(slideHolder, .5, { x:0-sw*CURR_SLIDE, ease:Strong.easeOut} );
			this.removeEventListener(Event.ENTER_FRAME, DragHome);
		}
	

		private function onGoPrev(e:Event):void 
		{
			
			if (GlobalVarContainer.LOADING_COMPONENTS) return;
			navtabRight.visible = true;
			CURR_SLIDE--;
			if (CURR_SLIDE == 0){
				navtabLeft.visible = false;
			}
			TweenMax.to(slideHolder, .5, {x:0 - CURR_SLIDE * sw, ease:Strong.easeOut});
			
			this.dispatchEvent(new MoreEvent(MoreEvent.SLIDE_CHANGED));
		}
		
		private function onGoNext(e:Event):void 
		{
			if (GlobalVarContainer.LOADING_COMPONENTS) return;
			navtabLeft.visible = true;
			CURR_SLIDE++;
			if (CURR_SLIDE == exArray.length-1){
				navtabRight.visible = false;
			}
			TweenMax.to(slideHolder, .5, {x:0 - CURR_SLIDE * sw, ease:Strong.easeOut});
			
			this.dispatchEvent(new MoreEvent(MoreEvent.SLIDE_CHANGED));
		}
		
		
	}

}