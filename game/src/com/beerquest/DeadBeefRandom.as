package com.beerquest {
public class DeadBeefRandom {
    public static function generate():DeadBeefRandom {
        return new DeadBeefRandom(Math.random());
    }

    public function DeadBeefRandom(seed:uint) {
        _seed = seed;
        _beef = 0xDEADBEEF;
    }

    public function next():uint {
        _count++;
        var a:uint = (_seed << 7) & 0xFFFFFFFF;
        var b:uint = (_seed >>> 25) & 0xFFFFFFFF;
        var c:uint = (b + _beef) & 0xFFFFFFFF;
        _seed = (a ^ c) & 0xFFFFFFFF;
        var d:uint = (_beef << 7) & 0xFFFFFFFF;
        var e:uint = (_beef >>> 25) & 0xFFFFFFFF;
        var f:uint = (e + 0xDEADBEEF) & 0xFFFFFFFF;
        _beef = (d ^ f) & 0xFFFFFFFF;
        return _seed;
    }

    public function nextFloat():Number {
        return next() / uint.MAX_VALUE;
    }

    public function nextInt(min:int, max:int):int {
        return min + Math.floor(next() % (max - min + 1));
    }

    public function get initialSeed():uint {
        return _initialSeed;
    }

    public function get generatedCount():Number {
        return _count;
    }

    private var _seed:uint;
    private var _beef:uint;

    // Debug stats
    private var _initialSeed:uint;
    private var _count:Number = 0;
}
}