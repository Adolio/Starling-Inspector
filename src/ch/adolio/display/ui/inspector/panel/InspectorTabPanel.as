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
	import feathers.controls.TabBar;
	import feathers.data.ListCollection;
	import starling.display.Quad;
	import starling.events.Event;

	public class InspectorTabPanel extends InspectorPanel
	{
		protected var _tabBarBackground:Quad;
		protected var _tabBar:TabBar;

		public function InspectorTabPanel()
		{
			// create tab bar & tab bar background for first size call
			_tabBar = new TabBar();
			_tabBar.customTabStyleName = InspectorConfiguration.STYLE_NAME_TAB_TOGGLE_BUTTON;
			_tabBarBackground = new Quad(1, 1, 0xaaaaaa);

			super();

			// remove default container
			body = null;

			// setup tab bar background
			_tabBarBackground.y = _header.height;
			addChild(_tabBarBackground);

			// setup tab bar
			_tabBar.dataProvider = new ListCollection();
			_tabBar.width = width;
			_tabBar.y = _header.height;
			addChild(_tabBar);
			_tabBar.validate();

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		protected function setupTabContentFromTabBar():void
		{
			// setup body for currently selected tab index
			for (var i:uint; i < _tabBar.dataProvider.length; ++i)
			{
				if (_tabBar.selectedIndex == i)
				{
					body = _tabBar.dataProvider.getItemAt(i).body;
					return;
				}
			}

			// no valid body found
			body = null;
		}

		public function addTab(id:String, body:InspectorBody):InspectorBody
		{
			// create new tab
			_tabBar.dataProvider.addItem({ label: id, body: body });

			// setup tab content
			body.width = computeBodyWidth();
			body.height = computeBodyHeight();

			// adjust body container
			_tabBar.validate();
			_bodyContainer.y = _tabBar.y + _tabBar.height;
			_tabBarBackground.height = _tabBar.height;

			return body;
		}

		public function replaceTabBody(previousBody:InspectorBody, newBody:InspectorBody):void
		{
			var selectedIndex:int = _tabBar.selectedIndex;

			var len:int = _tabBar.dataProvider.length;
			for (var i:int = 0; i < len; i++)
			{
				var item:Object = _tabBar.dataProvider.getItemAt(i);
				if (item.body == previousBody)
				{
					// update environment item
					_tabBar.dataProvider.setItemAt({ label:item.label, body:newBody }, i);

					// update active body if selected index was the replaced body
					if (selectedIndex == i)
						body = newBody;

					return;
				}
			}
		}

		// override to take the top bar into account
		override public function computeBodyHeight():Number
		{
			return height - _tabBar.height - _header.height - _footer.height;
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			// register to events
			_tabBar.addEventListener(Event.CHANGE, onTabSelectionChanged);

			// refresh selected index
			setupTabContentFromTabBar();
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			// unregister from events
			_tabBar.removeEventListener(Event.CHANGE, onTabSelectionChanged);
		}

		private function onTabSelectionChanged(e:Event):void
		{
			setupTabContentFromTabBar();
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		override public function set width(value:Number):void
		{
			super.width = value;

			// resize tabs bar
			_tabBar.width = width;
			_tabBarBackground.width = width;
			_tabBar.validate();
		}
	}
}