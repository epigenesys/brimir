/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import Rails from "@rails/ujs";

window.jQuery = jQuery
window.$ = $

require("trix");
require("@rails/actiontext");
require("select2");

import 'bootstrap';

Rails.start();
$('.select2').select2({ width: '100%' });

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