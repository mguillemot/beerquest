package com.beerquest.ui {
import com.beerquest.*;
import com.beerquest.events.BoardEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.beerquest.events.GroupCollectionEvent;
import com.beerquest.ui.events.UiCapacityExecutionEvent;
import com.beerquest.ui.events.UiGameOverEvent;
import com.beerquest.ui.events.UiScoreEvent;
import com.beerquest.ui.events.UiTokenEvent;
import com.greensock.TweenLite;
import com.greensock.easing.Expo;
import com.greensock.easing.Linear;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.core.BitmapAsset;
import mx.core.UIComponent;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;

[Event(name="UiScoreGained", type="com.beerquest.ui.events.UiScoreEvent")]
[Event(name="UiTokenGained", type="com.beerquest.ui.events.UiTokenEvent")]
[Event(name="UiGameOver", type="com.beerquest.ui.events.UiGameOverEvent")]
public class BoardView extends UIComponent {

    private static const EXPLODE_DURATION_MS:int = 250;
    private static const GROUP5_COMPACTION_DURATION_MS:int = 1000;
    private static const SWAP_TIME_MS:Number = 400;
    private static const FALL_TIME_MS:Number = 200;
    private static const PISS_RAISE_TIME_MS:Number = 500;

    public function BoardView() {
        super();
        width = 320;
        height = 320;

        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            _board[i] = new Array();
        }

        addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        });

        // Background
        var bg:BitmapAsset = new BoardBackground();
        bg.name = "bg";
        bg.width = width;
        bg.height = height;
        addChild(bg);

        // Gems
        _gemsLayer = new Sprite();
        addChild(_gemsLayer);

        // Piss
        _pissLayer = new Sprite();
        var subPiss:BitmapAsset = new PissAnimation();
        _pissLayer.addChild(subPiss);
        subPiss = new PissAnimation();
        subPiss.x = subPiss.width;
        _pissLayer.addChild(subPiss);
        _pissLayer.alpha = 0.6;
        _pissLayer.name = "piss";
        _pissLayer.width = 2 * width;
        _pissLayer.height = 3 * height / Constants.BOARD_SIZE + 5;
        _pissLayer.y = height;
        addChild(_pissLayer);
        _currentPissLevel = 0;

        // Selection
        _selection = new Sprite();
        _selection.name = "selection";
        _selection.graphics.lineStyle(2, 0xff0000);
        _selection.graphics.drawRect(0, 0, width / Constants.BOARD_SIZE, height / Constants.BOARD_SIZE);
        addChild(_selection);

        // Mask
        var rect:Sprite = new Sprite();
        rect.name = "mask";
        rect.graphics.beginFill(0xff0000);
        rect.graphics.drawRect(0 - 1, 0 - 1, width + 2, height + 2);
        addChild(rect);
        mask = rect;

        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);

        Constants.GAME.addEventListener(GameEvent.GAME_START, processEvent);
        Constants.GAME.addEventListener(GameEvent.GAME_OVER, processEvent);
        Constants.GAME.addEventListener(BoardEvent.BOARD_RESET, processEvent);
        Constants.GAME.addEventListener(BoardEvent.CELLS_DESTROYED, processEvent);
        Constants.GAME.addEventListener(BoardEvent.CELLS_TRANSFORMED, processEvent);
        Constants.GAME.addEventListener(GroupCollectionEvent.GROUPS_COLLECTED, processEvent);
        Constants.GAME.addEventListener(GemsSwappedEvent.GEMS_SWAPPED, processEvent);
        Constants.GAME.addEventListener(GameEvent.PISS_LEVEL_CHANGED, processEvent);
    }

    public function processEvent(e:Event):void {
        if (_currentAction == "") {
            switch (e.type) {
                case GameEvent.GAME_START:
                    onGameStart(e as GameEvent);
                    break;
                case GameEvent.GAME_OVER:
                    onGameOver(e as GameEvent);
                    break;
                case BoardEvent.BOARD_RESET:
                    onBoardReset(e as BoardEvent);
                    break;
                case BoardEvent.CELLS_DESTROYED:
                    onCellsDestroyed(e as BoardEvent);
                    break;
                case BoardEvent.CELLS_TRANSFORMED:
                    onCellsTransformed(e as BoardEvent);
                    break;
                case GroupCollectionEvent.GROUPS_COLLECTED:
                    onGroupsCollected(e as GroupCollectionEvent);
                    break;
                case GemsSwappedEvent.GEMS_SWAPPED:
                    onGemsSwapped(e as GemsSwappedEvent);
                    break;
                case GameEvent.PISS_LEVEL_CHANGED:
                    onPissLevelChanged(e as GameEvent);
                    break;
                case UiCapacityExecutionEvent.ASK_FOR_EXECUTION:
                    startBigBang();
                    break;
                default:
                    throw "Unkown event buffered: " + e.type;
            }
        } else {
            trace(e.type + " received while " + _currentAction + " is in progress: buffering");
            _eventBuffer.push(e);
        }
    }

    private function onMouseUp(e:MouseEvent):void {
        if (_currentAction == "" && _draggingX != -1 && _draggingY != -1) {
            var local:Point = globalToLocal(new Point(e.stageX, e.stageY));
            var lx:int = Math.floor(local.x / width * Constants.BOARD_SIZE);
            var ly:int = Math.floor(local.y / height * Constants.BOARD_SIZE);
            var dx:Number = lx - _draggingX;
            var dy:Number = ly - _draggingY;
            if (Math.abs(dx) > 0 && Math.abs(dy) == 0 && _draggingY < Constants.BOARD_SIZE - Constants.GAME.pissLevel) {
                // Horizontal drag
                if (dx > 0 && _draggingX + 1 < Constants.BOARD_SIZE) {
                    if (selectCell(_draggingX, _draggingY)) {
                        swapTokens(_draggingX + 1, _draggingY);
                    }
                } else if (dx < 0 && _draggingX - 1 >= 0) {
                    if (selectCell(_draggingX, _draggingY)) {
                        swapTokens(_draggingX - 1, _draggingY);
                    }
                }
            } else if (Math.abs(dx) == 0 && Math.abs(dy) > 0) {
                // Vertical drag
                if (dy > 0 && _draggingY + 1 < Constants.BOARD_SIZE - Constants.GAME.pissLevel) {
                    if (selectCell(_draggingX, _draggingY)) {
                        swapTokens(_draggingX, _draggingY + 1);
                    }
                } else if (dy < 0 && _draggingY - 1 >= 0) {
                    if (selectCell(_draggingX, _draggingY)) {
                        swapTokens(_draggingX, _draggingY - 1);
                    }
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
                if (Constants.DEBUG) {
                    reinitBoardView();
                }
                break;
            case 81: // q
                if (Constants.DEBUG) {
                    Constants.GAME.generateTestBoard();
                }
                break;
            case 82: // r
                if (Constants.DEBUG) {
                    Constants.GAME.generateRandomKeepingSomeVomit();
                }
                break;
            case 84: // t
                if (Constants.DEBUG) {
                    Constants.GAME.me.addPartialBeer(TokenType.BLOND_BEER);
                }
                break;
            case 89: // y
                if (Constants.DEBUG) {
                    Constants.GAME.me.addPartialBeer(TokenType.BROWN_BEER);
                }
                break;
            case 85: // u
                if (Constants.DEBUG) {
                    Constants.GAME.me.addPartialBeer(TokenType.AMBER_BEER);
                }
                break;
            case 73: // i
                if (Constants.DEBUG) {
                    Constants.GAME.me.addPartialBeer(TokenType.TRIPLE);
                }
                break;
            case 49: // 1
                if (Constants.DEBUG) {
                    Constants.GAME.me.gainCapacity(Capacity.BLOND_FURY_BAR);
                }
                break;
            case 50: // 2
                if (Constants.DEBUG) {
                    Constants.GAME.me.gainCapacity(Capacity.AMBER_FURY_BAR);
                }
                break;
            case 51: // 3
                if (Constants.DEBUG) {
                    Constants.GAME.me.gainCapacity(Capacity.BROWN_FURY_BAR);
                }
                break;
            case 52: // 4
                if (Constants.DEBUG) {
                    Constants.GAME.me.gainCapacity(Capacity.DIVINE_PEANUTS);
                }
                break;
            case 53: // 5
                if (Constants.DEBUG) {
                    Constants.GAME.me.gainCapacity(Capacity.BIG_BANG);
                }
                break;
            case 54: // 6
                if (Constants.DEBUG) {
                    Constants.GAME.me.gainCapacity(Capacity.BLOODY_MARY);
                }
                break;
            case 55: // 7
                if (Constants.DEBUG) {
                    Constants.GAME.me.gainCapacity(Capacity.WATERFALL);
                }
                break;
            case 86: // v
                if (Constants.DEBUG) {
                    Constants.GAME.me.vomit += 10;
                }
                break;
            case 66: // b
                if (Constants.DEBUG) {
                    Constants.GAME.me.piss += 10;
                }
                break;
            case 65: // a
                if (Constants.DEBUG) {
                    Constants.GAME.pissLevel = (Constants.GAME.pissLevel + 1) % 4;
                }
                break;
            case 27: // Escape
                if (_currentAction == "selectTokenToDestroy") {
                    if (_destroyCursor != 0) {
                        CursorManager.removeCursor(_destroyCursor);
                        _destroyCursor = 0;
                    }
                    endAction("selectTokenToDestroy");
                }
                break;
            case 90: // z
                if (Constants.DEBUG) {
                    Constants.GAME.endOfGame();
                }
                break;
            case 69: // e
                if (Constants.DEBUG) {
                    Constants.GAME.newTurn();
                }
                break;
            default:
                trace("unknown key pressed: " + e.keyCode);
                break;
        }
    }

    private function onEnterFrame(e:Event):void {
        _currentFrame++;
        if (_pissLayer != null) {
            _pissLayer.x -= 3;
            if (_pissLayer.x <= -width) {
                _pissLayer.x = 0;
            }
        }
    }

    private function onGameStart(e:GameEvent):void {
        startAction("gameStart", e.board);
        endAction("gameStart");
        onBoardReset(new BoardEvent(BoardEvent.BOARD_RESET, new Array(), _currentActionBoardView));
        trace("Game started.");
    }

    private function onGameOver(e:GameEvent):void {
        startAction("gameOver");
        dispatchEvent(new UiGameOverEvent());
        trace("Game ended.");
    }

    private function onBoardReset(e:BoardEvent):void {
        startAction("onBoardReset", e.board);
        clearSelection();
        var i:int, j:int, token:Token;
        resetMarks();
        for each (var cell:Point in e.cells) {
            getToken(cell.x, cell.y).mark = true;
        }
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE; j++) {
                token = getToken(i, j);
                if (token != null && !token.mark) {
                    var duration:Number = 1 + Math.random() * 0.5;
                    var d:Number = Math.random() * 0.2;
                    var x:Number = Math.random() * width - width / Constants.BOARD_SIZE;
                    var y:Number = height + Math.random() * height;
                    TweenLite.to(token, duration, {x:x, y:y, ease:Expo.easeIn, delay:d});
                }
            }
        }
        var timer:Timer = new Timer(1500, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            endBoardReset();
        });
        timer.start();
    }

    private function endBoardReset():void {
        continueAction("onBoardReset", "endBoardReset");
        var i:int, j:int, token:Token;
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE; j++) {
                token = getToken(i, j);
                if (token != null && !token.mark) {
                    removeToken(token);
                    token = null;
                }
                if (token == null) {
                    token = generateToken(boardState.getCell(i, j), boardState.getSuper(i, j));
                    addToken(token);
                    setToken(i, j, token);
                    TweenLite.from(token, 0.7, {x:token.x, y:-height / Constants.BOARD_SIZE, delay:(Constants.BOARD_SIZE - j) * 0.075});
                }
            }
        }
        var timer:Timer = new Timer(1500, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            endAction("endBoardReset");
        });
        timer.start();
    }

    private function checkSynchro():void {
        var i:int, j:int, token:Token;
        trace("checkSynchro() board should be\n" + Constants.GAME.board.toString());
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE; j++) {
                token = getToken(i, j);
                if (token == null) {
                    throw ("WARN: (" + i + ":" + j + ") should not be null");
                } else if (token.type != boardState.getCell(i, j) || token.superToken != boardState.getSuper(i, j)) {
                    throw ("WARN: (" + i + ":" + j + ") should be " + boardState.getCell(i, j).repr + (boardState.getSuper(i, j) ? "!" : "-") + " instead of " + token.type.repr + (token.superToken ? "!" : "-"));
                }
                if (boardState.getCell(i, j) != Constants.GAME.board.getCell(i, j) || boardState.getSuper(i, j) != Constants.GAME.board.getSuper(i, j)) {
                    throw ("WARN: boardView discrepancy! (" + i + ":" + j + ") should be " + Constants.GAME.board.getCell(i, j).repr + (Constants.GAME.board.getSuper(i, j) ? "!" : "-") + " instead of " + boardState.getCell(i, j).repr + (boardState.getSuper(i, j) ? "!" : "-"));
                }
            }
        }
    }


    private function reinitBoardView():void {
        trace("reinitBoardView() called");
        checkSynchro();
        var i:int, j:int, token:Token;
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE; j++) {
                token = getToken(i, j);
                if (token == null || token.type != boardState.getCell(i, j) || token.superToken != boardState.getSuper(i, j)) {
                    if (token != null) {
                        removeToken(token);
                    }
                    token = generateToken(boardState.getCell(i, j), boardState.getSuper(i, j));
                    addToken(token);
                    setToken(i, j, token);
                }
            }
        }
    }

    private function onCellsTransformed(e:BoardEvent):void {
        startAction("onCellsTransformed", e.board);
        for each (var cell:Point in e.cells) {
            var token:Token = getToken(cell.x, cell.y);
            removeToken(token);
            token = generateToken(boardState.getCell(cell.x, cell.y), boardState.getSuper(cell.x, cell.y));
            addToken(token);
            setToken(cell.x, cell.y, token);
            TweenLite.from(token, .5, {scaleX:0.1, scaleY:0.1});
        }
        var timer:Timer = new Timer(500, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            endAction("onCellsTransformed");
        });
        timer.start();
    }

    private function onGemsSwapped(e:GemsSwappedEvent):void {
        startAction("onGemsSwapped", e.board);
        var s:Token = getToken(e.sx, e.sy);
        var d:Token = getToken(e.dx, e.dy);
        setToken(e.sx, e.sy, d);
        setToken(e.dx, e.dy, s);
        endAction("onGemsSwapped");
    }

    private function generateToken(type:TokenType, superToken:Boolean):Token {
        var token:Token = new Token(type, superToken);
        token.width = width / Constants.BOARD_SIZE;
        token.height = height / Constants.BOARD_SIZE;
        return token;
    }

    private function clickCell(x:int, y:int):void {
        var token:TokenType;
        if (_currentAction == "selectTokenToDestroy") {
            token = getToken(x, y).type;
            if (token.collectible) {
                Constants.GAME.executeCapacity(Capacity.BIG_BANG, token);
                if (_destroyCursor != 0) {
                    CursorManager.removeCursor(_destroyCursor);
                    _destroyCursor = 0;
                }
                endAction("selectTokenToDestroy");
            }
        } else if (_currentAction == "") {
            if (y >= Constants.BOARD_SIZE - Constants.GAME.pissLevel) {
                // Cannot click in piss
                return;
            }
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
        var valid:Boolean;
        // Check the reference board instead of the local view to be 100% sure that pending actions won't prevent the swap
        if (dx != 0) {
            valid = Constants.GAME.board.isLegalMove("horizontal", Math.min(x, sx), y);
            TweenLite.to(src, SWAP_TIME_MS / 1000, {x: src.x + dx * width / Constants.BOARD_SIZE});
            TweenLite.to(dst, SWAP_TIME_MS / 1000, {x: dst.x - dx * width / Constants.BOARD_SIZE});
        } else {
            valid = Constants.GAME.board.isLegalMove("vertical", x, Math.min(y, sy));
            TweenLite.to(src, SWAP_TIME_MS / 1000, {y: src.y + dy * height / Constants.BOARD_SIZE});
            TweenLite.to(dst, SWAP_TIME_MS / 1000, {y: dst.y - dy * height / Constants.BOARD_SIZE});
        }
        var timer:Timer = new Timer(SWAP_TIME_MS, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            if (valid) {
                Constants.GAME.swapCells(sx, sy, x, y);
                endAction("swapping");
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
                    endAction("swapping");
                });
                timer.start();
                Constants.STATS.invalidMoves++;
            }
        });
        timer.start();
        clearSelection();
    }

    private function startAction(action:String, boardView:BoardState = null):void {
        if (action == "") {
            throw "Invalid empty action";
        }
        if (_currentAction != "") {
            throw "Impossible to start " + action + ": " + _currentAction + " is already in progress";
        }
        trace("(frame " + _currentFrame + ") START " + action);
        _currentAction = action;
        _currentActionStart = _currentFrame;
        if (boardView != null) {
            trace("Updated board view to:\n" + boardView.toString());
            _currentActionBoardView = boardView;
        }
        dispatchEvent(new Event("currentActionChanged"));
    }

    private function continueAction(oldAction:String, action:String):void {
        if (action == "") {
            throw "Invalid empty action";
        }
        if (_currentAction != oldAction && _currentAction != action) {
            throw "Impossible to continue " + oldAction + ": " + _currentAction + " is already in progress";
        }
        trace("(frame " + _currentFrame + ") CONTINUE " + oldAction + " => " + action);
        _currentAction = action;
        _currentActionStart = _currentFrame;
        dispatchEvent(new Event("currentActionChanged"));
    }

    private function endAction(oldAction:String):void {
        if (_currentAction != oldAction) {
            throw "Impossible end " + oldAction + ": current was " + _currentAction;
        }
        trace("(frame " + _currentFrame + ") END " + oldAction);
        _currentAction = "";
        _currentActionStart = _currentFrame;
        dispatchEvent(new Event("currentActionChanged"));
        refreshStats();
        if (_eventBuffer.length > 0) {
            var e:Event = _eventBuffer.shift();
            trace("Unstack pending " + e.type);
            processEvent(e);
        } else if (oldAction != "gameStart") {
            checkSynchro();
        }
    }

    [Bindable(event="currentActionChanged")]
    public function get currentAction():String {
        return _currentAction;
    }

    private function selectCell(x:int, y:int):Boolean {
        if (x < 0 || x >= Constants.BOARD_SIZE || y < 0 || y >= Constants.BOARD_SIZE) {
            throw "invalid select coords: " + x + ":" + y;
        }
        if (y >= Constants.BOARD_SIZE - Constants.GAME.pissLevel) {
            // Cannot select in piss    
            return false;
        }
        _selectedX = x;
        _selectedY = y;
        _selection.visible = true;
        _selection.x = _selectedX * width / Constants.BOARD_SIZE;
        _selection.y = _selectedY * height / Constants.BOARD_SIZE;
        trace("Selected " + x + ":" + y);
        return true;
    }

    private function clearSelection():void {
        _selectedY = -1;
        _selectedX = -1;
        _selection.visible = false;
        trace("Unselected");
    }

    private function onCellsDestroyed(e:BoardEvent):void {
        startAction("onCellsDestroyed", e.board);
        resetMarks();
        for each (var cell:Point in e.cells) {
            var token:Token = getToken(cell.x, cell.y);
            token.mark = true;
            TweenLite.to(token, EXPLODE_DURATION_MS / 1000, {alpha:0});
        }
        var timer:Timer = new Timer(EXPLODE_DURATION_MS, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                for (var j:int = Constants.BOARD_SIZE - 1; j >= 0; j--) {
                    var token:Token = getToken(i, j);
                    if (token.mark) {
                        removeToken(token);
                    }
                }
            }
            continueAction("onCellsDestroyed", "gravity");
            gravity();
        });
        timer.start();
    }

    private function onGroupsCollected(e:GroupCollectionEvent):void {
        startAction("onGroupsCollected", e.board);

        resetMarks();
        var maxDuration:Number = 0;
        var groups:Array = e.groups;
        for each (var group:Group in groups) {
            var duration:Number = collectGroup(group);
            if (duration > maxDuration) {
                maxDuration = duration;
            }
        }

        var timer:Timer = new Timer(maxDuration, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            for each (var group:Group in groups) {
                for (var k:int = 0; k < group.length; k++) {
                    var i:int = group.x;
                    var j:int = group.y;
                    if (group.direction == "horizontal") {
                        i += k;
                    } else {
                        j += k;
                    }
                    var token:Token = getToken(i, j);
                    if (token != null) {
                        // Since a token can be present in 2 groups in the same phase...
                        removeToken(token);
                    }
                }
            }
            continueAction("onGroupsCollected", "gravity");
            gravity();
        });
        timer.start();
    }

    private function collectGroup(group:Group):Number {
        // VFX
        var token:Token = getToken(group.x, group.y);
        var local:Point = new Point(token.x, token.y);
        if (group.direction == "horizontal") {
            local.x += width / Constants.BOARD_SIZE * group.length / 2;
            local.y += height / Constants.BOARD_SIZE / 2;
        } else {
            local.x += width / Constants.BOARD_SIZE / 2;
            local.y += height / Constants.BOARD_SIZE * group.length / 2;
        }
        var scoreCoords:Point = localToGlobal(local);
        dispatchEvent(new UiScoreEvent(group.beerGain, group.turnsGain, scoreCoords.x, scoreCoords.y));
        if (group.collectedToken != null) {
            dispatchEvent(new UiTokenEvent(group.collectedToken, scoreCoords.x, scoreCoords.y));
        }

        // Explosion or collection effect
        for (var k:int = 0; k < group.length; k++) {
            var i:int = group.x;
            var j:int = group.y;
            if (group.direction == "horizontal") {
                i += k;
            } else {
                j += k;
            }
            token = getToken(i, j);
            if (!token.mark) {
//            if (group.length <= 4) {
                TweenLite.to(token, EXPLODE_DURATION_MS / 1000, {alpha:0});
//            } else if (token.mark is Point) {
//                var focus:Point; // TODO
//                var dx:Number = (focus.x - i) * width / Constants.BOARD_SIZE;
//                var dy:Number = (focus.y - j) * height / Constants.BOARD_SIZE;
//                TweenLite.to(token, GROUP5_COMPACTION_DURATION_MS / 1000, {x:dx.toString(), y:dy.toString()});
//                duration = GROUP5_COMPACTION_DURATION_MS;
//            }
                token.mark = true; // To prevent tween conflicts with a token participating in multiple groups
            }
        }
        return EXPLODE_DURATION_MS;
    }

    private function gravity():void {
        continueAction("gravity", "gravity");
        resetFalling();
        var i:int, j:int, holes:int, token:Token;
        var falling:Boolean = false;
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = Constants.BOARD_SIZE - 1; j >= 0; j--) {
                token = getToken(i, j);
                if (token == null) {
                    falling = true;
                    holes = 0;
                    for (var jj:int = j - 1; jj >= -1; jj--) {
                        var upToken:Token;
                        if (jj >= 0) {
                            upToken = getToken(i, jj);
                        } else {
                            upToken = generateToken(boardState.getCell(i, holes), false);
                            addToken(upToken);
                            setToken(i, jj, upToken);
                        }
                        if (upToken != null) {
                            upToken.falling = true;
                            TweenLite.to(upToken, FALL_TIME_MS / 1000, {y: (jj + 1) * height / Constants.BOARD_SIZE, ease:Linear.easeNone});
                        } else {
                            holes++;
                        }
                    }
                    break;
                }
            }
        }
        if (falling) {
            var timer:Timer = new Timer(FALL_TIME_MS, 1);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                trace("Next falling pass...");
                updateFalling();
                gravity();
            });
            timer.start();
        } else {
            endAction("gravity");
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

    private function resetMarks():void {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                var token:Token = getToken(i, j);
                if (token != null) {
                    token.mark = false;
                }
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

    private function get hasSelectedCell():Boolean {
        return (_selectedX != -1 && _selectedY != -1);
    }

    public function addToken(token:Token):void {
        _gemsLayer.addChild(token);
    }

    public function removeToken(token:Token):void {
        setToken(token.boardX, token.boardY, null);
        _gemsLayer.removeChild(token);
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

    private function refreshStats():void {
        var moves:Array = boardState.computeMoves();
        availableMoves = moves.length;
        if (moves.length > 0) {
            moves = Utils.randomizeArray(moves);
            setHint(moves[0].hintX, moves[0].hintY);
        } else {
            setHint(-1, -1);
        }
        /*trace("available moves:");
         for each (var move:Object in state.computeMoves()) {
         trace("  " + move.type + " of " + move.startX + ":" + move.startY);
         }*/
    }

    private function setHint(x:int, y:int):void {
        if (_hint != null) {
            _hint.hint = false;
        }
        if (x != -1 && y != -1) {
            _hint = getToken(x, y);
            if (_hint != null) {
                _hint.hint = true;
            }
        } else {
            _hint = null;
        }
    }

    private function onPissLevelChanged(e:GameEvent):void {
        startAction("onPissLevelChanged");
        var dy:int = Constants.GAME.pissLevel - _currentPissLevel;
        _currentPissLevel = Constants.GAME.pissLevel;
        var epsilon:int = (_currentPissLevel > 0) ? -5 : 0;
        TweenLite.to(_pissLayer, PISS_RAISE_TIME_MS / 1000, {y: (Constants.BOARD_SIZE - _currentPissLevel) * height / Constants.BOARD_SIZE + epsilon});
        if (_selectedY >= Constants.BOARD_SIZE - _currentPissLevel) {
            clearSelection();
        }
        if (dy > 0) {
            // TODO dispatch sound events ?
        }
        endAction("onPissLevelChanged");
    }

    private function startBigBang():void {
        startAction("selectTokenToDestroy");
        if (_destroyCursor == 0) {
            _destroyCursor = CursorManager.setCursor(DestroyCursor, CursorManagerPriority.HIGH);
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

    private function get boardState():BoardState {
        if (_currentActionBoardView == null) {
            throw "unknown board state";
        }
        return _currentActionBoardView;
    }

    private var _board:Array = new Array();
    private var _selectedX:int = -1;
    private var _selectedY:int = -1;
    private var _selection:Sprite;
    private var _swapX:int = -1;
    private var _swapY:int = -1;
    private var _draggingX:int = -1;
    private var _draggingY:int = -1;
    private var _currentFrame:int = 0;
    private var _currentAction:String = "";
    private var _currentActionStart:int = 0;
    private var _currentActionBoardView:BoardState;
    private var _availableMoves:int;
    private var _gemsLayer:DisplayObjectContainer;
    private var _pissLayer:DisplayObjectContainer;
    private var _hint:Token = null;
    private var _currentPissLevel:int = 0;
    private var _destroyCursor:int = 0;
    private var _resolvingCapacity:Boolean = false;
    private var _eventBuffer:Array = new Array();

    [Embed(source="../../../assets/image/board.png")]
    private static var BoardBackground:Class;

    [Embed(source="../../../assets/image/effet-pisse.png")]
    private static var PissAnimation:Class;

    [Embed(source="../../../assets/image/curseur-bigbang.png")]
    private static var DestroyCursor:Class;

}
}