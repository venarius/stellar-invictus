$(document).on("turbolinks:load", function() {
  $("#app-container").on("click", ".user-bio-save-btn", function(e) {
    e.preventDefault();
    var text = $(".user-bio-text").val();
    loading_animation($(this));
    $.post("user/update_bio", { text: text }, function(data) {
      Turbolinks.visit(window.location);
    });
  });
});
