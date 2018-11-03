$( document ).on('turbolinks:load', function() {
  $('#app-container').on('click', '.target-player-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "ships/target", {id: id}, function() {
      if ($('.enemy-space-ship').length) {
        $('.enemy-space-ship').append("<div class='text-center'><h5 style='margin-top:10px'>5</h5></div>");
        var time = 5
        target_interval = setInterval(function() {
          time = time-1;
          $('.enemy-space-ship').empty().append("<div class='text-center'><h5 style='margin-top:10px'>"+time+"</h5></div>");
          if (time <= 0) {
            clearInterval(target_interval);
          }
        }, 1000);
      }
    })
  });
});

function refresh_target_info() {
  if ($('.ship-card').length) {
    $.get("/game/ship_info", function(data) {
      $('.ship-card .card-body').empty().append(data);
    });
  }
}

function getting_targeted(name) {
  if ($('.players-card').length) {
    $('.players-card .players-card-name-td').each(function() {
      if ($(this).html() == name) {
        $(this).parent().addClass('flash');
      }
    });
  }
}