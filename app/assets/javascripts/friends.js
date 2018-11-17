$( document ).on('turbolinks:load', function() {
  $('.friends-card').on('shown.bs.tab', '.nav-pills a', function (e) {
    var id = $(this).attr('href');
    Cookies.set('friends_tab', id);
  });
  
  // Accept friend request AJAX
  $('.friends-card').on('click', '.accept-friend-request-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    $.post('friends/accept_request', {id: id}, function(data){
      Cookies.set('friends_tab', '#friends');
      Turbolinks.visit(window.location);
    }).error(function(){Turbolinks.visit(window.location);});
  });
  
  // Remove friend AJAX
  $('body').on('click', '.remove-as-friend-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    $.post('friends/remove_friend', {id: id}, function(data){
      Turbolinks.visit(window.location); 
    });
  });
  
  // Cookie getter
  if ($('.friends-card').length) {
    var type = Cookies.get('friends_tab');
    if (type) {
      $('.friends-card .nav-pills a').each(function() {
        if ($(this).attr('href') == type) { $(this).tab('show'); }
      });
    }
  }
});

// Alert for new friendrequest
function new_friendrequest() {
  if ($('.friends-card').length) {
    Turbolinks.visit(window.location);
  } else if ($('#navbarColor02').length && !$('#friends-alert').length) {
    $('#navbarColor02 .nav-item').each(function() {
      if ($(this).find('a').attr('href') == "/friends") {
        $(this).find('a').append("<span class='badge badge-danger' id='friends-alert'><i class='fa fa-exclamation'></i></span>")
      }
    });
  }
}