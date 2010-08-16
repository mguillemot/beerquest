package com.beerquest {
import com.beerquest.events.GameEvent;

import com.beerquest.ui.EffectLayer;
import com.beerquest.ui.TokenCollectionView;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.media.Sound;

import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

public class PlayerData extends EventDispatcher {

    public function PlayerData() {
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

    [Bindable(event="FullBeersChanged")]
    public function get fullBeers():Number {
        return _fullBeers;
    }

    public function set fullBeers(value:Number):void {
        _fullBeers = value;
        dispatchEvent(new GameEvent(GameEvent.FULL_BEERS_CHANGED, this));
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

    public function get capacities():ArrayCollection {
        return _capacities;
    }

    public function clearCapacities():void {
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            _capacities.setItemAt(Capacity.NONE, i);
        }
    }

    public function usedCapacity(c:Capacity):Boolean {
        Constants.STATS.capacityUsed(c);
        for (var i:int = Constants.MAX_CAPACITIES - 1; i >= 0; i--) {
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

    public function partialBeersEncodedState():String {
        var res:String = "";
        for each (var pb:TokenType in partialBeers) {
            res += pb.repr;
        }
        return res;
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

    public function addPartialBeer(type:TokenType):void {
        var timer:Timer = new Timer(EffectLayer.TOKEN_EFFECT_TIME_MS, 1);
        timer.addEventListener(TimerEvent.TIMER, function():void {
            if (_partialBeers.length == TokenCollectionView.MAX_STACK) {
                _partialBeers.removeItemAt(0);
            }
            _partialBeers.addItem(type);
        });
        timer.start();
    }

    public function doPiss():void {
        piss *= 0.4;
        if (Constants.SOUND_ENABLED) {
            var fx:Sound = new PissFX();
            fx.play();
        }
    }

    public function doGainCapacity(capacity:Capacity):Boolean {
        var i:int, c:Capacity;
        for (i = 0; i < Constants.MAX_CAPACITIES; i++) {
            c = _capacities.getItemAt(i) as Capacity;
            if (!c.enabled) {
                _capacities.setItemAt(capacity, i);
                if (Constants.SOUND_ENABLED) {
                    var fx:Sound = new CapaGainFX();
                    fx.play();
                }
                return true;
            }
        }
        return false;
    }

    private var _fullBeers:Number = 0;
    private var _piss:Number = 0;
    private var _vomit:Number = 0;
    private var _partialBeers:ArrayCollection;
    private var _capacities:ArrayCollection;

    [Embed(source="../../pipi.mp3")]
    private static var PissFX:Class;

    [Embed(source="../../ok-capa.mp3")]
    private static var CapaGainFX:Class;

}
}