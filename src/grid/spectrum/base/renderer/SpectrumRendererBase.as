package spectrum.base.renderer
{
	import flash.display.Sprite;

	public class SpectrumRendererBase extends Sprite
	{
		protected var settingsObject :Object = null;
		
		public function SpectrumRendererBase(settingsObject:Object)
		{
			super();
			
			this.settingsObject = settingsObject
		}
	}
}