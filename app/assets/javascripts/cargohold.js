$( document ).on('turbolinks:load', function() {
  $('#inventory-modal').on('shown.bs.modal', function () {
    $('#inventory-modal-body').empty().append("<div class='text-center'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
    $.get('/ship/cargohold', function(data){
      $('#inventory-modal-body').empty().append(data);
    });
  })
  $('#inventory-modal').on('hidden.bs.modal', function () {
    $('#inventory-modal-body').empty();
  })
  
  $('#inventory-modal').on('click', '.eject-cargo-btn', function(e) {
    e.preventDefault();
    var loader = $(this).data('loader');
    $.post('/ship/eject_cargo', {loader: loader}, function() {
      $('#inventory-modal').modal('hide');
    });
  });
});