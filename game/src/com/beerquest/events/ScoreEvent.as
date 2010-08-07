package com.beerquest.events {
import flash.events.Event;

public class ScoreEvent extends Event {
    public static const SCORE_GAINED:String = "ScoreGained";

    public function ScoreEvent(caps:int, beers:int, stageX:Number, stageY:Number) {
        super(SCORE_GAINED, true);
        _caps = caps;
        _beers = beers;
        _stageX = stageX;
        _stageY = stageY;
    }

    public function get caps():int {
        return _caps;
    }

    public function get beers():int {
        return _beers;
    }

    public function get stageX():Number {
        return _stageX;
    }

    public function get stageY():Number {
        return _stageY;
    }

    private var _caps:int;
    private var _beers:int;
    private var _stageX:Number;
    private var _stageY:Number;
}
}