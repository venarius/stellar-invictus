$( document ).on('turbolinks:load', function() {
  // Show Inventory Modal AJAX
  $('#inventory-modal').on('shown.bs.modal', function () {
    $('#inventory-modal-body').empty().append("<div class='text-center'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
    $.get('/ship/cargohold', function(data){
      $('#inventory-modal-body').empty().append(data);
    });
  })
  $('#inventory-modal').on('hidden.bs.modal', function () {
    $('#inventory-modal-body').empty();
  })
  
  // Eject Cargo Btn AJAX
  $('#inventory-modal').on('click', '.eject-cargo-btn', function(e) {
    e.preventDefault();
    var amount = $(this).closest('.input-group').find('.eject-input').val();
    var loader = $(this).data('loader');
    var button = $(this);
    
    $.post('/ship/eject_cargo', {loader: loader, amount: amount}, function() {
      $('#inventory-modal').modal('hide');
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
});