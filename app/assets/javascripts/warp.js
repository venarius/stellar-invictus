$( document ).on('turbolinks:load', function() {
  // Go into warp and show warpcard AJAX
  $('#app-container').on('click', '.warp-btn', function(e) {
    e.preventDefault();
    loading_animation($(this))
    var target = $(this).data("id");
    if (target) {
      var xhr = $.post( "game/warp", { id: target }, function( data ) {
        doWarp(10);
      }).error(function(data) { show_error(data.responseJSON.error_message); });
    }
  });
  
  // Go into warp and show warpcard AJAX
  $('#app-container').on('click', '.jumpgate-jump-btn', function(e) {
    e.preventDefault();
    loading_animation($(this))
    var time = parseInt($(this).data('time'))
    var xhr = $.post("game/jump", function() {
      doWarp(time);
    }).error(function(data) { show_error(data.responseJSON.error_message); });
  });
});

// Show warpcard
var jump_interval;
function doWarp(warpTime) {
  if (jump_interval == null || jump_interval == false) {
    remove_target();
    $('.game-card-row').empty().append(
      "<div class='col-md-12'><div class='card black-card card-body warp-card'><h2 class='flexbox-vert-center'>WARPING</h2><h4 class='flexbox-vert-center'>"+warpTime+"</h4></div></div>"
    );
    jump_interval = setInterval(function() {
      warpTime = warpTime - 0.25;
      if ($('.warp-card').length) {
        $('.game-card-row .warp-card h4').empty().append(
          Math.round(warpTime)
        ); 
      } else {
        $('.game-card-row').empty().append(
          "<div class='col-md-12'><div class='card black-card card-body warp-card'><h2 class='flexbox-vert-center'>WARPING</h2><h4 class='flexbox-vert-center'>"+Math.round(warpTime)+"</h4></div></div>"
        );
      }
      if (warpTime <= 0) {
        App.local.reload();
        clearInterval(jump_interval);
        jump_interval = false
      }
    },250); 
  }
}

// Remove player from list if warped out
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

// Reload player card AJAX
function reload_players_card() {
  if ($('#players-card').length) {
    $.get("game/local_players", function(data) {
      $('#players-card').replaceWith(data);
    });
  }
}