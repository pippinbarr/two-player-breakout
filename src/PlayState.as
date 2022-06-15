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
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class PlayState extends FlxState
	{
		
		[Embed(source="assets/ballhit.mp3")]
		private const BALL_HIT:Class;
		
		[Embed(source="assets/ballout.mp3")]
		private const BALL_OUT:Class;
		
		[Embed(source="assets/brickhit.mp3")]
		private const BRICK_HIT:Class;
		
		[Embed(source="assets/victory.mp3")]
		private const VICTORY:Class;
		
		private var bat:FlxSprite;
		private var ball:FlxSprite;
		
		private var walls:FlxGroup;
		private var leftWall:FlxTileblock;
		private var rightWall:FlxTileblock;
		private var topWall:FlxTileblock;
		private var bottomWall:FlxTileblock;
		
		private var bricks:FlxGroup;
		
		
		private var _bricksVisibleText:FlxText;
		private var _livesText:FlxText;
		private var _superResult:FlxText;
		private var _result:FlxText;
		
		private var _instructionsText:FlxText;
		
		private var _lives:uint = 15;
		private var _bricks:uint = 0;
		
		private const START:uint = 0;
		private const PLAYING:uint = 1;
		private const LAUNCHING:uint = 2;
		private const GAMEOVER:uint = 3;
		
		private var _state:uint = START;

		
		private var _ballHitSound:FlxSound;
		private var _ballOutSound:FlxSound;
		private var _brickHitSound:FlxSound;
		private var _victorySound:FlxSound;
		
		public function PlayState() 
		{
		}
		
		override public function create():void
		{
			bat = new FlxSprite(180, 220).makeGraphic(40, 6, 0xffd63bc3);
			bat.immovable = true;
			bat.elasticity = 1;
			
			ball = new FlxSprite(196, 214).makeGraphic(6, 6, 0xffd3b6cd);
			ball.elasticity = 1;
			ball.maxVelocity.x = 500;
			ball.maxVelocity.y = 500;
			//ball.velocity.y = 200;
			
			walls = new FlxGroup;
			
			leftWall = new FlxTileblock(-100, 0, 10, 240);
			leftWall.makeGraphic(100, 240, 0xffababab);
			walls.add(leftWall);
			
			rightWall = new FlxTileblock(FlxG.width, 0, 10, 240);
			rightWall.makeGraphic(100, 240, 0xffababab);
			walls.add(rightWall);
			
			topWall = new FlxTileblock(0, -100, 320, 10);
			topWall.makeGraphic(320, 100, 0xffababab);
			walls.add(topWall);
			
			bottomWall = new FlxTileblock(0, 239, 320, 10);
			bottomWall.makeGraphic(320, 10, 0xff000000);
			add(bottomWall);
			
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
					tempBrick.elasticity = 1;
					bricks.add(tempBrick);
					bx += 20;
					_bricks++;
				}
				
				bx = 0;
				by += 10;
			}
			
			_bricksVisibleText = new FlxText(0,0,FlxG.width,"BRICKS: " + _bricks, true);
			_bricksVisibleText.setFormat(null,16,0xFFFFFFFF,"left");
			_livesText = new FlxText(0,0,FlxG.width,"LIVES: " + _lives, true);
			_livesText.setFormat(null,16,0xFFFFFFFF,"right");
			
			_instructionsText = new FlxText(0,FlxG.height/2 - 50,FlxG.width,
											"\n\nBRICKS: 'A' / 'D' TO MOVE.\n" +
											"BAT: 'LEFT' / 'RIGHT' TO MOVE.\n" +
											"'SPACE' LAUNCHES BALL.\n" +
											"FIGHT FOR SURVIVAL.",true);
			_instructionsText.setFormat(null,16,0xFFFFFFFF,"center");
			
			
			_ballHitSound = new FlxSound();
			_ballHitSound.loadEmbedded(BALL_HIT);
			_ballOutSound = new FlxSound();
			_ballOutSound.loadEmbedded(BALL_OUT);
			_brickHitSound = new FlxSound();
			_brickHitSound.loadEmbedded(BRICK_HIT);
			_victorySound = new FlxSound();
			_victorySound.loadEmbedded(VICTORY);
			
			
			add(walls);
			add(bat);
			add(ball);
			add(bricks);
			add(_bricksVisibleText);
			add(_livesText);
			add(_instructionsText);
			
		}
		
		override public function update():void
		{
			super.update();
			
			if (_state != GAMEOVER)
			{
				handleBatInput();
				handleBricksInput();
				checkVisibleBricks();
			}

			if (_state == PLAYING)
			{
				checkBall();
				checkBricks();
			
				FlxG.collide(ball, walls);
				FlxG.collide(ball, bottomWall, bottom);
				FlxG.collide(bat, ball, ping);
				FlxG.collide(ball, bricks, hit);
			
				FlxG.collide(bricks, walls);
			}
		}
		
		
		private function handleBatInput():void
		{
			bat.velocity.x = 0;
			
			if (FlxG.keys.LEFT && bat.x > 0)
			{
				bat.velocity.x = -300;
			}
			else if (FlxG.keys.RIGHT && bat.x + bat.width < FlxG.width)
			{
				bat.velocity.x = 300;
			}
			
			if (bat.x < 0)
			{
				bat.x = 0;
			}
			
			if (bat.x + bat.width > FlxG.width)
			{
				bat.x = FlxG.width - bat.width;
			}
			
			if (_state == LAUNCHING || _state == START)
			{
				ball.x = bat.x + 16;
				ball.y = bat.y - 6;;
				
				if (FlxG.keys.SPACE)
				{
					_state = PLAYING;
					ball.velocity.x = bat.velocity.x;
					ball.velocity.y = 200;
					
					_instructionsText.visible = false;
				}
			}
		}
		
		private function handleBricksInput():void
		{
			bricks.setAll("velocity",new FlxPoint(0,0));
			
			var brickVelocity:Number = (300 - bricks.countLiving()*3);
			
			if (FlxG.keys.A)
			{
				bricks.setAll("velocity",new FlxPoint(-brickVelocity,0));
			}
			else if (FlxG.keys.D)
			{
				bricks.setAll("velocity",new FlxPoint(brickVelocity,0));
			}
		}
		
		
		private function checkVisibleBricks():void
		{
			_bricks = 0;
			
			for (var i:int = 0; i < bricks.members.length; i++)
			{
				if (bricks.members[i] != null && bricks.members[i].exists)
				{
					if (bricks.members[i].x + bricks.members[i].width > 0 &&
					    bricks.members[i].x < FlxG.width)
					{
						_bricks++;
					}
				}
			}
			
			_bricksVisibleText.text = "BRICKS: " + _bricks;
		}
		
		private function checkBall():void
		{
			if (ball.x + ball.width < 0 || ball.x > FlxG.width)
			{
				_ballOutSound.play();
				// Game over due to loss of ball, highest total wins (advantage to bricks)
				ball.visible = false;
				gameOver();
			}
		}
		
		
		private function checkBricks():void
		{
			if (_bricks <= 0)
			{
				gameOver();
			}
		}
		
		
		private function hit(_ball:FlxObject, _brick:FlxObject):void
		{			
			if (_brick.y == (2 * 10) + 30)
			{
				trace("Go faster!");
				ball.velocity.y += 50;
			}
			
			ball.velocity.x += _brick.velocity.x / 2;
			
			_brick.exists = false;

			_brickHitSound.play();
			
		}
		
		private function ping(_bat:FlxObject, _ball:FlxObject):void
		{
			var batmid:int = _bat.x + 20;
			var ballmid:int = _ball.x + 3;
			var diff:int;
			
			if (ballmid < batmid)
			{
				//	Ball is on the left of the bat
				diff = batmid - ballmid;
				ball.velocity.x = ( -10 * diff);
			}
			else if (ballmid > batmid)
			{
				//	Ball on the right of the bat
				diff = ballmid - batmid;
				ball.velocity.x = (10 * diff);
			}
			else
			{
				//	Ball is perfectly in the middle
				//	A little random X to stop it bouncing up!
				ball.velocity.x = 2 + int(Math.random() * 8);
			}
			
			_ballHitSound.play();
		}
		
		private function bottom(_ball:FlxObject, _wall:FlxObject):void
		{
			_ballOutSound.play();
			
			_lives--;
			_livesText.text = "LIVES: " + _lives;
			
			_state = LAUNCHING;
			ball.velocity.x = 0;
			ball.velocity.y = 0;
			
			if (_lives == 0)
			{
				gameOver();
			}
		}
		
		
		private function gameOver():void
		{
			ball.active = false;
			bricks.active = false;
			bat.active = false;
			
			_result = new FlxText(0,FlxG.height/2 - 20,FlxG.width,"",true);
			_result.setFormat(null,40,0xFFFFFFFF,"center");
			
			_superResult = new FlxText(0,FlxG.height/2 - 40,FlxG.width,"",true);
			_superResult.setFormat(null,20,0xFFFFFFFF,"center");
			
			if (ball.x + ball.width < 0 || ball.x > FlxG.width)
				_superResult.text = "BALL OUT OF PLAY!";
			else if (_bricks == 0 && _lives == 0)
				_superResult.text = "BOTH DEAD!";
			else if (_bricks == 0)
				_superResult.text = "BRICKS DEAD!";
			else if (_lives == 0)
				_superResult.text = "BAT DEAD!";
			
			if (ball.x + ball.width < 0 || ball.x > FlxG.width)
			{
				_result.text = "IT'S A DRAW!";
			}
			else if (_bricks == _lives)
			{
				_result.text = "TIE GAME!";
			}
			else if (_bricks < _lives)
			{
				_victorySound.play();
				_result.text = "BAT WINS!";
			}
			else if (_lives < _bricks)
			{
				_victorySound.play();
				_result.text = "BRICKS WIN!";
			}
			
			add(_superResult);
			add(_result);
			
			_state = GAMEOVER;
			
			_instructionsText.text = "\n\n\n\n'R' TO RESTART.";
			_instructionsText.visible = true;
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);

		}
		
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.R)
			{
				FlxG.switchState(new PlayState);
			}
		}
		
		
		public override function destroy():void
		{
			ball.destroy();
			bat.destroy();
			walls.destroy();
			bricks.destroy();
			bottomWall.destroy();
			_result.destroy();
			_superResult.destroy();
			_bricksVisibleText.destroy();
			_livesText.destroy();
			_instructionsText.destroy();
		}

		
	}
	
}