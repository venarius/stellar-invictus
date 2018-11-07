$( document ).on('turbolinks:load', function() {
  $('#app-container').on('click', '.mine-asteroid-btn', function(e) {
    e.preventDefault();
    var id = $(this).data('id');
    $.post("/asteroid/mine", {id: id}, function(data) {
      remove_target();
      $('.enemy-space-ship').empty().append("<img src='/assets/objects/asteroid.png'></img>");
      $('.enemy-space-ship').next().first().append("<span>NAME: "+data.name+"</span><br><span class='asteroid-resources'>AMOUNT: "+data.resources+"</span>");
    });
  });
});

function update_asteroid_resources(resources) {
  if ($('.asteroid-resources').length) {
    $('.asteroid-resources').empty().append("AMOUNT: " + resources);
  }
}