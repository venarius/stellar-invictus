$( document ).on('turbolinks:load', function() {
  // Show info on player AJAX
  $('#app-container').on('click', '.player-modal' ,function(e){
    e.preventDefault(); 
    if ($(this).data( "id" )) {
      $.get( "user/info/" + $(this).data( "id" ), function( data ) {
        $('body').append(data);
        $('#player-show-modal').modal('show');
      });
    }
  });
  
  // Add as friend AJAX
  $('body').on('click', '.add-as-friend-btn', function(e){
    e.preventDefault(); 
    var id = $(this).data('id');
    $.post('friends/add_friend', {id: id}, function() {
      $('#player-show-modal').modal('hide');
    });
  });
  
  // Remove modal if close button is clicked
  $('body').on('hidden.bs.modal', '#player-show-modal', function () {
    $(this).remove();
  });
});