package com.beerquest {
import com.beerquest.events.BoardEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.beerquest.events.GroupCollectionEvent;
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
        _rand = new DeadBeefRandom(seed);
        _board = new BoardState(_rand);
        _board.generateRandomWithoutGroups(DiscardEventBuffer.INSTANCE);
        execute(new GameEvent(GameEvent.GAME_START, _board.clone()));
    }

    internal function execute(event:Event):void {
        dispatchEvent(event);
        switch (event.type) {
            case GameEvent.TURN_END:
                if (remainingTurns <= 0) {
                    endOfGame();
                } else if (_board.computeMoves().length == 0) {
                    trace("No more move availables: reset board");
                    _board.generateRandomKeepingSomeVomit(InstantEventBuffer.INSTANCE);
                }
                break;
            case GroupCollectionEvent.GROUPS_COLLECTED:
                var ge:GroupCollectionEvent = event as GroupCollectionEvent;
                collectGroups(ge.groups);
                break;
            case GemsSwappedEvent.GEMS_SWAPPED:
                newTurn();
                break;
            case BoardEvent.BOARD_RESET:
                skipTurns(3);
                if (remainingTurns <= 0) {
                    endOfGame();
                }
                break;
        }
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
        dispatchEvent(new Event("gameOverChanged"));
        execute(new GameEvent(GameEvent.GAME_OVER));
    }

    [Bindable(event="remainingTurnsChanged")]
    public function get remainingTurns():int {
        return Math.max(0, totalTurns - _currentTurn);
    }

    public function gainAdditionalTurns(t:int):void {
        if (t != 0) {
            _currentTurn -= t;
            dispatchEvent(new Event("remainingTurnsChanged"));
            execute(new GameEvent(GameEvent.CURRENT_TURN_CHANGED));
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
        execute(new GameEvent(GameEvent.CURRENT_TURN_CHANGED));
    }

    public function executeCapacity(capacity:Capacity, token:TokenType, eventBuffer:EventBuffer):void {
        switch (capacity) {
            case Capacity.DIVINE_PEANUTS:
                board.transformTokensOfType(TokenType.LIQUOR, TokenType.WATER, eventBuffer);
                break;
            case Capacity.WATERFALL:
                board.destroyTokensOfType(TokenType.VOMIT, eventBuffer);
                break;
            case Capacity.BIG_BANG:
                board.destroyTokensOfType(token, eventBuffer);
                break;
            case Capacity.BLOND_FURY_BAR:
                var blonds:int = board.destroyTokensOfType(TokenType.BLOND_BEER, eventBuffer);
                me.fullBeers += blonds;
                dispatchEvent(new UiScoreEvent(blonds, 0, null, null, capacity));
                break;
            case Capacity.BROWN_FURY_BAR:
                var browns:int = board.destroyTokensOfType(TokenType.BROWN_BEER, eventBuffer);
                me.fullBeers += browns;
                dispatchEvent(new UiScoreEvent(browns, 0, null, null, capacity));
                break;
            case Capacity.AMBER_FURY_BAR:
                var ambers:int = board.destroyTokensOfType(TokenType.AMBER_BEER, eventBuffer);
                me.fullBeers += ambers;
                dispatchEvent(new UiScoreEvent(ambers, 0, null, null, capacity));
                break;
            case Capacity.BLOODY_MARY:
                var turns:int = 6;
                gainAdditionalTurns(turns);
                dispatchEvent(new UiScoreEvent(0, turns, null, null, capacity));
                board.createVomit(3, InstantEventBuffer.INSTANCE);
                break;
        }
        me.useCapacity(capacity, token);
    }

    public function collectGroups(groups:Array):Array {
        // Reorder collected partial beers during the phase to favorize stack groups
        var groups2:Array = Utils.cloneArray(groups);
        var collected:Array = new Array();
        var group:Group;
        while (groups2.length > 0) {
            var preferred:TokenType = me.preferredPartialBeer;
            var found:Boolean = false;
            var kept:Array = new Array();
            for (var i:int = 0; i < groups2.length; i++) {
                group = groups2[i];
                var collectedToken:TokenType = group.collectedToken;
                if (collectedToken != null && TokenType.isCompatible(collectedToken, preferred)) {
                    collectGroup(group);
                    collected.push(group);
                    found = true;
                } else {
                    kept.push(group);
                }
            }
            if (found) {
                groups2 = kept;
            } else {
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

        me.piss += group.pissGain;
        me.gainVomit(group.vomitGain);
        me.fullBeers += group.beerGain;
        gainAdditionalTurns(group.turnsGain);
    }

    public function generateTestBoard():void {
        _board.generateTestBoard(InstantEventBuffer.INSTANCE);
    }

    public function generateRandomKeepingSomeVomit():void {
        _board.generateRandomKeepingSomeVomit(InstantEventBuffer.INSTANCE);
    }

    public function swapCells(sx:int, sy:int, dx:int, dy:int):void {
        _board.swapCells(sx, sy, dx, dy, InstantEventBuffer.INSTANCE);
    }

    public function get pissLevel():int {
        return _board.pissLevel;
    }

    public function set pissLevel(value:int):void {
        var pissRaise:Boolean = (value > _board.pissLevel);
        _board.pissLevel = value;
        execute(new PissLevelEvent(pissRaise));
    }

    private var _mode:String;
    private var _me:PlayerData;
    private var _currentTurn:int = 0;
    private var _board:BoardState;
    private var _gameOver:Boolean = false;
    private var _rand:DeadBeefRandom;

}
}