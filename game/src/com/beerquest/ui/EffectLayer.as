package com.beerquest.ui {
import com.greensock.TweenLite;

import mx.containers.Canvas;

public class EffectLayer extends Canvas {
    private static const NUM_EFFECTS:int = 16;

    public function EffectLayer() {
        super();
        _effectBuffer = new Array();
        for (var i:int = 0; i < NUM_EFFECTS; i++) {
            var fx:ScoreFx = new ScoreFx();
            fx.visible = false;
            addChild(fx);
            _effectBuffer.push(fx);
        }
    }

    public function addEffectAt(value:int, x:Number, y:Number):void {
        if (_effectBuffer.length > 0) {
            var vfx:ScoreFx = _effectBuffer.pop();
            vfx.visible = true;
            vfx.alpha = 1;
            vfx.value = value;
            vfx.x = x - vfx.width / 2;
            vfx.y = y - vfx.height / 2;
            TweenLite.to(vfx, 1, {alpha:0, y:"-20", onComplete:function():void {
                vfx.visible = false;
                _effectBuffer.push(vfx);
            }});
        }
    }

    private var _effectBuffer:Array;
}
}