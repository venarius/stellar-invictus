// Remove target if cached
$( document ).ready(function() {
  remove_target();
});

$( document ).on('turbolinks:load', function() {
  // Target player if clicked AJAX
  $('#app-container').on('click', '.target-player-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "ship/target", {id: id}, function(data) {
      if ($('.enemy-space-ship').length) {
        remove_target();
        animation_target_counter(data.time);
      }
    });
  });
  
  // Untarget player if clicked AJAX
  $('.ship-card').on('click', '.untarget-player-btn', function(e) {
    id = $(this).data("id");
    $.post( "ship/untarget", {id: id}, function() {
      remove_target();
    });
  });
  
  // Use Equipment AJAX
  $('.ship-card').on('click', '.use-equipment-btn', function(e) {
    e.preventDefault();
    var button = $(this)
    id = $(this).data("id");
    $.post( "equipment/switch", {id: id}, function(data) {
      button.tooltip('dispose');
      $('#septarium-usage').text(data.usage);
      if (data && (data.type == "Weapon" || data.type == "Warp Disruptor")) {
        $('.enemy-space-ship').css("border", "1px solid red");
        if (button.hasClass('btn-outline-secondary')) {
          button.removeClass('btn-outline-secondary').addClass('btn-outline-danger');
        } else {
          button.removeClass('btn-outline-danger').addClass('btn-outline-flash-danger');
          setTimeout(function() {button.removeClass('btn-outline-flash-danger').addClass('btn-outline-secondary');}, 1000)
        }
      } else if (data.type == "Repair Bot") {
        if (button.hasClass('btn-outline-secondary')) {
          button.removeClass('btn-outline-secondary').addClass('btn-outline-success');
        } else {
          button.removeClass('btn-outline-success').addClass('btn-outline-flash-success');
          setTimeout(function() {button.removeClass('btn-outline-flash-success').addClass('btn-outline-secondary');}, 1000)
        }
      }
    });
  });
});

// Reload target info AJAX
function refresh_target_info() {
  if ($('.ship-card').length) {
    $.get("/game/ship_info", function(data) {
      $('.ship-card .card-body').html(data);
      load_ship_info_animations();
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
          $('.ship-card').removeClass('outline-danger');
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
          $('.ship-card').removeClass('outline-danger');
          $(this).parent().removeClass('attack-flash').addClass('target-flash');  
        }
      }
    });
  }
}

// Update own health
function update_health(hp) {
  if ($('#own-ship-health').length) {
    var health = parseInt($('#own-ship-health').text());
    $('#own-ship-health').empty().append(hp);
    if (health < hp) {
      if (!$('#own-ship-health').parent().hasClass('success-flash') && !$('#own-ship-health').parent().hasClass('attack-flash')) {
        $('#own-ship-health').parent().addClass('success-flash');
        setTimeout(function() {$('#own-ship-health').parent().removeClass('success-flash');}, 1000)
      }
    } else {
      if (!$('.ship-card').hasClass('outline-danger')) {
        $('.ship-card').addClass('outline-danger');
      }
      if (!$('#own-ship-health').parent().hasClass('success-flash') && !$('#own-ship-health').parent().hasClass('attack-flash')) {
        $('#own-ship-health').parent().addClass('attack-flash');
        setTimeout(function() {$('#own-ship-health').parent().removeClass('attack-flash');}, 1000)
      }
    }
  }
}

// Update target health
function update_target_health(hp) {
  if ($('#target-ship-health').length) {
    var health = parseInt($('#target-ship-health').text());
    $('#target-ship-health').empty().append(hp);
    if (health < hp) {
      if (!$('#target-ship-health').parent().hasClass('success-flash') && !$('#target-ship-health').parent().hasClass('attack-flash')) {
        $('#target-ship-health').parent().addClass('success-flash');
        setTimeout(function() {$('#target-ship-health').parent().removeClass('success-flash');}, 1000)
      }
    } else {
      if (!$('#target-ship-health').parent().hasClass('success-flash') && !$('#target-ship-health').parent().hasClass('attack-flash')) {
        $('#target-ship-health').parent().addClass('attack-flash');
        setTimeout(function() {$('#target-ship-health').parent().removeClass('attack-flash');}, 1000)
      }
    }
  }
}

// Remove target
function remove_target() {
  if ($('.enemy-space-ship').length) {
    $('.enemy-space-ship').css("border", "1px solid grey");
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
  }
  // Remove npc target interval
  if (typeof npc_target_interval !== 'undefined') {
    clearInterval(npc_target_interval);
  }
  if (typeof animation_remove_target !== 'undefined') {
    animation_remove_target(); 
  };
}

// Show died modal with text
function show_died_modal(text_message) {
  $('#died-modal-body').empty().append(text_message);
  $('#died-modal').modal('show');
}