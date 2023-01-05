<?php
  /*
  Plugin Name: RevoSHOP - Flutter Woocommerce Full App Manager
  Plugin URI:
  Description: Mobile App Management. Manage everything from WP-ADMIN.
  Author: Revo Apps
  Version: 6.5.5
  Build 2021
  */ 

  if (!defined('WPINC')) {
      die;
  }

  // if( ! defined( 'WP_UNINSTALL_PLUGIN' ) ){
  //   global $wpdb;
  //   $wpdb->query( "
  //                   DROP TABLE IF EXISTS revo_access_key;
  //                   DROP TABLE IF EXISTS revo_extend_products;
  //                   DROP TABLE IF EXISTS revo_flash_sale;
  //                   DROP TABLE IF EXISTS revo_hit_products;
  //                   DROP TABLE IF EXISTS revo_list_categories;
  //                   DROP TABLE IF EXISTS revo_list_mini_banner;
  //                   DROP TABLE IF EXISTS revo_mobile_slider;
  //                   DROP TABLE IF EXISTS revo_mobile_variable;
  //                   DROP TABLE IF EXISTS revo_notification;
  //                   DROP TABLE IF EXISTS revo_popular_categories;
  //                   DROP TABLE IF EXISTS revo_token_firebase;
  //                 " );
  //   delete_option("2.3.2");
  // }

  $upload = wp_upload_dir();
  $upload_dir = $upload['basedir'];
  $upload_dir = $upload_dir . '/revo';
  if (! is_dir($upload_dir)) {
    mkdir( $upload_dir, 0777 );
  }

  $revo_plugin_name = 'revo-apps-setting';
  $revo_plugin_version = '6.5.5';
  global $revo_plugin_version;

  require (plugin_dir_path( __FILE__ ).'helper.php');

  add_action('woocommerce_new_order', 'notif_new_order',  10, 1  );
  add_action('woocommerce_order_status_changed', 'notif_new_order', 10, 1  );
  
  $revo_api_url = 'revo-admin/v1';
  add_action('admin_menu','routes');
  add_action('rest_api_init', function () {

    global $revo_api_url;
  
    if(!empty(get_oauth_parameters())){

      if (get_oauth_parameters()['oauth_consumer_key']) {

        security_0auth();

        register_rest_route( $revo_api_url, '/home-api', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_home',
        ));
        register_rest_route( $revo_api_url, '/home-api/slider', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_slider',
        ));
        register_rest_route( $revo_api_url, '/home-api/categories', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_categories',
        ));
        register_rest_route( $revo_api_url, '/home-api/mini-banner', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_mini_banner',
        ));
        register_rest_route( $revo_api_url, '/home-api/flash-sale', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_flash_sale',
        ));
        register_rest_route( $revo_api_url, '/home-api/extend-products', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_extend_products',
        ));
        register_rest_route( $revo_api_url, '/home-api/hit-products', array(
          'methods' => 'POST',
          'callback' => 'rest_hit_products',
        ));
        register_rest_route( $revo_api_url, '/home-api/recent-view-products', array(
          'methods' => 'POST',
          'callback' => 'rest_get_hit_products',
        ));
        register_rest_route( $revo_api_url, '/home-api/intro-page', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_get_intro_page',
        ));
        register_rest_route( $revo_api_url, '/home-api/splash-screen', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_get_splash_screen',
        ));
        register_rest_route( $revo_api_url, '/home-api/general-settings', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_get_general_settings',
        ));
        register_rest_route( $revo_api_url, '/home-api/add-remove-wistlist', array(
          'methods' => 'POST',
          'callback' => 'rest_add_remove_wistlist',
        ));
        register_rest_route( $revo_api_url, '/home-api/list-product-wistlist', array(
          'methods' => 'POST',
          'callback' => 'rest_list_wistlist',
        ));
        register_rest_route( $revo_api_url, '/home-api/popular-categories', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'popular_categories',
        ));
        register_rest_route( $revo_api_url, '/home-api/key-firebase', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_key_firebase',
        ));
        register_rest_route( $revo_api_url, '/home-api/input-token-firebase', array(
          'methods' => 'POST',
          'callback' => 'rest_token_user_firebase',
        ));
        register_rest_route( $revo_api_url, '/home-api/check-produk-variation', array(
          'methods' => 'POST',
          'callback' => 'rest_check_variation',
        ));
        register_rest_route( $revo_api_url, '/home-api/list-orders', array(
          'methods' => 'POST',
          'callback' => 'rest_list_orders',
        ));
        register_rest_route( $revo_api_url, '/home-api/list-review-user', array(
          'methods' => 'POST',
          'callback' => 'rest_list_review',
        ));
        register_rest_route( $revo_api_url, '/home-api/list-notification', array(
          'methods' => 'POST',
          'callback' => 'rest_list_notification',
        ));
        register_rest_route( $revo_api_url, '/home-api/list-notification-new', array(
          'methods' => 'POST',
          'callback' => 'rest_list_notification_new',
        ));
        register_rest_route( $revo_api_url, '/home-api/read-notification', array(
          'methods' => 'POST',
          'callback' => 'rest_read_notification',
        ));
        register_rest_route( $revo_api_url, '/list-categories', array(
          'methods' => 'POST',
          'callback' => 'rest_categories_list',
        ));
        register_rest_route( $revo_api_url, '/insert-review', array(
          'methods' => 'POST',
          'callback' => 'rest_insert_review',
        ));
        register_rest_route( $revo_api_url, '/get-barcode', array(
          'methods' => 'POST',
          'callback' => 'rest_get_barcode',
        ));
        register_rest_route( $revo_api_url, '/product/details', array(
          'methods' => 'POST',
          'callback' => 'rest_product_details',
        ));
        register_rest_route( $revo_api_url, '/product/lists', array(
          'methods' => 'GET',
          'callback' => 'rest_product_lists',
        ));
        register_rest_route( $revo_api_url, '/list-produk', array(
          'methods' => 'POST',
          'callback' => 'rest_list_product',
        ));
        register_rest_route( $revo_api_url, '/disabled-service', array(
          'methods' => 'POST',
          'callback' => 'rest_disabled_service',
        ));
        register_rest_route( $revo_api_url, '/topup-woowallet', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_topup_woowallet',
        ));
        register_rest_route( $revo_api_url, '/transfer-woowallet', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_transfer_woowallet',
        ));

        // filter 

        register_rest_route( $revo_api_url, '/data-filter-attribute-by-category', array(
          'methods' => 'POST',
          'callback' => 'rest_data_attribute_bycategory',
        ));

        register_rest_route( $revo_api_url, '/data-woo-discount-rules', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_data_woo_discount_rules',
        ));

        // chat
        register_rest_route( $revo_api_url, '/list-user-chat', array(
          'methods' => 'POST',
          'callback' => 'rest_list_user_chat',
        ));

        register_rest_route( $revo_api_url, '/detail-chat', array(
          'methods' => 'POST',
          'callback' => 'rest_detail_chat',
        ));

        register_rest_route( $revo_api_url, '/insert-chat', array(
          'methods' => 'POST',
          'callback' => 'rest_insert_chat',
        ));

        register_rest_route( $revo_api_url, '/list-users', array(
          'methods' => 'POST',
          'callback' => 'rest_list_users',
        ));

        register_rest_route( $revo_api_url, '/delete-account', array(
          'methods' => 'POST',
          'callback' => 'rest_delete_account',
        ));

        register_rest_route( $revo_api_url, '/list_coupons', array(
          'methods' => 'POST',
          'callback' => 'rest_list_coupons',
        ));

        register_rest_route($revo_api_url, '/customer/address', array(
          'methods' => 'POST',
          'callback' => 'rest_post_customer_address'
        ));
      
        register_rest_route($revo_api_url, '/products/reviews', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_show_reviews_product'
        ));
      
        register_rest_route($revo_api_url, '/products/attributes', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_products_attributes'
        ));
      
        register_rest_route( $revo_api_url, '/list-produk-custom', array(
          'methods' => 'POST',
          'callback' => 'rest_list_product_custom',
        ));

        register_rest_route( $revo_api_url, '/home-api-custom', array(
          'methods' => 'POST',
          'callback' => 'rest_home_custom',
        ));
      
        register_rest_route( $revo_api_url, '/list-blog', array(
          'methods' =>  WP_REST_Server::READABLE,
          'callback' => 'rest_list_blog',
        ));
      
        register_rest_route( $revo_api_url, '/apply-coupon', array(
          'methods' => 'POST',
          'callback' => 'rest_apply_coupon',
        ));

        register_rest_route( $revo_api_url, '/apply-coupon/v2', array(
          'methods' => 'POST',
          'callback' => 'rest_apply_coupon_v2',
        ));

        register_rest_route( $revo_api_url, '/list-coupons', array(
          'methods' => 'POST',
          'callback' => 'rest_list_coupons',
        ));

        register_rest_route( $revo_api_url, '/states', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_states',
        ));
        
        register_rest_route( $revo_api_url, '/cities', array(
          'methods' => WP_REST_Server::READABLE,
          'callback' => 'rest_cities',
        ));

        register_rest_route( $revo_api_url, '/memberships/products', array(
          'methods'  => 'POST',
          'callback' => 'rest_get_memberships_products',
        ));

      }
      
    }

    register_rest_route( $revo_api_url, '/set-intro-page', array(
      'methods' => 'GET',
      'callback' => 'rest_intro_page_status',
    ));

  });

  // plugin uninstallation
  register_deactivation_hook( __FILE__, 'remove_license' );
  
  // And here goes the uninstallation function:
  function remove_license(){
    global $wpdb;
    // $queryLC = $wpdb->get_row("SELECT `id`,`description` FROM `revo_mobile_variable` WHERE `slug` = 'license_code' AND `description` NOT NULL", OBJECT);
    
    $queryLC = $wpdb->get_row("SELECT id,description,update_at FROM `revo_mobile_variable` WHERE slug = 'license_code' AND description != '' AND update_at is not NULL", OBJECT);
    
    if (!$queryLC) return true;
    
    $update = ["description"=>null];
    $wpdb->update('revo_mobile_variable',$update,['id' => $queryLC->id]);
    
    $license_code = json_decode($queryLC->description)->license_code;
    $body = json_encode(compact('license_code'));
    $curl = curl_init();
    curl_setopt_array($curl, array(
      CURLOPT_URL => "https://activation.revoapps.net/wp-json/license/uninstall",
      CURLOPT_RETURNTRANSFER => true,
      CURLOPT_ENCODING => "",
      CURLOPT_MAXREDIRS => 10,
      CURLOPT_TIMEOUT => 30,
      CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
      CURLOPT_CUSTOMREQUEST => "POST",
      CURLOPT_HTTPHEADER => array(
          "Content-Type: application/json",
      ),
      CURLOPT_POSTFIELDS => $body,
    ));

    $response = curl_exec($curl);

    $err = curl_error($curl);

    curl_close($curl);

    if ($err) {
      return 'error';
    }    
    return json_decode($response);
  }
  
  require (plugin_dir_path( __FILE__ ).'revo-checkout/checkout-api.php');

  function routes(){
    global $submenu;
    global $revo_plugin_name;

    // add_menu_page( "Mobile Revo Settings", "REVO APPS <br> Flutter Woocommerce", 0, $revo_plugin_name,"index_settings", get_logo('black_white') );
    // add_submenu_page($revo_plugin_name, "Intro Page", "Intro Page", 1, "revo-intro-page", 'revo_intro_page');
    // add_submenu_page($revo_plugin_name, "Home Sliding Banner", "Home Sliding Banner", 1, "revo-mobile-banner", 'revo_mobile_banner');
    // add_submenu_page($revo_plugin_name, "Home Categories", "Home Categories", 2, "revo-mobile-categories", 'revo_custom_categories');
    // add_submenu_page($revo_plugin_name, "Home Additional Banner", "Home Additional Banner", 4, "revo-mini-banner", 'revo_mini_banner');
    // add_submenu_page($revo_plugin_name, "Home Flash Sale", "Home Flash Sale", 5, "revo-flash-sale", 'revo_list_flash_sale');
    // add_submenu_page($revo_plugin_name, "Home Additional Products", "Home Additional Products", 6, "revo-additional-products", 'revo_list_extend_products');
    // add_submenu_page($revo_plugin_name, "Empty Result Image", "Empty Result Image", 7, "revo-empty-result-image", 'revo_empty_result_image');
    // add_submenu_page($revo_plugin_name, "Popular Categories", "Popular Categories", 3, "revo-popular-categories", 'revo_popular_categories');
    // add_submenu_page($revo_plugin_name, "Push Notification", "Push Notification", 8, "revo-post-notification", 'revo_post_notification');
    // add_submenu_page($revo_plugin_name, "App Color Setting", "App Color Setting", 9, "revo-color-setting", 'revo_color_setting');

    // capabilities error -> https://wordpress.stackexchange.com/questions/16614/plugins-error-use-roles-and-capabilities-instead-on-latest-version-multisite

    add_menu_page( "Mobile Revo Settings", "RevoSHOP", 'manage_options', $revo_plugin_name,"index_settings", get_logo('black_white') );
    add_submenu_page($revo_plugin_name, "Intro Page", "Intro Page", 'manage_options', "revo-intro-page", 'revo_intro_page');
    add_submenu_page($revo_plugin_name, "Home Search bar Text", "Home Search bar Text", 'manage_options', "revo-searchbar", 'revo_searchbar');
    add_submenu_page($revo_plugin_name, "Home Sliding Banner", "Home Sliding Banner", 'manage_options', "revo-mobile-banner", 'revo_mobile_banner');
    add_submenu_page($revo_plugin_name, "Home Categories", "Home Categories", 'manage_options', "revo-mobile-categories", 'revo_custom_categories');
    add_submenu_page($revo_plugin_name, "Home Additional Banner", "Home Additional Banner", 'manage_options', "revo-mini-banner", 'revo_mini_banner');
    add_submenu_page($revo_plugin_name, "Home Flash Sale", "Home Flash Sale", 'manage_options', "revo-flash-sale", 'revo_list_flash_sale');
    add_submenu_page($revo_plugin_name, "Home Additional Products", "Home Additional Products", 'manage_options', "revo-additional-products", 'revo_list_extend_products');
    add_submenu_page($revo_plugin_name, "Popular Categories", "Popular Categories", 'manage_options', "revo-popular-categories", 'revo_popular_categories');
    add_submenu_page($revo_plugin_name, "Empty Result Image", "Empty Result Image", 'manage_options', "revo-empty-result-image", 'revo_empty_result_image');
    add_submenu_page($revo_plugin_name, "Push Notification", "Push Notification", 'manage_options', "revo-post-notification", 'revo_post_notification');
    add_submenu_page($revo_plugin_name, "App Color Setting", "App Color Setting", 'manage_options', "revo-color-setting", 'revo_color_setting');
    add_submenu_page($revo_plugin_name, "Social Media Setting", "Social Media Setting", 'manage_options', "revo-sosmed-setting", 'revo_sosmed_setting');
    add_submenu_page($revo_plugin_name, "Apps Setting", "Apps Setting", 'manage_options', "revo-apps-additional-setting", 'revo_apps_additional_setting');

    $submenu[$revo_plugin_name][0][0] = 'Dashboard';
  }
  
  $query_cekpluginversion = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'plugin' AND title = 'version'";
  $where_cekpluginversion = $wpdb->get_row($query_cekpluginversion, OBJECT);

  if (empty($where_cekpluginversion) || $where_cekpluginversion->description != $revo_plugin_version) {

    if (check_exist_database('revo_mobile_variable')) {

      $revo_mobile_variable = "CREATE TABLE `revo_mobile_variable` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `slug` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
              `title` varchar(1000) NULL DEFAULT NULL,
              `image` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
              `description` TEXT NULL DEFAULT NULL,
              `sort` tinyint(2) NOT NULL DEFAULT 0,
              `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              `update_at` timestamp NULL,
              PRIMARY KEY (`id`) USING BTREE)";
        
        $wpdb->query($wpdb->prepare($revo_mobile_variable,[]));

        $wpdb->insert('revo_mobile_variable',data_default_MV('splashscreen'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('kontak_wa'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('kontak_phone'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('kontak_sms'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('sms'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('about'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('cs'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('privacy_policy'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('term_condition'));
        $wpdb->insert('revo_mobile_variable',data_default_MV('logo'));
        // $wpdb->insert('revo_mobile_variable',data_default_MV('app_primary_color'));
        // $wpdb->insert('revo_mobile_variable',data_default_MV('app_secondary_color'));

        $intro_page_1 = data_default_MV('intro_page_1');
        $intro_page_1['sort'] = '1';
        $wpdb->insert('revo_mobile_variable',$intro_page_1);

        $intro_page_2 = data_default_MV('intro_page_2');
        $intro_page_2['sort'] = '2';
        $wpdb->insert('revo_mobile_variable',$intro_page_2);

        $intro_page_3 = data_default_MV('intro_page_3');
        $intro_page_3['sort'] = '3';
        $wpdb->insert('revo_mobile_variable',$intro_page_3);

        for ($i=0; $i < count($data); $i++) { 
          $wpdb->insert('revo_mobile_variable',$data[$i]);
        }

        for ($i=1; $i < 6; $i++) { 
          $wpdb->insert('revo_mobile_variable',data_default_MV('empty_images_'.$i));
        }
    }

    if (check_exist_database('revo_mobile_slider')) {
      $revo_mobile_slider = "CREATE TABLE `revo_mobile_slider` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `order_by` int(55) NOT NULL,
                `product_id` int(11) NULL DEFAULT NULL,
                `title` varchar(500) NULL DEFAULT NULL,
                `images_url` varchar(500) NULL DEFAULT NULL,
                `product_name` varchar(255) NULL DEFAULT NULL,
                `is_active` int(1) NULL DEFAULT 1,
                `is_deleted` int(1) NULL DEFAULT 0,
                `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`id`) USING BTREE ) ";
      
      $wpdb->query($wpdb->prepare($revo_mobile_slider,[]));
    }

    if (check_exist_database('revo_list_categories')) {
      $revo_list_categories = " CREATE TABLE `revo_list_categories` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `order_by` int(55) NOT NULL,
          `image` varchar(500) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
          `category_id` int(55) NOT NULL,
          `category_name` varchar(1000) NULL DEFAULT NULL,
          `is_active` int(1) NULL DEFAULT 1,
          `is_deleted` int(1) NULL DEFAULT 0,
          `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
          PRIMARY KEY (`id`) USING BTREE) ";
      
      $wpdb->query($wpdb->prepare($revo_list_categories,[]));
    }

    if (check_exist_database('revo_list_mini_banner')) {
      $revo_list_mini_banner = " CREATE TABLE `revo_list_mini_banner` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `order_by` int(55) NOT NULL,
          `product_id` int(11) NULL DEFAULT NULL,
          `product_name` varchar(255) NULL DEFAULT NULL,
          `image` varchar(500) NOT NULL,
          `type` varchar(55) NULL DEFAULT NULL,
          `is_active` int(1) NULL DEFAULT 1,
          `is_deleted` int(1) NULL DEFAULT 0,
          `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
          PRIMARY KEY (`id`) USING BTREE) ";
      
      $wpdb->query($wpdb->prepare($revo_list_mini_banner,[]));
    }

    if (check_exist_database('revo_flash_sale')) {
      $revo_flash_sale = "CREATE TABLE `revo_flash_sale` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `title` varchar(255) NOT NULL,
            `start` timestamp NULL DEFAULT NULL,
            `end` timestamp NULL DEFAULT NULL,
            `products` longtext NOT NULL,
            `image` varchar(500) NOT NULL,
            `is_active` tinyint(1) NOT NULL DEFAULT 1,
            `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE)";
      
      $wpdb->query($wpdb->prepare($revo_flash_sale,[]));
    }

    if (check_exist_database('revo_extend_products')) {
      $revo_extend_products = 
            "CREATE TABLE `revo_extend_products` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `type` enum('special','our_best_seller','recomendation') NOT NULL DEFAULT 'special',
            `title` varchar(255) NOT NULL,
            `description` varchar(500) DEFAULT NULL,
            `products` longtext NOT NULL,
            `is_active` tinyint(1) NOT NULL DEFAULT 1,
            `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE)";
      $wpdb->query($wpdb->prepare($revo_extend_products,[]));

      for ($i=1; $i <= 3; $i++) {
        $wpdb->insert('revo_extend_products', data_default_MV('additional_products_' . $i));
      }
    }

    if (check_exist_database('revo_popular_categories')) {
      $revo_popular_categories = "CREATE TABLE `revo_popular_categories` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `title` varchar(55) NOT NULL,
            `categories` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
            `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE)";
      $wpdb->query($wpdb->prepare($revo_popular_categories,[]));
    }

    if (check_exist_database('revo_hit_products')) {
      $revo_hit_products = "CREATE TABLE `revo_hit_products` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `products` varchar(55) NOT NULL,
            `user_id` varchar(55) NULL,
            `type` enum('hit','wistlist') NOT NULL DEFAULT 'hit',
            `ip_address` varchar(55) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE)";
      $wpdb->query($wpdb->prepare($revo_hit_products,[]));
    }

    if (check_exist_database('revo_access_key')) {
      $revo_access_key = "CREATE TABLE `revo_access_key` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `firebase_servey_key` TEXT NULL DEFAULT NULL,
            `firebase_api_key` TEXT NULL DEFAULT NULL,
            `firebase_auth_domain` TEXT NULL DEFAULT NULL,
            `firebase_database_url` TEXT NULL DEFAULT NULL,
            `firebase_project_id` TEXT NULL DEFAULT NULL,
            `firebase_storage_bucket` TEXT NULL DEFAULT NULL,
            `firebase_messaging_sender_id` TEXT NULL DEFAULT NULL,
            `firebase_app_id` TEXT NULL DEFAULT NULL,
            `firebase_measurement_id` TEXT NULL DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE)";
      $wpdb->query($wpdb->prepare($revo_access_key,[]));

      $wpdb->insert('revo_access_key',['firebase_api_key' => NULL]);
    }

    if (check_exist_database('revo_token_firebase')) {
      $revo_token_firebase = "CREATE TABLE `revo_token_firebase` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `token` TEXT NULL DEFAULT NULL,
            `user_id` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
            `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE)";
      $wpdb->query($wpdb->prepare($revo_token_firebase,[]));
    }

    if (check_exist_database('revo_notification')) {
      $revo_notification = "CREATE TABLE `revo_notification` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `user_id` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
            `target_id` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
            `type` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
            `message` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
            `is_read` tinyint(1) NOT NULL DEFAULT 0,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE)";
      $wpdb->query($wpdb->prepare($revo_notification,[]));
    }

    if (check_exist_database('revo_conversations')) {
      $revo_conversations = "CREATE TABLE `revo_conversations` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `sender_id` int(11) NOT NULL,
          `receiver_id` int(11) NOT NULL,
          `is_delete_sender` tinyint(2) NOT NULL DEFAULT 0,
          `is_delete_receiver` tinyint(2) NOT NULL DEFAULT 0,
          `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
          PRIMARY KEY (`id`) USING BTREE,
          KEY (`sender_id`) USING BTREE,
          KEY (`receiver_id`) USING BTREE );";
      $wpdb->query($wpdb->prepare($revo_conversations,[]));
    }

    if (check_exist_database('revo_conversation_messages')) {
      $revo_conversation_messages = "CREATE TABLE `revo_conversation_messages` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `conversation_id` int(11) NOT NULL,
            `sender_id` int(11) NOT NULL,
            `receiver_id` int(11) NOT NULL,
            `message` varchar(1000) NOT NULL,
            `image` TEXT NULL DEFAULT NULL,
            `is_read` tinyint(2) NOT NULL DEFAULT 0,
            `type` enum('store','product','order','chat') NOT NULL DEFAULT 'chat',
            `post_id` int(11) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE,
            KEY (`post_id`) USING BTREE,
            KEY (`sender_id`) USING BTREE,
            KEY (`receiver_id`) USING BTREE,
            KEY (`conversation_id`) USING BTREE );";
      $wpdb->query($wpdb->prepare($revo_conversation_messages,[]));
    }

    if (check_exist_database('revo_push_notification')) {
      $revo_push_notification = "CREATE TABLE `revo_push_notification` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `type` varchar(55) NULL DEFAULT NULL,
        `description` TEXT NULL DEFAULT NULL,
        `user_id` TEXT NULL DEFAULT NULL,
        `user_read` TEXT NULL DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`id`) USING BTREE)";

      $wpdb->query($wpdb->prepare($revo_push_notification,[]));
    }
  
    if (empty($where_cekpluginversion)) {
      $wpdb->insert('revo_mobile_variable',                  
                [
                  'slug' => 'plugin',
                  'title' => 'version',
                  'description' => $revo_plugin_version,
                ]);
    } else {
      $wpdb->update( 'revo_mobile_variable', ['description' =>  $revo_plugin_version], array( 'slug' => 'plugin'));
    }
  
    $cek_sql = "SELECT * FROM `revo_mobile_variable` WHERE `slug` = 'empty_image' AND `title` = 'login_required'";
    $cek_sql = $wpdb->get_row($cek_sql, OBJECT);
    if (empty($cek_sql)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('empty_images_5'));
    }

    $cek_sql = "SELECT * FROM `revo_mobile_variable` WHERE `slug` = 'empty_image' AND `title` = 'coupon_empty'";
    $cek_sql = $wpdb->get_row($cek_sql, OBJECT);
    if (empty($cek_sql)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('empty_images_6'));
    }
  
    $query_pp = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'privacy_policy'";
    $data_pp = $wpdb->get_row($query_pp, OBJECT);
    if (empty($data_pp)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('privacy_policy'));
    }
  
    $query_tc = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'term_condition'";
    $data_pp = $wpdb->get_row($query_tc, OBJECT);
    if (empty($data_pp)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('term_condition'));
    }
  
    $query_lc = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'license_code'";
    $data_pp = $wpdb->get_row($query_lc, OBJECT);
    if (empty($data_pp)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('license_code'));
    }
  
    // $query_intro_page_1 = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'intro_page' AND title LIKE '%Manage Everything%' ";
    // $where_pp_1 = $wpdb->get_row($query_intro_page_1, OBJECT);
    // if (!empty($where_pp_1)) {
    //   $intro_page_1 = data_default_MV('intro_page_1');
    //   $wpdb->update('revo_mobile_variable',$intro_page_1,['id' => $where_pp_1->id]);
    // }
  
    // $query_intro_page_2 = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'intro_page' AND title LIKE '%Support All Payments%' ";
    // $where_pp_2 = $wpdb->get_row($query_intro_page_2, OBJECT);
    // if (!empty($where_pp_2)) {
    //   $intro_page_2 = data_default_MV('intro_page_2');
    //   $wpdb->update('revo_mobile_variable',$intro_page_2,['id' => $where_pp_2->id]);
    // }
  
    // $query_intro_page_3 = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'intro_page' AND title LIKE '%Support All Shipping Methods%' ";
    // $where_pp_3 = $wpdb->get_row($query_intro_page_3, OBJECT);
    // if (!empty($where_pp_3)) {
    //   $intro_page_3 = data_default_MV('intro_page_3');
    //   $wpdb->update('revo_mobile_variable',$intro_page_3,['id' => $where_pp_3->id]);
    // }

    $query_all_intro_page = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'intro_page' ";
    $res_query_all_page = $wpdb->get_results($query_all_intro_page, OBJECT);
    if (!empty($res_query_all_page)) {
        foreach ($res_query_all_page as $query) {
          if (is_null(json_decode($query->title))) {
            $update_data = [
              'title' => '{"title": "' .$query->title . '"}', 
              'description' => '{"description": "' .$query->description . '"}', 
            ];

            $wpdb->update('revo_mobile_variable', $update_data, array( 'id' => $query->id ));
          }
        }
    }
  
    $query_searchbartext = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'searchbar_text' AND title = 'Search Bar Text' ";
    $where_searchbartext = $wpdb->get_row($query_searchbartext, OBJECT);
    if (empty($where_searchbartext)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('searchbar'));
    }
  
    $query_sosmedlink = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'sosmed_link' AND title = 'Social Media Link' ";
    $where_sosmedlink = $wpdb->get_row($query_sosmedlink, OBJECT);
    if (empty($where_sosmedlink)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('sosmed_link'));
    }
    
    $query_primcolor = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'app_color' AND title = 'primary' ";
    $where_primcolor = $wpdb->get_row($query_primcolor, OBJECT);
    if (empty($where_primcolor)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('app_primary_color'));
    }
    
    $query_seccolor = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'app_color' AND title = 'secondary' ";
    $where_seccolor = $wpdb->get_row($query_seccolor, OBJECT);
    if (empty($where_seccolor)) {
      $wpdb->insert('revo_mobile_variable',data_default_MV('app_secondary_color'));
    }

    $query_btncolor = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'app_color' AND title = 'button_color' ";
    $where_btncolor = $wpdb->get_row($query_btncolor, OBJECT);
    if (empty($where_btncolor)) {
      $wpdb->insert('revo_mobile_variable', data_default_MV('app_button_color'));
    }

    $query_txtbtncolor = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'app_color' AND title = 'text_button_color' ";
    $where_txtbtncolor = $wpdb->get_row($query_txtbtncolor, OBJECT);
    if (empty($where_txtbtncolor)) {
      $wpdb->insert('revo_mobile_variable', data_default_MV('app_text_button_color'));
    }
  
    $query_defbanner = "SELECT * FROM `revo_mobile_slider` ";
    $where_defbanner = $wpdb->get_results($query_defbanner, OBJECT);
    if (empty($where_defbanner)) {
      for ($i=1; $i <= 5; $i++) { 
        $wpdb->insert('revo_mobile_slider',data_default_MV('slider_banner_'.$i));
      }
    }
  
    $query_defposter = "SELECT * FROM `revo_list_mini_banner` ";
    $where_defposter = $wpdb->get_results($query_defposter, OBJECT);
    if (empty($where_defposter)) {
      for ($i=1; $i <= 10; $i++) { 
        $wpdb->insert('revo_list_mini_banner',data_default_MV('poster_banner_'.$i));
      }
    }

    $query_categories = "SELECT * FROM `revo_list_categories` ";
    $where_categories = $wpdb->get_results($query_categories, OBJECT);
    if (empty($where_categories)) {
      for ($i=1; $i <= 4; $i++) {
        $wpdb->insert('revo_list_categories', data_default_MV('home_categories_'.$i));
      }
    }

    $query_flash_sale = "SELECT * FROM `revo_flash_sale` ";
    $where_flash_sale = $wpdb->get_results($query_flash_sale, OBJECT);
    if (empty($where_flash_sale)) {
      $wpdb->insert('revo_flash_sale', data_default_MV('flash_sale'));
    }

    $query_popular_categories = "SELECT * FROM `revo_popular_categories` ";
    $where_popular_categories = $wpdb->get_results($query_popular_categories, OBJECT);
    if (empty($where_popular_categories)) {
      $wpdb->insert('revo_popular_categories', data_default_MV('popular_categories'));
    }

    $query_extend_products = "SELECT * FROM `revo_extend_products`";
    $where_extend_products = $wpdb->get_results($query_extend_products, OBJECT);
    if (empty($where_extend_products)) {
      for ($i = 1; $i <= 3; $i++) {
        $data = data_default_MV('additional_products_' . $i);

        $wpdb->query(
          "INSERT INTO `revo_extend_products` (type, title, description, products) VALUES $data"
        );
      }
    }
  }

  require (plugin_dir_path( __FILE__ ).'api/index.php');
  require (plugin_dir_path( __FILE__ ).'page/index.php');
  require (plugin_dir_path( __FILE__ ).'custom/index.php');


  /**
   * Register the Revo URL caching endpoints so they will be cached.
   */
  // function wprc_add_revo_endpoints( $allowed_endpoints ) {
  //     if ( ! isset( $allowed_endpoints[$revo_api_url] ) || ! in_array( 'cache', $allowed_endpoints[$revo_api_url] ) ) {
  //         $allowed_endpoints[$revo_api_url][] = 'cache';
  //     }
  //     return $allowed_endpoints;
  // }
  // add_filter( 'wp_rest_cache/allowed_endpoints', 'wprc_add_revo_endpoints', 10, 1);

  
  // add_filter( 'woocommerce_product_data_store_cpt_get_products_query', 'handle_custom_query_var', 10, 2 );
  // function handle_custom_query_var( $query, $query_vars ) {
  //     if ( isset( $query_vars['like_name'] ) && ! empty( $query_vars['like_name'] ) ) {
  //         $query['s'] = esc_attr( $query_vars['like_name'] );
  //     }

  //     return $query;
  // }

?>
