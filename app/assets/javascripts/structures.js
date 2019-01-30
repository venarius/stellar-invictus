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
  
  // Ajax for cargo attack
  $('#app-container').on('click', '.attack-container-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    var button = $(this)
    $.post('structure/attack', {id: id}, function(data) {button.tooltip('dispose');});
  });
  
  // Remove cargocontainer modal if close button is clicked
  $('#app-container').on('hidden.bs.modal', '#cargocontainer-modal', function () {
    $(this).remove();
  });
  
  // Load item from cargo container AJAX
  $('#app-container').on('click', '.cargocontainer-pickup-cargo-btn', function(e) {
    e.preventDefault();
    var button = $(this);
    var loader = $(this).data('loader');
    var id = $(this).data('id');
    
    $.post('structure/pickup_cargo', {id: id, loader: loader}, function(data) {
      if (data.amount) {
        button.parent().parent().find('.amount').empty().append(data.amount + "&times;");
      } else {
        button.parent().parent().remove(); 
      }
      refresh_player_info();
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
  
  // Load all items from cargo container AJAX
  $('#app-container').on('click', '.cargocontainer-pickup-all-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    $.post('structure/pickup_cargo', {id: id}, function(data) {
      $('#cargocontainer-modal').modal('hide');
      refresh_player_info();
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
});