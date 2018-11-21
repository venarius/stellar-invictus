$( document ).on('turbolinks:load', function() {
  // On Invite Modal Close
  $('#app-container').on('hidden.bs.modal', '.invited-to-fleet-modal', function(e) {
    $(this).remove();
  });
  
  // Invite to Fleet AJAX
  $('body').on('click', '.invite-to-fleet-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    if (id) {
      $.post('fleet/invite', {id: id}, function(data){
        Cookies.set('chat_tab', '#chatroom-' + id)
        Cookies.set('collapse-chat', 'shown')
        Turbolinks.visit(window.location);  
      });
    }
  });
  
  // Accept invite AJAX
  $('#app-container').on('click', '.accept-fleet-invite-btn', function(e){
    e.preventDefault();
    var id = $(this).data('id');
    if (id) {
      $.post('fleet/accept_invite', {id: id}, function(data){
        Cookies.set('chat_tab', '#chatroom-' + id)
        Cookies.set('collapse-chat', 'shown')
        Turbolinks.visit(window.location);  
      });
    }
  });
});

// Invited to Fleet Modal
function invited_to_fleet(data) {
  var modal = data
  $(modal).appendTo('#app-container').modal('show');
}