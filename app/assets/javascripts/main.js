document.addEventListener("turbolinks:before-cache", function() {
  $('.modal').modal('hide');
  if ($('.warp-card').length) {
    $('.warp-card').remove();
  }
  $('table tbody').empty();
  $('.alert').remove();
})

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
    $('body').tooltip({
      selector: '[data-toggle="tooltip"]'
    });
    
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
      if(this.checked) {
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