package com.beerquest {
public class MersenneTwister {
    public function MersenneTwister(seed:uint) {
        _mt[0] = seed;
        for (var i:int = 1; i < 623; i++) {
            _mt[i] = (1812433253 * (_mt[i - 1] ^ (_mt[i - 1] >> 30)) + 1) & 0xFFFFFFFF
        }
    }

    private function generateNumbers():void {
        for (var i:int = 0; i <= 623; i++) {
            _y = 0x80000000 & _mt[i] + 0x7FFFFFFF & (_mt[(i + 1) % 624]);
            _mt[i] = _mt[(i + 397) % 624] ^ (_y >> 1);
            if ((_y % 2) == 1) {
                _mt[i] = _mt[i] ^ 2567483615;
            }
        }
    }

    public function next():Number {
        if (_z == 0) {
            generateNumbers();
        }
        _y = _mt[_z];
        _y ^= (_y >> 11);
        _y ^= (_y << 7) & 0x9d2c5680;
        _y ^= (_y << 15) & 0xefc60000;
        _y ^= (_y >> 18);
        _z = (_z + 1) % 624;
        return _y;
    }

    public function nextFloat():Number {
        return next() / int.MAX_VALUE;
    }

    public function nextInt(min:int, max:int):int {
        return min + Math.floor(next() % (max - min + 1));
    }

    private var _mt:Array = new Array();
    private var _y:Number, _z:uint = 0;
}
}