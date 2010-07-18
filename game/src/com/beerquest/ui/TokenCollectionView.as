package com.beerquest.ui {
import com.beerquest.*;
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.display.Sprite;

import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.events.CollectionEvent;

public class TokenCollectionView extends UIComponent {

    public function TokenCollectionView() {
        width = 170;
        height = 34;
        graphics.clear();
        graphics.beginFill(0x80ff0000);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
    }

    [Bindable]
    public function set collection(value:ArrayCollection):void {
        if (_collection != null) {
            _collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        }
        _collection = value;
        _collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        compact();
    }

    private function onCollectionChange(e:CollectionEvent):void {
        switch (e.kind) {
            case "add":
                for each(var token:Object in e.items) {
                    var t:Sprite = new Sprite();
                    t.graphics.lineStyle(1, 0x0);
                    t.graphics.beginFill(token.color);
                    t.graphics.drawCircle(50, 50, 50);
                    t.graphics.endFill();
                    token.token = t;
                    t.width = t.height = 10;
                    addChild(t);
                }
                compact();
                break;
        }
    }

    public function compact():void {
        trace("Compacting collected tokens");
        for (var i:int = 0; i < _collection.length - 2; i++) {
            var type:TokenType = _collection.getItemAt(i).type;
            if (_collection.getItemAt(i + 1).type == type && _collection.getItemAt(i + 2).type == type) {
                for (var k:int; k < 3; k++) {
                    TweenLite.to(_collection.getItemAt(i + 2).token, 0.2, {opacity: 0});
                    //var item:Object = _collection.removeItemAt(i);
                    //removeChild(item.token);
                }
                return;
            }
        }
        recomputeCoords();
    }

    private function recomputeCoords():void {
        var cursorX:Number = 0;
        var cursorY:Number = 0;
        for (var i:int = 0; i < _collection.length; i++) {
            var token:DisplayObject = _collection.getItemAt(i).token;
            if (cursorX + token.width > width) {
                cursorX = 0;
                cursorY += 20;
            }
            token.x = cursorX;
            token.y = cursorY;
            cursorX += token.width;
        }
    }

    private var _collection:ArrayCollection;

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