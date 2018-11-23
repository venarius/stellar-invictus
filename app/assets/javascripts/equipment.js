var main_equipment_sortable;
var utility_equipment_sortable;
var list_equipment_sortable;

$( document ).on('turbolinks:load', function() {
  
  if ($('.list-equipment-card').length) {
    
    after_change();
    
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
  
});

function update_placeholder(event,ui) {
  if (ui.placeholder.parent().attr('id') == "utility-equipment-sortable" || ui.placeholder.parent().attr('id') == "main-equipment-sortable") {
    ui.placeholder.removeClass('col-md-4').addClass('col-12');
  } else {
    ui.placeholder.removeClass('col-12').addClass('col-md-4');
  }
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
    $('#power-display').text(data.power);
    $('#storage-display').text(data.storage);
    $('#defense-display').text(data.defense);
    $('#align-display').text(data.align);
    set_equipment_draggables();
    refresh_player_info();
  }).fail(function() {reset_equipment_draggables();});
}