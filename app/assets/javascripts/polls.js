$(document).on("turbolinks:load", function() {
  // Admin Create Poll Btn
  $(".admin-add-poll-btn").on("click", function() {
    var question = $("#admin-add-poll-question-input").val();
    var link = $("#admin-add-poll-link-input").val();

    if (question && question != "") {
      $.post("poll/create", { question: question, link: link }, function() {
        Turbolinks.visit(window.location);
      });
    }
  });

  // Poll Upvote Btn
  $(".poll-upvote-btn").on("click", function() {
    var id = $(this).data("id");
    var button = $(this);
    var html = button.html();

    loading_animation(button);
    $.post("poll/upvote", { id: id }, function(data) {
      button
        .closest(".card")
        .find(".progress-bar.bg-success")
        .css("width", data.upvotes + "%");
      button
        .closest(".card")
        .find(".progress-bar.bg-danger")
        .css("width", data.downvotes + "%");
      button
        .closest(".card")
        .find(".vote-size")
        .html(data.votes);
      button.closest("div").remove();
    }).fail(function(data) {
      if (data.responseJSON.error_message) {
        $.notify(data.responseJSON.error_message, { style: "alert" });
      }
      button.html(html);
    });
  });

  // Poll Downvote Btn
  $(".poll-downvote-btn").on("click", function() {
    var id = $(this).data("id");
    var button = $(this);

    loading_animation(button);
    $.post("poll/downvote", { id: id }, function(data) {
      button
        .closest(".card")
        .find(".progress-bar.bg-success")
        .css("width", data.upvotes + "%");
      button
        .closest(".card")
        .find(".progress-bar.bg-danger")
        .css("width", data.downvotes + "%");
      button
        .closest(".card")
        .find(".vote-size")
        .html(data.votes);
      button.closest("div").remove();
    }).fail(function(data) {
      if (data.responseJSON.error_message) {
        $.notify(data.responseJSON.error_message, { style: "alert" });
      }
      button.html(html);
    });
  });

  // Poll Move Up Btn
  $(".poll-move-up-btn").on("click", function() {
    var id = $(this).data("id");

    loading_animation($(this));
    $.post("poll/move_up", { id: id }, function(data) {
      Turbolinks.visit(window.location);
    });
  });

  // Poll Delete Btn
  $(".poll-delete-btn").on("click", function() {
    var id = $(this).data("id");
    var button = $(this);

    loading_animation($(this));
    $.post("poll/delete", { id: id }, function(data) {
      button.closest(".card").remove();
    });
  });
});
