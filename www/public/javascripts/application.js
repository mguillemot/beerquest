function pad_number(n) {
    if (n >= 100) {
        return "" + n;
    } else if (n >= 10) {
        return "0" + n;
    } else if (n >= 1) {
        return "00" + n;
    } else {
        return "000";
    }
}

function number_with_delimiter(n, delimiter) {
    var result = "";
    var first = true;
    while (n > 0) {
        var part = (n < 1000) ? (n % 1000).toString() : pad_number(n % 1000);
        result = part + (first ? "" : delimiter) + result;
        n = Math.floor(n / 1000);
        first = false;
    }
    return result;
}

$(function() {
    $("ul.tabs").tabs("div.panes > div.pane", {
        tabs: 'li'
    });
    $("#subtabs1").tabs("#subpanes1 > div.subpane");
    $("#subtabs2").tabs("#subpanes2 > div.subpane");
    $("#subtabs3").tabs("#subpanes3 > div.subpane");
    $("#subtabs4").tabs("#subpanes4 > div.subpane");

    setInterval(function() {
        var node = $("#world-score .total-beers");
        var increase = parseFloat(node.data("increase"));
        var target = parseFloat(node.data("target"));
        var current = parseFloat(node.data("current"));
        var delimiter = node.data("delimiter");
        var next = current + increase / 10.0;
        var formatted = number_with_delimiter(Math.floor(next), delimiter);
        node.data("current", next).html(formatted);
        if (next >= target) {
            reloadWorldScore();
        }
    }, 100);
});
