package com.beerquest {
import com.beerquest.events.GameEvent;

import flash.events.EventDispatcher;
import flash.media.Sound;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

public class PlayerData extends EventDispatcher {

    public function PlayerData(id:int, name:String, title:String, avatarUrl:String, level:Number, totalBeers:Number, totalCaps:Number) {
        _id = id;
        _name = name;
        _title = title;
        _avatarUrl = avatarUrl;
        _level = level;
        _totalBeers = totalBeers;
        _totalCaps = totalCaps;
        _capacities = new ArrayCollection();
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            _capacities.addItem(Capacity.NONE);
        }
        _partialBeers = new ArrayCollection();
        _partialBeers.addEventListener(CollectionEvent.COLLECTION_CHANGE, onPartialBeerCollectionChanged);
    }

    private function onPartialBeerCollectionChanged(e:CollectionEvent):void {
        dispatchEvent(new GameEvent(GameEvent.PARTIAL_BEERS_CHANGED, this));
    }

    [Bindable(event="ScoreChanged")]
    public function get score():Number {
        return _score;
    }

    public function set score(value:Number):void {
        _score = value;
        dispatchEvent(new GameEvent(GameEvent.SCORE_CHANGED, this));
    }

    [Bindable(event="FullBeersChanged")]
    public function get fullBeers():Number {
        return _fullBeers;
    }

    public function set fullBeers(value:Number):void {
        _fullBeers = value;
        dispatchEvent(new GameEvent(GameEvent.FULL_BEERS_CHANGED, this));
    }

    [Bindable(event="MultiplierChanged")]
    public function get multiplier():Number {
        return _multiplier;
    }

    public function set multiplier(value:Number):void {
        _multiplier = value;
        dispatchEvent(new GameEvent(GameEvent.MULTIPLIER_CHANGED, this));
    }

    [Bindable(event="PissChanged")]
    public function get piss():Number {
        return _piss;
    }

    public function set piss(value:Number):void {
        _piss = value;
        if (_piss < 0) {
            _piss = 0;
        } else if (_piss > 100) {
            _piss = 100;
        }
        dispatchEvent(new GameEvent(GameEvent.PISS_CHANGED, this));
    }

    [Bindable(event="VomitChanged")]
    public function get vomit():Number {
        return _vomit;
    }

    public function set vomit(value:Number):void {
        _vomit = value;
        if (_vomit < 0) {
            _vomit = 0;
        } else if (_vomit > 101) {
            _vomit = 101;
        }
        dispatchEvent(new GameEvent(GameEvent.VOMIT_CHANGED, this));
    }

    [Bindable(event="CoasterReserveChanged")]
    public function get coasterReserve():Number {
        return _coasterReserve;
    }

    public function set coasterReserve(value:Number):void {
        _coasterReserve = value;
        if (_coasterReserve < 0) {
            _coasterReserve = 0;
        } else if (_coasterReserve > 3) {
            _coasterReserve = 3;
        }
        dispatchEvent(new GameEvent(GameEvent.COASTER_RESERVE_CHANGED, this));
    }

    public function get capacities():ArrayCollection {
        return _capacities;
    }

    public function clearCapacities():void {
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            _capacities.setItemAt(Capacity.NONE, i);
        }
    }

    public function usedCapacity(c:Capacity):Boolean {
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            if (_capacities.getItemAt(i) == c) {
                _capacities.setItemAt(Capacity.NONE, i);
                return true;
            }
        }
        return false;
    }

    public function get partialBeers():ArrayCollection {
        return _partialBeers;
    }

    public function get preferredPartialBeer():TokenType {
        if (_partialBeers.length == 0) {
            return TokenType.NONE;
        } else if (_partialBeers.length == 1) {
            return _partialBeers.getItemAt(0) as TokenType;
        } else if (_partialBeers.getItemAt(0) == TokenType.TRIPLE) {
            return _partialBeers.getItemAt(_partialBeers.length - 2) as TokenType;
        } else {
            return _partialBeers.getItemAt(_partialBeers.length - 1) as TokenType;
        }
    }

    public function get id():int {
        return _id;
    }

    public function get name():String {
        return _name;
    }

    public function get title():String {
        return _title;
    }

    public function get avatarUrl():String {
        return _avatarUrl;
    }

    public function get level():Number {
        return _level;
    }

    public function get totalBeers():Number {
        return _totalBeers;
    }

    public function get totalCaps():Number {
        return _totalCaps;
    }

    public function addPartialBeer(type:TokenType):void {
        if (_partialBeers.length == 45) {
            _partialBeers.removeItemAt(0);
        }
        _partialBeers.addItem(type);
    }

    public function doPiss():void {
        piss /= 2;
        if (Constants.SOUND_ENABLED) {
            var fx:Sound = new PissFX();
            fx.play();
        }
    }

    public function doGainCapacity(capacity:Capacity):Boolean {
        var i:int, c:Capacity;
        for (i = 0; i < Constants.MAX_CAPACITIES; i++) {
            c = _capacities.getItemAt(i) as Capacity;
            if (c == capacity) {
                return false;
            }
        }
        for (i = 0; i < Constants.MAX_CAPACITIES; i++) {
            c = _capacities.getItemAt(i) as Capacity;
            if (!c.enabled) {
                _capacities.setItemAt(capacity, i);
                return true;
            }
        }
        return false;
    }

    private var _id:int;
    private var _name:String;
    private var _title:String;
    private var _avatarUrl:String;
    private var _level:Number;
    private var _totalBeers:Number;
    private var _totalCaps:Number;
    private var _score:Number = 0;
    private var _multiplier:Number = 1;
    private var _fullBeers:Number = 0;
    private var _piss:Number = 0;
    private var _vomit:Number = 0;
    private var _partialBeers:ArrayCollection;
    private var _capacities:ArrayCollection;
    private var _coasterReserve:Number = 0;

    [Embed(source="../../pipi.mp3")]
    private static var PissFX:Class;

}
}