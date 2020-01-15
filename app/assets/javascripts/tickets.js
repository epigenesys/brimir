// Brimir is a helpdesk system to handle email support requests.
// Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

jQuery(function() {

  // TODO #1 - Make ajax modal style
  jQuery('[data-assignee-id]').click(function(e) {
    e.preventDefault();

    var elem = jQuery(this);
    var dialog = jQuery('#change-assignee');
    var options = dialog.find('form select');

    /* set ticket id */
    dialog.find('form').attr('action',
        elem.parents('[data-ticket-url]').data('ticket-url'));

    /* select assigned user */
    options.removeAttr('selected');
    options.find('[value="' + elem.data('assignee-id') + '"]').attr('selected', 'selected');

      /* show the dialog */
    dialog.foundation('reveal','open');

  });

  // TODO #2 - Do we need the add label button to be a modal anymore?
  jQuery('.select2-create').select2({
    width: 'resolve',
    createSearchChoicePosition: 'bottom',
    createSearchChoice: function(term, data) {
      return { id:term, text:term };
    },
    ajax: {
      url: '/labels.json',
      dataType: 'json',
      data: function (term, page) {
        return {
          q: term
        };
      },
      results: function (data) {
        return { results: data };
      }
    }
  });

  // TODO #3 - Explore this, how do canned replies work
  jQuery('#canned-reply').on('change', function(){
    var editor = jQuery(this).parents('form#new_reply').find('trix-editor')[0].editor;
    var url = this.value;
    if (url) {
      jQuery.ajax({
        url: url
      }).done(function(response) {
        editor.loadHTML(response.message);
      });
    } else {
      editor.loadHTML('');
    }
  });

  // TODO #4 - Update locking, maybe move it to a websocket connection. Has a
  //           higher upfront cost, but no need for re-hitting endpoint)
  if(jQuery('[data-lock-path]').length > 0) {

    function keepLock() {
      jQuery.ajax({
        url: jQuery('[data-lock-path]').data('lock-path'),
        type: 'post'
      });
    }
    keepLock();
    /* renew lock every 4 minutes */
    setInterval(keepLock, 1000 * 60 * 4);
  }
});
