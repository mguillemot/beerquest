package com.beerquest.events {
import com.beerquest.TokenType;

import flash.events.Event;

public class TokenEvent extends Event {
    public static const TOKEN_GAINED:String = "TokenGained";

    public function TokenEvent(token:TokenType, stageX:Number, stageY:Number) {
        super(TOKEN_GAINED, true);
        _token = token;
        _stageX = stageX;
        _stageY = stageY;
    }

    public function get token():TokenType {
        return _token;
    }

    public function get stageX():Number {
        return _stageX;
    }

    public function get stageY():Number {
        return _stageY;
    }

    private var _token:TokenType;
    private var _stageX:Number;
    private var _stageY:Number;
}
}