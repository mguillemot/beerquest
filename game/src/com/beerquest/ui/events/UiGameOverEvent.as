package com.beerquest.ui.events {
import com.beerquest.Capacity;

import flash.events.Event;

public class UiGameOverEvent extends Event {
    public static const GAME_OVER:String = "UiGameOver";

    public function UiGameOverEvent() {
        super(GAME_OVER, true);
    }
}
}