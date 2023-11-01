package spectrum.iface.renderer
{
	public interface ISpectrumRenderer
	{
		function render (spectrumArray:Array):void;
		
		function resize (newWidth:Number, newHeight:Number):void;
	}
}