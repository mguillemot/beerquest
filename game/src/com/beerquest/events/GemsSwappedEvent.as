package com.beerquest.events {
public class GemsSwappedEvent extends GameEvent {
    public static const GEMS_SWAPPED:String = "GemsSwapped";

    public function GemsSwappedEvent(sx:int, sy:int, dx:int, dy:int) {
        super(GEMS_SWAPPED);
        _sx = sx;
        _sy = sy;
        _dx = dx;
        _dy = dy;
    }

    public function get sx():int {
        return _sx;
    }

    public function get sy():int {
        return _sy;
    }

    public function get dx():int {
        return _dx;
    }

    public function get dy():int {
        return _dy;
    }

    private var _sx:int;
    private var _sy:int;
    private var _dx:int;
    private var _dy:int;
}
}