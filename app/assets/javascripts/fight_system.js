// Remove target if cached
$(document).ready(function() {
  remove_target();
});

$(document).on("turbolinks:load", function() {
  // Target player if clicked AJAX
  $("#app-container").on("click", ".target-player-btn", function(e) {
    e.preventDefault();
    var id = $(this).data("id");
    var button = $(this);

    $.post("ship/target", { id: id }, function(data) {
      if ($(".enemy-space-ship").length) {
        remove_target();
        animation_target_counter(data.time);
        button_target_counter(button, data.time);
      }
    });
  });

  // Untarget player if clicked AJAX
  $(".ship-card").on("click", ".untarget-player-btn", function(e) {
    id = $(this).data("id");
    $.post("ship/untarget", { id: id }, function() {
      remove_target();
    });
  });

  // Use Equipment AJAX
  $(".ship-card").on("click", ".use-equipment-btn", function(e) {
    e.preventDefault();
    let button = $(this);
    id = $(this).data("id");
    $.post("equipment/switch", { id: id }, function(data) {
      button.tooltip("dispose");
      if (data && (data.type == "Weapon" || data.type == "Warp Disruptor")) {
        if (button.hasClass("btn-outline-secondary")) {
          if (data.type == "Weapon") {
            button
              .removeClass("btn-outline-secondary")
              .addClass("btn-outline-danger");
          } else if (data.type == "Warp Disruptor") {
            button
              .removeClass("btn-outline-secondary")
              .addClass("btn-outline-warning");
          }
        } else {
          button
            .removeClass("btn-outline-danger btn-outline-warning")
            .addClass("btn-outline-flash-danger");
          setTimeout(function() {
            button
              .removeClass("btn-outline-flash-danger")
              .addClass("btn-outline-secondary");
          }, 1000);
        }
      } else if (data.type == "Repair Bot" || data.type == "Repair Beam") {
        if (button.hasClass("btn-outline-secondary")) {
          button
            .removeClass("btn-outline-secondary")
            .addClass("btn-outline-success");
        } else {
          button
            .removeClass("btn-outline-success")
            .addClass("btn-outline-flash-success");
          setTimeout(function() {
            button
              .removeClass("btn-outline-flash-success")
              .addClass("btn-outline-secondary");
          }, 1000);
        }
      }
    });
  });
});

// Reload target info AJAX
function refresh_target_info() {
  if ($(".ship-card").length) {
    $.get("/game/ship_info", function(data) {
      $(".ship-card .card-body").html(data);
      load_ship_info_animations();
    });
  }
}

// Remove flash from player who is untargeting you
function stopping_target(name) {
  if ($(".players-card").length) {
    $(".players-card .players-card-name-td").each(function() {
      if ($(this).html() == name) {
        if (
          $(this)
            .parent()
            .hasClass("attack-flash")
        ) {
          $(this)
            .parent()
            .removeClass("attack-flash");
          $(".ship-card").removeClass("outline-danger");
          return;
        }
        if (
          $(this)
            .parent()
            .hasClass("help-flash")
        ) {
          $(this)
            .parent()
            .removeClass("help-flash");
          return;
        }
        if (
          $(this)
            .parent()
            .hasClass("target-flash")
        ) {
          $(this)
            .parent()
            .removeClass("target-flash");
        }
      }
    });
  }
}

// Add flash to player who is targeting you
function getting_targeted(name) {
  if ($(".players-card").length) {
    $(".players-card .players-card-name-td").each(function() {
      if ($(this).html() == name) {
        if (
          !$(this)
            .parent()
            .hasClass("target-flash")
        ) {
          $(this)
            .parent()
            .addClass("target-flash");
        }
      }
    });
  }
}

// Add flash to player who is attacking you
function getting_attacked(name) {
  if ($(".players-card").length) {
    $(".players-card .players-card-name-td").each(function() {
      if ($(this).html() == name) {
        if (
          $(this)
            .parent()
            .hasClass("target-flash")
        ) {
          $(this)
            .parent()
            .removeClass("target-flash")
            .addClass("attack-flash");
          return;
        }
        if (
          $(this)
            .parent()
            .hasClass("help-flash")
        ) {
          $(this)
            .parent()
            .removeClass("help-flash")
            .addClass("attack-flash");
        }
      }
    });
  }
}

// Stopping Attack
function stopping_attack(name) {
  if ($(".players-card").length) {
    $(".players-card .players-card-name-td").each(function() {
      if ($(this).html() == name) {
        if (
          $(this)
            .parent()
            .hasClass("attack-flash")
        ) {
          $(this)
            .parent()
            .removeClass("attack-flash")
            .addClass("target-flash");
        }
        if (
          $(this)
            .parent()
            .hasClass("help-flash")
        ) {
          $(this)
            .parent()
            .removeClass("help-flash")
            .addClass("target-flash");
        }
      }
    });
  }
}

// Disable Equipment
function disable_equipment() {
  if ($(".players-card").length) {
    $(".use-equipment-btn").each(function() {
      $(this)
        .removeClass("btn-outline-success")
        .removeClass("btn-outline-danger")
        .addClass("btn-outline-secondary");
    });
  }
}

// Add flash to player who is helping you
function getting_helped(name) {
  if ($(".players-card").length) {
    $(".players-card .players-card-name-td").each(function() {
      if ($(this).html() == name) {
        if (
          $(this)
            .parent()
            .hasClass("target-flash")
        ) {
          $(this)
            .parent()
            .removeClass("target-flash")
            .addClass("help-flash");
        }
        if (
          $(this)
            .parent()
            .hasClass("attack-flash")
        ) {
          $(this)
            .parent()
            .removeClass("attack-flash")
            .addClass("help-flash");
        }
      }
    });
  }
}

// Update own health
var attackBorderTimeout;
function update_health(hp) {
  if ($("#own-ship-health").length) {
    var health = parseInt($("#own-ship-health").text());
    $("#own-ship-health")
      .empty()
      .append(hp);
    if (health <= hp) {
      if (
        !$("#own-ship-health")
          .parent()
          .hasClass("success-flash") &&
        !$("#own-ship-health")
          .parent()
          .hasClass("attack-flash")
      ) {
        $("#own-ship-health")
          .parent()
          .addClass("success-flash");
        setTimeout(function() {
          $("#own-ship-health")
            .parent()
            .removeClass("success-flash");
        }, 1000);
      }
    } else {
      $(".ship-card").addClass("outline-danger");
      clearTimeout(attackBorderTimeout);
      attackBorderTimeout = setTimeout(function() {
        $(".ship-card").removeClass("outline-danger");
      }, 2500);
      if (
        !$("#own-ship-health")
          .parent()
          .hasClass("success-flash") &&
        !$("#own-ship-health")
          .parent()
          .hasClass("attack-flash")
      ) {
        $("#own-ship-health")
          .parent()
          .addClass("attack-flash");
        play_hit();
        player_got_hit();
        flashTitle("Under Attack!", 1);
        setTimeout(function() {
          $("#own-ship-health")
            .parent()
            .removeClass("attack-flash");
        }, 1000);
      }
    }
  } else {
    play_hit();
  }
}

// Update target health
function update_target_health(hp) {
  if ($("#target-ship-health").length) {
    var health = parseInt($("#target-ship-health").text());
    $("#target-ship-health")
      .empty()
      .append(hp);
    if (health <= hp) {
      if (
        !$("#target-ship-health")
          .parent()
          .hasClass("success-flash") &&
        !$("#target-ship-health")
          .parent()
          .hasClass("attack-flash")
      ) {
        $("#target-ship-health")
          .parent()
          .addClass("success-flash");
        setTimeout(function() {
          $("#target-ship-health")
            .parent()
            .removeClass("success-flash");
        }, 1000);
      }
    } else {
      if (
        !$("#target-ship-health")
          .parent()
          .hasClass("success-flash") &&
        !$("#target-ship-health")
          .parent()
          .hasClass("attack-flash")
      ) {
        $("#target-ship-health")
          .parent()
          .addClass("attack-flash");
        play_hit();
        enemy_got_hit();
        if (hp <= 0) {
          play_explosion();
        }
        setTimeout(function() {
          $("#target-ship-health")
            .parent()
            .removeClass("attack-flash");
        }, 1000);
      }
    }
  }
}

// Remove target
function remove_target() {
  if ($(".enemy-space-ship").length) {
    $(".enemy-space-ship").css("border", "0");
    $(".enemy-space-ship")
      .next()
      .empty();
    $(".enemy-space-ship")
      .next()
      .next()
      .empty();
  }
  // Remove mining interval
  if (typeof mining_interval !== "undefined") {
    clearInterval(mining_interval);
    mining_interval = false;
  }
  mining_progress = 0;
  // Remove target interval
  if (typeof target_interval !== "undefined") {
    clearInterval(target_interval);
  }
  // Remove npc target interval
  if (typeof npc_target_interval !== "undefined") {
    clearInterval(npc_target_interval);
  }
  if (typeof animation_remove_target !== "undefined") {
    animation_remove_target();
    stop_mining();
  }
}

// Show died modal with text
function show_died_modal(text_message) {
  $("#died-modal-body")
    .empty()
    .append(text_message);
  $("#died-modal").modal("show");
}

// Button Target Counter
var button_target_counter_interval;
function button_target_counter(button, time) {
  clearInterval(button_target_counter_interval);

  $(".players-card")
    .find(".target-player-btn")
    .each(function() {
      $(this).html("<i class='fa fa-crosshairs'></i>");
    });
  $(".players-card")
    .find(".target-npc-btn")
    .each(function() {
      $(this).html("<i class='fa fa-crosshairs'></i>");
    });

  button.html(time);
  button_target_counter_interval = setInterval(function() {
    time = time - 1;
    button.html(time);
    if (time == 0) {
      clearInterval(button_target_counter_interval);
      button.html("<i class='fa fa-crosshairs'></i>");
    }
  }, 1000);
}
