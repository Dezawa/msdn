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

