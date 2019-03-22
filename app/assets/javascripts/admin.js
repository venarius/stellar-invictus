$(document).on("turbolinks:load", function() {
  // Search for Users AJAX
  $("#admin-search-users-search-btn").on("click", function() {
    var search = $("#admin-search-users-input").val();

    $("#admin-search-users-search-btn")
      .closest(".tab-pane")
      .find(".results")
      .html(
        "<div class='text-center spinner-modal'><i class='fa fa-spinner fa-spin fa-2x'></i></div>"
      );
    $.post("admin/search", { name: search }, function(data) {
      $("#admin-search-users-search-btn")
        .closest(".tab-pane")
        .find(".results")
        .html(data);
    });
  });

  // Teleport To Btn
  $("body").on("click", ".admin-teleport-to-btn", function() {
    var id = $(this).data("id");
    var button = $(this);

    $.post("admin/teleport", { id: id }, function() {
      button.closest(".modal").modal("hide");
    });
  });

  // Admin Ban Btn
  $("body").on("click", ".admin-ban-btn", function() {
    var id = $(this).data("id");
    var reason = $("#admin-banreason-input").val();
    var duration = $("#admin-bantime-input").val();
    var button = $(this);
    var html = button.html();

    loading_animation(button);
    $.post(
      "admin/ban",
      { id: id, duration: duration, reason: reason },
      function(data) {
        $.notify(data.message, { style: "success" });
        button.html(html);
        var collapse = button.closest(".collapse");
        collapse.html(
          "<p class='text-center'>User banned until " +
            data.banned_until +
            "</p><div class='text-center'><button class='btn btn-outline-primary admin-unban-btn'>Unban</button></div>"
        );
        collapse.find("button").data("id", id);
      }
    );
  });

  // Admin Unban Btn
  $("body").on("click", ".admin-unban-btn", function() {
    var id = $(this).data("id");
    var button = $(this);
    var html = button.html();

    loading_animation(button);
    $.post("admin/unban", { id: id }, function(data) {
      $.notify(data.message, { style: "success" });
      button.closest(".modal").modal("hide");
    });
  });

  // Admin Set Credits Btn
  $("body").on("click", ".admin-set-credits-btn", function() {
    var id = $(this).data("id");
    var credits = $("#admin-credits-input").val();
    var button = $(this);
    var html = button.html();

    loading_animation(button);
    $.post("admin/set_credits", { id: id, credits: credits }, function(data) {
      $.notify(data.message, { style: "success" });
      button.html(html);
    });
  });

  // Admin Send Server Message Btn
  $(".admin-send-server-message-btn").on("click", function() {
    var message = $("#admin-server-message-input").val();

    if (message) {
      $.post("admin/server_message", { text: message }, function() {
        $("#admin-server-message-input").val("");
      });
    }
  });

  // Admin Mute Btn
  $("body").on("click", ".admin-mute-btn", function() {
    var id = $(this).data("id");
    var button = $(this);

    if (id) {
      $.post("admin/mute", { id: id }, function(data) {
        $.notify(data.message, { style: "success" });
        button.closest(".modal").modal("hide");
      });
    }
  });

  // Admin Unmute Btn
  $("body").on("click", ".admin-unmute-btn", function() {
    var id = $(this).data("id");
    var button = $(this);

    if (id) {
      $.post("admin/unmute", { id: id }, function(data) {
        $.notify(data.message, { style: "success" });
        button.closest(".modal").modal("hide");
      });
    }
  });

  // Admin Delete Chat Btn
  $("body").on("click", ".admin-delete-chat-btn", function() {
    var id = $(this).data("id");

    if (id) {
      $.post("admin/delete_chat", { id: id }, function(data) {
        $.notify(data.message, { style: "success" });
      });
    }
  });
});
