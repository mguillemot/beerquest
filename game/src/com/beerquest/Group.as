/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 3 sept. 2010
 * Time: 12:55:27
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest {
public class Group {
    public function Group() {
    }

    public var x:int;
    public var y:int;
    public var length:int;
    public var token:TokenType;
    public var direction:String;
    public var supers:int;

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
}
}