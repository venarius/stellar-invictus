$( document ).on('turbolinks:load', function() {
  // Equipment Info AJAX
  $('#app-container').on('click', '.equipment-info', function(e) {
    e.preventDefault();
    var loader = $(this).data('loader');
    
    $.get('equipment/info', {loader: loader}, function(data) {
      $(data).appendTo('#app-container').modal('show');
    });
  });
  
  // Close Equipment Info
  $('#app-container').on('hidden.bs.modal', '#equipment-info-modal', function () {
    $(this).remove();
  })
});

// ##################
// Equipment Manager
// ##################

var main_equipment_sortable;
var utility_equipment_sortable;
var list_equipment_sortable;

function sort_equipment_card() {
  
  if ($('.list-equipment-card').length) {
    
    after_change_simple();
    
    set_equipment_draggables();
    
    $('#main-equipment-sortable').sortable({
      placeholder: 'col-12 equipment-placeholder mt-5px',
      connectWith: "#list-equipment-sortable, #utility-equipment-sortable",
      helper: "clone",
      update: function() {
        after_change();
      },
      change: function( event, ui ) {
        update_placeholder(event, ui);
      }
    });
    
    $('#utility-equipment-sortable').sortable({
      placeholder: 'col-12 equipment-placeholder mt-5px',
      connectWith: "#main-equipment-sortable, #list-equipment-sortable",
      helper: "clone",
      update: function() {
        after_change();
      },
      change: function( event, ui ) {
        update_placeholder(event, ui);
      }
    });
    
    $('#list-equipment-sortable').sortable({
      placeholder: 'col-md-4 equipment-placeholder mt-5px',
      helper: 'clone',
      opacity: 0.75,
      appendTo: $('#ship-equipment'),
      cursor: "move",
      scroll: false,
      connectWith: "#main-equipment-sortable, #utility-equipment-sortable",
      change: function( event, ui ) {
        update_placeholder(event, ui);
      }
    });
    
  }
  
}

function update_placeholder(event,ui) {
  if (ui.placeholder.parent().attr('id') == "utility-equipment-sortable" || ui.placeholder.parent().attr('id') == "main-equipment-sortable") {
    ui.placeholder.removeClass('col-md-4').addClass('col-12');
  } else {
    ui.placeholder.removeClass('col-12').addClass('col-md-4');
  }
}

function after_change_simple() {
  $('#main-equipment-sortable, #utility-equipment-sortable').children('.col-md-4').each(function() {
    $(this).removeClass('col-md-4').addClass('col-md-12');
  });
  
  $('#list-equipment-sortable').children('.col-md-12').each(function() {
    $(this).removeClass('col-md-12').addClass('col-md-4');
  })
}

function set_equipment_draggables() {
  // Set Variables
  main_equipment_sortable = $('#main-equipment-sortable').html();
  utility_equipment_sortable = $('#utility-equipment-sortable').html();
  list_equipment_sortable = $('#list-equipment-sortable').html();
}

function reset_equipment_draggables() {
  
  if ($('.list-equipment-card').length) {
    $('#main-equipment-sortable').html(main_equipment_sortable);
    $('#utility-equipment-sortable').html(utility_equipment_sortable);
    $('#list-equipment-sortable').html(list_equipment_sortable); 
  }
}

function after_change() {
  $('#main-equipment-sortable, #utility-equipment-sortable').children('.col-md-4').each(function() {
    $(this).removeClass('col-md-4').addClass('col-md-12');
  });
  
  $('#list-equipment-sortable').children('.col-md-12').each(function() {
    $(this).removeClass('col-md-12').addClass('col-md-4');
  });
  
  var main_ids = []
  var utility_ids = []
  
  // Get all ids of equipped items
  $('#utility-equipment-sortable').children('.col-md-12').each(function() {
    utility_ids.push($(this).data('id'));
  });
  $('#main-equipment-sortable').children('.col-md-12').each(function() {
    main_ids.push($(this).data('id'));
  });
  
  $.post('equipment/update', {ids: {main: main_ids, utility: utility_ids}}, function(data) {
    $('#storage-display').text(data.storage);
    $('#defense-display').text(data.defense);
    $('#align-display').text(data.align);
    $('#target-display').text(data.target);
    set_equipment_draggables();
    refresh_player_info();
  }).fail(function(data) {if (data.responseJSON.error_message) { $.notify(data.responseJSON.error_message, {style: 'alert'}); } reset_equipment_draggables();});
}