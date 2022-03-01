// // Brimir is a helpdesk system to handle email support requests.
// // Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
// //
// // This program is free software: you can redistribute it and/or modify
// // it under the terms of the GNU Affero General Public License as published by
// // the Free Software Foundation, either version 3 of the License, or
// // (at your option) any later version.
// //
// // This program is distributed in the hope that it will be useful,
// // but WITHOUT ANY WARRANTY; without even the implied warranty of
// // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// // GNU Affero General Public License for more details.
// //
// // You should have received a copy of the GNU Affero General Public License
// // along with this program.  If not, see <http://www.gnu.org/licenses/>.

// jQuery(function() {
//   // TODO #3 - Explore this, how do canned replies work
//   jQuery('#canned-reply').on('change', function(){
//     var editor = jQuery(this).parents('form#new_reply').find('trix-editor')[0].editor;
//     var url = this.value;
//     if (url) {
//       jQuery.ajax({
//         url: url
//       }).done(function(response) {
//         editor.loadHTML(response.message);
//       });
//     } else {
//       editor.loadHTML('');
//     }
//   });
// });
