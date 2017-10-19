package utilities 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class TutorialScreen extends Sprite
	{
		
		private var back:Btn_Black = new Btn_Black();
		private var SC:Number = 1;
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var CURR_TUT:Number = 0;
		private var note:Tutorial_Notes;
		private var notesArray:Array = [];
		private var btn_gotit:Btn_Tutorials = new Btn_Tutorials();
		private var btn_end:Btn_Tutorials = new Btn_Tutorials();
		
		public function TutorialScreen() 
		{
			back.width = sw;
			back.height = sh;
			back.alpha = .7;
			
			addChild(back);
			addChild(btn_gotit);
			addChild(btn_end);
			
			btn_gotit.width = btn_end.width = sw * .55;
			
			btn_gotit.scaleY = btn_end.scaleY = btn_end.scaleX;
			
			btn_end.x = sw / 2 - btn_end.width / 2;
			btn_gotit.x = sw / 2 - btn_gotit.width / 2;
			
			btn_end.y = sh - btn_end.height - 15;
			btn_gotit.y = btn_end.y - btn_gotit.height - 20;
			
			btn_end.gotoAndStop(2);
			btn_gotit.addEventListener(MouseEvent.CLICK, onGotIt);
			btn_end.addEventListener(MouseEvent.CLICK, onEndIt);
			
			btn_gotit.buttonMode = btn_end.buttonMode = true;
			
		}
		
		private function onEndIt(e:MouseEvent):void 
		{
			GlobalVarContainer.SHOW_TUTORIAL = false;
			this.dispatchEvent(new MoreEvent(MoreEvent.CLOSE_POPUP));
		}
		
		private function onGotIt(e:MouseEvent):void 
		{
			this.dispatchEvent(new MoreEvent(MoreEvent.CLOSE_POPUP));
		}
		
		public function LoadNotes(n:Number):void{
			ClearNotes();
			GlobalVarContainer.TUTORIAL_ARRAY[n] = 1;
			trace("TUT ARRAY: " + GlobalVarContainer.TUTORIAL_ARRAY);
			switch(n){
				case 0: ShowHomeNotes(); break;
					
				case 1:ShowExhibitNotes(); break;
				
				case 2:ShowComponentNotes(); break;
				
				case 3:ShowSectionNotes(); break;
				
				case 3:ShowSectionNotes(); break;
				
				case 5:ShowMapNotes(); break;
			}
		}
		
		private function ClearNotes():void 
		{
			for (var i:uint = 0 ; i < notesArray.length; ++i){
				note = notesArray[i];
				removeChild(note);
				note = null;
			}
			notesArray = [];
		}
		
		
		private function ShowMapNotes():void 
		{
			if(GlobalVarContainer.TUTORIAL_ARRAY[1]==0){
				note = new Tutorial_Notes();	
				note.gotoAndStop(4);
				note.scaleX=note.scaleY=SC;
				addChild(note);
				note.x = 4.4;
				note.y = 20.5;
				notesArray.push(note);
				
				note = new Tutorial_Notes();	
				note.scaleX=note.scaleY=SC;
				note.gotoAndStop(5);
				addChild(note);
				note.x =  sw - 78;
				note.y = 32.5;
				notesArray.push(note);
				
				var start:Number = note.y + note.height + 90;
			}else{
				start = sh*.4;
			}
			note = new Tutorial_Notes();	
			note.gotoAndStop(10);
			addChild(note);
			note.scaleX = note.scaleY = .9*SC;
			note.x = sw/2-note.width/2;
			note.y = start;
			notesArray.push(note);
		}
		
		private function ShowSectionNotes():void 
		{
			note = new Tutorial_Notes();	
			note.gotoAndStop(9);
			note.scaleX=note.scaleY=SC;
			addChild(note);
			note.x = sw/2-note.width/2;
			note.y = sh/2-note.height-20;
			notesArray.push(note);
		}
		
		private function ShowComponentNotes():void 
		{
			note = new Tutorial_Notes();	
			note.gotoAndStop(8);
			note.scaleX=note.scaleY=SC;
			addChild(note);
			note.x = sw/2-note.width/2;
			note.y = sh/2-note.height;
			notesArray.push(note);
		}
		
		private function ShowExhibitNotes():void 
		{
			if(GlobalVarContainer.TUTORIAL_ARRAY[5]==0){
				note = new Tutorial_Notes();	
				note.gotoAndStop(4);
				note.scaleX=note.scaleY=SC;
				addChild(note);
				note.x = 4.4;
				note.y = 20.5;
				notesArray.push(note);
				
				note = new Tutorial_Notes();	
				note.gotoAndStop(5);
				note.scaleX=note.scaleY=SC;
				addChild(note);
				note.x =  sw - 78;
				note.y = 32.5;
				notesArray.push(note);
				
				var start:Number = note.y + note.height + 60;
			}else{
				start = sh *.3;
			}
			
			note = new Tutorial_Notes();	
			note.gotoAndStop(6);
			addChild(note);
			note.scaleX = note.scaleY = .9*SC;
			note.x = sw/2-note.width/2;
			note.y = start;
			notesArray.push(note);
			
			note = new Tutorial_Notes();	
			note.gotoAndStop(7);
			note.scaleX=note.scaleY=SC;
			addChild(note);
			note.x = sw/2-note.width/2;
			note.y = btn_gotit.y - note.height - 40;
			notesArray.push(note);
		}
		
		private function ShowHomeNotes():void 
		{
			note = new Tutorial_Notes();	
			note.gotoAndStop(1);
			note.scaleX=note.scaleY=SC;
			addChild(note);
			note.x = 20;
			note.y = 20;
			notesArray.push(note);
			
			note = new Tutorial_Notes();	
			note.gotoAndStop(3);
			note.scaleX=note.scaleY=SC;
			addChild(note);
			note.x = 20;
			note.y = sw *.5;
			notesArray.push(note);
			
			note = new Tutorial_Notes();	
			note.gotoAndStop(2);
			note.scaleX=note.scaleY=SC;
			addChild(note);
			note.x = sw-note.width-20;
			note.y = sw *.4;
			notesArray.push(note);
		}
		
	}

}