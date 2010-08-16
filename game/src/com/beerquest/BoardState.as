package com.beerquest {

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

    public function setCell(x:int, y:int, value:TokenType, superToken:Boolean):void {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid cell: " + x + ":" + y;
        }
        _state[x * Constants.BOARD_SIZE + y] = value;
        _supers[x * Constants.BOARD_SIZE + y] = superToken;
    }

    public function setAllCells(cells:Array, allSupers:Boolean):void {
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                setCell(i, j, cells[j][i], allSupers);
            }
        }
    }

    public function updateTo(otherState:BoardState):void {
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                setCell(i, j, otherState.getCell(i, j), otherState.getSuper(i, j));
            }
        }
        pissLevel = otherState.pissLevel;
    }

    public function toString():String {
        var repr:String = "";
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                repr += getCell(i, j).value.toString();
                repr += (getSuper(i, j)) ? "S" : "-";
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
                var tr:String = getCell(i,j).repr;
                repr += getSuper(i, j) ? tr.toUpperCase() : tr;
            }
        }
        return repr;
    }

    public function generateFullRandom():void {
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                setCell(i, j, generateNewCell(), false);
            }
        }
    }

    public function generateRandomWithoutGroups():void {
        do {
            generateFullRandom();
            normalize();
        } while (computeMoves().length == 0);
    }

    public function getRandomNonVomitNonSuperCell():Object {
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
                return {x:x, y:y};
            }
        }
        return null;
    }

    public function count(token:TokenType):int {
        var count:int = 0;
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                if (getCell(i, j) == token) {
                    count++;
                }
            }
        }
        return count;
    }

    public function normalize():void {
        while (hasGroups > 0) {
            destroyGroups();
            compact();
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
                        groups.push({type:"horizontal", startX:i, startY:j, midX:(i + Math.floor(di / 2)), midY:j, length:di, token:token, supers:supers});
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
                        groups.push({type:"vertical", startX:i, startY:j, midX:i, midY:(j + Math.floor(dj / 2)), length:dj, token:token, supers:supers});
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
        normalize();
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
        // TODO optimize
        for each (var move:Object in computeMoves()) {
            if (move.type == type && move.startX == startX && move.startY == startY) {
                return true;
            }
        }
        return false;
    }

    private function destroyGroups():void {
        for each (var group:Object in computeGroups()) {
            if (group.type == "horizontal") {
                for (var di:int = 0; di < group.length; di++) {
                    setCell(group.startX + di, group.startY, TokenType.NONE, false);
                }
            } else {
                for (var dj:int = 0; dj < group.length; dj++) {
                    setCell(group.startX, group.startY + dj, TokenType.NONE, false);
                }
            }
        }
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

    public function generateNewCell():TokenType {
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

    public function get pissLevel():int {
        return _pissLevel;
    }

    public function set pissLevel(pissLevel:int):void {
        _pissLevel = pissLevel;
    }

    private var _state:Array = new Array();
    private var _supers:Array = new Array();
    private var _pissLevel:int = 0;
    private var _rand:MersenneTwister;

}
}