$( document ).on('turbolinks:load', function() {
    // Loading Button
    $('.btn-load').on('click', function() {
        if ($('.field_with_errors').length == 0) {
            var width = $(this).width();
            $(this).children('span').remove();
            $(this).children('.fas').removeClass('fa-arrow-right').addClass('fa-spinner fa-spin');
            $(this).width(width);
            $(this).closest('form').submit();   
        }
    });
    
    
    // Remove field with errors on keyup
    $( "input" ).keyup(function() {
        $(this).closest('.field_with_errors').removeClass('field_with_errors');
    });
});