/**
 * Atari 2600 Breakout
 * In Flixel 2.5
 * By Richard Davey, Photon Storm
 * In 20mins :)
 * 
 * Modified by Pippin Barr
 * In way longer :(
 */
package  
{
	import flash.events.MouseEvent;
	
	import org.flixel.*;
	
	public class ClickToPlay extends FlxState
	{	
		private var bricks:FlxGroup;
		private var _instructionsText:FlxText;
		
		
		public function ClickToPlay() 
		{
		}
		
		override public function create():void
		{

			//	Some bricks
			bricks = new FlxGroup;
			
			var bx:int = 0;
			var by:int = 30;
			
			var brickColours:Array = [ 0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6 ];
			
			for (var y:int = 0; y < 6; y++)
			{
				for (var x:int = 0; x < 16; x++)
				{
					var tempBrick:FlxSprite = new FlxSprite(bx, by);
					tempBrick.makeGraphic(20, 10, brickColours[y]);
					tempBrick.immovable = true;
					bricks.add(tempBrick);
					bx += 20;
				}
				
				bx = 0;
				by += 10;
			}
			
			_instructionsText = new FlxText(0,FlxG.height/2,FlxG.width,
				"CLICK TO PLAY",true);
			_instructionsText.setFormat(null,32,0xFFFFFFFF,"center");

			
			add(bricks);
			add(_instructionsText);
			
			FlxG.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
		}
		
		override public function update():void
		{
			super.update();
		}
		
		

		
		
		private function onMouseUp(e:MouseEvent):void
		{
			FlxG.switchState(new PlayState);
		}
		
		
		public override function destroy():void
		{
			bricks.destroy();
			_instructionsText.destroy();
		}
		
		
	}
	
}