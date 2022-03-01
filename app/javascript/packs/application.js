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

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);

import 'bootstrap';
import 'scripts/tickets';
import 'scripts/replies';

Rails.start();
$('.select2').select2({ width: '100%' });

$(document).on('show.bs.modal	', function(e) {
  console.log("hello :)")
  $(e.target).find('select.select2:not(.select2-container)').select2({ width: '100%' })
  $(e.target).find('select.select2-tags:not(.select2-container)').select2({ tags: true, width: '100%', placeholder: 'Select or enter your own item' })
});