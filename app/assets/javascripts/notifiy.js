$(document).ready(function() {
  $.notify.addStyle('alert', {
    html: "<div><i class='fa fa-exclamation-triangle'></i>&nbsp;&nbsp;<span data-notify-text/></div>",
    classes: {
      base: {
        "color": "white",
        "margin-bottom": "10px",
        "background": "rgba(0, 0, 0, 0.75)",
        "border": "1px solid #FF8800",
        "padding": "10px",
        "white-space": "nowrap"
      }
    }
  }); 
  
  $.notify.addStyle('info', {
    html: "<div><i class='fa fa-info'></i>&nbsp;&nbsp;<span data-notify-text/></div>",
    classes: {
      base: {
        "color": "white",
        "margin-bottom": "10px",
        "background": "rgba(0, 0, 0, 0.75)",
        "border": "1px solid #2A9FD6",
        "padding": "10px",
        "white-space": "nowrap"
      }
    }
  });
  
  $.notify.addStyle('success', {
    html: "<div><i class='fa fa-check'></i>&nbsp;&nbsp;<span data-notify-text/></div>",
    classes: {
      base: {
        "color": "white",
        "margin-bottom": "10px",
        "background": "rgba(0, 0, 0, 0.75)",
        "border": "1px solid #77B300",
        "padding": "10px",
        "white-space": "nowrap"
      }
    }
  }); 
});

(function () {

var original = document.title;
var timeout;

window.flashTitle = function (newMsg, howManyTimes) {
    function step() {
        document.title = (document.title == original) ? newMsg : original;

        if (--howManyTimes > 0) {
            timeout = setTimeout(step, 1000);
        };
    };

    howManyTimes = parseInt(howManyTimes);

    if (isNaN(howManyTimes)) {
        howManyTimes = 5;
    };

    cancelFlashTitle(timeout);
    step();
};

window.cancelFlashTitle = function () {
    clearTimeout(timeout);
    document.title = original;
};

}());