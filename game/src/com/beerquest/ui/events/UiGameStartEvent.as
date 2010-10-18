package com.beerquest.ui.events {
import com.beerquest.Capacity;

import flash.events.Event;

public class UiGameStartEvent extends Event {
    public static const UI_GAME_START:String = "UiGameStart";

    public function UiGameStartEvent(scoreRaise:int = 0) {
        super(UI_GAME_START, true);
        _scoreRaise = scoreRaise;
    }

    public function get scoreRaise():int {
        return _scoreRaise;
    }

    private var _scoreRaise:int;
}
}