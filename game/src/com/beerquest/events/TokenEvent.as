package com.beerquest.events {
import com.beerquest.BoardState;
import com.beerquest.TokenType;

public class TokenEvent extends GameEvent {

    public static const TOKEN_ADDED:String = "TokenAdded";
    public static const TOKEN_EJECTED:String = "TokenEjected";
    public static const TOKEN_GROUP_COLLECTED:String = "TokenGroupCollected";

    public function TokenEvent(event:String, token:TokenType, board:BoardState = null) {
        super(event, board);
        _token = token;
    }

    public function get token():TokenType {
        return _token;
    }

    private var _token:TokenType;
}
}