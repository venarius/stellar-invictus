var align_interval;
var overview_card;
$( document ).on('turbolinks:load', function() {
  
  // Go into warp and show warpcard AJAX
  $('#app-container').on('click', '.warp-btn', function(e) {
    e.preventDefault();
    
    // Give all warp buttons fa-icon
    clearInterval(align_interval);
    $('.warp-btn').each(function() { $(this).empty().append("<i class='fa fa-angle-double-right'></i>"); })
    
    loading_animation($(this))
    var button = $(this)
    var xhr = $.post( "game/warp", { id: button.data("id") }, function( data ) {
      if (data.align_time) {
        var align_time = data.align_time;
        
        button.empty().append(align_time);
        align_interval = setInterval(function(){ align_time = align_time - 1; button.empty().append(align_time); if (align_time <= 0) {clearInterval(align_interval); doWarp(10, "WARPING");}}, 1000)
      } else {
        clearInterval(align_interval);
        button.empty().append("<i class='fa fa-angle-double-right'></i>");
      }
    }).error(function(data) { if (data.responseJSON.error_message) { show_error(data.responseJSON.error_message); } });
  });
  
  // Go into warp and show warpcard AJAX
  $('#app-container').on('click', '.jumpgate-jump-btn', function(e) {
    e.preventDefault();
    loading_animation($(this))
    var time = parseInt($(this).data('time'))
    var xhr = $.post("game/jump", function() {
      doWarp(time, "JUMPING");
    }).error(function(data) { if (data.responseJSON.error_message) { show_error(data.responseJSON.error_message); } });
  });
});

// Show warpcard
var jump_interval;
function doWarp(warpTime, name) {
  if (jump_interval == null || jump_interval == false) {
    remove_target();
    $('.game-card-row').empty().append(
      "<div class='col-md-12'><div class='card black-card card-body warp-card'><h2 class='flexbox-vert-center'>"+name+"</h2><h4 class='flexbox-vert-center'>"+warpTime+"</h4></div></div>"
    );
    pixi_background_speed = 10;
    jump_interval = setInterval(function() {
      warpTime = warpTime - 0.25;
      if ($('.warp-card').length) {
        $('.game-card-row .warp-card h4').empty().append(
          Math.round(warpTime)
        ); 
      } else {
        $('.game-card-row').empty().append(
          "<div class='col-md-12'><div class='card black-card card-body warp-card'><h2 class='flexbox-vert-center'>"+name+"</h2><h4 class='flexbox-vert-center'>"+Math.round(warpTime)+"</h4></div></div>"
        );
      }
      if (warpTime <= 0) {
        clearInterval(jump_interval);
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

// Clear Jump
function clear_jump() {
  App.local.reload();
  App['local-chat'].unsubscribe();
  App['local-chat'] = null;
  clearInterval(jump_interval);
  jump_interval = false
  pixi_background_speed = 1;
}