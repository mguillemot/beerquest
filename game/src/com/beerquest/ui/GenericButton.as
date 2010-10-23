/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 23/10/10
 * Time: 16:31
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest.ui {
import mx.controls.Label;
import mx.core.UIComponent;

public class GenericButton extends UIComponent {
    public function GenericButton() {
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        graphics.clear();
        graphics.lineStyle(unscaledWidth/40, 0x000000);
        graphics.beginFill(0x11c308);
        graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, unscaledWidth/10);
        graphics.endFill();
    }

    private var _label:Label;
}
}
