$(document).ready(function(){
  $('.reply-content blockquote').addClass('d-none');
  $('.reply-content blockquote').each((i, element) => {
    var quoteButton = $("<button class='btn btn-secondary'>Open Quote</button>"); 
    quoteButton.on('click', function(e) {
      if($(element).hasClass('d-none')) {
        $(element).removeClass('d-none');
        quoteButton.text('Hide quote');
      } else {
        $(element).addClass('d-none');
        quoteButton.text('Open quote');
      }
    });

    $(element).after(quoteButton);
  });

  $('.split-off-ticket').bind('click', function(e) {
    e.preventDefault();
    
    current_selection = window.getSelection().toString();

    if (current_selection != '') {
      var url = $(this).attr('href') + '.json';
      var data = {
        selected_text: current_selection
      };

      jQuery.ajax({
        url: url,
        type: 'post',
        data: data,
        success: function(result) {
          window.location = result.ticket_path;
        }
      });

      return false;
    }
  });
});