/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 23/10/10
 * Time: 16:31
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest.ui {
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import mx.containers.Canvas;

public class GenericButton extends Canvas {

    public function GenericButton() {
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.ROLL_OVER, onRollOver);
        addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        filters = [new DropShadowFilter(5, 45, 0x111111, 1.0, 10.0, 10.0)];
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        const REDUC_FACTOR:Number = 0.02;
        var tx:Number = (_pressed) ? unscaledWidth * REDUC_FACTOR : 0;
        var ty:Number = (_pressed) ? unscaledHeight * REDUC_FACTOR : 0;
        var w:Number = (_pressed) ? unscaledWidth * (1-2*REDUC_FACTOR) : unscaledWidth;
        var h:Number = (_pressed) ? unscaledHeight * (1-2*REDUC_FACTOR) : unscaledHeight;
        graphics.clear();
        graphics.lineStyle(w/40, 0xffffff);
        graphics.beginFill(_hover ? hoverColor : color);
        graphics.drawRoundRect(tx, ty, w, h, w/8);
        graphics.endFill();
    }

    private function onMouseDown(e:MouseEvent):void {
        _pressed = true;
        invalidateDisplayList();
    }

    private function onMouseUp(e:MouseEvent):void {
        _pressed = false;
        invalidateDisplayList();
    }

    private function onRollOver(e:MouseEvent):void {
        _hover = true;
        invalidateDisplayList();
    }

    private function onRollOut(e:MouseEvent):void {
        _hover = false;
        _pressed = false;
        invalidateDisplayList();
    }

    public var hoverColor:uint = 0x1af20f;
    public var color:uint = 0x11c308; // sombre: 0x6e936c

    private var _hover:Boolean = false;
    private var _pressed:Boolean = false;

}
}
