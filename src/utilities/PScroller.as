package  utilities
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class PScroller extends PageScroller
	{
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var rect:Rectangle;
		private var Xtra:Number;
		private var MaxDrag:Number;
		public var ScrollAmnt:Number;
		public var movAmt:Number;
		public var ACTIVE:Boolean = false;
		private var ScrollStart:Number;
		
		public function PScroller(hy:Number) 
		{
			back.height = hy;
			
			//trace("BHeight= " + sh);
			addScrollRect();
			scroller.buttonMode = true;
			scroller.addEventListener(MouseEvent.MOUSE_DOWN, ScrollDrag);
			//scroller.addEventListener(MouseEvent.MOUSE_OUT, ScrollStop);
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_UP, ScrollStop);
			
			GlobalVarContainer.MainStage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}
		
		private function addScrollRect():void {
			MaxDrag = back.height - scroller.height+6;
			rect = new Rectangle(0, 0, 0, MaxDrag);
		}
		
		public function ResizeScroller():void {
			back.height = GlobalVarContainer.ScreenH - 110;
			MaxDrag = back.height - scroller.height+6;
			rect.height = MaxDrag;
		}
		
		private function ScrollDrag(e:MouseEvent):void {
		//	trace("HEY!!!!!");
			scroller.startDrag(false, rect);
			this.addEventListener(Event.ENTER_FRAME, onScrollDrag);
		}
		
		private function ScrollStop(e:MouseEvent):void {
			scroller.stopDrag();
			this.removeEventListener(Event.ENTER_FRAME, onScrollDrag);
		}
		
		private function handleMouseWheel(event:MouseEvent):void {
		//	trace("Scroll: " + event.delta);
		if (!ACTIVE) return;
			scroller.y -= event.delta*9;
			if ( scroller.y < 0) scroller.y = 0;
			if (scroller.y > MaxDrag) scroller.y = MaxDrag;
			ScrollAmnt = Math.round(scroller.y * movAmt);
			this.dispatchEvent(new WN_Event(WN_Event.GET_SCROLL));
			
		}
		public function SetSize(n:Number):void {
			back.height = n;
			MaxDrag = back.height - scroller.height;
			rect.height = MaxDrag;
		}
		
		public function SetScroll(i:Number):void {
			/*
			MaxDrag = back.height - scroller.height;
			if(i>100){
			MaxDrag -= 180;
			}else {
				MaxDrag -= 280;
			}*/
			scroller.y = 0;
			Xtra = i;
			//trace("Mov= " + MaxDrag + "/" + Xtra + "= " + Xtra / MaxDrag);
			movAmt = Xtra / MaxDrag;
		}
		
		private function onScrollDrag(e:Event):void {
			ScrollAmnt = Math.round(scroller.y * movAmt);
			this.dispatchEvent(new WN_Event(WN_Event.GET_SCROLL));
		}
		
		
		//******** Touch Scrolling Functions ******** 		
		
		public function StartTouchScroll():void{
			ScrollStart = scroller.y;
			this.addEventListener(Event.ENTER_FRAME, onScrollDrag);
		}
		
		public function StopTouchScroll():void{
			this.removeEventListener(Event.ENTER_FRAME, onScrollDrag);
		}
		
		
		public function onTouchScroll(n:Number):void{
				trace("SCROLLING: " + scroller.y);
			if (scroller.y <= MaxDrag && scroller.y >= 0){
				scroller.y = ScrollStart-n;
			}
			if (scroller.y > MaxDrag) scroller.y = MaxDrag;
			if (scroller.y < 0) scroller.y = 0;
		}
	}
	
}