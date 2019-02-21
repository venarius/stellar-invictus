$( document ).on('turbolinks:load', function() {

  gameLayoutResize(true);
  
  $(window).resize(function(){
    gameLayoutResize();
  });
    
  
  $('.mobile-menu-open-btn').on('click', function() {
    $('body').css('padding-bottom', '0');
    $('.navbar.main-navbar').fadeIn("fast", function() {
      $('#app-container').fadeOut("fast");
      $('.mobile-nav').fadeOut("fast");
    });
  });
  
  $('.mobile-menu-close-btn').on('click', function() {
    $('body').css('padding-bottom', '50px');
    $('#app-container').fadeIn("fast", function() {
      $('.mobile-nav').fadeIn("fast");
      $('.navbar.main-navbar').fadeOut("fast");
    });
  });
  
  $('.mobile-menu-chat-btn').on('click', function() {
    if ($(this).hasClass('active')) {
      $('.chat-card .collapse').collapse('hide');
      $(this).removeClass('active');
    } else {
      $('.chat-card .collapse').collapse('show');
      $(this).addClass('active');
    }
  });
  
  $('#app-container').on('click', '.toggle-mobile-info', function() {
    if ($(window).width() <= 767) {
      if ($('.mobile-player-info').css('top') == "-55px") {
        $('.mobile-player-info').css('top', '-1px');
        $('#app-container').css('padding-top', '105px');
      } else {
        $('.mobile-player-info').css('top', '-55px');
        $('#app-container').css('padding-top', '50px');
      }
    }
  });
  
  $('.mobile-menu-nav-btn').on('click', function() {
    Turbolinks.visit($(this).data('path'));
  });
  
});

var mobile = false;
function gameLayoutResize(hard) {
  if (($(window).width() <= 767 && mobile == false) || ($(window).width() <= 767 && hard)) {
    gameLayoutMobile();
    mobile = true;
  } else if (($(window).width() > 767 && mobile == true) || ($(window).width() > 767 && hard)) {
    gameLayoutDesktop();
    mobile = false;
  }
}

function gameLayoutMobile() {
  $('.chat-card').insertAfter('.system-card');
  $('.game-card-row .col-lg-4').insertAfter('.game-card-row .col-lg-8');
}

function gameLayoutDesktop() {
  $('.chat-card').insertAfter('.ship-card');
  $('.game-card-row .col-lg-8').insertAfter('.game-card-row .col-lg-4');
}