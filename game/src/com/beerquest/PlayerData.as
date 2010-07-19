package com.beerquest {
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

public class PlayerData extends EventDispatcher {
    public function PlayerData(name:String, title:String, level:Number) {
        _name = name;
        _title = title;
        _level = level;
    }

    [Bindable(event="scoreChanged")]
    public function get score():Number {
        return _score;
    }

    public function set score(value:Number):void {
        _score = value;
        dispatchEvent(new Event("scoreChanged"));
    }

    [Bindable(event="fullBeersChanged")]
    public function get fullBeers():Number {
        return _fullBeers;
    }

    public function set fullBeers(value:Number):void {
        _fullBeers = value;
        dispatchEvent(new Event("fullBeersChanged"));
    }

    [Bindable(event="multiplierChanged")]
    public function get multiplier():Number {
        return _multiplier;
    }

    public function set multiplier(value:Number):void {
        _multiplier = value;
        dispatchEvent(new Event("multiplierChanged"));
    }

    public function get partialBeers():ArrayCollection {
        return _partialBeers;
    }

    public function get name():String {
        return _name;
    }

    public function get title():String {
        return _title;
    }

    public function get level():Number {
        return _level;
    }

    public function addCollectedBeer(type:TokenType, big:Boolean):void {
        if (big) {
            fullBeers++;
        } else {
            if (_partialBeers.length == 45) {
                _partialBeers.removeItemAt(0);
            }
            _partialBeers.addItem(type);
        }
    }

    private var _name:String;
    private var _title:String;
    private var _level:Number;
    private var _score:Number = 0;
    private var _multiplier:Number = 1;
    private var _fullBeers:Number = 0;
    private var _partialBeers:ArrayCollection = new ArrayCollection();
}
}