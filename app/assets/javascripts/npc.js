$(document).on("turbolinks:load", function() {
  // Target npc if clicked AJAX
  $("#app-container").on("click", ".target-npc-btn", function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    var button = $(this);

    $.post("npc/target", { id: id }, function(data) {
      if ($(".enemy-space-ship").length) {
        remove_target();
        animation_target_counter(data.time);
        button_target_counter(button, data.time);
      }
    });
  });

  // Untarget player if clicked AJAX
  $(".ship-card").on("click", ".untarget-npc-btn", function(e) {
    $.post("npc/untarget", function() {
      remove_target();
    });
  });
});
