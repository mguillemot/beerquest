package com.beerquest.events {
import com.beerquest.BoardState;
import com.beerquest.Capacity;
import com.beerquest.TokenType;

public class CapacityEvent extends GameEvent {

    public static const CAPACITY_GAINED:String = "CapacityGained";
    public static const CAPACITY_EXECUTED:String = "CapacityExecuted";

    public function CapacityEvent(event:String, capacity:Capacity, slot:int, targetToken:TokenType = null, board:BoardState = null) {
        super(event, board);
        _capacity = capacity;
        _slot = slot;
        _targetToken = targetToken;
    }

    public function get capacity():Capacity {
        return _capacity;
    }

    public function get slot():int {
        return _slot;
    }

    public function get targetToken():TokenType {
        return _targetToken;
    }

    private var _capacity:Capacity;
    private var _slot:int;
    private var _targetToken:TokenType;
}
}