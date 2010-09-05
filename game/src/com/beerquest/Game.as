package com.beerquest {
import com.beerquest.events.GameEvent;
import com.beerquest.ui.events.ScoreEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

public class Game extends EventDispatcher {

    public function start(mode:String, me:PlayerData, seed:int):void {
        _mode = mode;
        _me = me;
        dispatchEvent(new Event("meChanged"));
        _totalTurns = Constants.INITIAL_TOTAL_TURNS;
        _rand = new MersenneTwister(seed);
        _board = new BoardState(_rand);
        _board.generateRandomWithoutGroups();
        _board.game = this; // Do this AFTER not to have events during generation phase
        dispatchEvent(new GameEvent(GameEvent.GAME_START));
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

    public function get rand():MersenneTwister {
        return _rand;
    }

    public function get totalTurns():int {
        return _totalTurns;
    }

    [Bindable(event="GameOver")]
    public function get gameOver():Boolean {
        return _gameOver;
    }

    public function endOfGame():void {
        _gameOver = true;
        Constants.STATS.gameOver = true;
        dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
    }

    [Bindable(event="CurrentTurnChanged")]
    public function get remainingTurns():int {
        return Math.max(0, totalTurns - _currentTurn);
    }

    [Bindable(event="CurrentTurnChanged")]
    public function get currentTurn():int {
        return _currentTurn;
    }

    public function gainAdditionalTurns(t:int):void {
        if (t != 0) {
            _currentTurn -= t;
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
                dispatchEvent(new ScoreEvent(blonds, 0, null, null, capacity));
                break;
            case Capacity.BROWN_FURY_BAR:
                var browns:int = board.destroyTokensOfType(TokenType.BROWN_BEER);
                me.fullBeers += browns;
                dispatchEvent(new ScoreEvent(browns, 0, null, null, capacity));
                break;
            case Capacity.AMBER_FURY_BAR:
                var ambers:int = board.destroyTokensOfType(TokenType.AMBER_BEER);
                me.fullBeers += ambers;
                dispatchEvent(new ScoreEvent(ambers, 0, null, null, capacity));
                break;
            case Capacity.BLOODY_MARY:
                var turns:int = 6;
                gainAdditionalTurns(turns);
                dispatchEvent(new ScoreEvent(0, turns, null, null, capacity));
                board.createVomit(3);
                break;
        }
        me.useCapacity(capacity);
    }

    public function collectGroups(groups:Array):void {
        // Reorder collected partial beers during the phase to favorize stack groups
        while (groups.length > 0) {
            var preferred:TokenType = me.preferredPartialBeer;
            if (preferred == TokenType.NONE || preferred == TokenType.TRIPLE) {
                collectGroup(groups.pop());
            } else {
                var found:Boolean = false;
                for (var i:int = 0; i < groups.length; i++) {
                    if (groups[i].collectedToken != null && TokenType.isCompatible(groups[i].collectedToken, preferred)) {
                        collectGroup(groups[i]);
                        groups.splice(i, 1);
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    collectGroup(groups.pop());
                }
            }
        }
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

        // Dispatch events for vfx display
//        var token:Token = getToken(group.startX, group.startY);
//        var local:Point = new Point(token.x, token.y);
//        if (group.type == "horizontal") {
//            local.x += width / Constants.BOARD_SIZE * group.length / 2;
//            local.y += height / Constants.BOARD_SIZE / 2;
//        } else {
//            local.x += width / Constants.BOARD_SIZE / 2;
//            local.y += height / Constants.BOARD_SIZE * group.length / 2;
//        }
//        var scoreCoords:Point = localToGlobal(local);
//        var now:Date = new Date();
//        dispatchEvent(new ScoreEvent(beerGain, turnsGain, scoreCoords.x, scoreCoords.y));
//        if (collectedToken != null) {
//            dispatchEvent(new TokenEvent(collectedToken, scoreCoords.x, scoreCoords.y));
//        }
    }

    private var _mode:String;
    private var _me:PlayerData;
    private var _totalTurns:int;
    private var _currentTurn:int = 0;
    private var _board:BoardState;
    private var _gameOver:Boolean = false;
    private var _rand:MersenneTwister;
}
}