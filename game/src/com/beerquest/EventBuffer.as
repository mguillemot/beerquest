/**
 * Created by IntelliJ IDEA.
 * User: erhune
 * Date: Oct 4, 2010
 * Time: 3:51:01 PM
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest {
import flash.events.Event;

public class EventBuffer {
    public function EventBuffer() {
    }

    public function push(event:Event):void {
        _buffer.push(event);
    }

    public function execute():void {
        for each (var event:Event in _buffer) {
            Constants.GAME.execute(event);
        }
        _buffer = new Array();
    }

    public function inspect():void {
        trace("EventBuffer content is:");
        for each (var event:Event in _buffer) {
            trace("  -> " + event.type);
        }
    }

    private var _buffer:Array = new Array();
}
}