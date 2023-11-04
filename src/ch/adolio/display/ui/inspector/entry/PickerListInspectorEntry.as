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
	import feathers.controls.PickerList;
	import feathers.data.ListCollection;
	import starling.events.Event;

	public class PickerListInspectorEntry extends InspectorEntry
	{
		private var _label:Label;
		private var _pickerList:PickerList;
		private var _getterFunc:Function;
		private var _setterFunc:Function;

		private var _disableCallback:Boolean = false;
		private var _items:Array;
		private var _itemsList:ListCollection;

		/**
		 * Constructor.
		 *
		 * <p>An item must be an `Object` and must look like: `{ label:"label", value:myObject }`.</p>
		 * <p>Getter function must return a value.</p>
		 * <p>Setter function must receive the item of type `Object`.</p>
		 */
		public function PickerListInspectorEntry(title:String, items:Array, getterFunc:Function, setterFunc:Function = null)
		{
			_title = title;
			_items = items;
			_getterFunc = getterFunc;
			_setterFunc = setterFunc;

			_label = new Label();
			_label.touchable = false;
			_label.styleName = InspectorConfiguration.STYLE_NAME_LABEL_ENTRY_TITLE;
			_label.text = title;
			_label.height = _preferredHeight;
			addChild(_label);

			var selectedIndex:int = -1;
			var value:String = getterFunc();
			_itemsList = new ListCollection();
			for (var i:uint = 0; i < items.length; ++i)
			{
				_itemsList.addItem( items[i] );

				if (items[i].value == value)
					selectedIndex = i;
			}

			_pickerList = new PickerList();
			_pickerList.styleName = InspectorConfiguration.STYLE_NAME_PICKER_LIST;
			_pickerList.height = _preferredHeight;
			_pickerList.x = _label.x + _label.width + 5;
			_pickerList.dataProvider = _itemsList;
			_pickerList.selectedIndex = selectedIndex;
			addChild(_pickerList);
			_pickerList.validate();

			width = _preferredWidth;
		}

		public function setSelectedItem(value:*, disableCallback:Boolean = true):void
		{
			_disableCallback = disableCallback;
			for (var i:uint = 0; i < _items.length; ++i) {
				if (_items[i].value == value) {
					_pickerList.selectedIndex = i;
					break;
				}
			}
			_disableCallback = false;
		}

		public function updateItems(items:Array):void
		{
			_disableCallback = true;

			_itemsList.removeAll();

			var selectedIndex:int = -1;
			var value:String = _getterFunc();
			for (var i:uint = 0; i < items.length; ++i)
			{
				_itemsList.addItem( items[i]);
				if (items[i].value == value)
					selectedIndex = i;
			}
			_pickerList.selectedIndex = selectedIndex;

			_disableCallback = false;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			_pickerList.addEventListener(Event.CHANGE, onPickerListValueChanged);

			refresh();
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			_pickerList.removeEventListener(Event.CHANGE, onPickerListValueChanged);
		}

		private function onPickerListValueChanged(e:Event):void
		{
			if (_setterFunc && !_disableCallback)
				_setterFunc(_pickerList.selectedItem);
		}

		//---------------------------------------------------------------------
		//-- Refreshment
		//---------------------------------------------------------------------

		override public function refresh():void
		{
			setSelectedItem(_getterFunc(), true);
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

			_label.x = _paddingLeft;
			_label.width = getLabelWidth();
			_pickerList.x = _label.x + _label.width + InspectorConfiguration.COMPONENTS_PADDING;
			_pickerList.width = getAvailableWidthForInputComponents();
		}
	}
}