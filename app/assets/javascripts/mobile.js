$( document ).on('turbolinks:load', function() {

  if (window.location.pathname == "/game") {
    
    gameLayoutResize();
    
    $(window).resize(function(){
      gameLayoutResize();
    });
    
  }
  
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
  
  $('.mobile-menu-nav-btn').on('click', function() {
    Turbolinks.visit($(this).data('path'));
  });
  
});

function gameLayoutResize() {
  if ($(window).width() <= 767) {
    gameLayoutMobile();
  } else if ($(window).width() > 767) {
    gameLayoutDesktop();
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