(function(jQuery, undefined)
{
	jQuery(function()
	{

		// click apply button
		jQuery('.apply-button').click(function()
		{
			var elm = getElements();
			// Project is not selected
			if (!elm['project_identifier']) {
				message_dialog(msg_project_not_selected, "");
				return;
			}
			jQuery('#confirm-dialog').dialog('open');
		});
		
		// inizialize confirm dialog 
		jQuery('#confirm-dialog').dialog(
		{
			resizable: false,
			modal: true,
			autoOpen: false,
			position: 'center',
			buttons:
			[
				{
					text: label_repository_yes,
					click: function()
					{
						var elm = getElements();		
						var action_name
						if(0 == elm['action']) {
							action_name = 'create' 
						} else {
							action_name = 'delete'
						}

						jQuery('#confirm-dialog').dialog("close");
						jQuery('#running-dialog').dialog('open');
						
						// run create
						jQuery.ajax({
			                url: 'ipf_repository/' + action_name + '?' + "project_identifier=" + elm['project_identifier'],
							type: 'GET', 
							dataType: 'json',
							success: function(data)
							{
								jQuery('#running-dialog').dialog('close');

								if(data.result == 0)
								{
									message_dialog(msg_success, "");
								} else {
									message_dialog(msg_failure, data.message);
								}
							},
							error: function(data)
							{
								jQuery('#running-dialog').dialog('close');
								message_dialog(msg_failure, "");
							}
							
			            });
					}
				},
				{
					text: label_repository_no,
					click: function()
					{
						jQuery('#confirm-dialog').dialog("close");
					}
				}
			]

		});
		
		// inizialize running dialog 
		jQuery('#running-dialog').dialog(
		{
			resizable: false,
			modal: true,
			closeOnEscape: false,
			autoOpen: false,
			position: 'center',
			open:function(event, ui){
				jQuery('.ui-dialog-titlebar-close', jQuery('#running-dialog').parent()).hide();
			}
		});
		
		// inizialize message dialog
		var message_dialog = function(message, cause_message)
		{
			jQuery('#message-dialog p').html(getDialogMssage(message, cause_message))
			
			jQuery('#message-dialog').dialog(
			{
				autoOpen: false,
				modal: true,
				resizable: false,
				position: 'center',
				buttons:
				[
					{
						text: label_repository_ok,
						click: function()
						{
							jQuery(this).dialog('close');
						}
					}
				]
			});

			jQuery('#message-dialog').dialog('open');
		}
		
		// get input value
		var getElements = function()
		{
			var rtnMap = new Object();
			rtnMap['action'] = jQuery('input[name="select_action"]:checked').val();
			if(0 == rtnMap['action']) {
				rtnMap['project_identifier'] = jQuery('#project_create').children(':selected').val();
			} else {
				rtnMap['project_identifier'] = jQuery('#project_delete').children(':selected').val();
			}
			return rtnMap
		}
		
		// get dialog message 
		var getDialogMssage = function(message, cause_message)
		{
			var rtnStr = "";
			if(cause_message) {
				rtnStr = 
					"<table>"
					+ "<tr><td colspan=\'2\'>" + message + "</td></tr>"
					+ "<tr valign=\"top\"><td nowrap>" + msg_cause + ":&nbsp</td><td>" + cause_message + "</td></tr>"
					+ "</table>"
					;
			} else {
				rtnStr = message;
			}	
			return rtnStr
		}
		
	});
	
})(jQuery);
