$(function() {
  $("ul.tabs").tabs("div.panes > div.pane", {
    tabs: 'li'
  });
  $("#subtabs1").tabs("#subpanes1 > div.subpane");
  $("#subtabs2").tabs("#subpanes2 > div.subpane");
  $("#subtabs3").tabs("#subpanes3 > div.subpane");
  $("#subtabs4").tabs("#subpanes4 > div.subpane");
});
