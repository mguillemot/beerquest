package com.beerquest.events {
import com.beerquest.TokenType;

public class TokenEvent extends GameEvent {
    public static const TOKEN_COLLECTED:String = "TokenCollected";

    public function TokenEvent(event:String, token:TokenType) {
        super(event);
        _token = token;
    }

    public function get token():TokenType {
        return _token;
    }

    private var _token:TokenType;
}
}