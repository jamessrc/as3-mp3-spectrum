package spectrum.impl.visualization
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import spectrum.base.visualization.SpectrumVisualizationBase;
	import spectrum.iface.visualization.ISpectrumVisualization;
	import spectrum.impl.reader.GeometricMeanReader;
	import spectrum.impl.renderer.GraphicEqualizerBarsRenderer;

	public class LimeGreenTraslucentGaphicEqualizerBarsVisualization extends SpectrumVisualizationBase implements ISpectrumVisualization
	{
		public function LimeGreenTraslucentGaphicEqualizerBarsVisualization(sprite:Sprite, settingsObject:Object)
		{
			super(new GeometricMeanReader(settingsObject),new GraphicEqualizerBarsRenderer(sprite,settingsObject));
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