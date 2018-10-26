$( document ).on('turbolinks:load', function() {
  $('.warp-btn').off('click').on('click', function(e) {
    e.preventDefault();
    var target = $(this).data("id");
    if (target) {
      $.post( "game/warp", { id: target }, function( data ) {
        doWarp();
      });
    }
  });
});

function doWarp() {
  $('.game-card-row').empty();
  var warpTime = 10;
  $('.game-card-row').append(
    "<div class='col-md-12'><div class='card black-card card-body'><h2 class='flexbox-vert-center'>WARPING</h2><h4 class='flexbox-vert-center'>"+warpTime+"</div></div>"
  );
  var interval = setInterval(function() {
    warpTime = warpTime - 1;
    $('.game-card-row').empty().append(
      "<div class='col-md-12'><div class='card black-card card-body'><h2 class='flexbox-vert-center'>WARPING</h2><h4 class='flexbox-vert-center'>"+warpTime+"</div></div>"
    );
    if (warpTime <= 0) {
      Turbolinks.visit(window.location);
      clearInterval(interval);
    }
  },1000);
}