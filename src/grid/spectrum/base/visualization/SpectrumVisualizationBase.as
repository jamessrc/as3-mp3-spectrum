package spectrum.base.visualization
{	
	import flash.display.Sprite;
	
	import spectrum.base.renderer.SpectrumRendererBase;
	import spectrum.iface.reader.ISpectrumReader;
	import spectrum.iface.renderer.ISpectrumRenderer;

	public class SpectrumVisualizationBase extends Sprite
	{
		protected var spectrumReader   :ISpectrumReader   = null;
		protected var spectrumRenderer :ISpectrumRenderer = null;
		
		public function SpectrumVisualizationBase(spectrumReader:ISpectrumReader, spectrumRenderer:ISpectrumRenderer)
		{
			super();
			
			this.spectrumReader   = spectrumReader;
			this.spectrumRenderer = spectrumRenderer;
			
			this.addChild(this.spectrumRenderer as SpectrumRendererBase);
		}
	}
}