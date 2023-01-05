<?php
/*
* Template Name: Revo API
*/

function getValue(&$val, $default = '')
{
    return isset($val) ? $val : $default;
}

if(isset($_POST['order'])){
    $data = json_decode(urldecode(base64_decode($_POST['order'])), true);
}elseif (filter_has_var(INPUT_GET, 'order')) {
    $data = filter_has_var(INPUT_GET, 'order') ? json_decode(urldecode(base64_decode(filter_input(INPUT_GET, 'order'))), true) : [];
}

if (isset($data)):
    global $woocommerce;

    if (isset($data['token']) && $data['token'] != "") {

        // Validate the cookie token
        $userId = wp_validate_auth_cookie($data['token'], 'logged_in');
    
        if (!$userId) {
            echo "Invalid authentication cookie. Please log out and try to login again!";
            return;
        }

        // Check user and authentication
        $user = get_userdata($userId);
        if ($user) {        
            wp_set_current_user($userId, $user->user_login);
            wp_set_auth_cookie($userId);

            // $url = filter_has_var(INPUT_SERVER, 'REQUEST_URI') ? filter_input(INPUT_SERVER, 'REQUEST_URI') : '';
            // header("Refresh: 0; url=$url");
        }

        if (isset($data['wallet_tab'])){
            $urlWallet = get_permalink( get_option('woocommerce_myaccount_page_id') ).'woo-wallet/add';
            if ($data['wallet_tab'] == 'transfer'){
                $urlWallet = get_permalink( get_option('woocommerce_myaccount_page_id') ).'woo-wallet/transfer';
            }
            wp_redirect( $urlWallet );
            exit();
        }

    } elseif (!isset($data['token']) || $data['token'] == "") {

        if (get_option( 'woocommerce_enable_guest_checkout' ) != 'yes') {
            echo "Store not allow to checkout without an account. You can login to checkout";
            return;
        }

    }
            
    $woocommerce->session->set('refresh_totals', true);

    $billing  = $data['billing'];
    $shipping = $data['shipping'];

    if(!empty($data['line_items'])){

        $woocommerce->cart->empty_cart();

        $products = $data['line_items'];
        foreach ($products as $product) {
            $productId = absint($product['product_id']);

            $quantity = $product['quantity'];
            $variationId = getValue($product['variation_id'], null);
            // Check the product variation
            if (!empty($variationId)) {
                $productVariable = new WC_Product_Variable($productId);
                $listVariations = $productVariable->get_available_variations();
                foreach ($listVariations as $vartiation => $value) {
                    if ($variationId == $value['variation_id']) {
                        if(isset($product['variation'][0]) != false){
                            $attribute = $product['variation'][0];
                        }else{
                            $attribute = $value['attributes'];   
                        }
                        $woocommerce->cart->add_to_cart($productId, $quantity, $variationId, $attribute);
                    }
                }
            } else {
                $woocommerce->cart->add_to_cart($productId, $quantity);
            }
        }

    }

    if (!empty($data['coupon_lines'])) {
        $coupons = $data['coupon_lines'];
        foreach ($coupons as $coupon) {
            $woocommerce->cart->add_discount($coupon['code']);
        }
    }

    $shippingMethod = '';
    if (!empty($data['shipping_lines'])) {
        $shippingLines = $data['shipping_lines'];
        $shippingMethod = $shippingLines[0]['method_id'];
    }

    // aliexpress
    if (is_plugin_active('ali2woo/ali2woo.php')) {
        $aliexpress = $data['aliexpress'];
        if (count($aliexpress) >= 1) {
            $carts = array_values(WC()->cart->get_cart());

            foreach ($carts as $key => $cart) {
                foreach ($aliexpress as $a) {
                    if ($key + 1 == $a['cart']) {
                        WC()->cart->cart_contents[$cart['key']]['a2w_shipping_method'] = $a['shipping_method'];
                    }
                }
            }

            $packages = WC()->cart->get_shipping_packages();
            foreach ($packages as $package_key => $package) {
                WC()->session->set('shipping_for_package_' . $package_key, false);
            }
        }

        WC()->cart->calculate_shipping();
        WC()->cart->calculate_totals();
    }
    // end aliexpress

    $url_woo = wc_get_checkout_url();

    // polylang active
    if (is_plugin_active('polylang/polylang.php')) {
        if (function_exists('pll_default_language') || function_exists('pll_the_languages')) {
            if (!empty($data['lang'])) {
                $translations = pll_the_languages(array('raw' => true, 'hide_if_empty' => false));

                if ( array_key_exists($data['lang'], $translations) ) { 
                    $lang = $data['lang']; 

                    $checkout_post_id = url_to_postid( $url_woo );
                    $checkout_translate_id = pll_get_post($checkout_post_id, $lang);

                    if ($checkout_translate_id) {
                        $url_woo = get_page_link($checkout_translate_id);
                    }
                }
            }
        }
    }

    // WPML active
    if (is_plugin_active('sitepress-multilingual-cms/sitepress.php')) {
        $languages = apply_filters( 'wpml_active_languages', NULL );

        if ( !empty($data['lang']) && array_key_exists($data['lang'], $languages) ) {
            $url_woo = apply_filters( 'wpml_permalink', $url_woo, $data['lang'], true );
        }
    }

    wp_redirect( $url_woo );
    exit;
endif;
?>
