$( document ).on('turbolinks:load', function() {
  // Ajax for cargo inventory
  $('#app-container').on('click', '.open-container-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    $.post('structure/open_container', {id: id}, function(data) {
      $('#app-container').append(data);
      $('#cargocontainer-modal').modal('show');
    });
  });
  
  // Remove modal if close button is clicked
  $('#cargocontainer-modal').on('hidden.bs.modal', function () {
    $(this).remove();
  });
});