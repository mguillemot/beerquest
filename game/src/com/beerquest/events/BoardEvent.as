package com.beerquest.events {
import com.beerquest.BoardState;

public class BoardEvent extends GameEvent {

    public static const BOARD_RESET:String = "BoardReset";
    public static const CELLS_DESTROYED:String = "CellsDestroyed";
    public static const CELLS_TRANSFORMED:String = "CellsTransformed";
    public static const CELLS_VOMITED:String = "CellsVomited";

    public function BoardEvent(event:String, cells:Array, board:BoardState = null) {
        super(event, board);
        _cells = cells;
    }

    public function get cells():Array {
        return _cells;
    }

    private var _cells:Array;
}
}