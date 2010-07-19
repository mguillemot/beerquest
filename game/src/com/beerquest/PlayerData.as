package com.beerquest {
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

public class PlayerData extends EventDispatcher {
    public function PlayerData(name:String, title:String, level:Number) {
        _name = name;
        _title = title;
        _level = level;
        _capacities = new ArrayCollection();
        _capacities.addItem(new Capacity("?"));
        _capacities.addItem(new Capacity("?"));
        _capacities.addItem(new Capacity("?"));
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

    [Bindable(event="pissChanged")]
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
        dispatchEvent(new Event("pissChanged"));
    }

    [Bindable(event="vomitChanged")]
    public function get vomit():Number {
        return _vomit;
    }

    public function set vomit(value:Number):void {
        _vomit = value;
        if (_vomit < 0) {
            _vomit = 0;
        } else if (_vomit > 100) {
            _vomit = 100;
        }
        dispatchEvent(new Event("vomitChanged"));
    }

    public function get capacities():ArrayCollection {
        return _capacities;
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

    public function doVomit():void {
        vomit /= 2;
    }

    public function doPiss():void {
        piss /= 2;
    }

    public function doGainCapacity():void {
        for (var i:int = 0; i < 3; i++) {
            var c:Capacity = _capacities.getItemAt(i) as Capacity;
            if (!c.active) {
                _capacities.setItemAt(new Capacity("Capacity " + (i + 1), true, true), i);
                return;
            }
        }
    }

    private var _name:String;
    private var _title:String;
    private var _level:Number;
    private var _score:Number = 0;
    private var _multiplier:Number = 1;
    private var _fullBeers:Number = 0;
    private var _piss:Number = 0;
    private var _vomit:Number = 0;
    private var _partialBeers:ArrayCollection = new ArrayCollection();
    private var _capacities:ArrayCollection;
}
}