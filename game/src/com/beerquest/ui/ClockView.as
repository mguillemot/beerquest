package com.beerquest.ui {
import mx.core.UIComponent;

public class ClockView extends UIComponent {
    public function ClockView() {
        super();
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var minutesAngle:Number = minutes / 60 * 2 * Math.PI - Math.PI / 2;
        var hourAngle:Number = hour / 12 * 2 * Math.PI - Math.PI / 2;

        graphics.clear();
        graphics.lineStyle(3, 0x000000);
        graphics.drawEllipse(0, 0, unscaledWidth, unscaledHeight);
        graphics.moveTo(unscaledWidth / 2, unscaledHeight / 2);
        graphics.lineTo(unscaledWidth * (0.5 + 0.4 * Math.cos(minutesAngle)), unscaledHeight * (0.5 + 0.4 * Math.sin(minutesAngle)));
        graphics.moveTo(unscaledWidth / 2, unscaledHeight / 2);
        graphics.lineTo(unscaledWidth * (0.5 + 0.3 * Math.cos(hourAngle)), unscaledHeight * (0.5 + 0.3 * Math.sin(hourAngle)));
    }

    [Bindable]
    public function get hour():int {
        return _hour;
    }

    [Bindable]
    public function set hour(value:int):void {
        _hour = value;
        invalidateDisplayList();
    }

    [Bindable]
    public function get minutes():int {
        return _minutes;
    }

    [Bindable]
    public function set minutes(value:int):void {
        _minutes = value;
        invalidateDisplayList();
    }

    private var _hour:int;
    private var _minutes:int;
}
}