$(document).on("turbolinks:load", function() {
  gameLayoutResize(true);
  getMobileInfo();

  $(window).resize(function() {
    gameLayoutResize();
  });

  $(".mobile-menu-open-btn").on("click", function() {
    $("body").css("padding-bottom", "0");
    $(".navbar.main-navbar").fadeIn("fast", function() {
      $(".mobile-nav").fadeOut("fast", function() {
        $("#app-container").fadeOut("fast");
      });
    });
  });

  $(".mobile-menu-close-btn").on("click", function() {
    $("body").css("padding-bottom", "50px");
    $("#app-container").fadeIn(1, function() {
      $(".mobile-nav").fadeIn(1, function() {
        $(".navbar.main-navbar").fadeOut("fast");
      });
    });
  });

  $("#app-container").on("click", ".toggle-mobile-info", function() {
    if ($(window).width() <= 767) {
      if ($(".mobile-player-info").css("top") == "-55px") {
        Cookies.set("mobile_info", "shown");
        $(".mobile-player-info").css("top", "-1px");
        $("#app-container").css("padding-top", "90px");
      } else {
        Cookies.set("mobile_info", "hidden");
        $(".mobile-player-info").css("top", "-55px");
        $("#app-container").css("padding-top", "35px");
      }
    }
  });

  $(".mobile-menu-nav-btn").on("click", function() {
    Turbolinks.visit($(this).data("path"));
  });
});

var mobile = false;
function gameLayoutResize(hard) {
  if (
    ($(window).width() <= 767 && mobile == false) ||
    ($(window).width() <= 767 && hard)
  ) {
    gameLayoutMobile();
    mobile = true;
  } else if (
    ($(window).width() > 767 && mobile == true) ||
    ($(window).width() > 767 && hard)
  ) {
    gameLayoutDesktop();
    mobile = false;
  }
}

function gameLayoutMobile() {
  $(".chat-card").insertAfter(".system-card.mobile-display-none");
  $(".game-card-row .col-lg-4").insertAfter(".game-card-row .col-lg-8");
}

function gameLayoutDesktop() {
  $(".chat-card").insertAfter(".ship-card");
  $(".game-card-row .col-lg-8").insertAfter(".game-card-row .col-lg-4");
}

function getMobileInfo() {
  if ($(window).width() <= 767) {
    var state = Cookies.get("mobile_info");
    if (state && state == "shown") {
      $(".mobile-player-info").removeClass("transition");
      $("#app-container").removeClass("transition");
      $(".mobile-player-info").css("top", "-1px");
      $("#app-container").css("padding-top", "90px");
      setTimeout(function() {
        $(".mobile-player-info").addClass("transition");
        $("#app-container").addClass("transition");
      }, 400);
    }
  }
}
