var mining_progress = 0;
var mining_interval;

$( document ).on('turbolinks:load', function() {
  $('#app-container').on('click', '.mine-asteroid-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    $.post("/asteroid/mine", {id: id}, function(data) {
      refresh_target_info();
      if (mining_interval == null || mining_interval == false) {
        mining_interval = setInterval(function() {
          mining_progress = mining_progress + 1;
          $('.mining-progress').css('width', mining_progress + "%");
        }, 300)
      }
    });
  });
  
  $('#app-container').on('click', '.stop-mining-btn', function(e) {
    e.preventDefault();
    $.post("/asteroid/stop_mine", function(data) {
      remove_target();
    });
  });
});

function update_asteroid_resources(resources) {
  if ($('.asteroid-resources').length) {
    $('.asteroid-resources').empty().append(resources);
  }
  mining_progress = 0;
}