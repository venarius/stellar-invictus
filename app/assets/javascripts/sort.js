$(document).on("turbolinks:load", function() {
  $("#app-container").on("click", ".sort-btn", function(e) {
    e.preventDefault();
    let column = $(this).data("column");
    let direction = $(this).data("direction");
    let url = $(this).data("url");
    let button = $(this);

    if (column && direction && url) {
      $.get(url, { column: column, direction: direction }, function(data) {
        let table = $(data);
        button.closest("table").replaceWith(table);
        if (direction == "asc") {
          table.find(".sort-btn").each(function() {
            $(this).data("direction", "desc");
          });
        } else {
          table.find(".sort-btn").each(function() {
            $(this).data("direction", "asc");
          });
        }
      });
    }
  });
});
