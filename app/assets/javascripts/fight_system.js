var target_interval

$( document ).on('turbolinks:load', function() {
  // Target player if clicked AJAX
  $('.players-card').on('click', '.target-player-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    if (target_interval == null || target_interval == false)
    $.post( "ship/target", {id: id}, function() {
      if ($('.enemy-space-ship').length) {
        $('.enemy-space-ship').next().empty();
        $('.enemy-space-ship').next().next().empty();
        $('.enemy-space-ship').empty().append("<div class='text-center counter'><h5 style='margin-top:10px'>5</h5></div>");
        var time = 5
        target_interval = setInterval(function() {
          time = time-1;
          $('.enemy-space-ship .counter').empty().append("<h5 style='margin-top:10px'>"+time+"</h5>"); 
          if (time <= 0) {
            $('.enemy-space-ship .counter').remove();
            clearInterval(target_interval);
            target_interval = false
          }
        }, 1000);
      }
    });
  });
  
  // Untarget player if clicked AJAX
  $('.ship-card').on('click', '.untarget-player-btn', function(e) {
    id = $(this).data("id");
    $.post( "ship/target", {id: id}, function() {
      if ($('.enemy-space-ship').length) {
        $('.enemy-space-ship').next().empty();
        $('.enemy-space-ship').next().next().empty();
      }
    });
  });
  
  // Attack Player AJAX
  $('.ship-card').on('click', '.attack-player-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "ship/attack", {id: id}, function() {
    })
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
        $(this).parent().removeClass('target-flash').addClass('attack-flash');
      }
    });
  }
}