$( document ).on('turbolinks:load', function() {
  // Equipment Info AJAX
  $('#app-container').on('click', '.ship-info', function(e) {
    e.preventDefault();
    var name = $(this).data('name');
    
    $.get('ship/info', {name: name}, function(data) {
      $(data).appendTo('#app-container').modal('show');
    });
  });
  
  // Close Equipment Info
  $('#app-container').on('hidden.bs.modal', '#ship-info-modal', function () {
    $(this).remove();
  })
});