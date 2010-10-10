package com.beerquest {
import com.adobe.serialization.json.JSON;

import flash.net.URLVariables;

public class GameStats {
    public function GameStats() {
        var now:Date = new Date();
        startTime = now.valueOf();
    }

    public function get elapsedTime():Number {
        var now:Date = new Date();
        return (now.valueOf() - startTime);
    }

    public function startTurn(game:Game):void {
        var now:Date = new Date();
        if (turnStart != 0) {
            timePerTurns.push(now.valueOf() - turnStart);
        }
        turnStart = now.valueOf();
        if (game.board.pissLevel > maxPissLevel) {
            maxPissLevel = game.board.pissLevel;
        }
        pissLevels.push(game.board.pissLevel);
        var vc:int = game.board.cellsOfType(TokenType.VOMIT).length;
        if (vc > maxVomitOnBoard) {
            maxVomitOnBoard = vc;
        }
        totalTurns++;
        vomitsOnBoard.push(vc);
        replay.push({
            type: "status",
            turn: totalTurns,
            time: elapsedTime,
            board: game.board.encodedState(),
            piss: game.me.piss,
            vomit: game.me.vomit,
            capa1: game.me.capacities[0].encodedState(),
            capa2: game.me.capacities[1].encodedState(),
            stack: game.me.stackEncodedState()
        });
    }

    public function boardReset():void {
        resetCount++;
        replay.push({
            type: "reset",
            turn: totalTurns,
            time: elapsedTime
        });
    }

    public function gemsSwapped(sx:int, sy:int, dx:int, dy:int):void {
        replay.push({
            type: "swap",
            turn: totalTurns,
            time: elapsedTime,
            sx: sx,
            sy: sy,
            dx: dx,
            dy: dy
        });
    }

    public function capacityUsed(c:Capacity, targetToken:TokenType):void {
        switch (c) {
            case Capacity.AMBER_FURY_BAR:
                capaAmberUsed++;
                break;
            case Capacity.BIG_BANG:
                capaLiquorUsed++;
                break;
            case Capacity.DIVINE_PEANUTS:
                capaFoodUsed++;
                break;
            case Capacity.BLOND_FURY_BAR:
                capaBlondUsed++;
                break;
            case Capacity.BLOODY_MARY:
                capaTomatoUsed++;
                break;
            case Capacity.BROWN_FURY_BAR:
                capaBrownUsed++;
                break;
        }
        replay.push({
            type: "capacity",
            turn: totalTurns,
            time: elapsedTime,
            capacity: c.encodedState(),
            target: (targetToken != null) ? targetToken.repr : ""
        });
    }

    public function pissed():void {
        pissCount++;
        replay.push({
            type: "piss",
            turn: totalTurns,
            time: elapsedTime
        });
    }

    public function avg(a:Array):Number {
        var total:Number = 0;
        for each (var b:Number in a) {
            total += b;
        }
        return total / a.length;
    }

    public function addCollectedGroup(type:TokenType, size:Number):void {
        if (size > maxGroupSize) {
            maxGroupSize = size;
        }
        if (size == 3) {
            groups3++;
        } else if (size == 4) {
            groups4++;
        } else {
            groups5++;
        }

        switch (type) {
            case TokenType.BLOND_BEER:
                collectedBlond += size;
                if (size >= 4) {
                    capaBlondGained++;
                }
                break;
            case TokenType.BROWN_BEER:
                collectedBrown += size;
                if (size >= 4) {
                    capaBrownGained++;
                }
                break;
            case TokenType.AMBER_BEER:
                collectedAmber += size;
                if (size >= 4) {
                    capaAmberGained++;
                }
                break;
            case TokenType.FOOD:
                collectedFood += size;
                if (size >= 4) {
                    capaFoodGained++;
                }
                break;
            case TokenType.WATER:
                collectedWater += size;
                if (size >= 4) {
                    capaWaterGained++;
                }
                break;
            case TokenType.LIQUOR:
                collectedLiquor += size;
                if (size >= 4) {
                    capaLiquorGained++;
                }
                break;
            case TokenType.TOMATO_JUICE:
                collectedTomato += size;
                if (size >= 4) {
                    capaTomatoGained++;
                }
                break;
        }
    }

    public function addCombo(size:Number):void {
        if (size > maxCombo) {
            maxCombo = size;
        }
        combos.push(size);
    }

    public function getForSerialization():URLVariables {
        var result:URLVariables = new URLVariables();
        result.play_time = elapsedTime;
        result.avg_time_per_turn = avg(timePerTurns);
        result.total_turns = totalTurns;
        result.replay = JSON.encode(replay);
        result.collected_blond = collectedBlond;
        result.collected_brown = collectedBrown;
        result.collected_amber = collectedAmber;
        result.collected_food = collectedFood;
        result.collected_water = collectedWater;
        result.collected_liquor = collectedLiquor;
        result.collected_tomato = collectedTomato;
        result.max_group_size = maxGroupSize;
        result.groups_3 = groups3;
        result.groups_4 = groups4;
        result.groups_5 = groups5;
        result.max_combo = maxCombo;
        result.avg_combo = avg(combos);
        result.capa_blond_gained = capaBlondGained;
        result.capa_blond_used = capaBlondUsed;
        result.capa_brown_gained = capaBrownGained;
        result.capa_brown_used = capaBrownUsed;
        result.capa_amber_gained = capaAmberGained;
        result.capa_amber_used = capaAmberUsed;
        result.capa_food_gained = capaFoodGained;
        result.capa_food_used = capaFoodUsed;
        result.capa_water_gained = capaWaterGained;
        result.capa_water_used = capaWaterUsed;
        result.capa_liquor_gained = capaLiquorGained;
        result.capa_liquor_used = capaLiquorUsed;
        result.capa_tomato_gained = capaTomatoGained;
        result.capa_tomato_used = capaTomatoUsed;
        result.piss_count = pissCount;
        result.vomit_count = vomitCount;
        result.reset_count = resetCount;
        result.max_piss_level = maxPissLevel;
        result.avg_piss_level = avg(pissLevels);
        result.max_vomit = maxVomitOnBoard;
        result.avg_vomit = avg(vomitsOnBoard);
        result.invalid_moves = invalidMoves;
        result.stack_ejected = stackEjected;
        result.stack_collected = stackCollected;
        result.game_over = gameOver;
        return result;
    }

    public var startTime:Number;
    public var turnStart:Number = 0;
    public var timePerTurns:Array = new Array();
    public var totalTurns:Number = 0;
    public var replay:Array = new Array();
    public var collectedBlond:Number = 0;
    public var collectedBrown:Number = 0;
    public var collectedAmber:Number = 0;
    public var collectedFood:Number = 0;
    public var collectedWater:Number = 0;
    public var collectedLiquor:Number = 0;
    public var collectedTomato:Number = 0;
    public var groupsPerTurn:Array = new Array();
    public var maxGroupsPerTurn:Number = 0;
    public var groups3:Number = 0;
    public var groups4:Number = 0;
    public var groups5:Number = 0;
    public var maxGroupSize:Number = 0;
    public var maxCombo:Number = 0;
    public var combos:Array = new Array();
    public var capaBlondGained:Number = 0;
    public var capaBlondUsed:Number = 0;
    public var capaBrownGained:Number = 0;
    public var capaBrownUsed:Number = 0;
    public var capaAmberGained:Number = 0;
    public var capaAmberUsed:Number = 0;
    public var capaFoodGained:Number = 0;
    public var capaFoodUsed:Number = 0;
    public var capaWaterGained:Number = 0;
    public var capaWaterUsed:Number = 0;
    public var capaLiquorGained:Number = 0;
    public var capaLiquorUsed:Number = 0;
    public var capaTomatoGained:Number = 0;
    public var capaTomatoUsed:Number = 0;
    public var pissCount:Number = 0;
    public var vomitCount:Number = 0;
    public var resetCount:Number = 0;
    public var maxPissLevel:Number = 0;
    public var pissLevels:Array = new Array();
    public var maxVomitOnBoard:Number = 0;
    public var vomitsOnBoard:Array = new Array();
    public var invalidMoves:Number = 0; // TODO probablement inutilisé
    public var stackEjected:Number = 0; // TODO probablement inutilisé
    public var stackCollected:Number = 0;
    public var gameOver:Boolean = false;

}
}