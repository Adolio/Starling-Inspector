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
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollInteractionMode;
	import feathers.controls.ScrollPolicy;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;

	/** Inspector body with vertical layout container for entries. */
	public class DefaultInspectorBody extends InspectorBody
	{
		protected var _scrollContainer:ScrollContainer;
		protected var _vLayout:VerticalLayout;

		public function DefaultInspectorBody(inspector:InspectorPanel)
		{
			super(inspector);

			// setup vertical scroll container
			_scrollContainer = new ScrollContainer();
			_vLayout = new VerticalLayout();
			_vLayout.horizontalAlign = HorizontalAlign.LEFT;
			_vLayout.verticalAlign = VerticalAlign.TOP;
			_vLayout.gap = InspectorConfiguration.COMPONENTS_PADDING;
			_vLayout.padding = InspectorConfiguration.COMPONENTS_PADDING;
			_scrollContainer.layout = _vLayout;
			_scrollContainer.interactionMode = ScrollInteractionMode.TOUCH_AND_SCROLL_BARS;
			_scrollContainer.horizontalScrollPolicy = ScrollPolicy.OFF;
			_scrollContainer.verticalScrollPolicy = ScrollPolicy.AUTO;
			_scrollContainer.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			_scrollContainer.padding = 0;
			addChild(_scrollContainer);

			// setup the entries container
			_entriesContainer = _scrollContainer;
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		public function refreshLayout():void
		{
			_scrollContainer.readjustLayout();
			_scrollContainer.validate();
		}

		override public function setupHeightFromContent():void
		{
			// readjust container to content
			_scrollContainer.height = NaN;
			_scrollContainer.readjustLayout();
			_scrollContainer.validate();

			// adjust from entries container
			super.setupHeightFromContent();
		}

		override protected function computeEntryWidth():Number
		{
			return _preferredWidth - (_vLayout.paddingLeft + _vLayout.paddingRight);
		}

		override public function set height(value:Number):void
		{
			super.height = value;

			// force invalidation of the scroll container to make sure that the panel is refreshed properly
			_scrollContainer.invalidate();
		}
	}
}