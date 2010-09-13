package com.beerquest.ui.events {
import com.beerquest.Capacity;

import flash.events.Event;

public class UiCapacityExecutionEvent extends Event {
    public static const ASK_FOR_EXECUTION:String = "AskForExecution";

    public function UiCapacityExecutionEvent(type:String, capacity:Capacity) {
        super(type, true);
        _capacity = capacity;
    }

    public function get capacity():Capacity {
        return _capacity;
    }

    private var _capacity:Capacity;
}
}