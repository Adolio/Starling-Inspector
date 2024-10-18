// =================================================================================================
//
//	Starling Inspector
//	Copyright (c) 2023 Aurelien Da Campo (Adolio), All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package ch.adolio.display.ui.inspector.entry
{
	import ch.adolio.display.ui.inspector.InspectorConfiguration;
	import feathers.controls.Label;
	import starling.events.Event;

	/** Simple read-only label entry. */
	public class LabelInspectorEntry extends InspectorEntry
	{
		private var _titleLabel:Label;
		private var _valueLabel:Label;
		private var _getterFunc:Function;

		public function LabelInspectorEntry(title:String, getterFunc:Function)
		{
			_title = title;
			_getterFunc = getterFunc;

			if (_title != null && _title.length > 0)
			{
				_titleLabel = new Label();
				_titleLabel.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
				_titleLabel.text = title;
				_titleLabel.toolTip = title;
				_titleLabel.height = _preferredHeight;
				addChild(_titleLabel);
			}

			_valueLabel = new Label();
			_valueLabel.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_VALUE;
			_valueLabel.text = _getterFunc();
			_valueLabel.toolTip = _valueLabel.text;
			_valueLabel.height = _preferredHeight;
			addChild(_valueLabel);
			_valueLabel.validate();
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			refresh();
		}

		override public function refresh():void
		{
			_valueLabel.text = _getterFunc();
			_valueLabel.validate();
		}

		//---------------------------------------------------------------------
		//-- Accessors
		//---------------------------------------------------------------------

		public function get titleLabel():Label
		{
			return _titleLabel;
		}

		public function get valueLabel():Label
		{
			return _valueLabel;
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		override public function get width():Number
		{
			return _preferredWidth;
		}

		override public function set width(value:Number):void
		{
			_preferredWidth = value;

			// titled
			if (_titleLabel)
			{
				_titleLabel.x = _paddingLeft;
				_titleLabel.width = getLabelWidth();
				_valueLabel.x = _titleLabel.x + _titleLabel.width + InspectorConfiguration.COMPONENTS_PADDING;
				_valueLabel.width = getAvailableWidthForInputComponents();
			}
			// no title
			else
			{
				_valueLabel.x = _paddingLeft;
				_valueLabel.width = getWidthWithoutPaddings();
			}
		}
	}
}