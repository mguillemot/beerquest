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

    public function get collectedBeers():ArrayCollection {
        return _collectedBeers;
    }

    public function addCollectedBeer(type:TokenType, big:Boolean):void {
        _collectedBeers.addItem({type: type, big: big});
    }

    private var _score:Number = 0;
    private var _collectedBeers:ArrayCollection = new ArrayCollection();
}
}