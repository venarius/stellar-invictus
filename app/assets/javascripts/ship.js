$(document).on("turbolinks:load", function() {
  // Equipment Info AJAX
  $("#app-container").on("click", ".ship-info", function(e) {
    e.preventDefault();
    var name = $(this).data("name");

    $.get("ship/info", { name: name }, function(data) {
      $(data)
        .appendTo("#app-container")
        .modal("show");
    });
  });

  // Close Equipment Info
  $("#app-container").on("hidden.bs.modal", "#ship-info-modal", function() {
    $(this).remove();
  });

  // Edit Ship Name Btn
  $(".station-card").on("click", ".edit-ship-name-btn", function() {
    if (
      $(this)
        .closest("td")
        .find(".custom-name").length
    ) {
      var name = $(this)
        .closest("td")
        .find(".custom-name")
        .text();
      $(this)
        .closest("td")
        .find(".custom-name")
        .replaceWith(
          "<input style='width:80%' type='text' value='" + name + "'>"
        );
    } else {
      var name = $(this)
        .closest("td")
        .find(".name")
        .text();
      $(this)
        .closest("td")
        .find(".name")
        .replaceWith(
          "<input style='width:80%' type='text' value='" + name + "'>"
        );
    }
    $(this)
      .closest("td")
      .find("input")
      .data("id", $(this).data("id"));
    $(this)
      .removeClass("edit-ship-name-btn fa-edit")
      .addClass("save-ship-name-btn fa-save")
      .css("margin-right", "3px")
      .css("margin-top", "6px");
  });

  // Save Ship Name Btn
  $(".station-card").on("click", ".save-ship-name-btn", function() {
    var name = $(this)
      .closest("td")
      .find("input")
      .val();
    var id = $(this)
      .closest("td")
      .find("input")
      .data("id");

    $.post("/ship/custom_name", { name: name, id: id }, function() {
      load_station_tab("#my_ships");
    });
  });

  // Upgrade Ship Btn AJAX
  $(".station-card").on("click", ".upgrade-ship-modal-btn", function() {
    $.get("/ship/upgrade_modal", function(data) {
      $(data)
        .appendTo("#app-container")
        .modal("show");
    });
  });

  // Close Upgrade Ship Modal
  $("#app-container").on("hidden.bs.modal", "#ship-upgrade-modal", function() {
    $(this).remove();
  });

  // Upgrade Ship Btn AJAX
  $("#app-container").on("click", ".upgrade-ship-btn", function() {
    var button = $(this);
    var html = button.html();

    loading_animation(button);
    $.post("/ship/upgrade", function(data) {
      setTimeout(function() {
        button.closest(".modal").modal("hide");
      }, 250);
      load_station_tab("#active_ship");
    }).fail(function(data) {
      if (data.responseJSON.error_message) {
        $.notify(data.responseJSON.error_message, { style: "alert" });
      }
      button.html(html);
    });
  });
});
