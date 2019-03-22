$(document).on("turbolinks:load", function() {
  $(".friends-card").on("shown.bs.tab", ".nav-pills a", function(e) {
    var id = $(this).data("target");
    Cookies.set("friends_tab", id);
  });

  // Accept friend request AJAX
  $(".friends-card").on("click", ".accept-friend-request-btn", function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    $.post("friends/accept_request", { id: id }, function(data) {
      Cookies.set("friends_tab", "#friends");
      Turbolinks.visit(window.location);
    }).fail(function() {
      Turbolinks.visit(window.location);
    });
  });

  // Remove friend AJAX
  $("body").on("click", ".remove-as-friend-btn", function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    $.post("friends/remove_friend", { id: id }, function(data) {
      Turbolinks.visit(window.location);
    });
  });

  // Cookie getter
  if ($(".friends-card").length) {
    var type = Cookies.get("friends_tab");
    if (type) {
      $(".friends-card .nav-pills a").each(function() {
        if ($(this).data("target") == type) {
          $(this).tab("show");
        }
      });
    }
  }

  // Search for Users AJAX
  $("#add-friend-modal").on("click", "#add-friend-modal-search-btn", function(
    e
  ) {
    if ($("#add-friend-modal-input").val()) {
      $("#add-friend-modal-input").css("border", "1px solid grey");
      $("#add-friend-modal-result")
        .empty()
        .append(
          "<div class='text-center spinner-modal'><i class='fa fa-spinner fa-spin fa-2x'></i></div>"
        );
      $.post(
        "friends/search",
        { name: $("#add-friend-modal-input").val() },
        function(data) {
          $("#add-friend-modal-body")
            .find(".spinner-modal")
            .remove();
          $("#add-friend-modal-result")
            .empty()
            .append(data);
        }
      );
    } else {
      $("#add-friend-modal-input").css("border", "1px solid red");
    }
  });

  // Search Add as friend AJAX
  $("#add-friend-modal").on("click", ".search-add-as-friend-btn", function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    $.post("friends/add_friend", { id: id }, function() {
      $("#add-friend-modal").modal("hide");
      Turbolinks.visit(window.location);
    });
  });

  // Search Remove friend AJAX
  $("#add-friend-modal").on("click", ".search-remove-as-friend-btn", function(
    e
  ) {
    e.preventDefault();
    var id = $(this).data("id");
    $.post("friends/remove_friend", { id: id }, function(data) {
      $("#add-friend-modal").modal("hide");
      Turbolinks.visit(window.location);
    });
  });

  // Search if pressed enter on input field
  $("#add-friend-modal-input").on("keyup", function(e) {
    if (e.keyCode == 13) {
      $("#add-friend-modal-search-btn").click();
    }
  });

  // Search for User Modal on Hidden
  $("#add-friend-modal").on("hidden.bs.modal", function() {
    $("#add-friend-modal-result").empty();
    $("#add-friend-modal-input").val("");
  });
});

// Alert for new friendrequest
function new_friendrequest() {
  if ($(".friends-card").length) {
    Turbolinks.visit(window.location);
  } else if ($("#navbarColor02").length && !$("#friends-alert").length) {
    $("#navbarColor02 .nav-item").each(function() {
      if (
        $(this)
          .find("a")
          .attr("href") == "/friends"
      ) {
        $(this)
          .find("a")
          .append(
            "<span class='badge badge-danger' id='friends-alert'><i class='fa fa-exclamation'></i></span>"
          );
      }
    });
  }
}
