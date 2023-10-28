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
	import ch.adolio.display.ui.inspector.panel.InspectorPanel;
	import starling.display.Sprite;
	import starling.events.Event;

	public class InspectorEntry extends Sprite
	{
		protected var _inspector:InspectorPanel;

		protected var _preferredWidth:Number = 300;
		protected var _preferredHeight:Number = InspectorConfiguration.ENTRY_PREFERRED_HEIGHT;

		protected var _labelWidthRatio:Number = 0.35;
		protected var _paddingLeft:Number = 8;
		protected var _paddingRight:Number = 8;

		public function InspectorEntry()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		public function get inspector():InspectorPanel
		{
			return _inspector;
		}

		public function set inspector(value:InspectorPanel):void
		{
			_inspector = value;
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
		//-- Refreshment
		//---------------------------------------------------------------------

		public function refresh():void
		{
			/* to override */
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		/** Return total available width without the side padding. */
		public function getWidthWithoutPaddings():Number
		{
			return (_preferredWidth - (_paddingLeft + _paddingRight));
		}

		/** Return the label width based on the label ratio. */
		public function getLabelWidth():Number
		{
			return Math.min(getWidthWithoutPaddings() * InspectorConfiguration.ENTRY_TITLE_WIDTH_RATIO, InspectorConfiguration.ENTRY_TITLE_MAX_WIDTH);
		}

		/** Return the actual available with for input components (left side). */
		public function getAvailableWidthForInputComponents():Number
		{
			return getWidthWithoutPaddings() - getLabelWidth() - InspectorConfiguration.COMPONENTS_PADDING;
		}

		override public function get height():Number
		{
			return _preferredHeight;
		}

		override public function set height(value:Number):void
		{
			_preferredHeight = value;
		}
	}
}