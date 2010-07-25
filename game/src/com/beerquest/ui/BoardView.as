package com.beerquest.ui {
import com.beerquest.*;
import com.beerquest.TokenType;
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.greensock.TweenLite;
import com.greensock.easing.Back;
import com.greensock.easing.Expo;
import com.greensock.easing.Linear;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.media.Sound;
import flash.utils.Timer;

import mx.core.BitmapAsset;
import mx.core.UIComponent;
import mx.effects.SoundEffect;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;

public class BoardView extends UIComponent {

    private static const EXPLODE_DURATION_MS:int = 250;
    private static const SWAP_TIME_MS:Number = 400;
    private static const FALL_TIME_MS:Number = 200;
    private static const PISS_RAISE_TIME_MS:Number = 500;

    public function BoardView() {
        super();

        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            _board[i] = new Array();
        }

        addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

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
            _pissLayer.alpha = 0.7;
            _pissLayer.name = "piss";
            _pissLayer.width = 2 * width;
            _pissLayer.height = 3 * height / Constants.BOARD_SIZE + 5;
            _pissLayer.y = height;
            addChild(_pissLayer);
            pissLevel = 0;

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

            regenBoard(false);
            _initialized = true;
            refreshStats();
        });
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onMouseUp(e:MouseEvent):void {
        if (_currentAction == "") {
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
                resetToTestBoard();
                break;
            case 82: // r
                regenBoard(true);
                break;
            case 84: // t
                game.me.addPartialBeer(TokenType.BLOND_BEER);
                game.opponent.addPartialBeer(TokenType.BLOND_BEER);
                break;
            case 89: // y
                game.me.addPartialBeer(TokenType.BROWN_BEER);
                game.opponent.addPartialBeer(TokenType.BROWN_BEER);
                break;
            case 85: // u
                game.me.addPartialBeer(TokenType.AMBER_BEER);
                game.opponent.addPartialBeer(TokenType.AMBER_BEER);
                break;
            case 73: // i
                game.me.addPartialBeer(TokenType.TRIPLE);
                game.opponent.addPartialBeer(TokenType.TRIPLE);
                break;
            case 79: // o
                dispatchEvent(new CapacityEvent(CapacityEvent.CAPACITY_GAINED, game.me, Capacity.BLOND_STACK_ORDER));
                dispatchEvent(new CapacityEvent(CapacityEvent.CAPACITY_GAINED, game.me, Capacity.TCHIN_TCHIN));
                dispatchEvent(new CapacityEvent(CapacityEvent.CAPACITY_GAINED, game.me, Capacity.BIG_BANG));
                break;
            case 86: // v
                game.me.vomit += 10;
                break;
            case 66: // b
                game.me.piss += 10;
                break;
            case 65: // a
                game.me.coasterReserve++;
                pissLevel = (pissLevel + 1) % 4;
                break;
            case 27: // Escape
                if (_currentAction == "selectTokenToDestroy") {
                    if (_destroyCursor != 0) {
                        CursorManager.removeCursor(_destroyCursor);
                        _destroyCursor = 0;
                    }
                    startAction("");
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

    private function regenBoard(discardPrevious:Boolean):void {
        startAction("regenBoard");
        clearSelection();
        var i:int, j:int, token:Token;
        if (discardPrevious) {
            game.currentTurn += 5;
            game.me.vomit = 0;
            game.me.piss = 0;
            for (i = 0; i < Constants.BOARD_SIZE; i++) {
                for (j = 0; j < Constants.BOARD_SIZE; j++) {
                    token = getToken(i, j);
                    var duration:Number = 1 + Math.random() * 0.5;
                    var d:Number = Math.random() * 0.2;
                    var x:Number = Math.random() * width - width / Constants.BOARD_SIZE;
                    var y:Number = height + Math.random() * height;
                    TweenLite.to(token, duration, {x:x, y:y, ease:Expo.easeIn, delay:d});
                }
            }
            var timer:Timer = new Timer(1500, 1);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                regenBoard2();
            });
            timer.start();
        } else {
            regenBoard2();
        }
    }

    private function regenBoard2():void {
        startAction("regenBoard2");
        removeAllTokens();
        var state:BoardState = new BoardState();
        state.generateRandomWithoutGroups();
        var i:int, j:int, token:Token;
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE; j++) {
                token = generateToken(state.getCell(i, j));
                addToken(token);
                setToken(i, j, token);
                TweenLite.from(token, 0.7, {x:token.x, y:-height / Constants.BOARD_SIZE, delay:(Constants.BOARD_SIZE - j) * 0.075});
            }
        }
        var timer:Timer = new Timer(1500, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            startAction("");
        });
        timer.start();
    }

    private function resetToTestBoard():void {
        startAction("resetToTestBoard");
        removeAllTokens();
        var i:int, j:int, token:Token;
        var state:BoardState = new BoardState();
        /*state.setAll([
         [TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD],
         [TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER],
         [TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD],
         [TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER],
         [TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD],
         [TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER],
         [TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD],
         [TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER,TokenType.FOOD,TokenType.WATER]
         ]);*/
        state.setAll([
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.AMBER_BEER,TokenType.AMBER_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.BLOND_BEER,TokenType.VOMIT,TokenType.VOMIT,TokenType.VOMIT,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.VOMIT],
            [TokenType.VOMIT,TokenType.VOMIT,TokenType.BLOND_BEER,TokenType.BLOND_BEER,TokenType.BROWN_BEER,TokenType.BROWN_BEER,TokenType.VOMIT,TokenType.BROWN_BEER]
        ]);
        for (i = 0; i < Constants.BOARD_SIZE; i++) {
            for (j = 0; j < Constants.BOARD_SIZE; j++) {
                token = generateToken(state.getCell(i, j));
                addToken(token);
                setToken(i, j, token);
            }
        }

        if (checkSeries() > 0) {
            throw "regenerated board has groups";
        }
        clearSelection();
        startAction("");
    }

    public function createVomit():void {
        var cell:Object = getCurrentState().getRandomNonVomitCell();
        if (cell != null) {
            trace("Creating vomit on " + cell.x + ":" + cell.y);
            var token:Token = generateToken(TokenType.VOMIT);
            removeToken(getToken(cell.x, cell.y));
            addToken(token);
            setToken(cell.x, cell.y, token);
        } else {
            trace("Too much vomit on board")
        }
    }

    private function removeAllTokens():void {
        while (_gemsLayer.numChildren > 0) {
            _gemsLayer.removeChildAt(0);
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
        state.pissLevel = pissLevel;
        return state;
    }

    private function clickCell(x:int, y:int):void {
        if (_currentAction == "selectTokenToDestroy") {
            var token:TokenType = getToken(x, y).type;
            if (token.collectible) {
                destroyTokensOfType(token);
                game.me.score += 150;
                game.me.clearCapacities();
            }
        } else if (_currentAction == "") {
            if (y >= Constants.BOARD_SIZE - _pissLevel) {
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
                dispatchEvent(new GemsSwappedEvent(game.me, sx, sy, x, y));
                setToken(x, y, src);
                setToken(sx, sy, dst);
                startScoring();
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
        if (y >= Constants.BOARD_SIZE - _pissLevel) {
            // Cannot select in piss    
            return;
        }
        _selectedX = x;
        _selectedY = y;
        _selection.visible = true;
        _selection.x = _selectedX * width / Constants.BOARD_SIZE;
        _selection.y = _selectedY * height / Constants.BOARD_SIZE;
        trace("Selected " + x + ":" + y);
    }

    private function clearSelection():void {
        _selectedY = -1;
        _selectedX = -1;
        _selection.visible = false;
        trace("Unselected");
    }

    private function checkSeries():int {
        resetMarks();
        var state:BoardState = getCurrentState();
        var groups:Array = state.computeGroups();
        for (var i:int = 0; i < groups.length; i++) {
            var group:Object = groups[i];
            for (var k:int = 0; k < group.length; k++) {
                var x:int = group.startX;
                var y:int = group.startY;
                if (group.type == "horizontal") {
                    x += k;
                } else {
                    y += k;
                }
                getToken(x, y).mark = true;
            }
        }
        invalidateDisplayList();
        return groups.length;
    }

    private function destroyMarked():void {
        startAction("exploding");
        for (var j:int = Constants.BOARD_SIZE - 1; j >= 0; j--) {
            for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
                var token:Token = getToken(i, j);
                if (token.mark) {
                    token.explode();
                }
            }
        }
        var timer:Timer = new Timer(EXPLODE_DURATION_MS, 1);
        timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
            endDestroySeries();
        });
        timer.start();
    }

    private function destroySeries():Boolean {
        var series:int = checkSeries();
        if (series > 0) {
            combo += series;
            destroyMarked();

            var state:BoardState = getCurrentState();
            var resetMultiplier:Boolean = true;
            var player:PlayerData = game.me;
            var maxGroup:int = 0;
            if (game.me.coasterReserve > 0) {
                player = game.opponent;
                game.me.coasterReserve--;
            }
            for each (var group:Object in state.computeGroups()) {
                if (group.length == 3) {
                    if (group.token == TokenType.BLOND_BEER || group.token == TokenType.BROWN_BEER || group.token == TokenType.AMBER_BEER) {
                        player.addPartialBeer(group.token);
                    } else if (group.token == TokenType.COASTER) {
                        player.coasterReserve++;
                    }
                } else if (group.length == 4) {
                    game.me.score += 20 * combo * game.me.multiplier;
                    dispatchEvent(new CapacityEvent(CapacityEvent.CAPACITY_GAINED, player, Capacity.fromToken(group.token)));
                    if (group.token == TokenType.BLOND_BEER || group.token == TokenType.BROWN_BEER || group.token == TokenType.AMBER_BEER) {
                        player.addPartialBeer(TokenType.TRIPLE);
                    } else if (group.token == TokenType.COASTER) {
                        player.coasterReserve++;
                    }
                } else if (group.length >= 5) {
                    game.me.score += 40 * combo * game.me.multiplier;
                    game.me.multiplier += 1;
                    resetMultiplier = false;
                    dispatchEvent(new CapacityEvent(CapacityEvent.CAPACITY_GAINED, player, Capacity.fromToken(group.token)));
                    if (group.token == TokenType.BLOND_BEER || group.token == TokenType.BROWN_BEER || group.token == TokenType.AMBER_BEER) {
                        player.fullBeers++;
                    } else if (group.token == TokenType.COASTER) {
                        player.coasterReserve += 3;
                    }
                }
                if (group.length > maxGroup) {
                    maxGroup = group.length;
                }
                game.me.score += group.token.score * combo * game.me.multiplier;
                trace("Collected group of " + group.token + " of size " + group.length);
                if (group.token == TokenType.BLOND_BEER || group.token == TokenType.BROWN_BEER || group.token == TokenType.AMBER_BEER) {
                    player.piss += 3 * group.length;
                    player.vomit += 3 * group.length;
                } else if (group.token == TokenType.WATER) {
                    player.piss += 3 * group.length;
                    player.vomit -= 3 * group.length;
                } else if (group.token == TokenType.LIQUOR) {
                    player.piss -= group.length;
                    player.vomit += 6 * group.length;
                } else if (group.token == TokenType.FOOD) {
                    player.vomit -= 7 * group.length;
                }
            }
            var fx:Sound;
            if (maxGroup == 3) {
                fx = new Beer3FX();
            } else if (maxGroup == 3) {
                fx = new Beer4FX();
            } else {
                fx = new Beer5FX();
            }
            fx.play();
            if (resetMultiplier) {
                game.me.multiplier = 1;
            }
            return true;
        }
        return false;
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
                        var upToken:Token;
                        if (jj >= 0) {
                            upToken = getToken(i, jj);
                        } else {
                            upToken = generateToken();
                            addToken(upToken);
                            setToken(i, jj, upToken);
                        }
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
                endDestroySeries();
            });
            timer.start();
        } else {
            endDestroySeries2();
        }
    }

    private function startScoring():void {
        _scoring = true;
        combo = 0;
    }

    private function endScoring():void {
        _scoring = false;
    }

    private function dumpBoard():void {
        trace(getCurrentState());
    }

    private function removeMarkedTokens():void {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = Constants.BOARD_SIZE - 1; j >= 0; j--) {
                var token:Token = getToken(i, j);
                if (token != null && token.mark) {
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
        if (!destroySeries()) {
            endScoring();
            startAction("");
            checkAvailableMoves();
        }
    }

    private function resetMarks():void {
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                var token:Token = getToken(i, j);
                token.mark = false;
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
        if (_initialized) {
            var state:BoardState = getCurrentState();
            availableMoves = state.computeMoves().length;
            /*trace("available moves:");
             for each (var move:Object in state.computeMoves()) {
             trace("  " + move.type + " of " + move.startX + ":" + move.startY);
             }*/
        }
    }

    private function checkAvailableMoves():void {
        if (availableMoves == 0) {
            regenBoard(true);
        }
    }

    public function get pissLevel():int {
        return _pissLevel;
    }

    public function set pissLevel(value:int):void {
        var dy:int = value - _pissLevel;
        _pissLevel = value;
        var epsilon:int = (_pissLevel > 0) ? -5 : 0;
        TweenLite.to(_pissLayer, PISS_RAISE_TIME_MS / 1000, {y: (Constants.BOARD_SIZE - _pissLevel) * height / Constants.BOARD_SIZE + epsilon});
        if (_selectedY >= Constants.BOARD_SIZE - _pissLevel) {
            clearSelection();
        }
        if (dy > 0) {
            var fx:Sound = new PissRaiseFX();
            fx.play();
        }
        refreshStats();
    }

    public function executeCapacity(player:PlayerData, capacity:Capacity):void {
        if (_currentAction != "") {
            trace("ERROR: unable to execute capacity because an action is already in progress");
        }
        switch (capacity) {
            case Capacity.BIG_PEANUTS:
                game.me.piss = 0;
                game.me.score += 100;
                game.me.clearCapacities();
                break;
            case Capacity.WATERFALL:
                destroyTokensOfType(TokenType.VOMIT);
                game.me.score += 75;
                game.me.clearCapacities();
                break;
            case Capacity.BIG_BANG:
                startAction("selectTokenToDestroy");
                if (_destroyCursor == 0) {
                    _destroyCursor = CursorManager.setCursor(DestroyCursor, CursorManagerPriority.HIGH);
                }
                break;
            case Capacity.TCHIN_TCHIN:
                stealPartialBeers();
                game.me.score += 150;
                game.me.clearCapacities();
        }
    }

    private function stealPartialBeers():void {
        while (game.opponent.partialBeers.length > 0) {
            var token:TokenType = game.opponent.partialBeers.removeItemAt(0) as TokenType;
            game.me.addPartialBeer(token);
        }
    }

    private function destroyTokensOfType(targetType:TokenType):void {
        if (_destroyCursor != 0) {
            CursorManager.removeCursor(_destroyCursor);
            _destroyCursor = 0;
        }
        startAction("destroyTokensOfType");
        for (var i:int = 0; i < Constants.BOARD_SIZE; i++) {
            for (var j:int = 0; j < Constants.BOARD_SIZE; j++) {
                var token:Token = getToken(i, j);
                if (token.type == targetType) {
                    token.mark = true;
                    game.me.score += targetType.score;
                }
            }
        }
        destroyMarked();
    }

    [Bindable(event="availableMovesChanged")]
    public function get availableMoves():int {
        return _availableMoves;
    }

    public function set availableMoves(value:int):void {
        _availableMoves = value;
        dispatchEvent(new Event("availableMovesChanged"));
    }

    [Bindable(event="comboChanged")]
    public function get combo():Number {
        return _combo;
    }

    public function set combo(value:Number):void {
        _combo = value;
        dispatchEvent(new Event("comboChanged"));
    }

    public function get game():Game {
        return _game;
    }

    public function set game(value:Game):void {
        _game = value;
        _game.me.addEventListener(GameEvent.PISS_CHANGED, onPissChanged);
        _game.me.addEventListener(GameEvent.VOMIT_CHANGED, onVomitChanged);
        _game.me.addEventListener(GameEvent.COASTER_RESERVE_CHANGED, onCoasterReserveChanged);
        _game.me.addEventListener(CapacityEvent.CAPACITY_EXECUTED, onCapacityExecuted);
    }

    private function onPissChanged(e:GameEvent):void {
        if (game.me.piss >= 100) {
            pissLevel = 3;
        } else if (game.me.piss >= 90) {
            pissLevel = 2;
        } else if (game.me.piss >= 80) {
            pissLevel = 1;
        } else {
            pissLevel = 0;
        }
    }

    private function onVomitChanged(e:GameEvent):void {
        if (game.me.vomit >= 100) {
            createVomit();
            createVomit();
            createVomit();
            createVomit();
            createVomit();
            game.me.vomit = 50;
            var fx:Sound = new VomitFX();
            fx.play();
        }
    }

    private function onCoasterReserveChanged(e:GameEvent):void {
        if (game.me.coasterReserve > 0) {
            if (_coasterCursor == 0) {
                _coasterCursor = CursorManager.setCursor(CoasterCursor, CursorManagerPriority.MEDIUM);
            }
        } else if (_coasterCursor != 0) {
            CursorManager.removeCursor(_coasterCursor);
            _coasterCursor = 0;
        }
    }

    private function onCapacityExecuted(e:CapacityEvent):void {
        executeCapacity(e.player, e.capacity);
    }

    private var _game:Game;
    private var _board:Array = new Array();
    private var _initialized:Boolean = false;
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
    private var _availableMoves:int;
    private var _scoring:Boolean = false;
    private var _combo:Number = 0;
    private var _gemsLayer:DisplayObjectContainer;
    private var _pissLayer:DisplayObjectContainer;
    private var _pissLevel:int = 0;
    private var _destroyCursor:int = 0;
    private var _coasterCursor:int = 0;

    [Embed(source="../../../board.png")]
    private static var BoardBackground:Class;

    [Embed(source="../../../effet-pisse.png")]
    private static var PissAnimation:Class;

    [Embed(source="../../../curseur-bang.png")]
    private static var DestroyCursor:Class;

    [Embed(source="../../../sous-bock.png")]
    private static var CoasterCursor:Class;

    [Embed(source="../../../son-montee-pisse.mp3")]
    private static var PissRaiseFX:Class;

    [Embed(source="../../../vomir.mp3")]
    private static var VomitFX:Class;

    [Embed(source="../../../biere-x3.mp3")]
    private static var Beer3FX:Class;

    [Embed(source="../../../biere-x4.mp3")]
    private static var Beer4FX:Class;

    [Embed(source="../../../biere-x5.mp3")]
    private static var Beer5FX:Class;

}
}