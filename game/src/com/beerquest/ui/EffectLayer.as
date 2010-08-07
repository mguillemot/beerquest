package com.beerquest.ui {
import com.beerquest.TokenType;
import com.greensock.TweenLite;

import com.greensock.easing.Quad;

import flash.display.Sprite;

import mx.containers.Canvas;
import mx.controls.Image;

import org.osmf.traits.TemporalTrait;

public class EffectLayer extends Canvas {
    private static const NUM_SCORE_EFFECTS:int = 10;
    private static const NUM_TOKEN_EFFECTS:int = 5;

    public function EffectLayer() {
        super();
        var i:int;

        _scoreEffectBuffer = new Array();
        for (i = 0; i < NUM_SCORE_EFFECTS; i++) {
            var fx:ScoreFx = new ScoreFx();
            fx.visible = false;
            addChild(fx);
            _scoreEffectBuffer.push(fx);
        }

        _tokenEffectBuffer = new Array();
        for (i = 0; i < NUM_TOKEN_EFFECTS; i++) {
            var tfx:Image = new Image();
            tfx.visible = false;
            addChild(tfx);
            _tokenEffectBuffer.push(tfx);
        }
    }

    public function addScoreEffect(value:int, x:Number, y:Number):void {
        if (_scoreEffectBuffer.length > 0) {
            var vfx:ScoreFx = _scoreEffectBuffer.pop();
            vfx.visible = true;
            vfx.alpha = 1;
            vfx.value = value;
            vfx.x = x - vfx.width / 2;
            vfx.y = y - vfx.height / 2;
            TweenLite.to(vfx, 1, {alpha:0, y:"-20", onComplete:function():void {
                vfx.visible = false;
                _scoreEffectBuffer.push(vfx);
            }});
        }
    }

    public function addTokenEffect(token:TokenType, sx:Number, sy:Number, dx:Number, dy:Number):void {
        if (_tokenEffectBuffer.length > 0) {
            var vfx:Image = _tokenEffectBuffer.pop();
            switch (token) {
                case TokenType.AMBER_BEER:
                    vfx.source = SmallAmber;
                    break;
                case TokenType.BLOND_BEER:
                    vfx.source = SmallBlond;
                    break;
                case TokenType.BROWN_BEER:
                    vfx.source = SmallBrown;
                    break;
                default:
                    vfx.source = SmallTriple;
                    break;
            }
            vfx.visible = true;
            vfx.scaleX = vfx.scaleY = 4;
            vfx.x = sx - vfx.width * vfx.scaleX / 2;
            vfx.y = sy - vfx.height * vfx.scaleY / 2;
            TweenLite.to(vfx, 1, {x:dx, y:dy, scaleX:1, scaleY:1, ease:Quad.easeIn, onComplete:function():void {
                vfx.visible = false;
                _tokenEffectBuffer.push(vfx);
            }});
        }
    }

    private var _scoreEffectBuffer:Array;
    private var _tokenEffectBuffer:Array;

    [Embed(source="../../../small-blond.png")]
    private static var SmallBlond:Class;

    [Embed(source="../../../small-amber.png")]
    private static var SmallAmber:Class;

    [Embed(source="../../../small-brown.png")]
    private static var SmallBrown:Class;

    [Embed(source="../../../small-triple.png")]
    private static var SmallTriple:Class;
}
}