package com.beerquest {
import com.greensock.TweenLite;

import com.greensock.easing.Linear;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.core.UIComponent;

public class GameBoard extends UIComponent {

    private static const EXPLODE_DURATION_FRAMES:int = 10;
    private static const SWAP_TIME_MS:Number = 400;
    private static const FALL_TIME_MS:Number = 200;

    public function GameBoard() {
        super();

        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            _board[i] = new Array();
        }
        clearSelection();

        addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

            // Mask
            var rect:Sprite = new Sprite();
            rect.graphics.beginFill(0xff0000);
            rect.graphics.drawRect(0, 0, width, height);
            addChild(rect);
            mask = rect;

            regenBoard();
        });
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onMouseUp(e:MouseEvent):void {
        var local:Point = globalToLocal(new Point(e.stageX, e.stageY));
        if (_draggingX != -1 && _draggingY != -1) {
            var lx:int = Math.floor(local.x / width * Constants.BOARD_SIZE);
            var ly:int = Math.floor(local.y / height * Constants.BOARD_SIZE);
            var dx:Number = lx - _draggingX;
            var dy:Number = ly - _draggingY;
            if (Math.abs(dx) > 0 && Math.abs(dy) == 0) {
                // Horizontal drag
                if (dx > 0 && _draggingX + 1 < Constants.BOARD_SIZE) {
                    selectCell(_draggingX, _draggingY);
                    swapTokens(_draggingX + 1, _draggingY);
                } else if (dx < 0 && _draggingX - 1 >= 0) {
                    selectCell(_draggingX, _draggingY);
                    swapTokens(_draggingX - 1, _draggingY);
                }
            } else if (Math.abs(dx) == 0 && Math.abs(dy) > 0) {
                // Vertical drag
                if (dy > 0 && _draggingY + 1 < Constants.BOARD_SIZE) {
                    selectCell(_draggingX, _draggingY);
                    swapTokens(_draggingX, _draggingY + 1);
                } else if (dy < 0 && _draggingY - 1 >= 0) {
                    selectCell(_draggingX, _draggingY);
                    swapTokens(_draggingX, _draggingY - 1);
                }
            }
        }
        _draggingX = _draggingY = -1;
    }

    private function onMouseDown(e:MouseEvent):void {
        var local:Point = globalToLocal(new Point(e.stageX, e.stageY));
        var x:int = Math.floor(local.x / width * Constants.BOARD_SIZE);
        var y:int = Math.floor(local.y / height * Constants.BOARD_SIZE);
        _draggingX = x;
        _draggingY = y;
        clickCell(x, y);
    }

    public function onKeyUp(e:KeyboardEvent):void {
        // Note: registered from the application
        switch (e.keyCode) {
            case 32: // space
                if (_currentAction == "") {
                    destroySeries();
                }
                break;
            case 82: // r
                regenBoard();
                break;
            default:
                trace("unknown key pressed: " + e.keyCode);
                break;
        }
    }

    private function onEnterFrame(e:Event):void {
        _currentFrame++;
        var elapsed:int = _currentFrame - _currentActionStart;
        switch (_currentAction) {
            case "exploding":
                if (elapsed >= EXPLODE_DURATION_FRAMES) {
                    trace("Explosion ended");
                    endDestroySeries();
                }
                break;
        }
    }

    private function regenBoard():void {
        startAction("regenBoard");

        var state:BoardState = new BoardState();
        state.generateRandomWithoutGroups();
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                var token:Token = getToken(i, j);
                if (token != null) {
                    removeToken(token);
                }
                token = generateToken(state.getCell(i, j));
                addToken(token);
                setToken(i, j, token);
            }
        }
        if (checkSeries() > 0) {
            throw "regenerated board has groups";
        }
        regenHiddenTokens();
        clearSelection();
        startAction("");
    }

    private function regenHiddenTokens():void {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            var token:Token = getToken(i, -1);
            if (token != null) {
                removeToken(token);
            }
            token = generateToken();
            addToken(token);
            setToken(i, -1, token);
        }
    }

    private function generateToken(type:TokenType = null):Token {
        if (type == null) {
            var value:int = Math.floor(Math.random() * 7) + 1;
            type = TokenType.fromValue(value);
        }
        var token:Token = new Token(type);
        token.width = width / Constants.BOARD_SIZE;
        token.height = height / Constants.BOARD_SIZE;
        return token;
    }

    public function getCurrentState():BoardState {
        var state:BoardState = new BoardState();
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                state.setCell(i, j, getToken(i, j).type);
            }
        }
        return state;
    }

    private function clickCell(x:int, y:int):void {
        if (_currentAction == "") {
            if (hasSelectedCell) {
                var dx:int = Math.abs(_selectedX - x);
                var dy:int = Math.abs(_selectedY - y);
                if (dx == 0 && dy == 0) {
                    clearSelection();
                } else if ((dx == 1 && dy == 0) || (dx == 0 && dy == 1)) {
                    swapTokens(x, y);
                } else {
                    selectCell(x, y);
                }
            } else {
                selectCell(x, y);
            }
        }
    }

    private function swapTokens(x:int, y:int):void {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid swap coords: " + x + ":" + y;
        }
        trace("swap(" + x + ":" + y + ")");
        _swapX = x;
        _swapY = y;
        var sx:int = _selectedX;
        var sy:int = _selectedY;
        var src:Token = getToken(sx, sy);
        var dst:Token = getToken(x, y);
        var dx:int = x - _selectedX;
        var dy:int = y - _selectedY;
        startAction("swapping");
        _currentActionStart = _currentFrame;
        var valid:Boolean;
        if (dx != 0) {
            valid = getCurrentState().isLegalMove("horizontal", Math.min(x, sx), y);
            TweenLite.to(src, SWAP_TIME_MS / 1000, {x: src.x + dx * width / Constants.BOARD_SIZE});
            TweenLite.to(dst, SWAP_TIME_MS / 1000, {x: dst.x - dx * width / Constants.BOARD_SIZE});
        } else {
            valid = getCurrentState().isLegalMove("vertical", x, Math.min(y, sy));
            TweenLite.to(src, SWAP_TIME_MS / 1000, {y: src.y + dy * height / Constants.BOARD_SIZE});
            TweenLite.to(dst, SWAP_TIME_MS / 1000, {y: dst.y - dy * height / Constants.BOARD_SIZE});
        }
        var timer:Timer = new Timer(SWAP_TIME_MS, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            if (valid) {
                setToken(x, y, src);
                setToken(sx, sy, dst);
                startAction("");
                destroySeries();
            } else {
                trace("Invalid swap");
                if (dx != 0) {
                    TweenLite.to(src, SWAP_TIME_MS / 1000, {x: src.x - dx * width / Constants.BOARD_SIZE});
                    TweenLite.to(dst, SWAP_TIME_MS / 1000, {x: dst.x + dx * width / Constants.BOARD_SIZE});
                } else {
                    TweenLite.to(src, SWAP_TIME_MS / 1000, {y: src.y - dy * height / Constants.BOARD_SIZE});
                    TweenLite.to(dst, SWAP_TIME_MS / 1000, {y: dst.y + dy * height / Constants.BOARD_SIZE});
                }
                var timer:Timer = new Timer(SWAP_TIME_MS, 1);
                timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                    startAction("");
                });
                timer.start();
            }
        });
        timer.start();
        clearSelection();
    }

    private function startAction(action:String):void {
        trace("(frame " + _currentFrame + ") START " + ((action != "") ? action : "(none)"));
        _currentAction = action;
        _currentActionStart = _currentFrame;
        if (action == "") {
            refreshStats();
        }
    }

    private function selectCell(x:int, y:int):void {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid select coords: " + x + ":" + y;
        }
        _selectedX = x;
        _selectedY = y;
        trace("Selected " + x + ":" + y);
        invalidateDisplayList();
    }

    private function clearSelection():void {
        _selectedX = -1;
        _selectedY = -1;
        trace("Unselected");
        invalidateDisplayList();
    }

    private function checkSeries():int {
        resetMarks();
        var group:int = 1;
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                var token:Token = getToken(i, j);
                if (token.type != TokenType.NONE) {
                    // Check for horizontal groups
                    if (token.markX == 0) {
                        var di:int = 1;
                        while ((i + di) < Constants.BOARD_SIZE && getToken(i + di, j).type == token.type) {
                            di++;
                        }
                        if (di >= 3) {
                            for (var k:int = 0; k < di; k++) {
                                getToken(i + k, j).markX = group;
                            }
                            group++;
                        }
                    }
                    // Check for vertical groups
                    if (token.markY == 0) {
                        var dj:int = 1;
                        while ((j + dj) < Constants.BOARD_SIZE && getToken(i, j + dj).type == token.type) {
                            dj++;
                        }
                        if (dj >= 3) {
                            for (k = 0; k < dj; k++) {
                                getToken(i, j + k).markY = group;
                            }
                            group++;
                        }
                    }
                }
            }
        }
        invalidateDisplayList();
        return (group - 1);
    }

    private function destroySeries():void {
        if (checkSeries() > 0) {
            startAction("exploding");
            for (var j:int = Constants.BOARD_SIZE - 1; j >= 0; j--) {
                for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                    var token:Token = getToken(i, j);
                    if (token.marked) {
                        token.explode();
                    }
                }
            }

            // TODO mieux faire
            var state:BoardState = getCurrentState();
            for each (var group:Object in state.computeGroups()) {
                if (group.length == 3) {
                    score += 100;
                } else if (group.length == 4) {
                    score += 1000;
                } else if (group.length == 5) {
                    score += 10000;
                }
            }
        }
    }

    private function endDestroySeries():void {
        startAction("falling");
        removeMarkedTokens();
        resetFalling();
        var falling:Boolean = false;
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = Constants.BOARD_SIZE - 1; j >= 0; j--) {
                var token:Token = getToken(i, j);
                if (token == null) {
                    falling = true;
                    for (var jj:int = j - 1; jj >= -1; jj--) {
                        var upToken:Token = getToken(i, jj);
                        if (upToken != null) {
                            upToken.falling = true;
                            TweenLite.to(upToken, FALL_TIME_MS / 1000, {y: (jj + 1) * height / Constants.BOARD_SIZE, ease:Linear.easeNone});
                        }
                    }
                    break;
                }
            }
        }
        if (falling) {
            var timer:Timer = new Timer(FALL_TIME_MS, 1);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                updateFalling();
                regenHiddenTokens();
                endDestroySeries();
            });
            timer.start();
        } else {
            endDestroySeries2();
        }
    }

    private function dumpBoard():void {
        trace(getCurrentState());
    }

    private function removeMarkedTokens():void {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = Constants.BOARD_SIZE - 1; j >= 0; j--) {
                var token:Token = getToken(i, j);
                if (token != null && token.marked) {
                    removeToken(token);
                }
            }
        }
    }

    private function updateFalling():void {
        for (var j:int = Constants.BOARD_SIZE - 2; j >= -1; j--) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                var token:Token = getToken(i, j);
                if (token != null && token.falling) {
                    setToken(i, j + 1, token);
                    if (j == -1 || (j > -Constants.BOARD_SIZE && getToken(i, j - 1) == null)) {
                        setToken(i, j, null);
                    }
                }
            }
        }
    }

    private function endDestroySeries2():void {
        startAction("endFalling");
        resetFalling();
        regenHiddenTokens();
        startAction("");
        destroySeries();
    }

    private function resetMarks():void {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                var token:Token = getToken(i, j);
                token.resetMarks();
            }
        }
    }

    private function resetFalling():void {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                var token:Token = getToken(i, j);
                if (token != null) {
                    token.falling = false;
                }
            }
        }
    }

    /*override protected function createChildren():void {
     super.createChildren();
     }

     override protected function commitProperties():void {
     super.commitProperties();
     }

     override protected function measure():void {
     super.measure();
     }  */

    private function get hasSelectedCell():Boolean {
        return (_selectedX != -1 && _selectedY != -1);
    }

    public function addToken(token:Token):void {
        addChild(token);
    }

    public function removeToken(token:Token):void {
        setToken(token.boardX, token.boardY, null);
        removeChild(token);
    }

    public function getToken(x:int, y:int):Token {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < -1 || y >= Constants.BOARD_SIZE) {
            throw "invalid coords: " + x + ":" + y;
        }
        var token:Token = _board[x][y + 1];
        if (token != null && (token.boardX != x || token.boardY != y)) {
            throw "invalid token state";
        }
        return token;
    }

    public function setToken(x:int, y:int, token:Token):void {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < -1 || y >= Constants.BOARD_SIZE) {
            throw "invalid coords: " + x + ":" + y;
        }
        if (token != null) {
            token.boardX = x;
            token.boardY = y;
            token.x = x * width / Constants.BOARD_SIZE;
            token.y = y * height / Constants.BOARD_SIZE;
        }
        _board[x][y + 1] = token;
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        graphics.clear();
        graphics.beginFill(0xffffff);
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.lineStyle(2, 0x0);
        var i:int;
        for (i = 0; i <= Constants.BOARD_SIZE; i++) {
            graphics.moveTo(i * unscaledWidth / Constants.BOARD_SIZE, 0);
            graphics.lineTo(i * unscaledWidth / Constants.BOARD_SIZE, unscaledHeight);
            graphics.moveTo(0, i * unscaledHeight / Constants.BOARD_SIZE);
            graphics.lineTo(unscaledWidth, i * unscaledHeight / Constants.BOARD_SIZE);
        }
        graphics.endFill();

        if (_selectedX != -1 && _selectedY != -1) {
            graphics.lineStyle(2, 0xff0000);
            graphics.beginFill(0xFFD7AD);
            graphics.drawRect(_selectedX * unscaledWidth / Constants.BOARD_SIZE, _selectedY * unscaledHeight / Constants.BOARD_SIZE,
                    unscaledWidth / Constants.BOARD_SIZE, unscaledHeight / Constants.BOARD_SIZE);
            graphics.endFill();
        }
    }

    private function refreshStats():void {
        var state:BoardState = getCurrentState();
        availableMoves = state.computeMoves().length;
        trace("available moves:");
        for each (var move:Object in state.computeMoves()) {
            trace("  " + move.type + " of " + move.startX + ":" + move.startY);
        }
    }

    [Bindable(event="availableMovesChanged")]
    public function get availableMoves():int {
        return _availableMoves;
    }

    public function set availableMoves(value:int):void {
        _availableMoves = value;
        dispatchEvent(new Event("availableMovesChanged"));
    }

    [Bindable(event="scoreChanged")]
    public function get score():Number {
        return _score;
    }

    public function set score(value:Number):void {
        _score = value;
        dispatchEvent(new Event("scoreChanged"));
    }

    private var _board:Array = new Array();
    private var _selectedX:int = -1;
    private var _selectedY:int = -1;
    private var _swapX:int = -1;
    private var _swapY:int = -1;
    private var _draggingX:int = -1;
    private var _draggingY:int = -1;
    private var _currentFrame:int = 0;
    private var _currentAction:String = "";
    private var _currentActionStart:int = 0;
    private var _availableMoves:int;
    private var _score:Number = 0;
}
}