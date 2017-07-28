package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import player.event.PlayerEvent;
	import player.impl.SweetPlayer;
	
	[SWF(frameRate="15")]
	public class SweetPlayerSolo extends Sprite
	{
		// Settings.
		private var settingsObject:Object = null;
		
		// Visual Objects.
		private var backgroundSprite          :Sprite        = null;
		private var sweetPlayer               :SweetPlayer   = null;
		private var sweetPlayerContainer      :Sprite        = null;
		
		// State
		private var isPlaying    : Boolean = false;
		private var retryAttempts: int     = 5;
		
		private function setupSongPlayer():void
		{
			if (--retryAttempts <= 0)
			{
				trace("ERROR in setupSongPlayer() after max retries.");
				return;
			}
			
			try
			{
				backgroundSprite          = new Sprite();
				sweetPlayerContainer      = new Sprite();
				
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align     = StageAlign.TOP_LEFT;
				
				this.initializeSettingsObject(this.loaderInfo.parameters);
				
				// Setup the containers.
				this.addChild(backgroundSprite);
				this.backgroundSprite.addChild(sweetPlayerContainer);
				
				// Setup the player.
				this.sweetPlayer = new SweetPlayer(this.settingsObject);
				this.sweetPlayerContainer.addChild(this.sweetPlayer);
				this.sweetPlayer.addEventListener(PlayerEvent.ON_PAUSE, this.onPlayerPause);
				this.sweetPlayer.addEventListener(PlayerEvent.ON_PLAY , this.onPlayerPlay);
				this.sweetPlayer.startSweetPlayer();
				
				// Set up the EQ to respond.
				this.stage.addEventListener(Event.RESIZE, this.onResize);
				this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
				
				this.onResize();
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
				
				this.setupSongPlayer();
			}
		}
		
		public function SweetPlayerSolo():void
		{
			this.setupSongPlayer();
		}
		
		private function onEnterFrame(e:Event):void
		{
			try
			{
				this.sweetPlayer.onEnterFrame();
				
				if (!this.isPlaying)
					return;
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
				
				this.setupSongPlayer();
			}
		}
		
		private function onPlayerPause(e:Event):void
		{
			this.isPlaying = false;
		}
		
		private function onPlayerPlay(e:Event):void
		{
			this.isPlaying = true;
		}
		
		private function onResize(e:Event=null):void
		{
			try
			{
				// Setup the player.
				this.sweetPlayerContainer.x = 0;
				this.sweetPlayerContainer.y = 0;
				this.sweetPlayer.resize(this.stage.stageWidth, this.stage.stageHeight);
			}
			catch (error:Error)
			{
				trace(error.getStackTrace());
				
				this.setupSongPlayer();
			}
		}
		
		private function initializeSettingsObject(settingsObject:Object):void
		{
			this.settingsObject = settingsObject;
		}
		
		private function resize_measurements (newWidth:Number, newHeight:Number):void
		{
		}
	}
	
}