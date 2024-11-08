// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.ui.inspector.panel
{
	import ch.adolio.display.ui.inspector.entry.ActionInspectorEntry;
	import ch.adolio.display.ui.inspector.entry.SliderInspectorEntry;
	import org.osflash.signals.Signal;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.Color;

	public class ColorSelectorPanel extends InspectorPanel
	{
		// color
		private var _color:uint;

		// parent
		private var _entry:DisplayObject;

		// UI elements
		private var _previewColor:Quad;
		private var _redSlider:SliderInspectorEntry;
		private var _greenSlider:SliderInspectorEntry;
		private var _blueSlider:SliderInspectorEntry;
		private var _hueSlider:SliderInspectorEntry;
		private var _saturationSlider:SliderInspectorEntry;
		private var _lightnessSlider:SliderInspectorEntry;

		// events
		public var colorChanged:Signal = new Signal(uint); // color:uint

		public function ColorSelectorPanel()
		{
			super(true, true, false);

			// setup title
			title = "Color Selector";
		}

		override protected function createEntries():void
		{
			createColorPreview();

			addSparatorEntry("RGB");

			_redSlider = new SliderInspectorEntry("Red",
				function():Number { return 0; },
				function(value:Number):void { updateColorFromRGB(); }
				, 0, 1.0, 0.01, false);
			addEntry(_redSlider);

			_greenSlider = new SliderInspectorEntry("Green",
				function():Number { return 0; },
				function(value:Number):void { updateColorFromRGB(); }
				, 0, 1.0, 0.01, false);
			addEntry(_greenSlider);

			_blueSlider = new SliderInspectorEntry("Blue",
				function():Number { return 0; },
				function(value:Number):void { updateColorFromRGB(); }
				, 0, 1.0, 0.01, false);
			addEntry(_blueSlider);

			addSparatorEntry("HSL");

			_hueSlider = new SliderInspectorEntry("Hue",
				function():Number { return 0; },
				function(value:Number):void { updateColorFromHSL(); }
				, 0, 1.0, 0.01, false);
			addEntry(_hueSlider);

			_saturationSlider = new SliderInspectorEntry("Saturation",
				function():Number { return 0; },
				function(value:Number):void { updateColorFromHSL(); }
				, 0, 1.0, 0.01, false);
			addEntry(_saturationSlider);

			_lightnessSlider = new SliderInspectorEntry("Lightness",
				function():Number { return 0; },
				function(value:Number):void { updateColorFromHSL(); }
				, 0, 1.0, 0.01, false);
			addEntry(_lightnessSlider);

			addEntry(new ActionInspectorEntry("OK", function():void { close(); }));
		}

		private function createColorPreview():void
		{
			var previewContainer:Sprite = new Sprite();

			var size:Number = 25;
			var bgMargin:Number = 5;
			var previewBackground:Quad = new Quad(size + bgMargin * 2, size + bgMargin * 2, 0x0);
			previewContainer.addChild(previewBackground);

			_previewColor = new Quad(size, size, 0x000000);
			_previewColor.x = bgMargin;
			_previewColor.y = bgMargin;
			previewContainer.addChild(_previewColor);

			addEntry(previewContainer);
		}

		private function updateColorFromHSL():void
		{
			// compute color from HSL
			var h:Number = _hueSlider.getValue();
			var s:Number = _saturationSlider.getValue();
			var l:Number = _lightnessSlider.getValue();
			_color = Color.hsl(h, s, l);
			updatePreview();

			// update RGB
			_redSlider.setValue(extractRed(_color) / 255.0);
			_greenSlider.setValue(extractGreen(_color) / 255.0);
			_blueSlider.setValue(extractBlue(_color) / 255.0);

			// notify color change
			colorChanged.dispatch(_color);
		}

		private function updateColorFromRGB():void
		{
			// compute color from RGB
			var r:Number = _redSlider.getValue() * 255;
			var g:Number = _greenSlider.getValue() * 255;
			var b:Number = _blueSlider.getValue() * 255;
			_color = combineRgb(r, g, b);
			updatePreview();

			// update HSL sliders
			var hsl:Vector.<Number> = Color.rgbToHsl(_color);
			_hueSlider.setValue(hsl[0]);
			_saturationSlider.setValue(hsl[1]);
			_lightnessSlider.setValue(hsl[2]);

			// notify color change
			colorChanged.dispatch(_color);
		}

		private function updatePreview():void
		{
			_previewColor.color = _color;
		}

		public function set color(color:uint):void
		{
			_color = color;
			updatePreview();

			// update RGB sliders
			_redSlider.setValue(extractRed(_color) / 255.0);
			_greenSlider.setValue(extractGreen(_color) / 255.0);
			_blueSlider.setValue(extractBlue(_color) / 255.0);

			// update HSL sliders
			var hsl:Vector.<Number> = Color.rgbToHsl(_color);
			_hueSlider.setValue(hsl[0]);
			_saturationSlider.setValue(hsl[1]);
			_lightnessSlider.setValue(hsl[2]);
		}

		public function get color():uint
		{
			return _color;
		}

		public function get entry():DisplayObject
		{
			return _entry;
		}

		public function set entry(value:DisplayObject):void
		{
			// remove previous entry event listeners
			if (_entry)
				_entry.removeEventListener(Event.REMOVED_FROM_STAGE, onEntryRemovedFromStage);

			// update value
			_entry = value;

			// add new entry event listeners
			if (_entry)
				_entry.addEventListener(Event.REMOVED_FROM_STAGE, onEntryRemovedFromStage);
		}

		private function onEntryRemovedFromStage(event:Event):void
		{
			close();
		}

		override public function close():void
		{
			// remove entry event listeners
			if (_entry)
				_entry.removeEventListener(Event.REMOVED_FROM_STAGE, onEntryRemovedFromStage);

			super.close();
		}

		//---------------------------------------------------------------------
		//-- Color tools
		//---------------------------------------------------------------------

		public static function combineRgb(r:uint, g:uint, b:uint):uint
		{
			return ( ( r << 16 ) | ( g << 8 ) | b );
		}

		public static function extractRed(c:uint):uint
		{
			return (( c >> 16 ) & 0xFF);
		}

		public static function extractGreen(c:uint):uint
		{
			return ( (c >> 8) & 0xFF );
		}

		public static function extractBlue(c:uint):uint
		{
			return ( c & 0xFF );
		}

		public static function colorToHexString(color:uint):String
		{
			return "0x" + color.toString(16).toUpperCase();
		}
	}
}