// Remove target if cached
$( document ).ready(function() {
  remove_target();
});

$( document ).on('turbolinks:load', function() {
  // Target player if clicked AJAX
  $('#app-container').on('click', '.target-player-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "ship/target", {id: id}, function() {
      if ($('.enemy-space-ship').length) {
        remove_target();
        $('.enemy-space-ship').append("<div class='text-center counter'><h5 style='margin-top:25px'>5</h5></div>");
        var time = 5
        var target_interval = setInterval(function() {
          time = time-1;
          $('.enemy-space-ship .counter').empty().append("<h5 style='margin-top:25px'>"+time+"</h5>"); 
          if (time <= 0) {
            $('.enemy-space-ship .counter').remove();
            clearInterval(target_interval);
          }
        }, 1000);
      }
    });
  });
  
  // Untarget player if clicked AJAX
  $('.ship-card').on('click', '.untarget-player-btn', function(e) {
    id = $(this).data("id");
    $.post( "ship/target", {id: id}, function() {
      remove_target();
    });
  });
  
  // Attack Player AJAX
  $('.ship-card').on('click', '.attack-player-btn', function(e) {
    e.preventDefault();
    var button = $(this)
    id = $(this).data("id");
    $.post( "ship/attack", {id: id}, function() {
      $('.enemy-space-ship').css("border", "1px solid red");
      button.text("Stop");
    });
  });
});

// Reload target info AJAX
function refresh_target_info() {
  if ($('.ship-card').length) {
    $.get("/game/ship_info", function(data) {
      $('.ship-card .card-body').empty().append(data);
    });
  }
}

// Add flash to player who is targeting you
function getting_targeted(name) {
  if ($('.players-card').length) {
    $('.players-card .players-card-name-td').each(function() {
      if ($(this).html() == name) {
        if ($(this).parent().hasClass('attack-flash')) {
          $(this).parent().removeClass('attack-flash');
          return
        }
        if ($(this).parent().hasClass('target-flash')) {
          $(this).parent().removeClass('target-flash');  
        } else {
          $(this).parent().addClass('target-flash');  
        }
      }
    });
  }
}

// Add flash to player who is attacking you
function getting_attacked(name) {
  if ($('.players-card').length) {
    $('.players-card .players-card-name-td').each(function() {
      if ($(this).html() == name) {
        if ($(this).parent().hasClass('target-flash')) {
          $(this).parent().removeClass('target-flash').addClass('attack-flash');
          return
        }
        if ($(this).parent().hasClass('attack-flash')) {
          $(this).parent().removeClass('attack-flash').addClass('target-flash');  
        }
      }
    });
  }
}

// Update own health
function update_health(hp) {
  if ($('#own-ship-health').length) {
    $('#own-ship-health').empty().append("HP: " + hp);
  }
}

// Update target health
function update_target_health(hp) {
  if ($('#target-ship-health').length) {
    $('#target-ship-health').empty().append("HP: " + hp);
  }
}

// Remove target
function remove_target() {
  if ($('.enemy-space-ship').length) {
    $('.enemy-space-ship').empty();
    $('.enemy-space-ship').next().empty();
    $('.enemy-space-ship').next().next().empty();
  }
  // Remove mining interval
  if (typeof mining_interval !== 'undefined') {
    clearInterval(mining_interval);
    mining_interval = false; 
  }
  mining_progress = 0;
  // Remove target interval
  if (typeof target_interval !== 'undefined') {
    clearInterval(target_interval);
    target_interval = false 
  }
  // Remove npc target interval
  if (typeof npc_target_interval !== 'undefined') {
    clearInterval(npc_target_interval);
  }
}