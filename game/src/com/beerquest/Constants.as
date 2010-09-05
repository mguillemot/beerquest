package com.beerquest {
public class Constants {

    public static const VERSION:Number = 0.91;
    public static const DEBUG:Boolean = true;

    public static const BOARD_SIZE:int = 8;
    public static const INITIAL_TOTAL_TURNS:int = 50;
    public static const MAX_CAPACITIES:int = 2;
    public static const SUPER_TOKEN_VALUE:int = 10;

    public static var GAME:Game = new Game();
    public static var STATS:GameStats = new GameStats();

    [Bindable]
    public static var SOUND_ENABLED:Boolean = true;
    
    function Constants() {
    }
}
}