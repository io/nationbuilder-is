jQuery(document).ready(function() {
	jQuery(".althingi_process_container h2, .althingi_process_container p").css("cursor","pointer");
	jQuery(".althingi_process_documents, .althingi_discussion").parent().addClass("shown")
	
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