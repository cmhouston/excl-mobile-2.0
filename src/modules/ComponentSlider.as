package modules 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import content.Component;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class ComponentSlider extends Sprite
	{
		private var slideArray:Array=[];
		private var posArray:Array=[];
		private var cArray:Array;
		public var  cnt:Number = 0;
		private var START:Number = 0;
		private var co:Component;
		private var slide:CompSlide;
		private var mySlide:CompSlide;
		private var slideHolder:Sprite= new Sprite();
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var SLIDE_Height:Number;
		private var SLIDE_LENGTH:Number;
		
		
		
		//Drag Vars
		private var dvx:Number = 0;  
		// previous coordinates  
		private var prevX:Number = 0;  
		// deceleration  
		private var friction:Number = 0.9;  

		private var dragRect:Rectangle;
		
		private var StartX:Number = 100;
		private var IS_DRAGGING:Boolean = true;
		public var IS_FULLY_LOADED:Boolean = false;
		public var TOTAL_SLIDES:Number; 
		/*private var THRESH:Number = 100;
		private var dragRect:Rectangle;
		private var CURR_SLIDE:Number = 0;*/
		
		public function ComponentSlider(h:Number) 
		{
			SLIDE_Height = h;
			this.buttonMode = true;
			
			addChild(slideHolder);
		}
		
		public function LoadSlider(n:Number):void{
			//ResetSlider();
			
			cArray = GlobalVarContainer.EXHIBITS[n].COMPONENTS;
			trace("LOADING COMPONENTS SLIDER: " + cArray.length);
			TOTAL_SLIDES = cArray.length;
			LoadComponents();
			
		}
		
		private function LoadComponents():void{
			co = cArray[cnt];
			slide = new CompSlide(co.IMAGE, co.TITLE, SLIDE_Height);
			slide.addEventListener(MoreEvent.SLIDE_LOADED, onSlideLoaded); 
		}
		
		private function onSlideLoaded(e:MoreEvent):void 
		{
			this.dispatchEvent(new MoreEvent(MoreEvent.UPDATE_COUNTER));
			slide.removeEventListener(MoreEvent.SLIDE_LOADED, onSlideLoaded);
			slide.alpha = 0;
			TweenMax.to(slide, .6, {alpha:1, ease:Strong.easeOut});
			slideHolder.addChild(slide);
			/*slide.height = SLIDE_Height;
			slide.scaleX = slide.scaleY;*/
			slide.x = START;
			posArray.push(START);
			START += slide.width+4;
			slide.NUM = cnt;
			slide.mouseChildren = false;
			slide.addEventListener(MouseEvent.CLICK, onShowComponent);
			slideArray.push(slide);
			
			SLIDE_LENGTH = START-sw;
			cnt++;
			
			if (cnt == 1){
				SetupDragging();
				dragRect = new Rectangle(0 - SLIDE_LENGTH, 0, SLIDE_LENGTH, 0);
			}else{
				dragRect.x = 0 - SLIDE_LENGTH;
				dragRect.width = SLIDE_LENGTH;
			}
			
			if (cnt < cArray.length){
				LoadComponents();
			}else{
				IS_FULLY_LOADED = true;
				this.dispatchEvent(new MoreEvent(MoreEvent.SLIDER_LOADED));
				trace("Components Loaded");
			}
			
		}		
		
		private function onShowComponent(e:MouseEvent):void 
		{
			mySlide = e.target as CompSlide;
			if (IS_DRAGGING) return;
			
			trace("SHOWING: " + mySlide.NUM);
			GlobalVarContainer.MAIN_INTERFACE.ShowComponent(cArray[mySlide.NUM]);
		}
		
		public function SetupDragging():void 
		{
			
			/*for (var i:uint = 0; i < slideArray.length; ++i){
				slide = slideArray[i];
				slide.addEventListener(MouseEvent.CLICK, onShowComponent);
			}*/
			
			 IS_DRAGGING = false;
			slideHolder.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
		}
		
		private function onStartDrag(e:MouseEvent):void 
		{
			 StartX = this.mouseX;
			 stopAnimation();;  
			 slideHolder.startDrag(false,dragRect);  
			 GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_UP, goMouseUp);  
			 GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_OUT, goMouseUp);  
			 this.addEventListener(Event.ENTER_FRAME, onDrag);  
		}
		
		private function onDrag(e:Event):void   
		{  
			trace("FIRST SLIDE: "+ slideArray[0].x + " : " + slideArray[0].y);
			if (Math.abs(this.mouseX - StartX) > 2) IS_DRAGGING = true;
			 dvx = slideHolder.x - prevX;  
			 prevX = slideHolder.x;  
		}  
		  
		private function goMouseUp(e:MouseEvent):void   
		{  
			 stopDrag();  
			 GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_UP, goMouseUp);  
			 GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_OUT, goMouseUp);  
			 this.removeEventListener(Event.ENTER_FRAME, onDrag);  
			 slideHolder.addEventListener(Event.ENTER_FRAME, throwAnimation);  
		}  
		
		private function throwAnimation(e:Event):void 
		{
			 dvx *= friction;  
			 slideHolder.x += dvx;  
			 
			 if (slideHolder.x < 0 - SLIDE_LENGTH){
				 slideHolder.x = 0 - SLIDE_LENGTH;
				 stopAnimation();
			 }else if (slideHolder.x > 0){
				 slideHolder.x = 0;
				 stopAnimation();
			 }
			 
			 if (Math.abs(dvx) < 0.1) stopAnimation();  
		}
		
		private function stopAnimation():void {  
			 IS_DRAGGING = false;
			 dvx =  prevX  = 0;  
			 slideHolder.removeEventListener(Event.ENTER_FRAME, throwAnimation);  
		}  


		public function StopSlider():void{			
			slideHolder.removeEventListener(Event.ENTER_FRAME, throwAnimation);
			
			 GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_UP, goMouseUp);  
			 GlobalVarContainer.MainStage.removeEventListener(MouseEvent.MOUSE_OUT, goMouseUp);  
			 
			this.removeEventListener(Event.ENTER_FRAME, onDrag); 
			slideHolder.x = 0;
		}


		
		private function ResetSlider():void 
		{
			START = 0;
			cnt = 0;
			for (var i:uint = 0; i < slideArray.length; ++i){
				slide = slideArray[i];
				slideHolder.removeChild(slide);
				slide = null;
			}
			slideArray = [];
			
			slideHolder.x = 0;
			slideHolder.removeEventListener(Event.ENTER_FRAME, throwAnimation);
			this.removeEventListener(Event.ENTER_FRAME, onDrag);  
			//slide.removeEventListener(MoreEvent.SLIDE_LOADED, onSlideLoaded);
		}
		
	}

}