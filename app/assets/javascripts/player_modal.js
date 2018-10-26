$( document ).on('turbolinks:load', function() {
  $(document.body).on('click', '.player-modal' ,function(e){
    e.preventDefault(); 
    if ($(this).data( "id" )) {
      $.get( "user/info/" + $(this).data( "id" ), function( data ) {
        $('body').append(data);
        $('#player-show-modal').modal('show');
      });
    }
  });
  $(document.body).on('click', '#player-show-modal-close' ,function(){
    var modal = $(this).closest('.modal')
    modal.modal('hide');
    setTimeout(function(){
      modal.remove();
    }, 1000);
  });
});