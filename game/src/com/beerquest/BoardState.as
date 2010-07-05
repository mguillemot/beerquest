package com.beerquest {
public class BoardState {
    public function BoardState() {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            _state.push(TokenType.NONE);
        }
    }

    public function getCell(x:int, y:int):TokenType {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid cell: " + x + ":" + y;
        }
        return _state[x * Constants.BOARD_SIZE + y];
    }

    public function setCell(x:int, y:int, value:TokenType):void {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid cell: " + x + ":" + y;
        }
        _state[x * Constants.BOARD_SIZE + y] = value;
    }

    public function toString():String {
        var repr:String = "";
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                repr += getCell(i, j).value.toString();
            }
            repr += "\n";
        }
        return repr;
    }

    public function generateFullRandom():void {
        for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                setCell(i, j, generateNewCell());
            }
        }
    }

    public function generateRandomWithoutGroups():void {
        generateFullRandom();
        normalize();
    }

    public function normalize():void {
        while (hasGroups > 0) {
            destroyGroups();
            compact();
        }
    }

    public function computeGroups():Array {
        var groups:Array = new Array();
        var i:int, j:int, cell:TokenType;

        // Check for horizontal groups
        for (j = 0; j < Constants.BOARD_SIZE; j++) {
            for (i = 0; i < Constants.BOARD_SIZE - 2; i++) {
                cell = getCell(i, j);
                if (cell != TokenType.NONE) {
                    var di:int = 1;
                    while ((i + di) < Constants.BOARD_SIZE && getCell(i + di, j) == cell) {
                        di++;
                    }
                    if (di >= 3) {
                        groups.push({type:"horizontal", startX:i, startY:j, length:di, token:cell});
                    }
                    i += (di - 1);
                }
            }
        }

        // Check for vertical groups
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE - 2; j++) {
                cell = getCell(i, j);
                if (cell != TokenType.NONE) {
                    var dj:int = 1;
                    while ((j + dj) < Constants.BOARD_SIZE && getCell(i, j + dj) == cell) {
                        dj++;
                    }
                    if (dj >= 3) {
                        groups.push({type:"vertical", startX:i, startY:j, length:dj, token:cell});
                    }
                    j += (dj - 1);
                }
            }
        }

        return groups;
    }

    public function get hasGroups():Boolean {
        var i:int, j:int, cell:TokenType;

        // Check for horizontal groups
        for (j = 0; j < Constants.BOARD_SIZE; j++) {
            for (i = 0; i < Constants.BOARD_SIZE - 2; i++) {
                cell = getCell(i, j);
                if (cell != TokenType.NONE) {
                    var di:int = 1;
                    while ((i + di) < Constants.BOARD_SIZE && getCell(i + di, j) == cell) {
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
                cell = getCell(i, j);
                if (cell != TokenType.NONE) {
                    var dj:int = 1;
                    while ((j + dj) < Constants.BOARD_SIZE && getCell(i, j + dj) == cell) {
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

    public function computeMoves():Array {
        normalize();
        var moves:Array = new Array();
        var i:int, j:int;

        // Check for horizontal moves
        for (j = 0; j < Constants.BOARD_SIZE; j++) {
            for (i = 0; i < Constants.BOARD_SIZE - 1; i++) {
                var leftCell:TokenType = getCell(i, j);
                var rightCell:TokenType = getCell(i + 1, j);
                setCell(i, j, rightCell);
                setCell(i + 1, j, leftCell);
                if (hasGroups) {
                    moves.push({type:"horizontal", startX:i, startY:j, endX:(i + 1), endY:j});
                }
                setCell(i, j, leftCell);
                setCell(i + 1, j, rightCell);
            }
        }

        // Check for vertical moves
        for (j = 0; j < Constants.BOARD_SIZE - 1; j++) {
            for (i = 0; i < Constants.BOARD_SIZE; i++) {
                var topCell:TokenType = getCell(i, j);
                var bottomCell:TokenType = getCell(i, j + 1);
                setCell(i, j, bottomCell);
                setCell(i, j + 1, topCell);
                if (hasGroups) {
                    moves.push({type:"vertical", startX:i, startY:j, endX:i, endY:(j+1)});
                }
                setCell(i, j, topCell);
                setCell(i, j + 1, bottomCell);
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
                    setCell(group.startX + di, group.startY, TokenType.NONE);
                }
            } else {
                for (var dj:int = 0; dj < group.length; dj++) {
                    setCell(group.startX, group.startY + dj, TokenType.NONE);
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
                        setCell(i, j, getCell(i, j - 1));
                        setCell(i, j - 1, TokenType.NONE);
                        compacted = true;
                    }
                }
            }
            for (var ii:int = 0; ii < Constants.BOARD_SIZE; ii++) {
                if (getCell(ii, 0) == TokenType.NONE) {
                    setCell(ii, 0, generateNewCell());
                }
            }
        }
    }

    public function generateNewCell():TokenType {
        return TokenType.fromValue(_rand.nextInt(1, 7));
    }

    private var _state:Array = new Array();
    private var _rand:MersenneTwister = new MersenneTwister(Math.floor(Math.random()*int.MAX_VALUE));
}
}