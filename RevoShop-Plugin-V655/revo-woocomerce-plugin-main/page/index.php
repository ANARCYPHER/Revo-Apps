<?php 
	
	function input_license(){
		include(plugin_dir_path( __FILE__ ).'license_code.php');
	}

	function index_settings(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_page.php');
		}else{
			input_license();
		}
	}

	function revo_mobile_banner(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_banner_slider.php');
		}else{
			input_license();
		}
	}

	function revo_custom_categories(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_custom_categories.php');
		}else{
			input_license();
		}
	}

	function revo_popular_categories(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_popular_categories.php');
		}else{
			input_license();
		}
	}

	function revo_mini_banner(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_mini_banner.php');
		}else{
			input_license();
		}
	}

	function revo_list_flash_sale(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_flash_sale.php');
		}else{
			input_license();
		}
	}

	function revo_list_extend_products(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_extend_products.php');
		}else{
			input_license();
		}
	}

	function revo_intro_page(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_intro_page.php');
		}else{
			input_license();
		}
	}

	function revo_searchbar(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_searchbar_text.php');
		}else{
			input_license();
		}
	}

	function revo_post_notification(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_post_notification.php');
		}else{
			input_license();
		}
	}

	function revo_empty_result_image(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_empty_result_image.php');
		}else{
			input_license();
		}
	}

	function revo_color_setting(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_app_color.php');
		}else{
			input_license();
		}
	}

	function revo_sosmed_setting(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ).'main_sosmed.php');
		}else{
			input_license();
		}
	}

	function revo_apps_additional_setting(){
		$cek = cek_internal_license_code();
		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ) . 'main_app_setting.php');
		}else{
			input_license();
		}
	}

	// for page v2
	// add_filter('woocommerce_rest_check_permissions', 'my_woocommerce_rest_check_permissions', 90, 4);
	// function my_woocommerce_rest_check_permissions($permission, $context, $object_id, $post_type) {
	// 	if (isset($_GET['fromAdmin'])) {
	// 		return true;
	// 	}

	// 	return $permission;
	// }