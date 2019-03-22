$(document).on("turbolinks:load", function() {
  // Support Ticket Submit Btn AJAX
  $("#support-ticket-submit-btn").on("click", function(e) {
    e.preventDefault();
    var button = $(this);
    var fails = 0;

    // check empty inputs
    button
      .closest(".card")
      .find(".form-control")
      .each(function() {
        if ($(this).val() == "") {
          fails = 1;
          $(this).css("border", "1px solid red");
        }
      });

    if (fails == 0) {
      $.post(
        "support_ticket/create",
        button.closest("form").serialize(),
        function(data) {
          show_error(data.message);
          button
            .closest(".card")
            .find("textarea")
            .val("");
          button
            .closest(".card")
            .find("#ticket_subject")
            .val("");
        }
      );
    }
  });
});
