$( document ).on('turbolinks:load', function() {
    // Loading Button
    $('.btn-load').on('click', function() {
        if ($('.field_with_errors').length == 0 && $(this).is("button")) {
            var width = $(this).width();
            $(this).children('span').remove();
            $(this).children('.fas').removeClass('fa-arrow-right').addClass('fa-spinner fa-spin');
            $(this).width(width);
            $(this).closest('form').submit();   
        } else if ($(this).is("a")) {
            var width = $(this).width();
            $(this).children('span').remove();
            $(this).children('.fas').removeClass('fa-arrow-right').addClass('fa-spinner fa-spin');
            $(this).width(width);
        }
    });
    
    
    // Remove field with errors on keyup
    $( "input" ).keyup(function() {
        $(this).closest('.field_with_errors').removeClass('field_with_errors');
    });
    
    // Smooth alert slides
    $(".alert").hide();
    $(".alert").slideDown(500);
    $(".alert").delay(3000).slideUp(500);
    
    // Remove nojs link
    $('.nav-link').each(function() {
        if ($(this).attr('href') == "/nojs") {
            $(this).attr('href', '/connect')
        }
    });
    if (window.location.pathname == "/nojs") {
        window.location.href = "/connect";
    }
});