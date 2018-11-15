$( document ).on('turbolinks:load', function() {
  // Target npc if clicked AJAX
  $('#app-container').on('click', '.target-npc-btn', function(e) {
    e.preventDefault();
    id = $(this).data("id");
    $.post( "npc/target", {id: id}, function() {
      if ($('.enemy-space-ship').length) {
        remove_target();
        animation_target_counter();
      }
    });
  });
  
  // Untarget player if clicked AJAX
  $('.ship-card').on('click', '.untarget-npc-btn', function(e) {
    id = $(this).data("id");
    $.post( "npc/untarget", {id: id}, function() {
      remove_target();
    });
  });
  
  // Attack Player AJAX
  $('.ship-card').on('click', '.attack-npc-btn', function(e) {
    e.preventDefault();
    var button = $(this);
    id = $(this).data("id");
    $.post( "npc/attack", {id: id}, function() {
      $('.enemy-space-ship').css("border", "1px solid red");
      button.text("Stop");
    });
  });
});