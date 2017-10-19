package Pages 
{
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class HomePage extends Home_Page
	{
		
		
		public function HomePage() 
		{
			
			btn_Exhibits.buttonMode = btn_Info.buttonMode = btn_Maps.buttonMode = true;
			
			exhibit_txt.mouseEnabled = info_txt.mouseEnabled = map_txt.mouseEnabled = false;
			
		}
		
		public function init():void{
			
			exhibit_txt.htmlText = GlobalVarContainer.HOME_EXHIBITS_LABEL;
			info_txt.htmlText = GlobalVarContainer.HOME_INFO_LABEL;
			map_txt.htmlText = GlobalVarContainer.HOME_MAPS_LABEL;
			
			btn_Exhibits.addEventListener(MouseEvent.MOUSE_DOWN, onGoExhibits);
			btn_Info.addEventListener(MouseEvent.MOUSE_DOWN, onGoInfo);
			btn_Maps.addEventListener(MouseEvent.MOUSE_DOWN, onGoMap);
			
		}
		
		private function onGoMap(e:MouseEvent):void 
		{
			GlobalVarContainer.MAIN_INTERFACE.ShowMap();
		}
		
		private function onGoInfo(e:MouseEvent):void 
		{
			GlobalVarContainer.MAIN_INTERFACE.ShowInfo();
		}
		
		private function onGoExhibits(e:MouseEvent):void 
		{
			GlobalVarContainer.MAIN_INTERFACE.ShowExhibits();
		}
	}

}