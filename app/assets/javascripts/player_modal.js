$( document ).on('turbolinks:load', function() {
  // Show info on player AJAX
  $('#app-container').on('click', '.player-modal' ,function(e){
    e.preventDefault(); 
    if ($(this).data( "id" )) {
      $.get( "user/info/" + $(this).data( "id" ), function( data ) {
        $('body').append(data);
        // Enable Popovers
        $('[data-toggle="popover"]').popover();
        $('#player-show-modal').modal('show');
      });
    }
  });
  
  // Show info on player AJAX (Admin)
  $('#app-container').on('click', '.admin-player-modal' ,function(e){
    e.preventDefault(); 
    if ($(this).data( "id" )) {
      $.get( "user/admin_info/" + $(this).data( "id" ), function( data ) {
        $('body').append(data);
        // Enable Popovers
        $('[data-toggle="popover"]').popover();
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
  
  // Add Bounty Btn
  $('body').on('click', '.add-bounty-btn', function(e) {
    if (!$('#bountyModal').is(':visible')) {
      $('#bountyModal').fadeIn(); 
    } else {
      $('#bountyModal').fadeOut(); 
    }
  });
  
  // Place Bounty AJAX
  $('body').on('click', '#bounty-place-btn', function(e) {
    var amount = $('#bounty-input').val();
    var id = $(this).data('id');
    
    $.post('user/place_bounty', {amount: amount, id: id}, function(data) {
      $('#user-bounty').text(parseInt($('#user-bounty').text()) + parseInt(amount));
      $('#bountyModal').fadeOut();
    }).error(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
  
  // Remove modal if close button is clicked
  $('body').on('hidden.bs.modal', '#player-show-modal', function () {
    $(this).remove();
  });
});