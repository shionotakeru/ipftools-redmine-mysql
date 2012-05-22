(function(jQuery, undefined)
{
	jQuery(function()
	{
		// click backup start button
		jQuery('.backup-exec-button').click(function()
		{
			jQuery('#backup-confirm-dialog').dialog('open');
			
		});
		
		// inizialize backup confirm dialog 
		jQuery('#backup-confirm-dialog').dialog(
		{
			resizable: false,
			modal: true,
			autoOpen: false,
			position: 'center',
			buttons:
			[
				{
					text: label_backup_yes,
					click: function()
					{
						jQuery('#backup-confirm-dialog').dialog("close");
						jQuery('#backup-running-dialog').dialog('open');
						
						var target = jQuery('input[name="backup_target"]:checked').val();
						
						// run backup
						jQuery.ajax({
			                url: 'ipf_backup/backup?' + "target=" + target,
							type: 'GET', 
							dataType: 'json',
							success: function(data)
							{
								jQuery('#backup-running-dialog').dialog('close');

								if(data.result == 0)
								{
									jQuery('#backup-success-dialog').dialog("open");
								} else {
									message_dialog(msg_backup_failure, data.message);
								}
							},
							error: function(data)
							{
								jQuery('#backup-running-dialog').dialog('close');
								message_dialog(msg_backup_failure, "");
							}
							
			            });
					}
				},
				{
					text: label_backup_no,
					click: function()
					{
						jQuery('#backup-confirm-dialog').dialog("close");
					}
				}
			]

		});
		
		// inizialize running dialog 
		jQuery('#backup-running-dialog').dialog(
		{
			resizable: false,
			modal: true,
			closeOnEscape: false,
			autoOpen: false,
			position: 'center',
			open:function(event, ui){
				jQuery('.ui-dialog-titlebar-close', jQuery('#backup-running-dialog').parent()).hide();
			}
		});
		
		// inizialize success dialog
		jQuery('#backup-success-dialog').dialog(
		{
				resizable: false,
				modal: true,
				autoOpen: false,
				position: 'center',
				close: function(event) {
					// reflesh
					urlJump();
				},
				buttons:
				[
					{
						text: label_backup_ok,
						click: function()
						{
							jQuery('#backup-success-dialog').dialog("close");
						}
					}
				]
		});

		// click delete link
		delete_click_global = function(backup_id)
		{
			// inizialize delete dialog 
			jQuery('#backup-delete-confirm-dialog').dialog(
			{
				resizable: false,
				modal: true,
				autoOpen: false,
				position: 'center',
				buttons:
				[
					{
						text: label_backup_yes,
						click: function()
						{
							jQuery.ajax({
				                url: 'ipf_backup/delete?' + "id=" + backup_id,
								type: 'GET', 
								dataType: 'json',
								success: function(data)
								{
									if(data.result == 0)
									{
										jQuery('#backup-delete-confirm-dialog').dialog("close");

										// reflesh
										urlJump();
										
									} else {
										jQuery('#backup-delete-confirm-dialog').dialog("close");
										message_dialog(msg_delete_failure, data.message);
									}
									
								},
								error: function(data)
								{
									jQuery('#backup-delete-confirm-dialog').dialog("close");
									message_dialog(msg_delete_failure, "");
								}
								
				            });
						}
					},
					{
						text: label_backup_no,
						click: function()
						{
							jQuery('#backup-delete-confirm-dialog').dialog("close");
						}
					}
				]
	
			});
			
			jQuery('#backup-delete-confirm-dialog').dialog('open');
		}
		
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
						text: label_backup_ok,
						click: function()
						{
							jQuery(this).dialog('close');
						}
					}
				]
			});

			jQuery('#message-dialog').dialog('open');
		}
		
		// reflesh
		var urlJump = function()
		{
			window.location.href = 'ipf_backup';
		}
		
		// download click 
		download_click_global = function(backup_id)
		{
			jQuery.ajax({
		        url: 'ipf_backup/download_check?' + "id=" + backup_id,
				type: 'GET', 
				dataType: 'json',
				success: function(data)
				{
					if(data.result == 0)
					{
						exec_download(backup_id);
		
					} else {
						message_dialog(msg_download_failure, data.message);
					}
					
				},
				error: function(data)
				{
					message_dialog(msg_download_failure, "");
				}
				
		    });
		}
		
		// download exec
		var exec_download = function(id)
		{
			window.location.href = 'ipf_backup/download?' + "id=" + id;
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

function download_click(backup_id)
{
	download_click_global(backup_id);	
}

function delete_click(backup_id)
{
	delete_click_global(backup_id);	
}
