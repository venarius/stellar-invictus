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
    
    // Cookie getter
    if ($('#collapse-chat').length) {
      var type = Cookies.get('collapse-chat');
      if (type == 'hidden') {
        $('#collapse-chat').removeClass('show');
        $('#collapse-chat').prev('.card-header').find('.fa-arrow-down').removeClass('fa-arrow-down').addClass('fa-arrow-right');
      }
    }

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
    
    
    // Remove field with errors on keyup
    $( "input" ).keyup(function() {
        $(this).closest('.field_with_errors').removeClass('field_with_errors');
    });
    
    // Smooth alert slides
    $(".alert").hide();
    $(".alert").slideDown(500);
    $(".alert").delay(3000).slideUp(500);
    
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