$(document).on("turbolinks:load", function() {
  // Mission Info Btn AJAX
  $(".station-card").on("click", ".mission-info-btn", function(e) {
    var id = $(this).data("id");
    var button = $(this);

    button
      .closest(".tab-pane")
      .find(".result")
      .html(
        "<br><div class='text-center'><i class='fa fa-spinner fa-spin fa-2x'></i></div>"
      );
    $.get("mission/info", { id: id }, function(data) {
      button
        .closest(".tab-pane")
        .find(".result")
        .html(data);
    });
  });

  // Accept Mission Btn AJAX
  $(".station-card").on("click", ".accept-mission-btn", function(e) {
    var id = $(this).data("id");

    $.post("mission/accept", { id: id }, function(data) {
      $.notify(data.message, { style: "success" });
      load_station_tab("#missions");
    });
  });

  // Finish Mission Btn AJAX
  $(".station-card").on("click", ".finish-mission-btn", function(e) {
    var id = $(this).data("id");
    var button = $(this);

    $.post("mission/finish", { id: id }, function(data) {
      $.notify(data.message, { style: "success" });
      refresh_player_info();
      button.closest(".result").empty();
      $("#current-mission-counter").html(
        parseInt($("#current-mission-counter").html()) - 1
      );
      $("#active-missions table")
        .find(".mission-info-btn")
        .each(function() {
          if ($(this).data("id") == id) {
            $(this)
              .closest("tr")
              .remove();
          }
        });
    }).fail(function(data) {
      if (data.responseJSON.error_message) {
        $.notify(data.responseJSON.error_message, { style: "alert" });
      }
    });
  });

  // Missions Modal Popup AJAX
  $("#missions-modal").on("shown.bs.modal", function() {
    $("#missions-modal-body")
      .empty()
      .append(
        "<div class='text-center'><i class='fa fa-spinner fa-spin fa-2x'></i></div>"
      );
    $.get("/mission/popup", function(data) {
      $("#missions-modal-body")
        .empty()
        .append(data);
    });
  });

  // Missions Modal Close
  $("#missions-modal").on("hidden.bs.modal", function() {
    $("#missions-modal-body").empty();
  });

  // Abort Mission Modal AJAX
  $(".station-card").on("click", ".abort-mission-modal-btn", function(e) {
    $("#abort-mission-modal")
      .find(".abort-mission-btn")
      .data("id", $(this).data("id"));
  });

  $(".station-card").on(
    "click",
    "#abort-mission-modal .abort-mission-btn",
    function(e) {
      var id = $(this).data("id");

      $.post("mission/abort", { id: id }, function(data) {
        $.notify(data.message, { style: "success" });
        $("#abort-mission-modal").modal("hide");
        setTimeout(function() {
          load_station_tab("#missions");
        }, 250);
      }).fail(function(data) {
        if (data.responseJSON.error_message) {
          $.notify(data.responseJSON.error_message, { style: "alert" });
        }
      });
    }
  );
});
