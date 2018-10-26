$( document ).on('turbolinks:load', function() {
    $('.avatar-selector').slick({
      centerMode: true,
      centerPadding: '0px',
      slidesToShow: 3,
      responsive: [
        {
          breakpoint: 990,
          settings: {
            arrows: false,
            centerPadding: '5px',
            centerMode: true,
            slidesToShow: 3
          }
        },
        {
          breakpoint: 767,
          settings: {
            arrows: true,
            centerMode: true,
            centerPadding: '10px',
            slidesToShow: 3
          }
        }
      ]
    });
});