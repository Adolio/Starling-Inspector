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
	import ch.adolio.utils.InspectionUtils;
	import feathers.controls.Tree;
	import feathers.controls.renderers.DefaultTreeItemRenderer;
	import feathers.controls.renderers.ITreeItemRenderer;
	import feathers.data.ArrayHierarchicalCollection;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	/**
	 * A display list inspector panel
	 */
	public class DisplayListInspectorPanel extends InspectorPanel
	{
		// core
		protected var _root:DisplayObjectContainer;
		protected var _includeRoot:Boolean;
		protected var _tree:Tree;

		// state
		protected var _isInitialized:Boolean;

		/** Used to ignore certain objects from the tree. */
		public var ignoreList:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		public function DisplayListInspectorPanel(root:DisplayObjectContainer, includeRoot:Boolean)
		{
			super();

			_root = root;
			_includeRoot = includeRoot;

			title = "Display List Explorer";

			// display list tree
			_tree = new Tree();
			addEntry(_tree);

			_tree.itemRendererFactory = function():ITreeItemRenderer
			{
				var itemRenderer:DefaultTreeItemRenderer = new DefaultTreeItemRenderer();
				itemRenderer.labelField = "text";
				return itemRenderer;
			};

			initialize();
		}

		private function initialize():void
		{
			refreshTree();
			_isInitialized = true;
		}

		private function refreshTree():void
		{
			// keep track of selected object
			var selectedDisplayObject:DisplayObject = _tree.selectedItem != null ? _tree.selectedItem.displayObject : null;

			// setup data provider
			var dataProvider:ArrayHierarchicalCollection = new ArrayHierarchicalCollection();
			var rootItem:Object;
			if (_includeRoot)
			{
				// build root item
				rootItem = new Object();
				rootItem.parent = null;
				buildEntriesRecursively(_root, rootItem);
				dataProvider.addItemAt(rootItem, 0);
			}
			else
			{
				// build children of root item
				for (var i:int = 0; i < _root.numChildren; i++)
				{
					var rootObject:DisplayObject = _root.getChildAt(i);
					if (ignoreList.indexOf(rootObject) != -1)
						continue;

					rootItem = new Object();
					rootItem.parent = null;
					buildEntriesRecursively(rootObject, rootItem);
					dataProvider.addItemAt(rootItem, i);
				}
			}

			_tree.dataProvider = dataProvider;

			// re-select previously selected object
			if (selectedDisplayObject)
				selectObject(selectedDisplayObject);
		}

		private function buildEntriesRecursively(displayObject:DisplayObject, item:Object):void
		{
			item.text = InspectionUtils.findObjectName(displayObject);
			item.displayObject = displayObject;

			if (displayObject is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = displayObject as DisplayObjectContainer;
				if (container.numChildren > 0)
				{
					item.children = new Array();
					for (var i:int = 0; i < container.numChildren; i++)
					{
						var childDisplayObject:DisplayObject = container.getChildAt(i);
						if (ignoreList.indexOf(childDisplayObject) != -1)
							continue;

						var childItem:Object = new Object();
						childItem.parent = item;
						item.children.push(childItem);

						buildEntriesRecursively(childDisplayObject, childItem);
					}
				}
			}
		}

		override protected function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);

			// register to events
			_tree.addEventListener(Event.CHANGE, onSelectedItemChanged);
		}

		override protected function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);

			// unregister from events
			_tree.removeEventListener(Event.CHANGE, onSelectedItemChanged);
		}

		public function selectObject(object:DisplayObject):void
		{
			var item:Object = findItemOfObject(object);
			if (item)
			{
				_tree.selectedItem = item;

				// make sure the parent branch is open
				if (item.parent != null && !_tree.isBranchOpen(item.parent))
				{
					_tree.toggleBranch(item.parent, true);

					// enforce refreshing the size of the tree
					_tree.invalidate();
				}
			}
		}

		public function findItemOfObject(object:DisplayObject):Object
		{
			// data provider not ready yet
			if (_tree.dataProvider == null)
				return null;

			var len:int = _tree.dataProvider.getLength();
			for (var i:int = 0; i < len; i++)
			{
				var item:Object = _tree.dataProvider.getItemAt(i);
				var foundItem:Object = findChildItemOfObject(item, object);
				if (foundItem != null)
					return foundItem;
			}

			return null;
		}

		public function findChildItemOfObject(item:Object, needle:DisplayObject):Object
		{
			// found!
			if (item.displayObject == needle)
				return item;

			// no children
			if (!item.hasOwnProperty("children"))
				return null;

			// browse children
			var children:Array = item.children;
			for (var i:int = 0; i < children.length; i++)
			{
				var childItem:Object = children[i];
				var foundItem:Object = findChildItemOfObject(childItem, needle);
				if (foundItem != null)
					return foundItem;
			}

			return null;
		}

		override public function updateEntries():void
		{
			super.updateEntries();

			refreshTree();
		}

		private function onSelectedItemChanged(event:Event):void
		{
			// nothing selected
			if (_tree.selectedItem == null)
			{
				ObjectInspectorPanel.instance.object = null;
				return;
			}

			if (ObjectInspectorPanel.instance.object == _tree.selectedItem.displayObject)
				return;

			ObjectInspectorPanel.instance.object = _tree.selectedItem.displayObject;
		}
	}
}