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
	import ch.adolio.display.ui.inspector.InspectorConfiguration;
	import ch.adolio.display.ui.inspector.entry.InspectorEntry;
	import ch.adolio.display.ui.inspector.entry.SeparatorInspectorEntry;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;

	public class InspectorBody extends Sprite
	{
		protected var _inspector:InspectorPanel;

		protected var _preferredWidth:Number = 100;
		protected var _preferredHeight:Number = 100;

		private var _bg:Quad;
		protected var _entriesContainer:Sprite;
		protected var _entries:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		public function InspectorBody(inspector:InspectorPanel)
		{
			_inspector = inspector;

			// setup background
			_bg = new Quad(1, 1, InspectorConfiguration.COLOR_PANEL_BODY_BACKGROUND_COLOR);
			_bg.alpha = InspectorConfiguration.COLOR_PANEL_BODY_BACKGROUND_ALPHA;
			addChild(_bg);

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		public function get inspector():InspectorPanel
		{
			return _inspector;
		}

		//---------------------------------------------------------------------
		//-- Entries management
		//---------------------------------------------------------------------

		public function addSparatorEntry(title:String):SeparatorInspectorEntry
		{
			var inspectorSeparatorEntry:SeparatorInspectorEntry = new SeparatorInspectorEntry(title);
			addEntry(inspectorSeparatorEntry);
			return inspectorSeparatorEntry;
		}

		public function addEntry(entry:DisplayObject):void
		{
			// setup width
			entry.width = computeEntryWidth();

			// setup inspector if possible
			if (_inspector && entry is InspectorEntry)
				(entry as InspectorEntry).inspector = _inspector;

			// add to entries list
			_entries.push(entry);

			// add to container
			if (_entriesContainer)
				_entriesContainer.addChild(entry);
		}

		public function removeEntries(dispose:Boolean = false):void
		{
			_entriesContainer.removeChildren(0, -1, dispose);
			_entries.length = 0;
		}

		public function get entries():Vector.<DisplayObject>
		{
			return _entries;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		protected function onRemovedFromStage(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		public function setupHeightFromContent():void
		{
			// update height
			if (_entriesContainer)
				height = _entriesContainer.height;
		}

		protected function computeEntryWidth():Number
		{
			return _preferredWidth;
		}

		override public function get width():Number
		{
			return _preferredWidth;
		}

		override public function set width(value:Number):void
		{
			_preferredWidth = value;
			super.width = _preferredWidth;

			if (_entriesContainer)
				_entriesContainer.width = value;
			_bg.width = value;

			var entryWidth:Number = computeEntryWidth();
			for each (var entry:DisplayObject in _entries)
				 entry.width = entryWidth;
		}

		override public function get height():Number
		{
			return _preferredHeight;
		}

		override public function set height(value:Number):void
		{
			_preferredHeight = value;
			super.height = _preferredHeight;

			if (_entriesContainer)
				_entriesContainer.height = value;
			_bg.height = value;
		}
	}
}