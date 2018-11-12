var npc_target_interval;
$( document ).on('turbolinks:load', function() {
  // Target npc if clicked AJAX
  $('#app-container').on('click', '.target-npc-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "npc/target", {id: id}, function() {
      if ($('.enemy-space-ship').length) {
        remove_target();
        $('.enemy-space-ship').append("<div class='text-center counter'><h5 style='margin-top:25px'>5</h5></div>");
        var time = 5
        npc_target_interval = setInterval(function() {
          time = time-1;
          $('.enemy-space-ship .counter').empty().append("<h5 style='margin-top:25px'>"+time+"</h5>"); 
          if (time <= 0) {
            $('.enemy-space-ship .counter').remove();
            clearInterval(npc_target_interval);
          }
        }, 1000);
      }
    });
  });
  
  // Untarget player if clicked AJAX
  $('.ship-card').on('click', '.untarget-npc-btn', function(e) {
    id = $(this).data("id");
    $.post( "npc/target", {id: id}, function() {
      remove_target();
    });
  });
  
  // Attack Player AJAX
  $('.ship-card').on('click', '.attack-npc-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "npc/attack", {id: id}, function() {
      $('.enemy-space-ship').css("border", "1px solid red");
    });
  });
});