package com.beerquest.ui.events {
import flash.events.Event;

public class UiGameEvent extends Event {
    public static const UI_GAME_EVENT:String = "UiGameEvent";

    public function UiGameEvent(e:Event) {
        super(UI_GAME_EVENT, true);
        _event = e;
    }

    public function get event():Event {
        return _event;
    }

    private var _event:Event;
}
}