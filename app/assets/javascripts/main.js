document.addEventListener("turbolinks:before-cache", function() {
  $('.modal').modal('hide');
  if ($('.warp-card').length) {
    $('.warp-card').remove();
  }
  $('table tbody').empty();
  $('.alert').remove();
  $('.speech-bubble').remove();
  $('.station-card').find('.tab-pane.fade.active.show').html("<div class='text-center mt-5px'><i class='fa fa-spinner fa-spin fa-2x'></i></div>");
})


var captchaCheck = false;
$( document ).on('turbolinks:load', function() {
    // HELPERS
    // Collapsing arrows
    $(document).on('hide.bs.collapse', '.collapse', function (event) {
        $(event.target).prev('.card-header').find('.fa-arrow-down').removeClass('fa-arrow-down').addClass('fa-arrow-right');
        Cookies.set($(event.target).attr('id'), 'hidden');
    });
    $(document).on('show.bs.collapse', '.collapse', function (event) {
        $(event.target).prev('.card-header').find('.fa-arrow-right').removeClass('fa-arrow-right').addClass('fa-arrow-down');
        Cookies.set($(event.target).attr('id'), 'shown');
    });
    
    // Loading Button
    $('.btn-load').on('click', function() {
        if ($('.field_with_errors').length == 0 && $(this).is("button")) {
            var width = $(this).width();
            $(this).children('span').remove();
            $(this).children('.fas').removeClass('fa-arrow-right').addClass('fa-spinner fa-spin');
            $(this).width(width);
            $(this).closest('form').submit();   
        } else if ($(this).is("a")) {
            var width = $(this).width();
            $(this).children('span').remove();
            $(this).children('.fas').removeClass('fa-arrow-right').addClass('fa-spinner fa-spin');
            $(this).width(width);
        }
    });
    
    // Smooth alert slides
    $(".alert").hide().slideDown(500).delay(3000).slideUp(500);
    
    // Remove nojs link
    $('.nav-link').each(function() {
        if ($(this).attr('href') == "/nojs") {
            $(this).attr('href', '/connect')
        }
    });
    if (window.location.pathname == "/nojs") {
        window.location.href = "/connect";
    }
    
    // Set avatar on new registration
    $('#new_user').submit(function(e) {
      e.preventDefault();
      var avatar = $('.slick-current').children('img').attr('id');
      $('#user_avatar').val(avatar);
      $(this).unbind('submit').submit();
    });
    
    // Show Server Time
    if ($('#server_time').length > 0) {
      setServerTime();
      setInterval(function() {
        setServerTime();
      },1000);
    }
    
    // Enable tooltips
    var isMobile = false; //initiate as false
    // device detection
    if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) 
        || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4))) { 
        isMobile = true;
    }

    if (!isMobile) {
      $('body').tooltip({
        selector: '[data-toggle="tooltip"]'
      }); 
    }
    
    // Smooth Scroll to sth
    $('a[href*="#"]')
    // Remove links that don't actually link to anything
    .not('[href="#"]')
    .not('[href="#0"]')
    .click(function(event) {
      // On-page links
      if (
        location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') 
        && 
        location.hostname == this.hostname
      ) {
        // Figure out element to scroll to
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
        // Does a scroll target exist?
        if (target.length) {
          // Only prevent default if animation is actually gonna happen
          event.preventDefault();
          $('html, body').animate({
            scrollTop: target.offset().top
          }, 1000, function() {
            // Callback after animation
            // Must change focus!
            var $target = $(target);
            $target.focus();
            if ($target.is(":focus")) { // Checking if the target was focused
              return false;
            } else {
              $target.attr('tabindex','-1'); // Adding tabindex for elements not focusable
              $target.focus(); // Set focus again
            };
          });
        }
      }
    });
    
    // Disconnect on Logout Btn
    $('#logout-btn').on('click', function() {
      App.appearance.unsubsribe();
    });
    
    // Enable Button after User aggreed to Privacy Policy
    $('#privpolCheck').change(function() {
      if($(this).prop('checked') && $('#tosCheck').prop('checked') && captchaCheck) {
        $('.enlist-btn').prop("disabled", false);
      } else {
        $('.enlist-btn').prop("disabled", true);
      }
    });
    $('#tosCheck').change(function() {
      if($(this).prop('checked') && $('#privpolCheck').prop('checked') && captchaCheck) {
        $('.enlist-btn').prop("disabled", false);
      } else {
        $('.enlist-btn').prop("disabled", true);
      }
    });
    
    // Multilevel Dropdowns
    $('.station-card').on('click', '.dropdown-menu a.dropdown-toggle', function(e) {
      if (!$(this).next().hasClass('show')) {
        $(this).parents('.dropdown-menu').first().find('.show').removeClass("show");
      }
      var $subMenu = $(this).next(".dropdown-menu");
      $subMenu.toggleClass('show');
    
    
      $(this).parents('li.nav-item.dropdown.show').on('hidden.bs.dropdown', function(e) {
        $('.dropdown-submenu .show').removeClass("show");
      });
    
    
      return false;
    });
});

// Time Functions
function calcTime(offset) {
    var d = new Date();
    var utc = d.getTime() + (d.getTimezoneOffset() * 60000);
    var nd = new Date(utc + (3600000*offset));
    return nd
}
function addZero(i) {
  if (i < 10) { i = "0" + i; }
  return i;
}
function setServerTime() {
  var dt = calcTime('0');
  var time = addZero(dt.getHours()) + ":" + addZero(dt.getMinutes()) + ":" + addZero(dt.getSeconds());
  $('#server_time').html("Server Time: " + time);
}

// Refresh player info
function refresh_player_info() {
  if ($('.player-info-card').length) {
    $.get("/game/player_info", function(data) {
      $('.player-info-card').empty().append(data);
    })
  }
}

// Show custom error
function show_error(error_message) {
  var alert = "<p class='alert alert-warning'>"+error_message+"</p>"
  $(alert).prependTo('#app-container').hide().slideDown(500).delay(3000).slideUp(500);
}

// Loading animation
function loading_animation(element) {
  var width = element.width();
  element.empty().append("<i class='fa fa-spinner fa-spin'></i>");
  element.width(width);
}

// Server Message
function server_message(text) {
  $.notify(text, { position:"top left", style: 'alert' } );
}

// Captcha Callback
function recaptcha_callback() {
  captchaCheck = true;
  if($('#tosCheck').prop('checked') && $('#privpolCheck').prop('checked') && captchaCheck) {
    $('.enlist-btn').prop("disabled", false);
  }
}