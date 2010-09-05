package com.beerquest.events {
public class BoardResetEvent extends GameEvent {
    public static const BOARD_RESET:String = "BoardReset";

    public function BoardResetEvent(except:Array) {
        super(BOARD_RESET);
        _except = except;
    }

    public function get except():Array {
        return _except;
    }

    private var _except:Array;
}
}