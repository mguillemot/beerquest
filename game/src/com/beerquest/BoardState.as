package com.beerquest {
import com.beerquest.events.BoardEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.beerquest.events.GroupCollectionEvent;

import flash.geom.Point;

public class BoardState {
    public function BoardState(rand:DeadBeefRandom = null) {
        _rand = (rand == null) ? DeadBeefRandom.generate() : rand;
        for (var i:int = 0; i < Constants.BOARD_SIZE * Constants.BOARD_SIZE; i++) {
            _state.push(TokenType.NONE);
            _supers.push(false);
        }
    }

    public function getCell(x:int, y:int):TokenType {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid cell: " + x + ":" + y;
        }
        return _state[x * Constants.BOARD_SIZE + y];
    }

    public function getSuper(x:int, y:int):Boolean {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid cell: " + x + ":" + y;
        }
        return _supers[x * Constants.BOARD_SIZE + y];
    }

    internal function setCell(x:int, y:int, value:TokenType, superToken:Boolean):void {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid cell: " + x + ":" + y;
        }
        _state[x * Constants.BOARD_SIZE + y] = value;
        _supers[x * Constants.BOARD_SIZE + y] = superToken;
    }

    private function clearSupers():void {
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                setCell(i, j, getCell(i, j), false);
            }
        }
    }

    public function toString():String {
        var repr:String = "";
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                repr += getCell(i, j).repr;
                repr += getSuper(i, j) ? "!" : "-";
                repr += "|";
            }
            repr += "\n";
        }
        return repr;
    }

    public function encodedState():String {
        var repr:String = "";
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                var tr:String = getCell(i, j).repr;
                repr += getSuper(i, j) ? tr.toUpperCase() : tr;
            }
        }
        return repr;
    }

    public function clone():BoardState {
        var clone:BoardState = new BoardState();
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                clone.setCell(i, j, getCell(i, j), getSuper(i, j));
            }
        }
        clone.pissLevel = pissLevel;
        return clone;
    }

    private function generateFullRandom():void {
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                setCell(i, j, generateNewCell(), false);
            }
        }
    }

    internal function generateRandomWithoutGroups(eventBuffer:EventBuffer):void {
        do {
            generateFullRandom();
            normalize(eventBuffer, false);
        } while (computeMoves().length == 0);
    }

    internal function generateRandomKeepingSomeVomit(eventBuffer:EventBuffer):void {
        var vomit:Array = cellsOfType(TokenType.VOMIT);
        if (vomit.length > 0) {
            vomit = Utils.randomizeArray(vomit, _rand);
            var toRemove:int = Math.floor(vomit.length * .25);
            vomit.splice(-toRemove, toRemove);
        }
        do {
            generateFullRandom();
            normalize(DiscardEventBuffer.INSTANCE, false);
            for each (var cell:Point in vomit) {
                setCell(cell.x, cell.y, TokenType.VOMIT, false);
            }
        } while (computeMoves().length == 0);
        eventBuffer.push(new BoardEvent(BoardEvent.BOARD_RESET, vomit, clone()));
    }

    internal function generateTestBoard(eventBuffer:EventBuffer):void {
        var repr:String = "" +
                "fvvvtvvv" +
                "fvvvrttv" +
                "vfvbbrrv" +
                "vvvvrbbv" +
                "vvvvbrrv" +
                "vvvvrbbv" +
                "vvvwbrrv" +
                "vwwvwbbv";
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                var tokenRepr:String = repr.substr(j * Constants.BOARD_SIZE + i, 1);
                setCell(i, j, TokenType.fromRepr(tokenRepr), tokenRepr.toLowerCase() != tokenRepr);
            }
        }
        eventBuffer.push(new BoardEvent(BoardEvent.BOARD_RESET, new Array(), clone()));
    }

    internal function createVomit(count:int, eventBuffer:EventBuffer):Array {
        var cells:Array = getRandomNonVomitNonSuperCells(count);
        transformCells(cells, TokenType.VOMIT, true, eventBuffer);
        return cells;
    }

    private function getRandomNonVomitNonSuperCells(maxCells:int):Array {
        var available:Array = new Array();
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                if (getCell(i, j) != TokenType.VOMIT && !getSuper(i, j)) {
                    available.push(new Point(i, j));
                }
            }
        }
        if (available.length > 0) {
            available = Utils.randomizeArray(available, _rand);
            available.splice(maxCells);
        }
        return available;
    }

    internal function swapCells(sx:int, sy:int, dx:int, dy:int, eventBuffer:EventBuffer):void {
        // Operation
        var destType:TokenType = getCell(dx, dy);
        var destSuper:Boolean = getSuper(dx, dy);
        setCell(dx, dy, getCell(sx, sy), getSuper(dx, sy));
        setCell(sx, sy, destType, destSuper);
        eventBuffer.push(new GemsSwappedEvent(sx, sy, dx, dy, clone()));
        normalize(eventBuffer, true);
    }

    private function destroyCells(cells:Array, eventBuffer:EventBuffer):void {
        for each (var cell:Point in cells) {
            setCell(cell.x, cell.y, TokenType.NONE, false);
        }
        compact();
        eventBuffer.push(new BoardEvent(BoardEvent.CELLS_DESTROYED, cells, clone()));
        normalize(eventBuffer, true);
    }

    internal function destroyTokensOfType(targetType:TokenType, eventBuffer:EventBuffer):int {
        var count:int = 0, supers:int = 0;
        var toRemove:Array = new Array();
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                if (getCell(i, j) == targetType) {
                    count++;
                    if (getSuper(i, j)) {
                        supers++;
                    }
                    toRemove.push(new Point(i, j));
                }
            }
        }
        destroyCells(toRemove, eventBuffer);
        return count + Constants.SUPER_GEM_VALUE * supers;
    }

    internal function transformTokensOfType(source:TokenType, target:TokenType, eventBuffer:EventBuffer):int {
        var cells:Array = new Array();
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                if (getCell(i, j) == source) {
                    cells.push(new Point(i, j));
                }
            }
        }
        transformCells(cells, target, false, eventBuffer);
        normalize(eventBuffer, true);
        return cells.length;
    }

    private function transformCells(cells:Array, target:TokenType, resetSuper:Boolean, eventBuffer:EventBuffer):void {
        for each (var cell:Point in cells) {
            setCell(cell.x, cell.y, target, resetSuper ? false : getSuper(cell.x, cell.y));
        }
        eventBuffer.push(new BoardEvent((target == TokenType.VOMIT) ? BoardEvent.CELLS_VOMITED : BoardEvent.CELLS_TRANSFORMED, cells, clone()));
        normalize(eventBuffer, true);
    }

    public function cellsOfType(token:TokenType):Array {
        var cells:Array = new Array();
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                if (getCell(i, j) == token) {
                    cells.push(new Point(i, j));
                }
            }
        }
        return cells;
    }

    private function normalize(eventBuffer:EventBuffer, generateSupers:Boolean):void {
        eventBuffer.push(new GameEvent(GameEvent.TURN_BEGIN, clone()));
        while (hasGroups) {
            eventBuffer.push(new GameEvent(GameEvent.PHASE_BEGIN, clone()));
            var groups:Array = computeGroups();
            destroyGroups(groups, generateSupers);
            compact();
            eventBuffer.push(new GroupCollectionEvent(groups, clone()));
            eventBuffer.push(new GameEvent(GameEvent.PHASE_END, clone()));
        }
        eventBuffer.push(new GameEvent(GameEvent.TURN_END, clone()));
    }

    public function computeGroups():Array {
        var groups:Array = new Array();
        var i:int, j:int, supers:int, token:TokenType;

        // Check for horizontal groups
        for (j = 0; j < Constants.BOARD_SIZE; j++) {
            for (i = 0; i < Constants.BOARD_SIZE - 2; i++) {
                token = getCell(i, j);
                if (token.collectible) {
                    var di:int = 0;
                    supers = 0;
                    while ((i + di) < Constants.BOARD_SIZE && getCell(i + di, j) == token) {
                        if (getSuper(i + di, j)) {
                            supers++;
                        }
                        di++;
                    }
                    if (di >= 3) {
                        groups.push(new Group(i, j, "horizontal", di, token, supers));
                    }
                    i += (di - 1);
                }
            }
        }

        // Check for vertical groups
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE - 2; j++) {
                token = getCell(i, j);
                if (token.collectible) {
                    var dj:int = 1;
                    supers = 0;
                    while ((j + dj) < Constants.BOARD_SIZE && getCell(i, j + dj) == token) {
                        if (getSuper(i, j + dj)) {
                            supers++;
                        }
                        dj++;
                    }
                    if (dj >= 3) {
                        groups.push(new Group(i, j, "vertical", dj, token, supers));
                    }
                    j += (dj - 1);
                }
            }
        }

        return groups;
    }

    public function get hasGroups():Boolean {
        var i:int, j:int, token:TokenType;

        // Check for horizontal groups
        for (j = 0; j < Constants.BOARD_SIZE; j++) {
            for (i = 0; i < Constants.BOARD_SIZE - 2; i++) {
                token = getCell(i, j);
                if (token.collectible) {
                    var di:int = 1;
                    while ((i + di) < Constants.BOARD_SIZE && getCell(i + di, j) == token) {
                        di++;
                    }
                    if (di >= 3) {
                        return true;
                    }
                    i += (di - 1);
                }
            }
        }

        // Check for vertical groups
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE - 2; j++) {
                token = getCell(i, j);
                if (token.collectible) {
                    var dj:int = 1;
                    while ((j + dj) < Constants.BOARD_SIZE && getCell(i, j + dj) == token) {
                        dj++;
                    }
                    if (dj >= 3) {
                        return true;
                    }
                    j += (dj - 1);
                }
            }
        }

        return false;
    }

    public function computeMoves(piss:Boolean = true):Array {
        if (hasGroups) {
            trace("WARN: impossible to compute moves on a board that has groups");
            return null;
        }

        var moves:Array = new Array();
        var i:int, j:int;
        var movePissLevel:int = (piss) ? pissLevel : 0;

        // Check for horizontal moves
        for (j = 0; j < Constants.BOARD_SIZE - movePissLevel; j++) {
            for (i = 0; i < Constants.BOARD_SIZE - 1; i++) {
                var leftCell:TokenType = getCell(i, j);
                var leftSuper:Boolean = getSuper(i, j);
                var rightCell:TokenType = getCell(i + 1, j);
                var rightSuper:Boolean = getSuper(i + 1, j);
                setCell(i, j, rightCell, rightSuper);
                setCell(i + 1, j, TokenType.NONE, false);
                if (hasGroups) {
                    moves.push({type:"horizontal", startX:i, startY:j, endX:(i + 1), endY:j, hintX:(i + 1), hintY:j});
                } else {
                    setCell(i, j, TokenType.NONE, false);
                    setCell(i + 1, j, leftCell, leftSuper);
                    if (hasGroups) {
                        moves.push({type:"horizontal", startX:i, startY:j, endX:(i + 1), endY:j, hintX:i, hintY:j});
                    }
                }
                setCell(i, j, leftCell, leftSuper);
                setCell(i + 1, j, rightCell, rightSuper);
            }
        }

        // Check for vertical moves
        for (j = 0; j < Constants.BOARD_SIZE - 1 - movePissLevel; j++) {
            for (i = 0; i < Constants.BOARD_SIZE; i++) {
                var topCell:TokenType = getCell(i, j);
                var topSuper:Boolean = getSuper(i, j);
                var bottomCell:TokenType = getCell(i, j + 1);
                var bottomSuper:Boolean = getSuper(i, j + 1);
                setCell(i, j, bottomCell, bottomSuper);
                setCell(i, j + 1, TokenType.NONE, false);
                if (hasGroups) {
                    moves.push({type:"vertical", startX:i, startY:j, endX:i, endY:(j + 1), hintX:i, hintY:(j + 1)});
                } else {
                    setCell(i, j, TokenType.NONE, false);
                    setCell(i, j + 1, topCell, topSuper);
                    if (hasGroups) {
                        moves.push({type:"vertical", startX:i, startY:j, endX:i, endY:(j + 1), hintX:i, hintY:j});
                    }
                }
                setCell(i, j, topCell, topSuper);
                setCell(i, j + 1, bottomCell, bottomSuper);
            }
        }

        return moves;
    }

    public function isLegalMove(type:String, startX:int, startY:int):Boolean {
        // Note: this function could be optimized by returning prematurely in case of success
        for each (var move:Object in computeMoves()) {
            if (move.type == type && move.startX == startX && move.startY == startY) {
                return true;
            }
        }
        return false;
    }

    private function destroyGroups(groups:Array, generateSupers:Boolean):Array {
        // Warning: this operation is tricky since we have to make sure that super-gems that are also members of a <=4 group stay
        // on board without any influence of the group destroy orders. To this prupose, destroy is implemented as a multiple pass
        // process.
        var group:Group, i:int, j:int, k:int;
        for each (group in groups) {
            for (k = 0; k < group.length; k++) {
                i = group.x;
                j = group.y;
                if (group.direction == "horizontal") {
                    i += k;
                } else {
                    j += k;
                }
                setCell(i, j, TokenType.NONE, false);
            }
        }
        if (generateSupers) {
            for each (group in groups) {
                if (group.length >= 5) {
                    setCell(group.midX, group.midY, group.token, true);
                }
            }
        }
        return groups;
    }

    private function compact():void {
        var compacted:Boolean = true;
        while (compacted) {
            compacted = false;
            for (var j:int = Constants.BOARD_SIZE - 1; j >= 1; j--) {
                for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                    if (getCell(i, j) == TokenType.NONE) {
                        setCell(i, j, getCell(i, j - 1), getSuper(i, j - 1));
                        setCell(i, j - 1, TokenType.NONE, false);
                        compacted = true;
                    }
                }
            }
            for (var ii:int = 0; ii < Constants.BOARD_SIZE; ii++) {
                if (getCell(ii, 0) == TokenType.NONE) {
                    setCell(ii, 0, generateNewCell(), false);
                }
            }
        }
    }

    private function generateNewCell():TokenType {
        var r:int = _rand.nextInt(1, 17);
        if (r <= 3) {
            return TokenType.BLOND_BEER;
        } else if (r <= 6) {
            return TokenType.BROWN_BEER;
        } else if (r <= 9) {
            return TokenType.AMBER_BEER;
        } else if (r <= 11) {
            return TokenType.FOOD;
        } else if (r <= 13) {
            return TokenType.WATER;
        } else if (r <= 15) {
            return TokenType.LIQUOR;
        } else { // r <= 17
            return TokenType.TOMATO_JUICE;
        }
    }

    internal function get pissLevel():int {
        return _pissLevel;
    }

    internal function set pissLevel(pissLevel:int):void {
        _pissLevel = pissLevel;
    }

    private var _state:Array = new Array();
    private var _supers:Array = new Array();
    private var _pissLevel:int = 0;
    private var _rand:DeadBeefRandom;

}
}