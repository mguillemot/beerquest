/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 3 sept. 2010
 * Time: 12:55:27
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest {
public class Group {
    public function Group(x:int, y:int, direction:String, length:int, token:TokenType, supers:int) {
        _x = x;
        _y = y;
        _direction = direction;
        _length = length;
        _token = token;
        _supers = supers;
    }

    public function get x():int {
        return _x;
    }

    public function get y():int {
        return _y;
    }

    public function get length():int {
        return _length;
    }

    public function get token():TokenType {
        return _token;
    }

    public function get direction():String {
        return _direction;
    }

    public function get supers():int {
        return _supers;
    }

    public function get midX():int {
        return (direction == "horizontal") ? (x + Math.floor(length / 2)) : x;
    }

    public function get midY():int {
        return (direction == "vertical") ? (y + Math.floor(length / 2)) : y;
    }

    public function get collectedToken():TokenType {
        if (token == TokenType.BLOND_BEER || token == TokenType.BROWN_BEER || token == TokenType.AMBER_BEER) {
            return (length >= 4) ? TokenType.TRIPLE : token;
        }
        return null;
    }

    public function get beerGain():int {
        var result:int = supers * Constants.SUPER_TOKEN_VALUE;
        if (token == TokenType.BLOND_BEER || token == TokenType.BROWN_BEER || token == TokenType.AMBER_BEER) {
            result += length;
        }
        return result;
    }

    public function get turnsGain():int {
        return (token == TokenType.TOMATO_JUICE) ? 1 : 0;
    }

    public function get pissGain():Number {
        return token.piss * length;
    }

    public function get vomitGain():Number {
        return token.vomit * length;
    }

    private var _x:int;
    private var _y:int;
    private var _length:int;
    private var _token:TokenType;
    private var _direction:String;
    private var _supers:int;
}
}