<?php

include plugin_dir_path(__FILE__)."templates/class-mobile-detect.php";
include plugin_dir_path(__FILE__)."templates/class-rename-generate.php";
include_once plugin_dir_path(__FILE__)."controllers/FlutterUser.php";

class RevoCheckOut
{
    public $version = '2.1.6';

    protected $checkout_template = 'revo-checkout-template.php';

    public function __construct()
    {
        define('REVO_CHECKOUT_VERSION', $this->version);
        define('REVO_PLUGIN_FILE', __FILE__);
        include_once (ABSPATH . 'wp-admin/includes/plugin.php');
        if (is_plugin_active('woocommerce/woocommerce.php') == false) {
            return 0;
        }

        $path = get_template_directory()."/templates";
        if (!file_exists($path)) {
            mkdir($path, 0777, true);
        }

        $templatePath = plugin_dir_path(__FILE__) . "templates/" . $this->checkout_template;
        if (!copy($templatePath, $path . "/" . $this->checkout_template)) {
            return 0;
        }

        $order = filter_has_var(INPUT_GET, 'order') && strlen(filter_input(INPUT_GET, 'order')) > 0 ? true : false;
        if ($order) {
            add_filter('woocommerce_is_checkout', '__return_true');
        }

        add_action('wp_print_scripts', array($this, 'handle_received_order_page'));

        //add meta box shipping location in order detail
        add_action( 'add_meta_boxes', 'mv_add_meta_boxes' );
        if ( ! function_exists( 'mv_add_meta_boxes' ) )
        {
            function mv_add_meta_boxes()
            {
                add_meta_box( 'mv_other_fields', __('Shipping Location','woocommerce'), 'mv_add_other_fields_for_packaging', 'shop_order', 'side', 'core' );
            }
        }

        // Adding Meta field in the meta container admin shop_order pages
        if ( ! function_exists( 'mv_add_other_fields_for_packaging' ) )
        {
            function mv_add_other_fields_for_packaging()
            {
                global $post;
                echo '<div class="mapouter"><div class="gmap_canvas"><iframe width="600" height="500" id="gmap_canvas" src="'.$post->post_excerpt.'" frameborder="0" scrolling="no" marginheight="0" marginwidth="0"></iframe><a href="https://www.embedgooglemap.net/blog/best-wordpress-themes/">embedgooglemap.net</a></div><style>.mapouter{position:relative;text-align:right;height:500px;width:600px;}.gmap_canvas {overflow:hidden;background:none!important;height:500px;width:600px;}</style></div>';
            }
        }
    }

    public function handle_received_order_page()
    {
        // default return true for getting checkout library working
        if (is_order_received_page()) {
            $detect = new MDetect;
            if ($detect->isMobile()) {
                wp_register_style('revo-order-custom-style', plugins_url('assets/css/revo-order-style.css', REVO_PLUGIN_FILE));
                wp_enqueue_style('revo-order-custom-style');
            }
        }

    }

    public function get_checkout_template () {
        return $this->checkout_template;
    }
}

$RevoCheckOut = new RevoCheckOut();
$revo_checkout_template = $RevoCheckOut->get_checkout_template();

// use JO\Module\Templater\Templater;
include plugin_dir_path(__FILE__)."wp-templater/src/Templater.php";

add_action('init', 'json_apiCheckAuthCookie', 100);

//custom rest api
function users_routes() {
    $controller = new FlutterUserController();
    $controller->register_routes();
} 

add_action( 'rest_api_init', 'users_routes' );
add_action( 'rest_api_init', 'my_register_route' );
function my_register_route() {
    register_rest_route( 'order', 'verify', array(
                    'methods' => 'GET',
                    'callback' => 'check_payment'
                )
            );
}

function check_payment() {
    return true;
}

function json_apiCheckAuthCookie()
{
    global $json_api;

    if (!empty($json_api)) {
        if (!empty($json_api->query)) {
            if ($json_api->query->cookie) {
                $user_id = wp_validate_auth_cookie($json_api->query->cookie, 'logged_in');
                if ($user_id) {
                    $user = get_userdata($user_id);
                    wp_set_current_user($user->ID, $user->user_login);
                }
            }
        }
    }

    global $wpdb;
    
    $posts = $wpdb->get_row("SELECT id FROM $wpdb->posts WHERE post_name = 'revo-checkout' and post_type = 'page' and post_status = 'publish'", OBJECT);
  
 	if(empty($posts)){
      add_checkout_page();
    }
    
}

function add_checkout_page() {
    global $revo_checkout_template;

    $page = get_page_by_title('Revo Checkout');
    $meta_value = get_post_meta($page->ID, '_wp_page_template');

    if ($page == null || strpos($page->post_name,"revo-checkout") === false || $page->post_status != "publish") {
        $my_post = array(
            'post_type' => 'page',
            'post_name' => 'revo-checkout',
            'post_title'    => 'Revo Checkout',
            'post_status'   => 'publish',
            'post_author'   => 1,
            'post_type'     => 'page'
        );

        // Insert the post into the database
        $page_id = wp_insert_post( $my_post );
        update_post_meta( $page_id, '_wp_page_template', 'templates/' . $revo_checkout_template );

        return;
    }

    if ($meta_value[0] !== 'templates/' . $revo_checkout_template ) {
        update_post_meta( $page->ID, '_wp_page_template', 'templates/' . $revo_checkout_template);
    }
}

add_filter( 'woocommerce_rest_prepare_product_variation_object','custom_woocommerce_rest_prepare_product_variation_object' );
add_filter( 'woocommerce_rest_prepare_product_object','custom_change_product_response', 20, 3 );
function custom_change_product_response( $response ) {
    global $woocommerce_wpml;

    if ( ! empty( $woocommerce_wpml->multi_currency ) && ! empty( $woocommerce_wpml->settings['currencies_order'] ) ) {

        $type  = $response->data['type'];
        $price = $response->data['price'];

            foreach ( $woocommerce_wpml->settings['currency_options'] as $key => $currency ) {
                $rate = (float)$currency["rate"];
                $response->data['multi-currency-prices'][ $key ]['price'] = $rate == 0 ? $price : sprintf("%.2f", $price*$rate);
            }
    }

    return $response;
}

function custom_woocommerce_rest_prepare_product_variation_object( $response ) {

    global $woocommerce_wpml;

    if ( ! empty( $woocommerce_wpml->multi_currency ) && ! empty( $woocommerce_wpml->settings['currencies_order'] ) ) {

        $type  = $response->data['type'];
        $price = $response->data['price'];

            foreach ( $woocommerce_wpml->settings['currency_options'] as $key => $currency ) {
                $rate = (float)$currency["rate"];
                $response->data['multi-currency-prices'][ $key ]['price'] = $rate == 0 ? $price : sprintf("%.2f", $price*$rate);
            }
    }

    return $response;
}

/**
 * Uncomment this hooks if total and shipping price not showing when plugin aliexpress activated
 * 
 */
// if (is_plugin_active('ali2woo/ali2woo.php')) {
//     add_action('woocommerce_review_order_before_order_total', function () {
//         if (!wp_doing_ajax()) {
//             $shipping_total = WC()->cart->get_cart_shipping_total();
//             echo "<tr> 
//                     <th>Shipping</th>
//                     <td>{$shipping_total}</td>
//                 </tr>";
//         }
//     });

//     add_action( 'woocommerce_review_order_before_order_total', function () {
//         if (!wp_doing_ajax()) {
//             global $woocommerce;
//             $newTotal = $woocommerce->cart->get_total();

//             echo '<td style="position: absolute; right: 0; bottom: 0;">' . $newTotal . '</td>';
//         }
//     });
// }