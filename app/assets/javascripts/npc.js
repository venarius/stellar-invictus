$( document ).on('turbolinks:load', function() {
  // Target npc if clicked AJAX
  $('#app-container').on('click', '.target-npc-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "npc/target", {id: id}, function(data) {
      if ($('.enemy-space-ship').length) {
        remove_target();
        animation_target_counter(data.time);
      }
    });
  });
  
  // Untarget player if clicked AJAX
  $('.ship-card').on('click', '.untarget-npc-btn', function(e) {
    $.post( "npc/untarget", function() {
      remove_target();
    });
  });
});