package com.beerquest.events {
public class VomitEvent extends GameEvent {
    public static const VOMIT:String = "Vomit";

    public function VomitEvent(cells:Array) {
        super(VOMIT);
        _cells = cells;
    }

    public function get cells():Array {
        return _cells;
    }

    private var _cells:Array;
}
}