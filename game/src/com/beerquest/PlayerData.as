package com.beerquest {
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

public class PlayerData extends EventDispatcher {
    public function PlayerData() {
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

    public function get partialBeers():ArrayCollection {
        return _partialBeers;
    }

    public function addCollectedBeer(type:TokenType, big:Boolean):void {
        if (big) {
            fullBeers++;
        } else {
            _partialBeers.addItem(type);
        }
    }

    private var _score:Number = 0;
    private var _fullBeers:Number = 0;
    private var _partialBeers:ArrayCollection = new ArrayCollection();
}
}