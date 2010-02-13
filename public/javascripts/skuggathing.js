jQuery(document).ready(function() {
	jQuery(".althingi_process_container h2, .althingi_process_container p").css("cursor","pointer");
	if (location.pathname.substring(1,19) != 'priority_processes') {
		jQuery(".althingi_process_documents, .althingi_discussion").hide();
		jQuery(".althingi_process_documents, .althingi_discussion").parent().addClass("hidden")
	}
	else {
		jQuery(".althingi_process_documents, .althingi_discussion").parent().addClass("shown")
	}
 
	jQuery(".althingi_process_container h2, .althingi_process_container p").click(function() {
		if (jQuery(this).parent().hasClass("hidden")) {
			jQuery(this).siblings("div").slideDown();
			jQuery(this).parent().addClass("shown");
			jQuery(this).parent().removeClass("hidden");
			jQuery(this).siblings().children("span.showorhide").text("fela");
			jQuery(this).children("span.showorhide").text("fela");
		}
		else {
			jQuery(this).siblings("div").slideUp();
			jQuery(this).parent().addClass("hidden");
			jQuery(this).parent().removeClass("shown");
			jQuery(this).siblings().children("span.showorhide").text("sjá");
			jQuery(this).children("span.showorhide").text("sjá");
		}
	});
});