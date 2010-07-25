package com.beerquest.ui {
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.Event;

import flash.geom.Matrix;

import mx.core.UIComponent;

public class ProgressBar extends UIComponent {
    public function ProgressBar() {
        super();
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        graphics.lineStyle(0, 0, 0);
        graphics.beginFill(emptyColor);
        graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 10);
        graphics.endFill();

        var m:Matrix = new Matrix();
        m.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2);
        graphics.beginGradientFill(GradientType.LINEAR, [fullColorLight, fullColorDark], [1.0, 1.0], [0, 255], m);
        graphics.drawRoundRect(0, 0, unscaledWidth * progress / 100, unscaledHeight, 10);
        graphics.endFill();

        graphics.lineStyle(1, 0x000000, 1.0, true);
        graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 10);
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
    public var fullColorLight:uint = 0xff0000;
    public var fullColorDark:uint = 0xff0000;

    private var _progress:Number = 0;
}
}