package spectrum.impl.visualization
{
	import flash.events.Event;
	
	import spectrum.base.visualization.SpectrumVisualizationBase;
	import spectrum.iface.visualization.ISpectrumVisualization;
	import spectrum.impl.reader.GeometricMeanReader;
	import spectrum.impl.renderer.EQGridShadowRenderer;

	public class EQShadowGrid extends SpectrumVisualizationBase implements ISpectrumVisualization
	{
		public function EQShadowGrid(settingsObject:Object)
		{
			super(new GeometricMeanReader(settingsObject),new EQGridShadowRenderer(settingsObject));
		}
		
		public function readAndRender(e:Event=null):void
		{
			var spectrumArray:Array = this.spectrumReader.read();
			
			this.spectrumRenderer.render(spectrumArray);
		}
		
		public function resize (newWidth:Number, newHeight:Number):void
		{
			this.spectrumRenderer.resize(newWidth, newHeight);
		}
	}
}