package com.beerquest {
import com.beerquest.events.GameEvent;
import com.beerquest.events.PissLevelEvent;
import com.beerquest.ui.events.UiScoreEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

public class Game extends EventDispatcher {

    public function start(mode:String, me:PlayerData, seed:int):void {
        if (_mode != null) {
            throw "cannot start game multiple times";
        }
        _mode = mode;
        _me = me;
        dispatchEvent(new Event("meChanged"));
        _rand = new MersenneTwister(seed);
        _board = new BoardState(_rand);
        _board.game = this;
        _board.generateRandomWithoutGroups();
        dispatchEvent(new GameEvent(GameEvent.GAME_START, _board.clone()));
    }

    public function get mode():String {
        return _mode;
    }

    [Bindable(event="meChanged")]
    public function get me():PlayerData {
        return _me;
    }

    public function get board():BoardState {
        return _board;
    }

    public function get totalTurns():int {
        return Constants.INITIAL_TOTAL_TURNS;
    }

    [Bindable(event="gameOverChanged")]
    public function get gameOver():Boolean {
        return _gameOver;
    }

    public function endOfGame():void {
        _gameOver = true;
        Constants.STATS.gameOver = true;
        dispatchEvent(new Event("gameOverChanged"));
        dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
    }

    [Bindable(event="remainingTurnsChanged")]
    public function get remainingTurns():int {
        return Math.max(0, totalTurns - _currentTurn);
    }

    public function gainAdditionalTurns(t:int):void {
        if (t != 0) {
            _currentTurn -= t;
            dispatchEvent(new Event("remainingTurnsChanged"));
            dispatchEvent(new GameEvent(GameEvent.CURRENT_TURN_CHANGED));
        }
    }

    public function skipTurns(t:int):void {
        for (var i:int = 0; i < t; i++) {
            newTurn();
        }
    }

    public function newTurn():void {
        _currentTurn++;
        dispatchEvent(new Event("remainingTurnsChanged"));
        dispatchEvent(new GameEvent(GameEvent.CURRENT_TURN_CHANGED));
        if (remainingTurns <= 0) {
            endOfGame();
        } else {
            Constants.STATS.startTurn(this);
        }
    }

    public function executeCapacity(capacity:Capacity, token:TokenType = null):void {
        switch (capacity) {
            case Capacity.DIVINE_PEANUTS:
                board.transformTokensOfType(TokenType.LIQUOR, TokenType.WATER);
                break;
            case Capacity.WATERFALL:
                board.destroyTokensOfType(TokenType.VOMIT);
                break;
            case Capacity.BIG_BANG:
                board.destroyTokensOfType(token);
                break;
            case Capacity.BLOND_FURY_BAR:
                var blonds:int = board.destroyTokensOfType(TokenType.BLOND_BEER);
                me.fullBeers += blonds;
                dispatchEvent(new UiScoreEvent(blonds, 0, null, null, capacity));
                break;
            case Capacity.BROWN_FURY_BAR:
                var browns:int = board.destroyTokensOfType(TokenType.BROWN_BEER);
                me.fullBeers += browns;
                dispatchEvent(new UiScoreEvent(browns, 0, null, null, capacity));
                break;
            case Capacity.AMBER_FURY_BAR:
                var ambers:int = board.destroyTokensOfType(TokenType.AMBER_BEER);
                me.fullBeers += ambers;
                dispatchEvent(new UiScoreEvent(ambers, 0, null, null, capacity));
                break;
            case Capacity.BLOODY_MARY:
                var turns:int = 6;
                gainAdditionalTurns(turns);
                dispatchEvent(new UiScoreEvent(0, turns, null, null, capacity));
                board.createVomit(3);
                break;
        }
        me.useCapacity(capacity);
    }

    public function collectGroups(groups:Array):Array {
        // Reorder collected partial beers during the phase to favorize stack groups
        var groups2:Array = Utils.cloneArray(groups);
        var collected:Array = new Array();
        var group:Group;
        while (groups2.length > 0) {
            var preferred:TokenType = me.preferredPartialBeer;
            var found:Boolean = false;
            for (var i:int = 0; i < groups2.length; i++) {
                group = groups2[i];
                var collectedToken:TokenType = group.collectedToken;
                if (collectedToken != null && TokenType.isCompatible(collectedToken, preferred)) {
                    collectGroup(group);
                    collected.push(group);
                    groups2.splice(i, 1);
                    found = true;
                }
            }
            if (!found) {
                group = groups2.pop();
                collectGroup(group);
                collected.push(group);
            }
        }
        return collected;
    }

    public function collectGroup(group:Group):void {
        if (group.collectedToken != null) {
            me.partialBeers.addItem(group.token);
        }
        if (group.length >= 4) {
            me.gainCapacity(Capacity.fromToken(group.token));
        }
        if (group.length >= 5) {
            // TODO create super
        }

        me.piss += group.pissGain;
        me.vomit += group.vomitGain;
        me.fullBeers += group.beerGain;
        gainAdditionalTurns(group.turnsGain);
        Constants.STATS.addCollectedGroup(group.token, group.length);
    }

    public function generateTestBoard():void {
        _board.generateTestBoard();
    }

    public function generateRandomKeepingSomeVomit():void {
        _board.generateRandomKeepingSomeVomit();
    }

    public function swapCells(sx:int, sy:int, dx:int, dy:int):void {
        Constants.STATS.gemsSwapped(sx, sy, dx, dy);
        _board.swapCells(sx, sy, dx, dy);
    }

    public function get pissLevel():int {
        return _board.pissLevel;
    }

    public function set pissLevel(value:int):void {
        var pissRaise:Boolean = (value > _board.pissLevel);
        _board.pissLevel = value;
        dispatchEvent(new PissLevelEvent(pissRaise));
    }

    private var _mode:String;
    private var _me:PlayerData;
    private var _currentTurn:int = 0;
    private var _board:BoardState;
    private var _gameOver:Boolean = false;
    private var _rand:MersenneTwister;

}
}