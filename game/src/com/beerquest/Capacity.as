package com.beerquest {
import flash.events.EventDispatcher;

public class Capacity extends EventDispatcher {
    public function Capacity(name:String, active:Boolean = false, clickable:Boolean = false) {
        super();
        _name = name;
        _active = active;
        _clickable = clickable;
    }

    public function get name():String {
        return _name;
    }

    public function get active():Boolean {
        return _active;
    }

    public function get clickable():Boolean {
        return _clickable;
    }

    private var _name:String;
    private var _active:Boolean;
    private var _clickable:Boolean;
}
}