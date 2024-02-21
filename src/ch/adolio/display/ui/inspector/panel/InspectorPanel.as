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
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.layout.VerticalLayout;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class InspectorPanel extends Sprite
	{
		// panel
		protected var _preferredWidth:Number = InspectorConfiguration.PANEL_DEFAULT_WIDTH;
		protected var _preferredHeight:Number = InspectorConfiguration.PANEL_DEFAULT_HEIGHT;

		// dragging
		protected var _isDraggable:Boolean = true;
		protected var _dragOffset:Point = new Point();
		protected var _positionAtGrab:Point = new Point();
		protected var _staysInScreenBounds:Boolean = true;

		// header
		protected var _header:Sprite;
		protected var _headerBackground:Quad;
		protected var _titleLabel:Label;
		protected var _closeButton:Button;
		protected var _refreshButton:Button;

		// body
		protected var _bodyContainer:Sprite;
		protected var _vLayout:VerticalLayout;
		protected var _body:InspectorBody;

		// footer
		protected var _footer:Sprite;
		protected var _footerBackground:Quad;

		// size grabber
		private var _isResizeable:Boolean;
		private var _sideGrabOffset:Point = new Point();
		private var _widthAtGrab:Number;
		private var _heightAtGrab:Number;
		private var _sizeGrabber:Quad;

		// screen
		private static var screenBounds:Rectangle = new Rectangle();

		public function InspectorPanel(isClosable:Boolean = true, isResizeable:Boolean = true, isRefreshable:Boolean = true)
		{
			_isResizeable = isResizeable;

			// header
			_header = new Sprite();
			addChild(_header);

			_titleLabel = new Label();
			_titleLabel.styleName = InspectorConfiguration.STYLE_NAME_LABEL_PANEL_TITLE;
			_titleLabel.text = "Title";
			_titleLabel.minHeight = InspectorConfiguration.PANEL_HEADER_MIN_HEIGHT;
			_titleLabel.touchable = false;
			_titleLabel.validate();

			_headerBackground = new Quad(_preferredWidth, _titleLabel.height, InspectorConfiguration.COLOR_PANEL_HEADER_BACKGROUND_COLOR);
			_headerBackground.alpha = InspectorConfiguration.COLOR_PANEL_HEADER_BACKGROUND_ALPHA;
			_header.addChild(_headerBackground);

			_header.addChild(_titleLabel);

			_refreshButton = new Button();
			_refreshButton.styleName = InspectorConfiguration.STYLE_NAME_PANEL_BACK_BUTTON;
			_refreshButton.height = _header.height;
			_refreshButton.label = "Refresh";
			_refreshButton.maxHeight = _header.height;
			_refreshButton.visible = isRefreshable;
			_refreshButton.validate();
			_header.addChild(_refreshButton);

			_closeButton = new Button();
			_closeButton.styleName = InspectorConfiguration.STYLE_NAME_PANEL_CLOSE_BUTTON;
			_closeButton.height = _headerBackground.height;
			_closeButton.label = "X";
			_closeButton.maxWidth = 24;
			_closeButton.visible = isClosable;
			_closeButton.validate();
			_header.addChild(_closeButton);

			// body
			_bodyContainer = new Sprite();
			_bodyContainer.y = _header.y + _header.height;
			addChild(_bodyContainer);

			// default body
			_body = new DefaultInspectorBody(this);
			_bodyContainer.addChild(_body);

			// footer
			_footer = new Sprite();
			addChild(_footer);
			_footerBackground = new Quad(_preferredWidth, InspectorConfiguration.PANEL_FOOTER_HEIGHT, InspectorConfiguration.COLOR_PANEL_FOOTER_BACKGROUND_COLOR);
			_footerBackground.alpha = InspectorConfiguration.COLOR_PANEL_FOOTER_BACKGROUND_ALPHA;
			_footer.addChild(_footerBackground);

			// side grabbers
			if (_isResizeable)
				setupSizeGrabber();

			// setup size
			width = _preferredWidth;
			height = _preferredHeight;

			// register to stage events
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		override public function dispose():void
		{
			// unregister from stage events
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

			// dispose parent
			super.dispose();

			// nullify references
			_dragOffset = null;
			_positionAtGrab = null;
			_header = null;
			_headerBackground = null;
			_titleLabel = null;
			_closeButton = null;
			_refreshButton = null;
			_bodyContainer = null;
			_vLayout = null;
			_body = null;
			_footer = null;
			_footerBackground = null;
			_sideGrabOffset = null;
			_sizeGrabber = null;
		}

		private function setupSizeGrabber():void
		{
			_sizeGrabber = new Quad(_footerBackground.height, _footerBackground.height, InspectorConfiguration.PANEL_FOOTER_SIZE_GRABBER_COLOR);
			_sizeGrabber.x = _footerBackground.width - _sizeGrabber.width;
			_footer.addChild(_sizeGrabber);
		}

		public function get title():String
		{
			return _titleLabel.text;
		}

		public function set title(value:String):void
		{
			_titleLabel.text = value;
		}

		public function close():void
		{
			removeFromParent();
		}

		public function checkScreenBounds():void
		{
			// compute screen bounds
			Starling.current.stage.getScreenBounds(Starling.current.stage, screenBounds);
			var panelBounds:Rectangle = bounds;

			// check top
			if (panelBounds.top < screenBounds.top)
				y = screenBounds.top;

			// check bottom
			if (panelBounds.bottom > screenBounds.bottom)
			{
				// resize if larger than the screen
				if (panelBounds.height > screenBounds.height)
				{
					height = screenBounds.height;
					panelBounds = bounds; // update bounds
				}

				// move up
				y = screenBounds.bottom - panelBounds.height;
			}

			// check left
			if (panelBounds.left < screenBounds.left)
				x = screenBounds.left;

			// check right
			if (panelBounds.right > screenBounds.right)
				x = screenBounds.right - width;
		}

		public function bringInFront():void
		{
			// check that panel is in front
			if (parent.getChildIndex(this) != parent.numChildren-1)
				parent.addChild(this);
		}

		//---------------------------------------------------------------------
		//-- Event handlers
		//---------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void
		{
			// check screen bounds
			if (_staysInScreenBounds)
				checkScreenBounds();

			// invalidate components
			_titleLabel.invalidate();
			_closeButton.invalidate();
			_refreshButton.invalidate();

			// register to events
			registerToEvents();
		}

		protected function onRemovedFromStage(e:Event):void
		{
			unregisterFromEvents()
		}

		protected function registerToEvents():void
		{
			_headerBackground.addEventListener(TouchEvent.TOUCH, onHeaderTouched);
			_footerBackground.addEventListener(TouchEvent.TOUCH, onHeaderTouched);
			_closeButton.addEventListener(Event.TRIGGERED, onCloseButtonTriggered);
			_refreshButton.addEventListener(Event.TRIGGERED, onRefreshButtonTriggered);

			if (_sizeGrabber)
				_sizeGrabber.addEventListener(TouchEvent.TOUCH, onBottomSideTouched);
		}

		protected function unregisterFromEvents():void
		{
			_headerBackground.removeEventListener(TouchEvent.TOUCH, onHeaderTouched);
			_footerBackground.removeEventListener(TouchEvent.TOUCH, onHeaderTouched);
			_closeButton.removeEventListener(Event.TRIGGERED, onCloseButtonTriggered);
			_refreshButton.removeEventListener(Event.TRIGGERED, onRefreshButtonTriggered);

			if (_sizeGrabber)
				_sizeGrabber.removeEventListener(TouchEvent.TOUCH, onBottomSideTouched);
		}

		private function onHeaderTouched(e:TouchEvent):void
		{
			if (!_isDraggable)
				return;

			var touch:Touch = e.touches[0];

			switch (touch.phase)
			{
				case TouchPhase.BEGAN:

					// setup drag
					_dragOffset.x = touch.globalX;
					_dragOffset.y = touch.globalY;
					_positionAtGrab.x = x;
					_positionAtGrab.y = y;

					// bring panel in front
					bringInFront();

					break;
				case TouchPhase.MOVED:

					// update position
					x = _positionAtGrab.x + Math.round(touch.globalX - _dragOffset.x);
					y = _positionAtGrab.y + Math.round(touch.globalY - _dragOffset.y);

					// check bounds
					if (_staysInScreenBounds)
						checkScreenBounds();

					break;
			}
		}

		private function onBottomSideTouched(e:TouchEvent):void
		{
			var touch:Touch = e.touches[0];

			switch (touch.phase)
			{
				case TouchPhase.BEGAN:

					// setup size grab
					_sideGrabOffset.x = touch.globalX;
					_sideGrabOffset.y = touch.globalY;
					_widthAtGrab = width;
					_heightAtGrab = height;

					// bring panel in front
					bringInFront();

					break;
				case TouchPhase.MOVED:

					// update dimensions
					Starling.current.stage.getScreenBounds(Starling.current.stage, screenBounds);
					width = Math.min(_widthAtGrab + Math.round(touch.globalX - _sideGrabOffset.x), screenBounds.right - x);
					height = Math.min(_heightAtGrab + Math.round(touch.globalY - _sideGrabOffset.y), screenBounds.bottom - y);
					break;
			}
		}

		private function onCloseButtonTriggered(event:Event):void
		{
			close();
		}

		protected function onRefreshButtonTriggered(event:Event):void
		{
			updateEntries();
		}

		//---------------------------------------------------------------------
		//-- Entries management
		//---------------------------------------------------------------------

		protected function addSparatorEntry(title:String):SeparatorInspectorEntry
		{
			return _body.addSparatorEntry(title);
		}

		public function addEntry(entry:DisplayObject):void
		{
			_body.addEntry(entry);
		}

		public function removeEntries(dispose:Boolean = false):void
		{
			_body.removeEntries(dispose);
		}

		/** Refreshes all entries from values. */
		public function updateEntries():void
		{
			for each (var entry:DisplayObject in _body.entries)
			{
				if (entry is InspectorEntry)
					(entry as InspectorEntry).refresh();
			}
		}

		public function get body():InspectorBody
		{
			return _body;
		}

		public function set body(body:InspectorBody):void
		{
			_body = body;

			_bodyContainer.removeChildren();

			if (_body)
			{
				_bodyContainer.addChild(_body);
				_body.width = computeBodyWidth();
				_body.height = computeBodyHeight();
			}
		}

		public function computeBodyWidth():Number
		{
			return width;
		}

		public function computeBodyHeight():Number
		{
			return height - (_header.height + _footer.height);
		}

		//---------------------------------------------------------------------
		//-- Drag management
		//---------------------------------------------------------------------

		public function get isDraggable():Boolean
		{
			return _isDraggable;
		}

		public function set isDraggable(value:Boolean):void
		{
			_isDraggable = value;
		}

		//---------------------------------------------------------------------
		//-- Size management
		//---------------------------------------------------------------------

		public function setupHeightFromContent():void
		{
			if (_body)
			{
				_body.setupHeightFromContent();
				height = _header.height + _body.height + _footer.height;
			}
			else
			{
				height = _header.height + _footer.height;
			}

			checkScreenBounds();
		}

		override public function get width():Number
		{
			return _preferredWidth;
		}

		override public function set width(value:Number):void
		{
			// check minimal allowed width
			if (value < 64)
				value = 64;

			// update components
			_preferredWidth = value;
			_closeButton.x = value - _closeButton.width;
			_refreshButton.x = _closeButton.x - _refreshButton.width;
			_titleLabel.width = value - _closeButton.width - _refreshButton.width;
			_headerBackground.width = value;
			_footerBackground.width = value;

			if (_sizeGrabber)
				_sizeGrabber.x = value - _sizeGrabber.width;

			// update body
			if (_body)
				_body.width = computeBodyWidth();
		}

		override public function get height():Number
		{
			return _preferredHeight;
		}

		override public function set height(value:Number):void
		{
			// check minimal allowed height
			if (value < 64)
				value = 64;

			// update components
			_preferredHeight = value;
			_footer.y = _preferredHeight - _footer.height;

			// update body
			if (_body)
				_body.height = computeBodyHeight();
		}
	}
}