// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.shape
{
	import starling.display.Quad;
	import starling.display.Sprite;

	/**
	 * A bordered rectangle
	 */
	public class BorderedRectangle extends Sprite
	{
		// internal
		private var _width:Number;
		private var _height:Number;

		// quads
		private var _bodyQuad:Quad;
		private var _borderTopQuad:Quad;
		private var _borderBottomQuad:Quad;
		private var _borderLeftQuad:Quad;
		private var _borderRightQuad:Quad;

		// style
		private var _bodyColor:uint;
		private var _bodyAlpha:Number = 1.0;
		private var _borderSize:Number;
		private var _borderAlpha:Number = 1.0;
		private var _borderColor:uint;

		public function BorderedRectangle(width:Number, height:Number, bodyColor:uint = 0x000000, borderSize:Number = 1.0, borderColor:uint = 0x000000)
		{
			// setup core variables
			_width = width;
			_height = height;
			_bodyColor = bodyColor;
			_borderSize = borderSize;
			_borderColor = borderColor;

			// quads creation
			_bodyQuad = new Quad(1, 1, 0x0);
			addChild(_bodyQuad);

			_borderTopQuad = new Quad(1, 1, 0x0);
			addChild(_borderTopQuad);

			_borderBottomQuad = new Quad(1, 1, 0x0);
			addChild(_borderBottomQuad);

			_borderLeftQuad = new Quad(1, 1, 0x0);
			addChild(_borderLeftQuad);

			_borderRightQuad = new Quad(1, 1, 0x0);
			addChild(_borderRightQuad);

			// initial update
			update();
		}

		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			_width = value;

			update();
		}

		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			_height = value;

			update();
		}

		public function get bodyAlpha():Number
		{
			return _bodyAlpha;
		}

		public function set bodyAlpha(value:Number):void
		{
			_bodyAlpha = value;

			update();
		}

		public function get borderAlpha():Number
		{
			return _borderAlpha;
		}

		public function set borderAlpha(value:Number):void
		{
			_borderAlpha = value;

			update();
		}

		private function update():void
		{
			_bodyQuad.width = _width - _borderSize * 2.0;
			_bodyQuad.height = _height - _borderSize * 2.0;
			_bodyQuad.x = _borderSize;
			_bodyQuad.y = _borderSize;
			_bodyQuad.color = _bodyColor;
			_bodyQuad.alpha = _bodyAlpha;

			_borderTopQuad.width = _width;
			_borderTopQuad.height = _borderSize;
			_borderTopQuad.color = _borderColor;
			_borderTopQuad.alpha = _borderAlpha;

			_borderBottomQuad.width = _width;
			_borderBottomQuad.height = _borderSize;
			_borderBottomQuad.y = _height - _borderSize;
			_borderBottomQuad.color = _borderColor;
			_borderBottomQuad.alpha = _borderAlpha;

			_borderLeftQuad.width = _borderSize;
			_borderLeftQuad.height = _height - _borderSize * 2.0;
			_borderLeftQuad.y = _borderSize;
			_borderLeftQuad.color = _borderColor;
			_borderLeftQuad.alpha = _borderAlpha;

			_borderRightQuad.width = _borderSize;
			_borderRightQuad.height = _height - _borderSize * 2.0;
			_borderRightQuad.x = _width - _borderSize;
			_borderRightQuad.y = _borderSize;
			_borderRightQuad.color = _borderColor;
			_borderRightQuad.alpha = _borderAlpha;
		}
	}
}