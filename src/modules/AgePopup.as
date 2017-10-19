package modules
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import utilities.AppUtility;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class AgePopup extends Age_Popup
	{
		private var ages:Array = ["under 3", " 3-4 yr", " 5 yr", " 6 yr", " 7 yr", " 8 yr", " 9 yr", " 10 yr", " 11 yr", " 12 yr", " 13+ yr", " Adult"];
		private var SelectedAges:Array = [];
		private var btnArray:Array=[];
		private var btn_age:Btn_Age_Toggle;
		private var Start:Number = 250;
		private var ageHolder:Sprite = new Sprite();
		
		public function AgePopup()
		{
			SelectedAges = GlobalVarContainer.AGE_RANGE;
			
			init();
		}
		
		private function init():void
		{
			addChild(ageHolder);
			ageHolder.y = Start;
			
			for (var i:uint = 0; i < ages.length; ++i)
			{
				btn_age = new Btn_Age_Toggle();
				btn_age.title_txt.htmlText = ages[i];
				if (SelectedAges.lastIndexOf(ages[i]) !=-1)
				{
					btn_age.toggle.gotoAndStop(2);
				}
				ageHolder.addChild(btn_age);
				btn_age.y = 45 * i;
				
				btn_age.toggle.addEventListener(MouseEvent.MOUSE_DOWN, onToggle);
				btn_age.toggle.num = i;
				btn_age.toggle.buttonMode = true;
				btnArray.push(btn_age);
			}
			btn_done.title_txt.mouseEnabled = btn_off.title_txt.mouseEnabled = false;
			btn_done.mouseChildren = btn_off.mouseChildren = false ;
			btn_done.buttonMode = btn_off.buttonMode = true;
			
			btn_done.addEventListener(MouseEvent.CLICK, onDone);
			
			if (SelectedAges.length > 0)
				icon_age.gotoAndStop(2);
			
			btn_off.addEventListener(MouseEvent.CLICK, onFilterOff);
			btn_showage.addEventListener(MouseEvent.CLICK, onShowAges);
			
			if (GlobalVarContainer.SHOW_AGE_ICONS){
				AppUtility.ChangeColor(btn_showage.back, 0xE58525);
				AppUtility.ChangeColor(ageIcons, 0xE58525);
			}else{
				AppUtility.ChangeColor(btn_showage.back, 0x666666);
				AppUtility.ChangeColor(ageIcons, 0x666666);
			}
		}
		
		private function onShowAges(e:MouseEvent):void 
		{
			if (GlobalVarContainer.SHOW_AGE_ICONS){
				GlobalVarContainer.SHOW_AGE_ICONS = false;
				AppUtility.ChangeColor(btn_showage.back, 0x666666);
				AppUtility.ChangeColor(ageIcons, 0x666666);
			}else{
				GlobalVarContainer.SHOW_AGE_ICONS = true;
				AppUtility.ChangeColor(btn_showage.back, 0xE58525);
				AppUtility.ChangeColor(ageIcons, 0xE58525);
			}
		}
		
		private function onDone(e:MouseEvent):void 
		{
			btn_done.removeEventListener(MouseEvent.CLICK, onDone);
			
			for (var i:uint = 0; i < btnArray.length; ++i){
				btn_age = btnArray[i];
				btn_age.toggle.removeEventListener(MouseEvent.MOUSE_DOWN, onToggle);
			}
			
			GlobalVarContainer.DATA_MANAGER.onSaveAgeSettings();
			this.dispatchEvent(new MoreEvent(MoreEvent.CLOSE_POPUP));
						
		}
		
		private function onFilterOff(e:MouseEvent):void 
		{
			icon_age.gotoAndStop(1);
			SelectedAges = [];
			GlobalVarContainer.AGE_RANGE = SelectedAges;
			
			for (var i:uint = 0; i < btnArray.length; ++i){
				btn_age = btnArray[i];
				btn_age.toggle.gotoAndStop(1);
			}
		}
		
		private function onToggle(e:MouseEvent):void
		{
			var mc:MovieClip = e.target as MovieClip;
			var n:Number = mc.num;
			if (mc.currentFrame == 1)
			{
				mc.gotoAndStop(2);
				SelectedAges.push(ages[n]);
			}
			else
			{
				mc.gotoAndStop(1);
				RemoveAge(ages[n]);
			}
			GlobalVarContainer.AGE_RANGE = SelectedAges;
			
			if (SelectedAges.length > 0){
				icon_age.gotoAndStop(2);
			}else{
				icon_age.gotoAndStop(1);
			}
			
			trace("AGE RANGE: " + GlobalVarContainer.AGE_RANGE);
		}
		
		private function RemoveAge(age:String):void
		{
			var n:Number = SelectedAges.lastIndexOf(age);
			if (n > -1)
				SelectedAges.splice(n, 1);
				
		}
	
	}

}