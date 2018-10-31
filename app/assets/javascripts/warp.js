$( document ).on('turbolinks:load', function() {
  $('#app-container').on('click', '.warp-btn', function(e) {
    e.preventDefault();
    var target = $(this).data("id");
    if (target) {
      $.post( "game/warp", { id: target }, function( data ) {
        doWarp(10);
      });
    }
  });
  
  $('#app-container').on('click', '.jumpgate-jump-btn', function(e) {
    e.preventDefault();
    var time = parseInt($(this).data('time'))
    $.post( "game/jump", function() {
      doWarp(time);
    })
  });
});

function doWarp(warpTime) {
  $('.game-card-row').empty();
  $('.game-card-row').append(
    "<div class='col-md-12'><div class='card black-card card-body warp-card'><h2 class='flexbox-vert-center'>WARPING</h2><h4 class='flexbox-vert-center'>"+warpTime+"</h4></div></div>"
  );
  var interval = setInterval(function() {
    warpTime = warpTime - 1;
    if ($('.warp-card').length) {
      $('.game-card-row .warp-card h4').empty().append(
        warpTime
      ); 
    } else {
      $('.game-card-row').empty();
      $('.game-card-row').append(
        "<div class='col-md-12'><div class='card black-card card-body warp-card'><h2 class='flexbox-vert-center'>WARPING</h2><h4 class='flexbox-vert-center'>"+warpTime+"</h4></div></div>"
      );
    }
    if (warpTime <= 0) {
      App.local.reload();
      Turbolinks.visit(window.location);
      clearInterval(interval);
    }
  },1000);
}

function player_warp_out(name) {
  if ($('.players-card')) {
    $('.players-card-name-td').each(function() {
      if ($(this).html() == name) {
        $(this).closest('tr').fadeOut('fast', 
          function(){ 
            $(this).remove();                    
          }
        );
      }
    });
  }
}

function reload_players_card() {
  if ($('#players-card').length) {
    $.get("game/local_players", function(data) {
      $('#players-card').replaceWith(data);
    });
  }
}