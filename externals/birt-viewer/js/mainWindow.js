
if(window.addEventListener) {
    window.addEventListener("load", init, false);
} else {
    window.onload = init;
}

function init () {
    var projectList = document.getElementById("project_name");
    if (projectList != null) {
        if (projectList.addEventListener) {
            projectList.addEventListener("change", projectListChanged, false);
        } else {
            projectList.onchange=projectListChanged;
        }
    }
}

function projectListChanged () {
    var projectList = document.getElementById("project_name");
    var index = projectList.selectedIndex;
    var projectId = null;
    var projectName = null;
    if (index != -1) {
        projectId = projectList.options[index].value;
        projectName = projectList.options[index].text;
    }
    var form = document.forms["mainForm"];
    form.submit();
}

function mainWindowOpen(url, windowName) {
    var option = 'menubar=yes,toolbar=yes,location=yes,resizable=yes,scrollbars=yes';
    commonWindowOpen(url, windowName, option, null, null);
}

function subWindowOpen(url, windowName, width, height) {
    var option = 'menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes';
    commonWindowOpen(url, windowName, option, '1280', '800');
}

function helpWindowOpen(url, windowName, width, height) {
    var option = 'menubar=yes,toolbar=yes,location=yes,resizable=yes,scrollbars=yes';
    commonWindowOpen(url, windowName, option, width, height);
}

function commonWindowOpen(url, windowName, option, width, height) {
    if (windowName == null) {
        windowName = '_blank';
    }
    if (width == null) {
        width = '';
    } else {
        width = 'width=' + width + ',';
    }
    if (height == null) {
        height = '';
    } else {
        height = 'height=' + height + ',';
    }
    var subWin = window.open(url, windowName, width + height + option);
    subWin.focus();
}

$(document).ready(function(){
	$("#menu_show_link").click(function(){
	    $("#container").animate({width : "+=305px", minWidth: "+=305px"});
	    $("#top_nav").animate({width : "+=305px", minWidth: "+=305px"});
	    $("#left_col").show();
	    $("#left_col").animate({width : "+=305px"});
	    $("#page_content").animate({marginLeft : "+=305px"}, 
	    	{complete: function() {
	    	    $("#menu_show").hide();
	    	    $("#menu_hide").show();
	    	}
	    });
	});
});


$(document).ready(function(){
	$("#menu_hide_link").click(function(){
	    $("#container").animate({width : "-=305px", minWidth: "-=305px"});
	    $("#top_nav").animate({width : "-=305px", minWidth: "-=305px"});
	    $("#left_col").animate({width : "-=305px"});
	    $("#page_content").animate({marginLeft : "-=305px"}, 
	    	{complete: function() {
	    	    $("#menu_hide").hide();
	    	    $("#menu_show").show();
	    	    $("#left_col").hide();
	    	}
	    });
	});
});

