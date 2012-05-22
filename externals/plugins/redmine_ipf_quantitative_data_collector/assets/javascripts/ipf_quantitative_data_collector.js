(function($, undefined)
{
    $(function()
    {
        var collect_type_pf = 'pf';
        var collect_type_graph = 'graph';

        var get_timestamp = function()
        {
            return Math.round((new Date()).getTime() / 1000);
        };

        var message_dialog = function(message)
        {
            jQuery('#message-dialog p').html(message);

            jQuery('#message-dialog').dialog(
            {
                autoOpen: false,
                modal: true,
                resizable: false,
                position: 'center',
                buttons:
                {
                    "OK": function()
                    {
                        jQuery(this).dialog('close');
                    }
                }
            });

            jQuery('#message-dialog').dialog('open');
        };

        // Apply to status check results
        var set_check_processing_result = function(statuses, mode, orgcaption)
        {
            var count = statuses.length;
            for(var x = 0; x < count; x++)
            {
                // get button element
                var btn = document.getElementById('exec_btn_' + mode + '_' + statuses[x].id);
                if(statuses[x].processing)
                {
                    // executing...
                    btn.disabled = true;
                    btn.value = label_button_processing;
                }
                else
                {
                    // idling
                    btn.disabled = false;
                    btn.value = orgcaption;
                }

                // update data update date
                var date_area = document.getElementById('date_area_' + mode + '_' + statuses[x].id);
                date_area.innerHTML = statuses[x].update_date;
            }
        }

        // check batch program executing
        var check_processing = function()
        {
            var data = 'project_id=' + project_id + '&tt=' + get_timestamp();
            jQuery.ajax(
            {
                url: 'ipf_data_collect/check?' + data,
                type: 'GET',
                dataType: 'json',
                error: function(data)
                {
                },
                success: function(data)
                {
                    // Apply project management PF data collecting statuses to view
                    set_check_processing_result(data.pf, 'pf', label_pf_button);

                    // Apply graph data collecting statuses to view
                    set_check_processing_result(data.graph, 'graph', label_graph_button);
                }
            });
        };

        // execute batch programs
        var execute_collection = function(mode, proc_id, orglabel)
        {
            var data = 'project_id=' + project_id + '&mode=' + mode + '&proc_id=' + proc_id + '&tt=' + get_timestamp();
            jQuery.ajax(
            {
                url: 'ipf_data_collect/execute?' + data,
                type: 'GET',
                dataType: 'json',
                error: function(data)
                {
                    // restore button where error occured
                    var btn = document.getElementById('exec_btn_' + mode + '_' + proc_id);
                    btn.disabled = false;
                    btn.value = orglabel;
                },
                success: function(data)
                {
                    // restore button where request successed
                    if(data.result == 9)
                    {
                        // executing batch program
                        message_dialog(data.message);
                    }
                    else if(data.result == 10)
                    {
                        // executing project management PF data collect.
                        message_dialog(data.message);
                        // restore button
                        var btn = document.getElementById('exec_btn_' + mode + '_' + proc_id);
                        btn.disabled = false;
                        btn.value = orglabel;
                    }
                    else
                    {
                        // restore button
                        var btn = document.getElementById('exec_btn_' + mode + '_' + proc_id);
                        btn.disabled = false;
                        btn.value = orglabel;

                        // check result
                        if(data.result == 0)
                        {
                            // refresh update date when result ok
                            var date_area = document.getElementById('date_area_' + mode + '_' + proc_id);
                            date_area.innerHTML = data.update_date;
                        }
                        else
                        {
                            // show error message
                            message_dialog(data.message);
                        }
                    }
                }
            });
        };

        // Click event for graph data collect button
        jQuery('.graph-exec-button').click(function()
        {
            var button = jQuery(this);
            var proc_id = jQuery(this).attr('id').replace('exec_btn_' + collect_type_graph + '_', '');
            var orglabel = jQuery(this).val();

            // initialize confirm dialog
            jQuery('#graph-confirm-dialog').dialog(
            {
                resizable: false,
                modal: true,
                autoOpen: false,
                position: 'center',
                buttons:
                [
                    {
                        text: label_accept_button,
                        click: function()
                        {
                            // change label to 'processing...' when 'OK' clicked
                            jQuery(button).attr('disabled', 'disabled');
                            jQuery(button).val(label_button_processing);

                            jQuery('#graph-confirm-dialog').dialog("close");

                            // execute collecting batch program
                            execute_collection(collect_type_graph, proc_id, orglabel);
                        }
                    },
                    {
                        text: label_cancel_button,
                        click: function()
                        {
                            // close this dialog when 'Cancel' clicked
                            jQuery('#graph-confirm-dialog').dialog("close");
                        }
                    }
                ]
            });

            // confirm execute
            jQuery('#graph-confirm-dialog').dialog('open');
        });

        // Click event for project management PF data collect button
        jQuery('.pf-exec-button').click(function()
        {
            var button = jQuery(this);
            var proc_id = jQuery(this).attr('id').replace('exec_btn_' + collect_type_pf + '_', '');
            var orglabel = jQuery(this).val();

            // initialize confirm dialog
            jQuery('#pf-confirm-dialog').dialog(
            {
                resizable: false,
                modal: true,
                autoOpen: false,
                position: 'center',
                buttons:
                [
                    {
                        text: label_accept_button,
                        click: function()
                        {
                            // change label to 'processing...' when 'OK' clicked
                            jQuery(button).attr('disabled', 'disabled');
                            jQuery(button).val(label_button_processing);

                            jQuery('#pf-confirm-dialog').dialog("close");

                            // execute collecting batch program
                            execute_collection(collect_type_pf, proc_id, orglabel);
                        }
                    },
                    {
                        text: label_cancel_button,
                        click: function()
                        {
                            // close this dialog when 'Cancel' clicked
                            jQuery('#pf-confirm-dialog').dialog("close");
                        }
                    }
                ]
            });

            // confirm execute
            jQuery('#pf-confirm-dialog').dialog('open');
        });

        // set status check interval (default:60sec)
        setInterval(check_processing, check_interval);

        // get status for first time
        check_processing();
    });

})(jQuery);
