package com.beerquest.events {
import com.beerquest.BoardState;
import com.beerquest.TokenType;

public class BoardEvent extends GameEvent {
    public static const BOARD_RESET:String = "BoardReset";
    public static const CELLS_DESTROYED:String = "CellsDestroyed";
    public static const CELLS_TRANSFORMED:String = "CellsTransformed";

    public static function FullBoardResetEvent():BoardEvent {
        return new BoardEvent(BOARD_RESET, new Array());
    }

    public function BoardEvent(event:String, cells:Array, board:BoardState = null) {
        super(event);
        _cells = cells;
        _board = board;
    }

    public function get cells():Array {
        return _cells;
    }

    public function get board():BoardState {
        return _board;
    }

    private var _cells:Array;
    private var _board:BoardState;
}
}