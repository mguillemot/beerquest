package com.beerquest {
import com.beerquest.events.BoardEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.beerquest.events.GroupCollectionEvent;

import flash.geom.Point;

public class BoardState {
    public function BoardState(rand:MersenneTwister = null) {
        _rand = (rand == null) ? MersenneTwister.generate() : rand;
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

    private function setAllCells(cells:Array, allSupers:Boolean):void {
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                setCell(i, j, cells[j][i], allSupers);
            }
        }
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

    internal function generateRandomWithoutGroups():void {
        do {
            generateFullRandom();
            normalize(true);
        } while (computeMoves().length == 0);
        clearSupers();
    }

    internal function generateRandomKeepingSomeVomit():void {
        var vomit:Array = cellsOfType(TokenType.VOMIT);
        if (vomit.length > 0) {
            vomit = Utils.randomizeArray(vomit, _rand);
            var toRemove:int = Math.floor(vomit.length * .25);
            vomit.splice(-toRemove, toRemove);
        }
        do {
            generateFullRandom();
            normalize(true);
            for each (var cell:Point in vomit) {
                setCell(cell.x, cell.y, TokenType.VOMIT, false);
            }
        } while (computeMoves().length == 0);
        if (_game != null) {
            _game.skipTurns(3);
            _game.dispatchEvent(new BoardEvent(BoardEvent.BOARD_RESET, vomit, clone()));
        }
    }

    internal function generateTestBoard():void {
        setAllCells([
            [TokenType.BLOND_BEER,TokenType.BROWN_BEER,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.BROWN_BEER,TokenType.BLOND_BEER,TokenType.BLOND_BEER,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.AMBER_BEER,TokenType.BROWN_BEER,TokenType.BROWN_BEER],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.BLOND_BEER,TokenType.BROWN_BEER,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.BROWN_BEER]
        ], false);
        setCell(0, 0, TokenType.BLOND_BEER, true);
        setCell(1, 1, TokenType.BLOND_BEER, true);
        if (_game != null) {
            _game.dispatchEvent(new BoardEvent(BoardEvent.BOARD_RESET, new Array(), clone()));
        }
    }

    private function getRandomNonVomitNonSuperCell():Point {
        var count:int = 0;
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                if (getCell(i, j) == TokenType.VOMIT || getSuper(i, j)) {
                    count++;
                }
            }
        }
        if (count == Constants.BOARD_SIZE * Constants.BOARD_SIZE) {
            return null;
        }
        while (true) {
            var x:int = _rand.nextInt(0, Constants.BOARD_SIZE - 1);
            var y:int = _rand.nextInt(0, Constants.BOARD_SIZE - 1);
            var token:TokenType = getCell(x, y);
            if (token != TokenType.VOMIT && !getSuper(x, y)) {
                return new Point(x, y);
            }
        }
        return null;
    }

    internal function swapCells(sx:int, sy:int, dx:int, dy:int):void {
        // Operation
        var destType:TokenType = getCell(dx, dy);
        var destSuper:Boolean = getSuper(dx, dy);
        setCell(dx, dy, getCell(sx, sy), getSuper(dx, sy));
        setCell(sx, sy, destType, destSuper);

        // Event
        if (_game != null) {
            _game.dispatchEvent(new GemsSwappedEvent(sx, sy, dx, dy, clone()));
        }

        // Result
        normalize();
        if (_game != null) {
            _game.newTurn();
        }
    }

    internal function createVomit(count:int):Array {
        var cells:Array = new Array();
        for (var i:int = 0; i < count; i++) {
            var cell:Point = getRandomNonVomitNonSuperCell();
            if (cell != null) {
                trace("Creating vomit on " + cell.x + ":" + cell.y);
                cells.push(cell);
            } else {
                trace("WARN: Too much vomit on board")
            }
        }
        transformCells(cells, TokenType.VOMIT, true);
        return cells;
    }

    private function destroyCells(cells:Array):void {
        for each (var cell:Point in cells) {
            setCell(cell.x, cell.y, TokenType.NONE, false);
        }
        compact();
        if (_game != null) {
            _game.dispatchEvent(new BoardEvent(BoardEvent.CELLS_DESTROYED, cells, clone()));
        }
        normalize();
    }

    internal function destroyTokensOfType(targetType:TokenType):int {
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
        destroyCells(toRemove);
        return count + Constants.SUPER_TOKEN_VALUE * supers;
    }

    internal function transformTokensOfType(source:TokenType, target:TokenType):int {
        var cells:Array = new Array();
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                if (getCell(i, j) == source) {
                    cells.push(new Point(i, j));
                }
            }
        }
        transformCells(cells, target, false);
        normalize();
        return cells.length;
    }

    private function transformCells(cells:Array, target:TokenType, resetSuper:Boolean):void {
        for each (var cell:Point in cells) {
            setCell(cell.x, cell.y, target, resetSuper ? false : getSuper(cell.x, cell.y));
        }
        if (_game != null) {
            _game.dispatchEvent(new BoardEvent(BoardEvent.CELLS_TRANSFORMED, cells, clone()));
        }
        normalize();
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

    private function normalize(inhibitEvents:Boolean = false):void {
        trace("[BoardState] start normalize()");
        while (hasGroups) {
            var groups:Array = computeGroups();
            trace("[BoardState] " + groups.length + " groups found. Piss level is " + pissLevel);
            destroyGroups(groups);
            trace("[BoardState] groups destroyed");
            if (_game != null && !inhibitEvents) {
                groups = _game.collectGroups(groups);
            }
            trace("[BoardState] groups collected by the game. Piss level is now " + pissLevel);
            compact();
            trace("[BoardState] compacted");
            if (_game != null && !inhibitEvents) {
                trace("[BoardState] dispatch collect event for " + groups.length + " groups");
                _game.dispatchEvent(new GroupCollectionEvent(groups, clone()));
            }
        }
        if (!inhibitEvents && computeMoves().length == 0) {
            trace("[BoardState] reset");
            generateRandomKeepingSomeVomit();
        }
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

    private function destroyGroups(groups:Array):Array {
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
        for each (group in groups) {
            if (group.length >= 5) {
                setCell(group.midX, group.midY, group.token, true);
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

    public function get game():Game {
        return _game;
    }

    public function set game(value:Game):void {
        _game = value;
    }

    private var _game:Game;
    private var _state:Array = new Array();
    private var _supers:Array = new Array();
    private var _pissLevel:int = 0;
    private var _rand:MersenneTwister;

}
}