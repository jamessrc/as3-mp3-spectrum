package spectrum.iface.visualization
{
	import flash.events.Event;
	
	public interface ISpectrumVisualization
	{
		function readAndRender (e:Event=null):void;
		
		function resize (newWidth:Number, newHeight:Number):void;
	}
}