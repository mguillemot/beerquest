package com.beerquest.ui.events {
import com.beerquest.Capacity;

import flash.events.Event;

public class UiScoreEvent extends Event {
    public static const SCORE_GAINED:String = "UiScoreGained";

    public function UiScoreEvent(beers:int, turns:int, stageX:Number = NaN, stageY:Number = NaN, capacity:Capacity = null) {
        super(SCORE_GAINED, true);
        _beers = beers;
        _turns = turns;
        _stageX = stageX;
        _stageY = stageY;
        _capacity = capacity;
    }

    public function get beers():int {
        return _beers;
    }

    public function get turns():int {
        return _turns;
    }

    public function get stageX():Number {
        return _stageX;
    }

    public function get stageY():Number {
        return _stageY;
    }

    public function get capacity():Capacity {
        return _capacity;
    }

    private var _beers:int;
    private var _turns:int;
    private var _stageX:Number;
    private var _stageY:Number;
    private var _capacity:Capacity;
}
}