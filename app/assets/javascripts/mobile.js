$( document ).on('turbolinks:load', function() {

  if (window.location.pathname == "/game") {
    
    gameLayoutResize();
    
    $(window).resize(function(){
      gameLayoutResize();
    }); 
  }
  
});

var mobile = false;
function gameLayoutResize() {
  if ($(window).width() <= 767 && mobile == false) {
    gameLayoutMobile();
    mobile = true;
  } else if ($(window).width() > 767 && mobile == true) {
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