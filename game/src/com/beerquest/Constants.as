package com.beerquest {
public class Constants {

    public static const VERSION:Number = 0.97;
    public static const DEBUG:Boolean = true;

    public static const BOARD_SIZE:int = 8;
    public static const INITIAL_TOTAL_TURNS:int = 40;
    public static const MAX_CAPACITIES:int = 2;
    public static const TOKEN_GROUP_VALUE:int = 5;
    public static const SUPER_GEM_VALUE:int = 10;
    public static const MAX_STACK:int = 15;
    public static const BLOODY_MARY_TURN_GAIN:int = 5;
    public static const BLOODY_MARY_VOMIT_GAIN:int = 3;
    public static const CELLS_CONTAMINATED_ON_VOMIT:int = 5;

    public static var GAME:Game = new Game();

    function Constants() {
    }
}
}