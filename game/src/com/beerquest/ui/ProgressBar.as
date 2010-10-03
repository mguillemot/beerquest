package com.beerquest.ui {
import com.greensock.TweenLite;

import com.greensock.easing.Quad;

import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.Event;

import flash.geom.Matrix;

import mx.controls.Label;
import mx.core.UIComponent;

public class ProgressBar extends UIComponent {
    public function ProgressBar() {
        super();

        _bar = new Sprite();
        addChild(_bar);

        _frame = new Sprite();
        addChild(_frame);
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        graphics.clear();
        graphics.lineStyle(0, 0, 0);
        graphics.beginFill(emptyColor);
        graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 10);
        graphics.endFill();

        _frame.graphics.clear();
        _frame.graphics.lineStyle(1, 0x000000, 1.0, true);
        _frame.graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 10);
    }

    [Bindable(event="progressChanged")]
    public function get progress():Number {
        return _progress;
    }

    public function set progress(value:Number):void {
        if (value < 0) {
            _progress = 0;
        } else if (value > 100) {
            _progress = 100;
        } else {
            _progress = value;
        }
        dispatchEvent(new Event("progressChanged"));

        var m:Matrix = new Matrix();
        m.createGradientBox(width, height, Math.PI / 2);
        _bar.graphics.clear();
        _bar.graphics.beginGradientFill(GradientType.LINEAR, [fullColorLight, fullColorDark], [1.0, 1.0], [0, 255], m);
        _bar.graphics.drawRoundRect(0, 0, width * progress / 100, height, 10);
        _bar.graphics.endFill();

        if (alert) {
            if (_progress >= 80) {
                var duration:Number = 0.8 - (_progress - 80) / 20 / 4;
                var delay:Number = 1 - (_progress - 80) / 20;
                if (_tween == null) {
                    _tween = new TweenLite(_bar, duration, {colorTransform:{tint:0xff0000, tintAmount:0.7}, ease:Quad.easeIn, delay:delay, onComplete:function():void {
                        _tween.reverse();
                    }, onReverseComplete:function():void {
                        _tween.restart(true);
                    }});
                } else {
                    _tween.duration = duration;
                    _tween.delay = delay;
                }
            } else {
                if (_tween != null) {
                    if (!_tween.reversed) {
                        _tween.reverse();
                    }
                    _tween.vars.onReverseComplete = null;
                    _tween = null;
                }
            }
        }
    }

    public var alert:Boolean = false;
    public var emptyColor:uint = 0xffffff;
    public var fullColorLight:uint = 0xff0000;
    public var fullColorDark:uint = 0xff0000;

    private var _progress:Number = 0;
    private var _bar:Sprite;
    private var _frame:Sprite;
    private var _tween:TweenLite;
}
}