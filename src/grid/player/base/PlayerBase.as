package player.base
{
	import player.iface.IDownloadProgressIndicator;

	public class PlayerBase
	{
		var settingsObject:Object = null;
		
		public function PlayerBase( downloadProgressIndicator:IDownloadProgressIndicator,
									settingsObject:Object)
		{
			this.settingsObject = settingsObject;
		}
	}
}