$( document ).on('turbolinks:load', function() {
  
  // Search for Users AJAX
  $('#admin-search-users-search-btn').on('click', function() {
    var search = $('#admin-search-users-input').val();
    
    $('#admin-search-users-search-btn').closest('.tab-pane').find('.results').html("<div class='text-center spinner-modal'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
    $.post('admin/search', {name: search}, function(data) {
      $('#admin-search-users-search-btn').closest('.tab-pane').find('.results').html(data);
    });
  });
  
  // Teleport To Btn
  $('body').on('click', '.admin-teleport-to-btn', function() {
    var id = $(this).data('id');
    var button = $(this);
    
    $.post('admin/teleport', {id: id}, function() {
      button.closest('.modal').modal('hide');
    });
  });
  
  // Admin Ban Btn
  $('body').on('click', '.admin-ban-btn', function() {
    var id = $(this).data('id');
    var button = $(this);
    
    $.post('admin/ban', {id: id, duration: duration}, function() {
      button.closest('.modal').modal('hide');
    });
  });
});