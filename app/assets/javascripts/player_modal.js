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
  
  // Remove modal if close button is clicked
  $('#player-show-modal').on('hidden.bs.modal', function () {
    var modal = $(this).closest('.modal')
    modal.modal('hide');
    setTimeout(function(){
      modal.remove();
    }, 1000);
  });
});