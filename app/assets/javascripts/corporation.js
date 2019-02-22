$( document ).on('turbolinks:load', function() {
  
  // Load Tab
  if (window.location.pathname == "/corporation" && $('.corporation-card').find('.nav').length) {
    load_corporation_tab($('.corporation-card a.nav-link.active').data('target')); 
  }
  
  // Cookie Setter and Lazy Load
  $('.corporation-card a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    Cookies.set('corporation_tab', $(this).data('target'));
    
    // Lazy Load
    $('.corporation-card a[data-toggle="tab"]').each(function() {
      $($(this).data('target')).empty();
    });
    load_corporation_tab($(this).data('target'));
  });
  
  // Cookie getter
  if ($('.corporation-card').length) {
    var type = Cookies.get('corporation_tab');
    if (type) {
      $('.corporation-card .nav-tabs a').each(function() {
        if ($(this).data('target') == type) { 
          $(this).tab('show'); 
          load_corporation_tab($('.corporation-card a.nav-link.active').data('target'));
        }
      });
    }
  }
  
  // Edit Corporation Motd Btn
  $('.corporation-card').on('click', '#edit-corporation-motd-btn', function() {
    var button = $(this);
    
    if ($('#corporation-motd').find('textarea').length) {
      
      // Save Mode
      var text = $('#corporation-motd-editarea').val();
      $.post('corporation/update_motd', {text: text}, function(data) {
        $('#corporation-motd').css('padding', '1.25rem');
        $('#corporation-motd').html(data.text);
        button.html(data.button_text);
      });
      
    } else {
      
      // Edit Mode
      if ($('#corporation-motd').find('.no-motd-pl').length) {
        $('#corporation-motd').html('...');
      }
      var old = $('#corporation-motd').html();
      $('#corporation-motd').html("<textarea class='form-control' id='corporation-motd-editarea'>"+old+"</textarea>");
      $('#corporation-motd').css('padding', '0');
      $('#corporation-motd-editarea').css('height', '100%');
      button.html("<i class='fa fa-save'></i>") 
      
    }
    
  });
  
  // Edit Coporation Btn
  $('.corporation-card').on('click', '#edit-corporation-btn', function(e) {
    var button = $(this)
    
    if ($('#corporation-form').find('.edit-view').is(":visible")) {
      
      // Save Mode
      var tax = $('#corporation-form').find('input').val();
      var about = $('#corporation-form').find('textarea').val();
      $.post('corporation/update_corporation', {tax: tax, about: about}, function(data) {
        $('#corporation-form').find('.edit-view').css('display', 'none');
        $('#corporation-form').find('.show-view').css('display', 'block');
        $('#corporation-form').find('.show-view-tax').html(data.tax.toFixed(1) + " %");
        $('#corporation-form').find('.show-view-bio').html(data.about);
        button.html(data.button_text);
      });
      
      
    } else {
      
      // Edit Mode
      $('#corporation-form').find('.edit-view').css('display', 'block');
      $('#corporation-form').find('.show-view').css('display', 'none');
      button.html("<i class='fa fa-save'></i>") 
      
    }
  });
  
  // Kick User from Corp Btn 
  $('.corporation-card').on('click', '.corporation-kick-user-btn', function() {
    var button = $(this);
    var result = confirm("Are you sure?");
    
    if (result) {
      $.post('corporation/kick_user', {id: button.data('id')}, function(data) {
        if (data.reload == true) {
          Turbolinks.visit(window.location);
        } else {
          button.closest('tr').remove(); 
        }
      });
    }
  });
  
  // Mote User Btn
  $('.corporation-card').on('click', '.corporation-mote-user-btn', function(e) {
    $.get('corporation/change_rank_modal', {id: $(this).data('id')}, function(data) {
      $(data).appendTo('#app-container').modal('show');
    });
  });
  
  // Mote User Modal Close
  $('#app-container').on('hidden.bs.modal', '#corporation-change-rank-modal', function() {
    $(this).remove();
  });
  
  // Save Mote User Btn
  $('#app-container').on('click', '#corporation-change-rank-modal .corporation-save-mote-user', function() {
    var rank = $('#corporation-change-rank-modal').find(":selected").val();
    var button = $(this);
    
    $.post('corporation/change_rank', {id: button.data('id'), rank: rank}, function(data) {
      button.closest('.modal').modal('hide');
      setTimeout(function(){ load_station_tab('#roster'); }, 250)
    }).fail(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
  
  // Deposit Credits Btn
  $('.corporation-card').on('click', '.corporation-deposit-credits-btn', function(e) {
    var button = $(this);
    var amount = button.closest('.modal').find('input').val();
    
    $.post('corporation/deposit_credits', {amount: amount}, function(data) {
      button.closest('.modal').modal('hide');
      setTimeout(function(){ load_station_tab('#finances'); }, 250)
    }).fail(function(data) {
      button.closest('.modal').find('input').addClass("outline-danger"); 
      if (!button.closest('.modal').find('.error').length) {
        button.closest('.modal').find('.modal-body').after("<span class='color-red text-center mb-3 error'>"+data.responseJSON.error_message+"</span>");
        setTimeout(function() {button.closest('.modal').find('.error').fadeOut("fast", function() {$(this).remove();});}, 1000) 
      }
    });
  });
  
  // Withdraw Credits Btn
  $('.corporation-card').on('click', '.corporation-withdraw-credits-btn', function(e) {
    var button = $(this);
    var amount = button.closest('.modal').find('input').val();
    
    $.post('corporation/withdraw_credits', {amount: amount}, function(data) {
      button.closest('.modal').modal('hide');
      setTimeout(function(){ load_station_tab('#finances'); }, 250)
    }).fail(function(data) {
      button.closest('.modal').find('input').addClass("outline-danger"); 
      if (!button.closest('.modal').find('.error').length) {
        button.closest('.modal').find('.modal-body').after("<span class='color-red text-center mb-3 error'>"+data.responseJSON.error_message+"</span>");
        setTimeout(function() {button.closest('.modal').find('.error').fadeOut("fast", function() {$(this).remove();});}, 1000) 
      }
    });
  });
  
  // Show info on corporation AJAX
  $('body').on('click', '.corporation-modal' , function(e){
    e.preventDefault(); 
    if ($(this).data( "id" )) {
      $.get( "/corporation/info", {id: $(this).data( "id" )}, function( data ) {
        $('body').append(data);
        // Enable Popovers
        $('[data-toggle="popover"]').popover();
        $('#corporation-show-modal').modal('show');
      });
    }
  });
  
  // Remove modal if close button is clicked
  $('body').on('hidden.bs.modal', '#corporation-show-modal', function () {
    $(this).remove();
  });
  
  // Corporation Apply Modal Btn
  $('body').on('click', '.corporation-apply-modal-btn' , function(e){
    e.preventDefault(); 
    if ($(this).data( "id" )) {
      $.get( "/corporation/apply_modal", {id: $(this).data( "id" )}, function( data ) {
        $('body').append(data);
        // Enable Popovers
        $('[data-toggle="popover"]').popover();
        $('#corporation-apply-modal').modal('show');
      });
    }
  });
  
  // Remove modal if close button is clicked
  $('body').on('hidden.bs.modal', '#corporation-apply-modal', function () {
    $(this).remove();
  });
  
  // Corporation Apply Btn
  $('body').on('click', '.corporation-apply-btn' , function(e){
    var text = $(this).closest('.modal').find('textarea').val();
    var id = $(this).data('id');
    var button = $(this);
    
    $.post('/corporation/apply', {id: id, text: text}, function(data) {
      button.closest('.modal').modal('hide');
      $.notify(data.message, {style: 'success'});
    }).fail(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
  
  // Corporation Accept Application Btn
  $('.corporation-card').on('click', '.corporation-accept-application-btn', function() {
    var id = $(this).data('id');
    button = $(this);
    
    $.post('corporation/accept_application', {id: id}, function(data) {
      button.closest('.modal').modal('hide');
      $('#corporation-applications-count').html(parseInt($('#corporation-applications-count').html()) - 1);
      setTimeout(function(){ load_station_tab('#applications'); }, 250)
    }).fail(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
  
  // Corporation Reject Application Btn
  $('.corporation-card').on('click', '.corporation-reject-application-btn', function() {
    var id = $(this).data('id');
    button = $(this);
    
    $.post('corporation/reject_application', {id: id}, function(data) {
      button.closest('.modal').modal('hide');
      $('#corporation-applications-count').html(parseInt($('#corporation-applications-count').html()) - 1);
      setTimeout(function(){ load_station_tab('#applications'); }, 250)
    }).fail(function(data) { if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } });
  });
  
  // Corporation Disband Corporation Btn
  $('.corporation-card').on('click', '.corporation-disband-corporation-btn', function() {
    $.post('corporation/disband', function() {
      Turbolinks.visit(window.location);
    });
  });
  
  // Corporation Search Btn
  $('#corporation-search-btn').on('click', function() {
    var search = $(this).closest('.input-group').find('input').val();
    
    $('#corporations-search-body').html("<div class='text-center spinner-modal'><i class='fa fa-spinner fa-spin fa-2x'></i></div>");
    $.post('/corporation/search', {search: search}, function(data) {
      $('#corporations-search-body').html(data);
    });
  });
});

function load_corporation_tab(href) {
  element = $(href);
  element.empty().append("<div class='text-center mt-5px'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
  $.get('/corporation?tab=' + href.substring(1), function(data) {
    element.empty().append(data);
  });
}