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
	import ch.adolio.display.ui.inspector.entry.TextInputInspectorEntry;
	import feathers.layout.VerticalLayout;
	import org.osflash.signals.Signal;

	public class SliderConfigPanel extends InspectorPanel
	{
		private var _verticalLayout:VerticalLayout;

		// UI elements
		private var _minTextInput:TextInputInspectorEntry;
		private var _maxTextInput:TextInputInspectorEntry;
		private var _stepTextInput:TextInputInspectorEntry;

		// events
		public var minChanged:Signal = new Signal(Number);
		public var maxChanged:Signal = new Signal(Number);
		public var stepChanged:Signal = new Signal(Number);

		// values
		private var _min:Number = 0;
		private var _max:Number = 0;
		private var _step:Number = 0;

		public function SliderConfigPanel(min:Number, max:Number, step:Number)
		{
			super(true, true, false);

			_min = min;
			_max = max;
			_step = step;

			// setup title
			title = "Slider Config";

			// create sliders
			_minTextInput = new TextInputInspectorEntry("Min",
				function():String { return _min.toString(); },
				function(value:String):void { _min = parseFloat(value); minChanged.dispatch(_min); });
			addEntry(_minTextInput);

			_maxTextInput = new TextInputInspectorEntry("Max",
				function():String { return _max.toString(); },
				function(value:String):void { _max = parseFloat(value); maxChanged.dispatch(_max); });
			addEntry(_maxTextInput);

			_stepTextInput = new TextInputInspectorEntry("Step",
				function():String { return _step.toString(); },
				function(value:String):void { _step = parseFloat(value); stepChanged.dispatch(_step); });
			addEntry(_stepTextInput);

			// setup default size
			setupHeightFromContent();
		}

		public function set min(value:Number):void
		{
			_min = value;
			_minTextInput.setText(value.toString());
		}

		public function set max(value:Number):void
		{
			_max = value;
			_maxTextInput.setText(value.toString());
		}

		public function set step(value:Number):void
		{
			_step = value;
			_stepTextInput.setText(value.toString());
		}
	}
}