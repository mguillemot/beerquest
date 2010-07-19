package com.beerquest.ui {
import flash.display.Sprite;
import flash.events.Event;

import mx.core.UIComponent;

public class ProgressBar extends UIComponent {
    public function ProgressBar() {
        width = 176;
        height = 14;

        var mask:Sprite = new Sprite();
        mask.graphics.beginFill(0x0);
        mask.graphics.drawRoundRect(0, 0, width, height, 7);
        mask.graphics.endFill();
        addChild(mask);
        this.mask = mask;
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        graphics.beginFill(emptyColor);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
        graphics.beginFill(fullColor);
        graphics.drawRect(0, 0, width * progress / 100, height);
        graphics.endFill();
        graphics.lineStyle(2, 0x000000);
        graphics.drawRoundRect(0, 0, width, height, 7);
    }

    [Bindable(event="progressChanged")]
    public function get progress():Number {
        return _progress;
    }

    public function set progress(value:Number):void {
        _progress = value;
        dispatchEvent(new Event("progressChanged"));
        invalidateDisplayList();
    }

    public var emptyColor:uint = 0xffffff;
    public var fullColor:uint = 0xff0000;

    private var _progress:Number;
}
}