// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

// ######### POPUP ########
// height:600, // sets the height in pixels of the window.
// width:600, // sets the width in pixels of the window.
// toolbar:0, // determines whether a toolbar (includes the forward and back buttons) is displayed {1 (YES) or 0 (NO)}.
// scrollbars:0, // determines whether scrollbars appear on the window {1 (YES) or 0 (NO)}.
// status:0, // whether a status line appears at the bottom of the window {1 (YES) or 0 (NO)}.
// resizable:1, // whether the window can be resized {1 (YES) or 0 (NO)}. Can also be overloaded using resizable.
// left:0, // left position when the window appears.
// top:0, // top position when the window appears.
// center:0, // should we center the window? {1 (YES) or 0 (NO)}. overrides top and left
// createnew:1, // should we create a new window for each occurance {1 (YES) or 0 (NO)}.
// location:0, // determines whether the address bar is displayed {1 (YES) or 0 (NO)}.
// menubar:0, // determines whether the menu bar is displayed {1 (YES) or 0 (NO)}.
// onUnload:null // function to call when the window is closed
var profiles =
{

	window68:
	{
		height:600,
	    width:800,
            scrollbars:1,
		status:1
	},
	window88:
	{
		height:800,
		width:800,
            scrollbars:1,
		status:1
	},

	window22:
	{
		height:200,
		width:200,
		status:1,
		resizable:0
	},

	windowCenter:
	{
		height:300,
		width:400,
		center:1
	},

	windowNotNew:
	{
		height:300,
		width:400,
		center:1,
		createnew:0
	},

	windowCallUnload:
	{
		height:300,
		width:400,
		center:1,
		onUnload:unloadcallback
	},

};

function unloadcallback(){
	alert("unloaded");
};


$(function()
{
  		$(".popupwindow").popupwindow(profiles);
});

$(function(){
		$('#year_year').change(function(){
		var the_year = $("#year_year").val();
		$.get("keeping/year_change?year=" + the_year);
	    });
    });

jQuery(function(){
	$("select#year_year").change(function(){
	var year = $("#year_year").val();
		$.ajax({
			url: "keeping/year_change",
			    type: "GET",
			    data: {year : $(":selected").attr("value"),
				id: 1,
				mode: 'hoge',
				type: 'entry'
				},
			    dataType: "html",
			    success: function(data) {
			    $("#this_year").text("複式簿記：メイン:"+year);
			},
			    error: function(data) {
			    alert("errror");
			}
		    });
	    });
    });

