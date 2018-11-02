$( document ).on('turbolinks:load', function() {
  $('#app-container').on('click', '.player-modal' ,function(e){
    e.preventDefault(); 
    if ($(this).data( "id" )) {
      $.get( "user/info/" + $(this).data( "id" ), function( data ) {
        $('body').append(data);
        $('#player-show-modal').modal('show');
      });
    }
  });
  $('#app-container').on('click', '#player-show-modal-close' ,function(){
    var modal = $(this).closest('.modal')
    modal.modal('hide');
    setTimeout(function(){
      modal.remove();
    }, 1000);
  });
});