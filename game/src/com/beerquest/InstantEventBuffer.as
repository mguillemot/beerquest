/**
 * Created by IntelliJ IDEA.
 * User: erhune
 * Date: Oct 3, 2010
 * Time: 11:51:34 PM
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest {
import flash.events.Event;

public class InstantEventBuffer extends EventBuffer {

    public static const INSTANCE:InstantEventBuffer = new InstantEventBuffer();

    function InstantEventBuffer() {
    }


    override public function execute():void {
        throw "no events can be buffered by the InstantEventBuffer"
    }


    override public function push(event:Event):void {
        Constants.GAME.execute(event);
    }
}
}