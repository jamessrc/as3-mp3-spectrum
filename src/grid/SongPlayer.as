package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import player.event.PlayerEvent;
	import player.impl.SweetPlayer;
	
	import spectrum.impl.visualization.EQShadowGrid;

	[SWF(frameRate="15")]
	public class SongPlayer extends Sprite
	{
		// Settings.
		private var settingsObject:Object = null;
		
		// Visual Objects.
		private var backgroundSprite          :Sprite        = null;
		private var graphicEqualizer          :EQShadowGrid  = null;
		private var graphicEqualizerContainer :Sprite        = null;
		private var sweetPlayer               :SweetPlayer   = null;
		private var sweetPlayerContainer      :Sprite        = null;
		
		// Measurements.
		private var height_eq     :Number = 0.0;
		private var height_player :Number = 0.0;
		private var top_player    :Number = 0.0;
		
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
				graphicEqualizerContainer = new Sprite();
				sweetPlayerContainer      = new Sprite();
				
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.align     = StageAlign.TOP_LEFT;
				
				this.initializeSettingsObject(this.loaderInfo.parameters);
				
				// Setup the containers.
				this.addChild(backgroundSprite);
				this.backgroundSprite.addChild(graphicEqualizerContainer);
				this.backgroundSprite.addChild(sweetPlayerContainer);
				
				// Set up Graphic Equalizer.
				this.graphicEqualizer = new EQShadowGrid(settingsObject);
				this.graphicEqualizerContainer.addChild(this.graphicEqualizer);
				
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
		
		public function SongPlayer():void
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
	
				this.graphicEqualizer.readAndRender();
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
				var resizeStageHeight:int = this.stage.stageHeight;
				var resizeStageWidth :int = this.stage.stageWidth;
				
				if (resizeStageHeight==0 || isNaN(resizeStageHeight))
				{
					resizeStageHeight = 1;
				}
				
				if (resizeStageWidth==0  || isNaN(resizeStageWidth))
				{
					resizeStageWidth = 1;
				}
								
				this.resize_measurements(resizeStageWidth, resizeStageHeight);
				
				// Set up the Graphic Equalizer.
				this.graphicEqualizerContainer.x = 0;
				this.graphicEqualizerContainer.y = 0;
				this.graphicEqualizer.resize(this.stage.stageWidth, this.height_eq);
	
				// Setup the player.
				this.sweetPlayerContainer.x = 0;
				this.sweetPlayerContainer.y = this.top_player;
				this.sweetPlayer.resize(this.stage.stageWidth, this.height_player);
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
			
			this.settingsObject["equalizerHeightPercent"] = this.settingsObject["equalizerHeightPercent"] ?this.settingsObject["equalizerHeightPercent"]:0.80;
			this.settingsObject["gapHeightPercent"]       = this.settingsObject["gapHeightPercent"]       ?this.settingsObject["gapHeightPercent"]      :0.04;	
			this.settingsObject["playerHeightPercent"]    = this.settingsObject["playerHeightPercent"]    ?this.settingsObject["playerHeightPercent"]   :0.20;	
		}
		
		private function resize_measurements (newWidth:Number, newHeight:Number):void
		{
			var adjustedHeight:Number = newHeight*(1.0-this.settingsObject["gapHeightPercent"]);
			
			this.height_eq     = adjustedHeight*(this.settingsObject["equalizerHeightPercent"]);
			this.height_player = adjustedHeight*(this.settingsObject["playerHeightPercent"]);
			this.top_player    = newHeight-this.height_player;
		}
	}
	
}