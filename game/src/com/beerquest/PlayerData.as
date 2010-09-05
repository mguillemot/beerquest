package com.beerquest {
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.ui.EffectLayer;
import com.beerquest.ui.TokenCollectionView;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

public class PlayerData extends EventDispatcher {

    public function PlayerData(game:Game) {
        _game = game;
        _capacities = new ArrayCollection();
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            _capacities.addItem(Capacity.NONE);
        }
        _partialBeers = new ArrayCollection();
        _partialBeers.addEventListener(CollectionEvent.COLLECTION_CHANGE, onPartialBeerCollectionChanged);
    }

    private function onPartialBeerCollectionChanged(e:CollectionEvent):void {
        _game.dispatchEvent(new GameEvent(GameEvent.PARTIAL_BEERS_CHANGED));
    }

    [Bindable(event="FullBeersChanged")]
    public function get fullBeers():Number {
        return _fullBeers;
    }

    public function set fullBeers(value:Number):void {
        _fullBeers = value;
        dispatchEvent(new GameEvent(GameEvent.FULL_BEERS_CHANGED));
    }

    [Bindable(event="PissChanged")]
    public function get piss():Number {
        return _piss;
    }

    [Bindable(event="PissChanged")]
    public function get pissLevel():int {
        if (_piss >= 100) {
            return 3;
        } else if (_piss >= 90) {
            return 2;
        } else if (_piss >= 80) {
            return 1;
        }
        return 0;
    }

    public function set piss(value:Number):void {
        _piss = value;
        if (_piss < 0) {
            _piss = 0;
        } else if (_piss > 100) {
            _piss = 100;
        }
        dispatchEvent(new GameEvent(GameEvent.PISS_CHANGED));
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
        _game.dispatchEvent(new GameEvent(GameEvent.VOMIT_CHANGED));
        if (vomit > 100) {
            _game.board.createVomit(5);
            dispatchEvent(new GameEvent(GameEvent.VOMIT));
            Constants.STATS.vomitCount++;
            vomit = 30;
        }
    }

    public function get capacities():ArrayCollection {
        return _capacities;
    }

    public function clearCapacities():void {
        for (var i:int = 0; i < Constants.MAX_CAPACITIES; i++) {
            _capacities.setItemAt(Capacity.NONE, i);
        }
    }

    public function useCapacity(c:Capacity):Boolean {
        for (var i:int = Constants.MAX_CAPACITIES - 1; i >= 0; i--) {
            if (_capacities.getItemAt(i) == c) {
                _capacities.setItemAt(Capacity.NONE, i);
                Constants.STATS.capacityUsed(c);
                _game.dispatchEvent(new CapacityEvent(CapacityEvent.CAPACITY_EXECUTED, c));
                return true;
            }
        }
        return false;
    }

    public function collectBeer():void {
        Constants.STATS.stackCollected++;
    }

    public function get partialBeers():ArrayCollection {
        return _partialBeers;
    }

    public function get stackCompletion():int {
        if (_partialBeers.length <= 1) {
            return _partialBeers.length;
        } else {
            return (_partialBeers.getItemAt(_partialBeers.length - 1) == _partialBeers.getItemAt(_partialBeers.length - 2)) ? 2 : 1;
        }
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
        // TODO virer le timer et le mettre dans l'UI
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
        Constants.STATS.pissed();
        _game.newTurn();
    }

    public function gainCapacity(capacity:Capacity):Boolean {
        var i:int, c:Capacity;
        for (i = 0; i < Constants.MAX_CAPACITIES; i++) {
            c = _capacities.getItemAt(i) as Capacity;
            if (!c.enabled) {
                _capacities.setItemAt(capacity, i);
                _game.dispatchEvent(new CapacityEvent(CapacityEvent.CAPACITY_GAINED, capacity));
                return true;
            }
        }
        return false;
    }

    private var _game:Game;
    private var _fullBeers:Number = 0;
    private var _piss:Number = 0;
    private var _vomit:Number = 0;
    private var _partialBeers:ArrayCollection;
    private var _capacities:ArrayCollection;

}
}