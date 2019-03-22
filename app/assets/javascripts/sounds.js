$(document).on("turbolinks:load", function() {
  // Sound toggle
  $(".sound-toggle-btn").on("click", function(e) {
    e.preventDefault();
    var mute = Cookies.get("sound_muted");
    var button = $(this).find("i");

    if (mute == null) {
      Cookies.set("sound_muted", "n");
      button.removeClass("fa-volume-mute").addClass("fa-volume-up");
    } else {
      if (mute == "n") {
        button.removeClass("fa-volume-up").addClass("fa-volume-mute");
        Cookies.set("sound_muted", "y");
      } else {
        button.removeClass("fa-volume-mute").addClass("fa-volume-up");
        Cookies.set("sound_muted", "n");
      }
    }
  });

  // Cookie getter
  var mute = Cookies.get("sound_muted");
  if (mute && mute == "n") {
    $(".sound-toggle-btn i")
      .removeClass("fa-volume-mute")
      .addClass("fa-volume-up");
  }
});

// Play Hit
function play_hit() {
  var mute = Cookies.get("sound_muted");
  if (mute && mute == "n") {
    var audio = document.createElement("audio");
    audio.src = window.location.origin + "/sounds/hit.mp3";
    audio.volume = 0.035;
    audio.play();
  }
}

// Play Explosion
function play_explosion() {
  var mute = Cookies.get("sound_muted");
  if (mute && mute == "n") {
    var audio = document.createElement("audio");
    audio.src = window.location.origin + "/sounds/explosion.mp3";
    audio.volume = 0.05;
    audio.play();
  }
}
