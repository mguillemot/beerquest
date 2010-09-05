package com.beerquest.events {
public class BoardEvent extends GameEvent {
    public function BoardEvent(event:String, x:int, y:int) {
        super(event);
        _x = x;
        _y = y;
    }

    private var _x:int;
    private var _y:int;
}
}