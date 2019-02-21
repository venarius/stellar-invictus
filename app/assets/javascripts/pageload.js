$(document).on("turbolinks:load", function(){
  var $prefetcher;

  $("a[data-turbolinks!=false]").hoverIntent(function(){
    var href = $(this).attr("href");
    
    if (typeof href != 'undefined' && href != '' && href.indexOf("#") == -1) {
      if(!href.match(/^\//)){ return; } // do not prefetch outside urls or mailto:

      // add or change the prefetched link, be careful not to preload the same href multiple times
      if ($prefetcher) {
        if($prefetcher.attr("href") != href) {
          $prefetcher.attr("href", href);
        }
      } else {
        // NOTE: pre-creating the link does not work
        $prefetcher = $('<link rel="prefetch" href="' + href + '" />').appendTo("body");
      } 
    }
  });
});