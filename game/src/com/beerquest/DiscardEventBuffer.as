/**
 * Created by IntelliJ IDEA.
 * User: erhune
 * Date: Oct 3, 2010
 * Time: 11:51:34 PM
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest {
import flash.events.Event;

public class DiscardEventBuffer extends EventBuffer {

    public static const INSTANCE:DiscardEventBuffer = new DiscardEventBuffer();

    function DiscardEventBuffer() {
    }

    override public function execute():void {
        throw "no events can be buffered by the DiscardEventBuffer"
    }


    override public function push(event:Event):void {
    }
}
}