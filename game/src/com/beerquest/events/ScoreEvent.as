package com.beerquest.events {
import flash.events.Event;

public class ScoreEvent extends Event {
    public static const CAPS_GAINED:String = "CapsGained";

    public function ScoreEvent(quantity:int, stageX:Number, stageY:Number) {
        super(CAPS_GAINED, true);
        _quantity = quantity;
        _stageX = stageX;
        _stageY = stageY;
    }

    public function get quantity():int {
        return _quantity;
    }

    public function get stageX():Number {
        return _stageX;
    }

    public function get stageY():Number {
        return _stageY;
    }

    private var _quantity:int;
    private var _stageX:Number;
    private var _stageY:Number;
}
}