<?php

class Revo_Flutter_Mobile_App_Public
{

    private $plugin_name;

    private $version;

    public function __construct()
    {

        $this->plugin_name = '';
        $this->version = '';

    }

    public function product_attributes(){

        $attributes = array();

        $category = $_REQUEST['category'];

        $args = array(
            'tax_query' => array(
                array(
                    'taxonomy' => 'product_cat',
                    'terms' => $category,
                    'operator' => 'IN',
                )
            ),
            'post_status' => 'publish',
        );

        foreach( wc_get_products($args) as $product ){

            foreach( $product->get_attributes() as $attr_name => $attr ){

                if( array_search($attr_name, array_column($attributes, 'id')) === false )
                $attributes[] = array(
                    'id' => $attr_name,
                    'name' => wc_attribute_label( $attr_name ),
                    'terms' => $this->get_attribute_terms($attr_name)
                );

            }
        }

        wp_send_json($attributes);

        die();

    }

    public function get_attribute_terms($attr_name){
        $terms = get_terms($attr_name,array(
            "hide_empty" => true,
        ));
        if(is_array($terms))
        return $terms;
        else return array();
    }

    public function set_user_cart(){
        global $woocommerce;
        $headers = apache_request_headers();
        $user_id = '';
        foreach ($headers as $header => $value) {
            if($header == 'user_id') {
                $user_id = $value;
                wp_set_current_user( $user_id );
                wp_set_auth_cookie( $user_id );
            }
        } if($user_id == '') {
            //
        }
        die();
    }

    public function add_all_products_cart(){
        global $woocommerce;
        $woocommerce->cart->empty_cart();

        $headers = apache_request_headers();
        json_decode('{foo:"bar"}');

        //** Add all Items To Cart **/
        /*global $woocommerce;
        $woocommerce->cart->empty_cart();
        $woocommerce->cart->add_to_cart( 499, 10 );*/
        wp_send_json(wp_get_current_user());

    }

    public function getRegoins($reg) {
        foreach ($reg as $key => $value) {
            $data[] = array(
                'label' => $value,
                'value' => (String)$key,
            );
        }
        return $data;
    }

    public function get_products($data = array()){

        // polylang active
        if (function_exists( 'pll_default_language' ) && function_exists( 'pll_the_languages' )) {
            $languages = pll_the_languages([
                'raw' => true, 
                'hide_if_empty' => false
            ]);

            $lang = pll_default_language();

            if ( !empty($data['lang']) && array_key_exists($data['lang'], $languages) ) { 
                $countProduct = pll_count_posts( $data['lang'], [
                    'post_type' => 'product'
                ] );

                if ($countProduct >= 1) {
                    $lang = $data['lang'];
                }
            }

            $args['lang'] = $lang;
        }

        // wpml active
        if (is_plugin_active('sitepress-multilingual-cms/sitepress.php')) {
            // $path = explode('/', $_SERVER['REDIRECT_URL']);
            // if ($path[array_key_last($path)] == 'list-produk') {}

            $languages = apply_filters( 'wpml_active_languages', NULL );
            $lang = apply_filters('wpml_default_language', NULL );

            if ( !empty($data['lang']) ) { 
                if ( $lang != $data['lang'] && array_key_exists($data['lang'], $languages) ) {
                    do_action( 'wpml_switch_language', $data['lang'] );

                    $check_product_exist = wc_get_products([
                        'posts_per_page' => 1,
                        'suppress_filters' => false
                    ]);

                    if ($check_product_exist >= 1) {
                        $lang = $data['lang'];
                    }
                }
            }

            do_action( 'wpml_switch_language', $lang );
        }

        if ( ! empty( $data['attribute'] ) ) {
            
            // $tax_query   = WC()->query->get_tax_query();

            // for ($i=0; $i < count($data['attribute']); $i++) {

            //     $tax_query[] = array(
            //         'taxonomy' => $data['attribute'][$i]->taxonomy,
            //         'field'    => 'slug',
            //         'terms'    => $data['attribute'][$i]->terms,
            //     );

            // }

            $taxonomy = wc_attribute_taxonomy_name_by_id($data['attribute']);

            $terms = get_terms([
                'taxonomy' => $taxonomy, 
                'hide_empty' => false,
                'fields' => 'names'
            ]);

            $tax_query[] = [
                'taxonomy' => $taxonomy,
                'field' => 'slug',
                'terms' => $terms,
            ];
        }

        // if ( ! empty( $data['wcpv_product_vendors'] ) ) {
        //     $tax_query[] = array(
        //         'taxonomy' => 'wcpv_product_vendors',
        //         'field'    => 'id',
        //         'terms'    => $data['wcpv_product_vendors'],
        //     );
        // }

        // featured
        if ( ! empty( $data['featured'] ) ) {
            $tax_query[] = array(
                'taxonomy' => 'product_visibility',
                'field'    => 'name',
                'terms'    => 'featured',
                'operator' => 'IN',
            );
        }
        
        $orderby = isset( $data['order_by'] ) ? $data['order_by'] : 'date';
        $order = isset( $data['order'] ) ? $data['order'] : 'DESC';

        switch ( $orderby ) {
            case 'id':
                $args['orderby'] = 'ID';
                break;
            case 'menu_order':
                $args['orderby'] = 'menu_order title';
                break;
            case 'name':
                $args['orderby'] = 'name';
                $args['order']   = ( 'DESC' === $order ) ? 'DESC' : 'ASC';
                break;
            case 'relevance':
                $args['orderby'] = 'relevance';
                $args['order']   = 'DESC';
                break;
            case 'rand':
                $args['orderby'] = 'rand'; // @codingStandardsIgnoreLine
                break;
            case 'date':
                $args['orderby'] = 'date ID';
                $args['order']   = ( 'ASC' === $order ) ? 'ASC' : 'DESC';
                break;
            case 'price':
                // $callback = 'DESC' === $order ? 'order_by_price_desc_post_clauses' : 'order_by_price_asc_post_clauses';
                // add_filter( 'posts_clauses', array( $this, $callback ) );
                $args['orderby'] = 'meta_value_num';
                $args['meta_key'] = '_price';
                if($order == 'asc') {
                    $args['order'] = 'asc';
                } else {
                    $args['order'] = 'desc';
                }
                break;

                // https://wordpress.stackexchange.com/questions/203240/order-by-rating-not-works-in-wp-query (sort by price & popularity)

            case 'popularity':
                // add_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
                $args['orderby'] = 'meta_value_num';
                $args['meta_key'] = 'total_sales';
                break;
            case 'rating':
                add_filter( 'posts_clauses', array( $this, 'order_by_rating_post_clauses' ) );
                break;
        }

        if (! empty( $data['tag'] )) {
            $args = array(
                'tag' => array( $data['tag'] ),
            );
        }

        // Filter by on sale products.
        if (isset($data['on_sale']) != false) {
            $on_sale_key = $data['on_sale'] == '1' ? 'post__in' : 'post__not_in';
            $on_sale_ids = wc_get_product_ids_on_sale();

            // Use 0 when there's no on sale products to avoid return all products.
            $on_sale_ids = empty( $on_sale_ids ) ? array( 0 ) : $on_sale_ids;

            $args['include'] = $on_sale_ids;
        }

        // Filter by on sale products.
        if (!empty($data['include'])) {
            $include = explode(',', $data['include']);
            $args['include'] = $include;
        }
        
        // for request from rest_product_flash_sale & rest_additional_products
        if (isset( $_POST['include'] )) {
            $args['include'] = json_decode($_POST['include']);
        }
        // end

        // if ( isset( $data['include'] ) ) {
        //     $args['include'] = json_decode($data['include']);
        // }

        // search
        // if ( ! empty( $data['search'] ) ) {
            // $args['s'] = $data['search'];
            // add_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
        // }

        // search
        if (! empty( $data['id'] )) {
            // $tax_query[] = array(
            //     'taxonomy' => 'product_cat',
            //     'field'    => 'term_id',
            //     'terms'    => $data['id'],
            // );
            $args['include'] = array($data['id']);
        }

        // Build tax_query if taxonomies are set.
        if (! empty( $tax_query )) {
            if ( ! empty( $data['tax_query'] ) ) {
                $args['tax_query'] = array_merge( $tax_query, $data['tax_query'] ); // WPCS: slow query ok.
            } else {
                $args['tax_query'] = $tax_query; // WPCS: slow query ok.
            }
        }

        // Page filter.
        // if ( ! empty( $data['page'] ) ) {
        //     $args['page'] = $data['page'];
        // }

        $args['post_status'] = 'publish';

        $args['post_type'] = array( 'product', 'product_variation' );

        if (isset( $data['product_id'] )) {
            $include = explode(',', $data['product_id']);
            $args['include'] = $include;
        }

        if (!empty($data['category'])) {
            $categories = explode(',', $data['category']);
            $categoriesSlug = [];
            if (is_array($categories)) {
                for ($i=0; $i < count($categories); $i++) {
                    $term = get_term_by('id', $categories[$i], 'product_cat', 'ARRAY_A');
                    if (!empty($term)) {
                        $categoriesSlug[] = $term['slug'];
                    }
                }
            }
            $args['category'] = $categoriesSlug;
        }

        if (!empty($data['slug_category'])) {

            $args['category'][] = $data['slug_category'];

            $args['category'] = array_unique($args['category']);

        }

        // Page filter.
        if (!empty( $data['page'] )) {
            $args['page'] = $data['page'];
        }

        if (!empty( $data['slug'] )) {
            $args['slug'] = $data['slug'];
            $product_obj = get_page_by_path( $data['slug'], OBJECT, 'product' );
            // print_r(get_object_vars($product_obj)['ID']); die;
            $args['include'] = array(get_object_vars($product_obj)['ID']);
        }

        if (!empty($data['limit'])) {
            $args['limit'] = $data['limit'];
        }

        if (!empty($data['stock_status'])) {
            $args['stock_status'] = $data['stock_status'];
            // $args['stock_status'] = 'outofstock'; // or 'outofstock' or 'onbackorder'
        }

        $check_config_out_of_stock = query_revo_mobile_variable('"show_out_of_stock_product"', 'sort')[0];
		$check_config_out_of_stock = !empty($check_config_out_of_stock) && $check_config_out_of_stock->description === 'show' ? false : true;
		if ($check_config_out_of_stock) {
			$args['stock_status'] = 'instock';
		}
                
        // if (!empty($data['price_range'])) {
        //     $args['price_range'] = $data['price_range'];
        // }
        
        if (!empty($data['search'])){
            
            $search = $data['search'];
        }
        
        if (!empty($data['exclude_sku'])){
            
            $exclude_sku = $data['exclude_sku'];
        }
        
        // search product with sku
        if (!empty($data['sku']) || !empty($data['search'])) {
            $data_sku = explode(',', (!empty($data['sku']) ? $data['sku'] : $data['search']));
            foreach ($data_sku as $data) {
                $get_data_product_by_sku = $this->get_product_by_sku($data);
                
                if(!empty($get_data_product_by_sku)){
                    $id_product_by_sku[] = $get_data_product_by_sku->get_id();
                }
            }
            
            if(!empty($id_product_by_sku)){
                $args['include'] = $id_product_by_sku;
            }  
        } 
        
        if ($exclude_sku) {
            $get_data_exclude_product_by_sku = $this->get_exclude_product_by_sku($data['exclude_sku']);
            
            foreach ($get_data_exclude_product_by_sku as $data => $key) {
                $id_exclude_product_by_sku[] = $key->post_id;
            }
            $args['exclude'] = $id_exclude_product_by_sku;
        
            if(!empty($args['include'])) {
                
                foreach ($args['include'] as $data) {
                    
                    $cek_exclude_product = array_search($data,$args['exclude']);
                    
                    if(empty($cek_exclude_product)){
                        $include_new[] = $data;
                    }
                    
                }
            
                $args['include'] = $include_new;
                
            }
        }
        
        if (empty($args['include']) || !empty($search)){ 
            unset($args['include']);
            
            if(!empty($search)){
                $args['s'] = $search;
                $args['meta_query'] = [
                    [
                        'key' => '_title',
                        'value' => $search,
                        'compare' => 'LIKE',
                    ]
                ];
            }
        }

        $cookie = is_null(cek_raw('cookie')) || empty(cek_raw('cookie')) ? $_GET['cookie'] : cek_raw('cookie');
        $user   = get_userdata(wp_validate_auth_cookie($cookie, 'logged_in'));

        if ($status_membership_plugin = is_plugin_active('woocommerce-memberships/woocommerce-memberships.php')) {
            $service_membership_discount = new WC_Memberships_Member_Discounts();

            if (strpos($_SERVER['REDIRECT_URL'], 'memberships/products') === false) {

                $args['tax_query'] = array([
                    'taxonomy' => 'product_cat',
                    'field'    => 'id',
                    'terms'    => array( get_option('revo_membership_selected_category', '') ), // HERE the product category to exclude
                    'operator' => 'NOT IN',
                ]);

            }
        }

        $products = wc_get_products( $args );

        if (is_plugin_active('sitepress-multilingual-cms/sitepress.php')) {
            
            if (empty($products)) {

                $default_lang = 'en';

                $list_lang = apply_filters( 'wpml_active_languages', NULL );

                $default_lang = array_values($list_lang)[0]['code'];

                do_action( 'wpml_switch_language', $default_lang );

                $products = wc_get_products( $args );

            }
            
        }
        
        $results = array();

        foreach ($products as $i => $product) {
            // wpml active
            // if (is_plugin_active('sitepress-multilingual-cms/sitepress.php') && !empty($data['lang'])) {
            //     $path = explode('/', $_SERVER['REDIRECT_URL']); 
            //     if ($path[array_key_last($path)] != 'home-api' && $data['order_by'] != 'rand') {
            //         $wpml_filter = apply_filters('wpml_post_language_details', NULL, $product->get_id());

            //         if ($data['lang'] != $wpml_filter['language_code']) {
            //             continue;
            //         }
            //     }
            // }

            $available_variations = $product->get_type() == 'variable' ? $product->get_available_variations() : null;
            $variation_attributes = $product->get_type() == 'variable' ? $product->get_variation_attributes() : null;

            $variation_options = array();
            $emptyValuesKeys = array();
            if ($available_variations != null) {
                $values = array();

                foreach ( $available_variations as $key => $value ) {
                    foreach ( $value['attributes'] as $atr_key => $atr_value ) {
                        $available_variations[$key]['option'][] = array(
                            'key' => $atr_key,
                            'value' => $this->attribute_slug_to_title($atr_key, $atr_value) //make it name
                        );

                        $values[] = $this->attribute_slug_to_title($atr_key, $atr_value);
                        if (empty($atr_value)) {
                            $emptyValuesKeys[] = $atr_key;
                        }

                        $variation = wc_get_product( $value['variation_id'] );

                        $available_variations[$key]['minmax_quantity'] = (function ($variation) {
                            $min_qty = get_post_meta( $variation->get_id(), 'min_quantity_var', true );   // min is empty = parse to "1"
                            $max_qty = get_post_meta( $variation->get_id(), 'max_quantity_var', true );   // max is empty = parse to "999"
                            $sold_individually = $variation->get_sold_individually();

                            if (!is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php')) {
                                $min_qty = 1;
                                $max_qty = !$sold_individually ? 999 : 1;
                            }

                            return [
                                'min_quantity' => (int) (empty($min_qty) ? 1 : $min_qty),
                                'max_quantity' => (int) (empty($max_qty) ? 999 : $max_qty),
                            ];
                        })($variation);

                        unset($available_variations[$key]['min_qty']);
                        unset($available_variations[$key]['max_qty']);

                        $regular_price = $variation->get_regular_price();
                        $sale_price = $variation->get_sale_price();

                        // membership price
                        if ($status_membership_plugin) {
                            if (wc_memberships_user_has_member_discount($variation, $user)) {
                                $sale_price = $service_membership_discount->get_discounted_price($variation->get_price(), $variation, $user->ID);

                                $available_variations[$key]['display_price'] = (double) $sale_price;
                            }
                        }

                        $available_variations[$key]['formated_price'] = $regular_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $regular_price ) ))) : strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_price() ) )));
                        $available_variations[$key]['formated_sales_price'] = $sale_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $sale_price ) ))) : null;
                        $available_variations[$key]['meta_data'] = $variation->get_meta_data();
                    }

                    $available_variations[$key]['image_id'] = null;
                }

                if ($variation_attributes) {
                    foreach ( $variation_attributes as $attribute_name => $options ) {

                        $new_options = array();
                        foreach (array_values($options) as $key => $value) {
                            $new_options[] = $this->attribute_slug_to_title($attribute_name, $value);
                        }
                        if (!in_array('attribute_' . $attribute_name, $emptyValuesKeys)) {
                            $options = array_intersect ( array_values($new_options) , $values );
                        }
                        $variation_options[] = array(
                            'name' => wc_attribute_label( $attribute_name ),
                            'options'   => array_values($options),
                            'attribute' => wc_attribute_label($attribute_name),
                        );
                    }
                }
            }

            /* Used for only Grocery APP */
            $children = array();
            if ( $product->get_type() == 'grouped' ) {
                $ids = array_values( $product->get_children( 'view' ) );
                $args = array(
                    'include' => $ids,
                );
                $children = empty($args['include']) ? array() : $this->get_grouped_products($args);
            }

            $is_wistlist = false;
            if ($user){
                $get = query_hit_products($product->get_id(), $user->ID);
                if ($get->is_wistlist == 1) {
                    $is_wistlist = true;
                }
            }

            $categories = get_the_terms( $product->get_id(), 'product_cat' );
            if (empty($categories)) {
                $categories = array();
            }

            $result = array(
                'id' => $product->get_id(),
                'name' => $product->get_name(),
                'is_wistlist' => $is_wistlist,
                'sku' => $product->get_sku( 'view' ),
                'type' => $product->get_type(),
                'status' => $product->get_status(),
                'permalink'  => $product->get_permalink(),
                'description' => $product->get_description(),
                'short_description' => $product->get_short_description(),
                'formated_price' => $product->get_regular_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_regular_price() ) ))) : strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_price() ) ))),
                'formated_sales_price' => $product->get_sale_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_sale_price() ) ))) : null,
                'price' => (double)$product->get_price(),
                'regular_price' => (double)$product->get_regular_price(),
                'sale_price' => (double)$product->get_sale_price(),
                'stock_status' => $product->get_stock_status(),
                'stock_quantity' => $product->get_stock_quantity(),
                'sold_individually' => is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php') ? false : $product->get_sold_individually(),
                'minmax_quantity'   => (function ($product) {
                    $min_qty = get_post_meta( $product->get_id(), 'min_quantity', true );   // min is empty = parse to "1"
                    $max_qty = get_post_meta( $product->get_id(), 'max_quantity', true );   // max is empty = parse to "999"
                    $sold_individually = $product->get_sold_individually();

                    if (!is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php')) {
                        $min_qty = 1;
                        $max_qty = !$sold_individually ? 999 : 1;
                    } else if ($sold_individually && empty($min_qty) && empty($max_qty)) {
                        $min_qty = 1;
                        $max_qty = 1;
                    } else {
                        $min_qty = empty($min_qty) ? 1 : $min_qty;
                        $max_qty = empty($max_qty) ? 999 : $max_qty;
                    }

                    return [
                        'min_quantity' => (int) $min_qty,
                        'max_quantity' => (int) $max_qty,
                    ];
                })($product),
                'on_sale' => $product->is_on_sale( 'view' ),
                'average_rating'        => wc_format_decimal( $product->get_average_rating(), 2 ),
                'rating_count'          => $product->get_rating_count(),
                'related_ids'           => array_map( 'absint', array_values( wc_get_related_products( $product->get_id() ) ) ),
                'upsell_ids'            => array_map( 'absint', $product->get_upsell_ids( 'view' ) ),
                'cross_sell_ids'        => array_map( 'absint', $product->get_cross_sell_ids( 'view' ) ),
                'parent_id'             => $product->get_parent_id( 'view' ),
                'images' => $this->get_images($product),
                'attributes'            => $this->get_attributes( $product ),
                'attributes_v2'         => $this->get_attributes_v2( $product ),
                'availableVariations'   => $available_variations,
                'variationAttributes'   => $variation_attributes,
                'meta_data'             => $product->get_meta_data(),
                'variationOptions'      => $variation_options,
                'total_sales'           => (int)$product->get_total_sales(),
                'vendor'                => $this->get_product_vendor($product->get_id()),
                'grouped_products'      => $product->get_children(),
                'children'              => $children,
                'categories'            => $categories,
                'tags'                  => wc_get_object_terms( $product->get_id(), 'product_tag', 'name' ),
                //'cashback_amount'       => woo_wallet()->cashback->get_product_cashback_amount($product) //UnComment Whne cashback need only
                'dimensions'            => $product->get_dimensions(false)
            );

            if ($status_membership_plugin) {
                if (wc_memberships_user_has_member_discount($product, $user)) {
                    $price = $service_membership_discount->get_discounted_price($product->get_price(), $product, $user->ID);

                    $result['price'] = (double) $price;

                    if ($result['type'] !== 'variable') {
                        $result['formated_sales_price'] = strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $price ) )));
                        $result['sale_price'] = (double) $price;
                    }
                }
            }

            $result['dimensions']['weight'] = $product->get_weight();
            
            $ws = '';
            $wsPriceKey = 'wholesale_customer_wholesale_price';
            $meta_data = $product->get_meta_data();
            $check = array_search($wsPriceKey, array_column($meta_data,'key'));

            if ($check !== false) {
                $ws = [['price' => $meta_data[$check]->value]];
                $result['is_variant'] = false;
            } else {
                $result['is_variant'] = true;
                $wsRaw = [];

                for ($i=0; $i < count($meta_data); $i++) {
                    $value = $meta_data[$i];
                    if ($value->key == 'wholesale_customer_variations_with_wholesale_price') {
                        $product_variation = (new WC_Product_Variation($value->value))->get_meta_data();
                        $data = array_map(function ($v) use ($value) {
                            return [
                                'id'=>$value->value,
                                'price'=>$v->value,
                            ];
                        }, array_filter($product_variation,function ($v) use ($wsPriceKey) {
                            return $v->key == $wsPriceKey;
                        }));

                        // $data = $product_variation;
                        array_push($wsRaw,$data);
                    }
                }

                if (!empty($wsRaw)) {
                    $ws = call_user_func_array('array_merge', $wsRaw);
                } // handling
            }

            $result['wholesales'] = $ws;

            $results[] = $result;
        }

        remove_filter( 'posts_clauses', array( $this, 'order_by_price_asc_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_price_desc_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_rating_post_clauses' ) );

        return $results;
    }

    public function get_products_custom($data = array()) {
        global $wpdb;

        $user = get_userdata(wp_validate_auth_cookie($data['cookie'], 'logged_in'));
        $user_roles = $user->roles;

        if (!empty($data['attribute'])) {
            
            $tax_query = WC()->query->get_tax_query();

            for ($i=0; $i < count($data['attribute']); $i++) {

                $tax_query[] = array(
                    'taxonomy' => $data['attribute'][$i]->taxonomy,
                    'field'    => 'slug',
                    'terms'    => $data['attribute'][$i]->terms,
                );

            }
        }

        // featured
        if (!empty($data['featured'])) {
            $tax_query[] = array(
                'taxonomy' => 'product_visibility',
                'field'    => 'name',
                'terms'    => 'featured',
                'operator' => 'IN',
            );
        }
        
        $orderby = isset($data['order_by']) ? $data['order_by'] : 'date';
        $order = isset($data['order']) ? $data['order'] : 'DESC';

        switch ( $orderby ) {
            case 'id':
                $args['orderby'] = 'ID';
                break;
            case 'menu_order':
                $args['orderby'] = 'menu_order title';
                break;
            case 'name':
                $args['orderby'] = 'name';
                $args['order']   = ( 'DESC' === $order ) ? 'DESC' : 'ASC';
                break;
            case 'relevance':
                $args['orderby'] = 'relevance';
                $args['order']   = 'DESC';
                break;
            case 'rand':
                $args['orderby'] = 'rand'; // @codingStandardsIgnoreLine
                break;
            case 'date':
                $args['orderby'] = 'date ID';
                $args['order']   = ( 'ASC' === $order ) ? 'ASC' : 'DESC';
                break;
            case 'price':
                // $callback = 'DESC' === $order ? 'order_by_price_desc_post_clauses' : 'order_by_price_asc_post_clauses';
                // add_filter( 'posts_clauses', array( $this, $callback ) );
                $args['orderby'] = 'meta_value_num';
                $args['meta_key'] = '_price';
                if($order == 'asc') {
                    $args['order'] = 'asc';
                } else {
                    $args['order'] = 'desc';
                }
                break;

                // https://wordpress.stackexchange.com/questions/203240/order-by-rating-not-works-in-wp-query (sort by price & popularity)

            case 'popularity':
                // add_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
                $args['orderby'] = 'meta_value_num';
                $args['meta_key'] = 'total_sales';
                break;
            case 'rating':
                add_filter( 'posts_clauses', array( $this, 'order_by_rating_post_clauses' ) );
                break;
        }

        if (!empty( $data['tag'])) {
            $args = array(
                'tag' => array( $data['tag'] ),
            );
        }

        // Filter by on sale products.
        if (isset($data['on_sale']) != false) {
            $on_sale_key = $data['on_sale'] == '1' ? 'post__in' : 'post__not_in';
            $on_sale_ids = wc_get_product_ids_on_sale();

            // Use 0 when there's no on sale products to avoid return all products.
            $on_sale_ids = empty( $on_sale_ids ) ? array( 0 ) : $on_sale_ids;

            $args['include'] = $on_sale_ids;
        }

        // Filter by on sale products.
        if (!empty($data['include'])) {
            $include = explode(',', $data['include']);
            $args['include'] = $include;
        }
        
        // for request from rest_product_flash_sale & rest_additional_products
        if (isset($_POST['include'])) {
            $args['include'] = json_decode($_POST['include']);
        }

        // search
        if (!empty($data['id'])) {
            // $tax_query[] = array(
            //     'taxonomy' => 'product_cat',
            //     'field'    => 'term_id',
            //     'terms'    => $data['id'],
            // );
            $args['include'] = array($data['id']);
        }

        // Build tax_query if taxonomies are set.
        if (!empty($tax_query)) {
            if ( ! empty( $data['tax_query'] ) ) {
                $args['tax_query'] = array_merge( $tax_query, $data['tax_query'] ); // WPCS: slow query ok.
            } else {
                $args['tax_query'] = $tax_query; // WPCS: slow query ok.
            }
        }

        $args['post_status'] = 'publish';
        $args['post_type'] = array( 'product', 'product_variation' );

        if (isset($data['product_id'])) {
            $include = explode(',', $data['product_id']);
            $args['include'] = $include;
        }

        if (!empty($data['category'])) {
            $categories = explode(',', $data['category']);
            $categoriesSlug = [];
            if (is_array($categories)) {
                for ($i=0; $i < count($categories); $i++) {
                    $term = get_term_by('id', $categories[$i], 'product_cat', 'ARRAY_A');
                    if (!empty($term)) {
                        $categoriesSlug[] = $term['slug'];
                    }
                }
            }
            $args['category'] = $categoriesSlug;
        }

        // Page filter.
        if (!empty($data['page'])) {
            $args['page'] = $data['page'];
        }

        if (!empty($data['slug'])) {
            $args['slug'] = $data['slug'];
            $product_obj = get_page_by_path( $data['slug'], OBJECT, 'product' );
            // print_r(get_object_vars($product_obj)['ID']); die;
            $args['include'] = array(get_object_vars($product_obj)['ID']);
        }

        if (!empty($data['limit'])) {
            $args['limit'] = $data['limit'];
        }

        if (!empty($data['stock_status'])) {
            $args['stock_status'] = $data['stock_status'];
            // $args['stock_status'] = 'outofstock'; // or 'outofstock' or 'onbackorder'
        }
        
        if (!empty($data['search'])) {
            
            $search = $data['search'];
        }
        
        if (!empty($data['exclude_sku'])) {
            
            $exclude_sku = $data['exclude_sku'];
        }
        
        // search product with sku
        if (!empty($data['sku']) || !empty($data['search'])) {
            $data_sku = explode(',', (!empty($data['sku']) ? $data['sku'] : $data['search']));
            foreach ($data_sku as $sku) {
                $get_data_product_by_sku = $this->get_product_by_sku($sku);

                if (!empty($get_data_product_by_sku)) {
                    $id_product_by_sku[] = $get_data_product_by_sku->get_id();
                }
            }
            
            if (!empty($id_product_by_sku)) {
                $args['include'] = $id_product_by_sku;
            }
        } 

        if ($exclude_sku) {
            if (!empty($data['exclude_sku'])) {
                $get_data_exclude_product_by_sku = $this->get_exclude_product_by_sku($data['exclude_sku']);
            }
            
            foreach ($get_data_exclude_product_by_sku as $key => $value) {
                $id_exclude_product_by_sku[] = $value->post_id;
            }

            $args['exclude'] = $id_exclude_product_by_sku;

            if (!empty($args['include'])) {
                foreach ($args['include'] as $id_include) {
                    $cek_exclude_product = in_array($id_include, $args['exclude']);
                    
                    if (!$cek_exclude_product) {
                        $include_new[] = $id_include;
                    }         
                }
            
                $args['include'] = $include_new;    
            }
        }

        if (empty($args['include'])) {
            unset($args['include']);

            if (!empty($search) || !empty($data['sku'])) {    
                $args['s'] = $search ?? $data['sku'];
            }
        }

        if (!empty($data['include'])) {
            if (!isset($args['include']) && isset($args['exclude'])) {
                return [];
            }
        }

        $products = wc_get_products($args);
        
        $results = array();

        foreach ($products as $i => $product) {
            $available_variations = $product->get_type() == 'variable' ? $product->get_available_variations() : null;
            $variation_attributes = $product->get_type() == 'variable' ? $product->get_variation_attributes() : null;

            $variation_options = array();
            $emptyValuesKeys = array();
            if ($available_variations != null) {
                $values = array();

                foreach ($available_variations as $key => $value) {
                    foreach ($value['attributes'] as $atr_key => $atr_value) {
                        $available_variations[$key]['option'][] = array(
                            'key' => $atr_key,
                            'value' => $this->attribute_slug_to_title($atr_key, $atr_value) //make it name
                        );
                        $values[] = $this->attribute_slug_to_title($atr_key, $atr_value);
                        if(empty($atr_value))
                        $emptyValuesKeys[] = $atr_key;

                        $variation = wc_get_product($value['variation_id']);

                        $variation_discount = apply_filters('advanced_woo_discount_rules_get_product_discount_price_from_custom_price', false, $variation, 1, 0, 'all', true);
                        if ($variation_discount) {
                            $variation_price = 0;
                            $original_variation_price = $variation_discount['initial_price'];
            
                            foreach ($variation_discount['total_discount_details'] as $variation_key => $variation_value) {
                                $variation_rules = $wpdb->get_row("SELECT id, conditions, product_adjustments FROM {$wpdb->prefix}wdr_rules WHERE id = $variation_key");
                                $variation_conditions = json_decode($variation_rules->conditions);
            
                                if (count($variation_conditions)) {
                                    $check = false;
            
                                    foreach($variation_conditions as $condition) {
                                        if ($condition->type === 'user_role' && in_array($user_roles[0], $condition->options->value)) {
                                            $check = true;
                                        } else if ($condition->type === 'user_logged_in') {
                                            if ($condition->options->value == 'yes' && $user) {
                                                $check = true;
                                            }
            
                                            if ($condition->options->value == 'no' && !$user) {
                                                $check = true;
                                            }
                                        }
                                    }
            
                                    if ($check) {
                                        $variation_price = $original_variation_price - ($original_variation_price * json_decode($variation_rules->product_adjustments)->value / 100);
                                    }
                                } else {
                                    $tmp = $variation_price == 0 ? $original_variation_price : $variation_price;
                                    $variation_price = $tmp - ($tmp * json_decode($variation_rules->product_adjustments)->value / 100);
                                }
                            }
                        }

                        $regular_price = $variation->get_regular_price();
                        $sale_price = $variation->get_sale_price();

                        $available_variations[$key]['formated_price'] = $regular_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $regular_price ) ))) : strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_price() ) )));
                        $available_variations[$key]['formated_sales_price'] = strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation_price ?? $sale_price ) )));
                        $available_variations[$key]['meta_data'] = $variation->get_meta_data();
                    }
                    $available_variations[$key]['image_id'] = null;
                }

                if ($variation_attributes) {
                    foreach ( $variation_attributes as $attribute_name => $options ) {

                        $new_options = array();
                        foreach (array_values($options) as $key => $value) {
                            $new_options[] = $this->attribute_slug_to_title($attribute_name, $value);
                        }
                        if (!in_array('attribute_' . $attribute_name, $emptyValuesKeys)) {
                            $options = array_intersect ( array_values($new_options) , $values );
                        }
                        $variation_options[] = array(
                            'name' => wc_attribute_label( $attribute_name ),
                            'options'   => array_values($options),
                            'attribute' => wc_attribute_label($attribute_name),
                        );
                    }
                }
            }

            /* Used for only Grocery APP */
            $children = array();
            if ($product->get_type() == 'grouped') {
                $ids = array_values( $product->get_children( 'view' ) );
                $args = array(
                    'include' => $ids,
                );
                $children = empty($args['include']) ? array() : $this->get_grouped_products($args);
            }

            $is_wistlist = false;
            if ($user_id = isset($data['user_id'])) {
                $get = query_hit_products($product->get_id(),$user_id);
                if ($get->is_wistlist == 1) {
                    $is_wistlist = true;
                }
            }

            $product_discount_rules = apply_filters('advanced_woo_discount_rules_get_product_discount_price_from_custom_price', false, $product, 1, 0, 'all', true);
            if ($product_discount_rules) {
                $res_price = 0;
                $product_discount = true;
                $initial_product_price = $product_discount_rules['initial_price'];

                foreach ($product_discount_rules['total_discount_details'] as $key => $value) {
                    $rules = $wpdb->get_row("SELECT id, conditions, product_adjustments FROM {$wpdb->prefix}wdr_rules WHERE id = $key");
                    $conditions = json_decode($rules->conditions);

                    if (count($conditions)) {
                        $check_rule = false;
                        
                        foreach($conditions as $condition) {
                            if ($condition->type === 'user_role' && in_array($user_roles[0], $condition->options->value)) {
                                $check_rule = true;
                            } else if ($condition->type === 'user_logged_in') {
                                if ($condition->options->value == 'yes' && $user) {
                                    $check_rule = true;
                                }

                                if ($condition->options->value == 'no' && !$user) {
                                    $check_rule = true;
                                }
                            }
                        }

                        if ($check_rule) {
                            $res_price = $initial_product_price - ($initial_product_price * json_decode($rules->product_adjustments)->value / 100);
                        } else {
                            $product_discount = false;
                            $res_price = $initial_product_price;
                        }
                    } else {  // ex: rule_id 14
                        $product_discount = true;
                        $tmp = $res_price == 0 ? $initial_product_price : $res_price;
                        $res_price = $tmp - ($tmp * json_decode($rules->product_adjustments)->value / 100);
                    }
                }

                $res_price = number_format($res_price, 2, '.', '');
            }

            // response price
            if ($product_discount_rules && $product_discount) {
                $response_price = $res_price;
                $response_reguler_price = $product->get_price();
                $response_sale_price = $res_price;
            } else if ($product->get_price() < $product->get_regular_price()) {
                $response_price = $product->get_price();
                $response_reguler_price = $product->get_regular_price();
                $response_sale_price = $product->get_sale_price();
            } else {  // don't have discount or sale_price
                $response_price = $product->get_price();
                $response_reguler_price = 0;
                $response_sale_price = 0;
            }

            $result = array(
                'id' => $product->get_id(),
                'name' => $product->get_name(),
                'is_wistlist' => $is_wistlist,
                'sku' => $product->get_sku( 'view' ),
                'type' => $product->get_type(),
                'status' => $product->get_status(),
                'permalink'  => $product->get_permalink(),
                'description' => $product->get_description(),
                'short_description' => $product->get_short_description(),
                'formated_price' => strip_tags(wc_price(wc_get_price_to_display( $product, [ 'price' => $response_reguler_price != 0 ? $response_reguler_price : $product->get_price() ] ))),
                'formated_sales_price' => $response_sale_price != 0 ? strip_tags(wc_price(wc_get_price_to_display( $product, [ 'price' => $response_sale_price ] ))) : null,
                'price' => (double) $response_price,
                'regular_price' => (double) $response_reguler_price,
                'sale_price' => (double) $response_sale_price,
                'discount' => (double) number_format((($response_reguler_price - $response_price) / $response_reguler_price) * 100, 2, '.', ''),
                'stock_status' => $product->get_stock_status(),
                'stock_quantity' => $product->get_stock_quantity(),
                'on_sale' => $product->is_on_sale( 'view' ),
                'average_rating'        => wc_format_decimal( $product->get_average_rating(), 2 ),
                'rating_count'          => $product->get_rating_count(),
                'related_ids'           => array_map( 'absint', array_values( wc_get_related_products( $product->get_id() ) ) ),
                'upsell_ids'            => array_map( 'absint', $product->get_upsell_ids( 'view' ) ),
                'cross_sell_ids'        => array_map( 'absint', $product->get_cross_sell_ids( 'view' ) ),
                'parent_id'             => $product->get_parent_id( 'view' ),
                'images' => $this->get_images($product),
                'attributes'            => $this->get_attributes( $product ),
                'availableVariations'   => $available_variations,
                'variationAttributes'   => $variation_attributes,
                'meta_data'             => $product->get_meta_data(),
                'variationOptions'      => $variation_options,
                'total_sales'           => (int)$product->get_total_sales(),
                'vendor'                => $this->get_product_vendor($product->get_id()),
                'grouped_products'      => $product->get_children(),
                'children'              => $children,
                'categories'            => get_the_terms( $product->get_id(), 'product_cat' ),
                'tags'                  => wc_get_object_terms( $product->get_id(), 'product_tag', 'name' ),
                //'cashback_amount'       => woo_wallet()->cashback->get_product_cashback_amount($product) //UnComment Whne cashback need only
                'dimensions'            => $product->get_dimensions(false)
            );

            $result['dimensions']['weight'] = $product->get_weight();
            
            $ws = '';
            $wsPriceKey = 'wholesale_customer_wholesale_price';
            $meta_data = array();
            $check = array_search($wsPriceKey,array_column($meta_data,'key'));

            if ($check !== false) {
                $ws = [['price' => $meta_data[$check]->value]];
                $result['is_variant'] = false;
            } else {
                $result['is_variant'] = true;
                $wsRaw = [];

                for ($i=0; $i < count($meta_data); $i++) {
                    $value = $meta_data[$i];
                    if ($value->key == 'wholesale_customer_variations_with_wholesale_price') {
                        $product_variation = (new WC_Product_Variation($value->value))->get_meta_data();
                        $data = array_map(function ($v) use ($value) {
                            return [
                            'id'=>$value->value,
                            'price'=>$v->value,
                            ];
                        }, array_filter($product_variation,function ($v) use ($wsPriceKey)
                    {
                        return $v->key == $wsPriceKey;
                    }));
                    // $data = $product_variation;
                    
                    array_push($wsRaw,$data);
                    }
                }

                $ws = call_user_func_array('array_merge', $wsRaw);
            }

            $result['wholesales'] = $ws;

            $results[] = $result;
        }

        remove_filter( 'posts_clauses', array( $this, 'order_by_price_asc_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_price_desc_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_rating_post_clauses' ) );

        return $results;
    }

    public function get_products_cart($data = array()) {

        $addon_data = $data['addon_data'];
        $products   = array();

        if (!is_null($addon_data['simple'])) {
            $products = wc_get_products([
                'limit'   => -1,
                'include' => array_map(fn($simple_key) => $simple_key, array_keys($addon_data['simple']))
            ]);
        }

        if (!is_null($addon_data['variation'])) {
            foreach ($addon_data['variation'] as $product_var_key => $product_var_value) {
                $products[] = wc_get_product($product_var_key);
            }
        }
        
        $results = array();

        foreach ($products as $product) {
            $product_id   = $product->get_id();
            $product_type = $product->get_type();

            $available_variations = $product->get_type() == 'variable' ? $product->get_available_variations() : null;
            $variation_attributes = $product->get_type() == 'variable' ? $product->get_variation_attributes() : null;

            $variation_options = array();
            $emptyValuesKeys   = array();

            if ($available_variations != null) {
                $values = array();

                foreach ( $available_variations as $key => $value ) {
                    foreach ( $value['attributes'] as $atr_key => $atr_value ) {
                        $available_variations[$key]['option'][] = array(
                            'key' => $atr_key,
                            'value' => $this->attribute_slug_to_title($atr_key, $atr_value) //make it name
                        );

                        $values[] = $this->attribute_slug_to_title($atr_key, $atr_value);
                        if (empty($atr_value)) {
                            $emptyValuesKeys[] = $atr_key;
                        }

                        $variation = wc_get_product( $value['variation_id'] );

                        $available_variations[$key]['minmax_quantity'] = (function ($variation) {
                            $min_qty = get_post_meta( $variation->get_id(), 'min_quantity_var', true );   // min is empty = parse to "1"
                            $max_qty = get_post_meta( $variation->get_id(), 'max_quantity_var', true );   // max is empty = parse to "999"
                            $sold_individually = $variation->get_sold_individually();

                            if (!is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php')) {
                                $min_qty = 1;
                                $max_qty = !$sold_individually ? 999 : 1;
                            }

                            return [
                                'min_quantity' => (int) (empty($min_qty) ? 1 : $min_qty),
                                'max_quantity' => (int) (empty($max_qty) ? 999 : $max_qty),
                            ];
                        })($variation);

                        unset($available_variations[$key]['min_qty']);
                        unset($available_variations[$key]['max_qty']);

                        $regular_price = $variation->get_regular_price();
                        $sale_price = $variation->get_sale_price();

                        $available_variations[$key]['formated_price'] = $regular_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $regular_price ) ))) : strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_price() ) )));
                        $available_variations[$key]['formated_sales_price'] = $sale_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $sale_price ) ))) : null;
                        $available_variations[$key]['meta_data'] = $variation->get_meta_data();
                    }

                    $available_variations[$key]['image_id'] = null;
                }

                if ($variation_attributes) {
                    foreach ( $variation_attributes as $attribute_name => $options ) {

                        $new_options = array();
                        foreach (array_values($options) as $key => $value) {
                            $new_options[] = $this->attribute_slug_to_title($attribute_name, $value);
                        }
                        if (!in_array('attribute_' . $attribute_name, $emptyValuesKeys)) {
                            $options = array_intersect ( array_values($new_options) , $values );
                        }
                        $variation_options[] = array(
                            'name' => wc_attribute_label( $attribute_name ),
                            'options'   => array_values($options),
                            'attribute' => wc_attribute_label($attribute_name),
                        );
                    }
                }
            }

            $categories = get_the_terms( $product->get_id(), 'product_cat' );
            if (empty($categories)) {
                $categories = array();
            }

            $result = array(
                'id'     => $addon_data[$product_type][$product_id]['product_id'],
                'name'   => $product->get_name(),
                'slug'   => $product->get_slug(),
                'sku'    => $product->get_sku('view'),
                'status' => $product->get_status(),
                'type'   => $product_type,
                'cart_quantity'       => $addon_data[$product_type][$product_id]['quantity'],
                'price_total'         => (double) $product->get_price() * $addon_data[$product_type][$product_id]['quantity'],
                'is_selected'         => true,
                'variant_id'          => $addon_data[$product_type][$product_id]['variation_id'],
                'variation_name'      => $addon_data[$product_type][$product_id]['variation_name'],
                'selected_variation'  => $addon_data[$product_type][$product_id]['variation_selected'],
                'total_sales'         => (int) $product->get_total_sales(),
                'manage_stock'        => $product->get_manage_stock(),
                'stock_status'        => $product->get_stock_status(),
                'stock_quantity'      => $product->get_stock_quantity(),
                'sold_individually'   => is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php') ? false : $product->get_sold_individually(),
                'minmax_quantity'     => (function ($product) {
                    $sold_individually = $product->get_sold_individually();

                    if ($product->get_type() === 'variation') {
                        $min_qty = get_post_meta( $product->get_id(), 'min_quantity_var', true );   // min is empty = parse to "1"
                        $max_qty = get_post_meta( $product->get_id(), 'max_quantity_var', true );   // max is empty = parse to "999"
                    } else {
                        $min_qty = get_post_meta( $product->get_id(), 'min_quantity', true );   // min is empty = parse to "1"
                        $max_qty = get_post_meta( $product->get_id(), 'max_quantity', true );   // max is empty = parse to "999"
                    } 

                    if (!is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php')) {
                        $min_qty = 1;
                        $max_qty = !$sold_individually ? 999 : 1;
                    } else if ($sold_individually && empty($min_qty) && empty($max_qty)) {
                        $min_qty = 1;
                        $max_qty = 1;
                    } else {
                        $min_qty = empty($min_qty) ? 1 : $min_qty;
                        $max_qty = empty($max_qty) ? 999 : $max_qty;
                    }

                    return [
                        'min_quantity' => (int) (empty($min_qty) ? 1 : $min_qty),
                        'max_quantity' => (int) (empty($max_qty) ? 999 : $max_qty),
                    ];
                })($product),
                'description'          => $product->get_description(),
                'short_description'    => $product->get_short_description(),
                'formated_price'       => $product->get_regular_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_regular_price() ) ))) : strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_price() ) ))),
                'formated_sales_price' => $product->get_sale_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_sale_price() ) ))) : null,
                'price'         => (double)$product->get_price(),
                'regular_price' => (double)$product->get_regular_price(),
                'sale_price'    => (double)$product->get_sale_price(),
                'images'        => $this->get_images($product),
                'categories'          => $categories,
                'average_rating'      => wc_format_decimal( $product->get_average_rating(), 2 ),
                'rating_count'        => $product->get_rating_count(),
                'attributes_v2'       => $this->get_attributes_v2( $product ),
                'permalink'           => $product->get_permalink(),
                'meta_data'           => $product->get_meta_data(),
                'availableVariations' => $available_variations,
                'variationAttributes' => $variation_attributes,
            );

            $ws = '';
            $wsPriceKey = 'wholesale_customer_wholesale_price';
            $meta_data  = $product->get_meta_data();
            $check      = array_search($wsPriceKey, array_column($meta_data,'key'));

            if ($check !== false) {
                $ws = [['price' => $meta_data[$check]->value]];
                $result['is_variant'] = false;
            } else {
                $result['is_variant'] = true;
                $wsRaw = [];

                for ($i = 0; $i < count($meta_data); $i++) {
                    $value = $meta_data[$i];
                    if ($value->key == 'wholesale_customer_variations_with_wholesale_price') {
                        $product_variation = (new WC_Product_Variation($value->value))->get_meta_data();
                        $data = array_map(function ($v) use ($value) {
                            return [
                                'id'=>$value->value,
                                'price'=>$v->value,
                            ];
                        }, array_filter($product_variation,function ($v) use ($wsPriceKey) {
                            return $v->key == $wsPriceKey;
                        }));

                        // $data = $product_variation;
                        array_push($wsRaw,$data);
                    }
                }

                if (!empty($wsRaw)) {
                    $ws = call_user_func_array('array_merge', $wsRaw);
                }
            }

            $result['wholesales'] = $ws;

            $results[] = $result;
        }

        return $results;

    }

    public function get_product_by_sku( $sku ) {

        global $wpdb;
        // print_r($sku); die;
    
        $product_id = $wpdb->get_var( $wpdb->prepare( "SELECT post_id FROM $wpdb->postmeta WHERE meta_key='_sku' AND meta_value LIKE %s", "%" . $sku . "%") );
    
        if ( $product_id ) return new WC_Product( $product_id );
    
        return null;
    }

    public function get_exclude_product_by_sku( $sku ) {

        global $wpdb;
    
        $products = $wpdb->get_results($wpdb->prepare( "SELECT post_id FROM $wpdb->postmeta WHERE meta_key='_sku' AND meta_value LIKE %s", "%" . $sku . "%"));
    
        if ( $products ) return $products;
    
        return null;
    }

    public function get_products_old($args = array()){

        $tax_query   = WC()->query->get_tax_query();

        for ($i=0; $i < 50; $i++) {

            if ( ! empty( $_POST['attributes' . $i] ) && ! empty( $_POST['attribute_term' . $i] ) ) {
                if ( in_array( $_POST['attributes' . $i], wc_get_attribute_taxonomy_names(), true ) ) {
                    $tax_query[] = array(
                        'taxonomy' => $_POST['attributes' . $i],
                        'field'    => 'term_id',
                        'terms'    => $_POST['attribute_term' . $i],
                    );
                }
            }

        }

        if ( ! empty( $_POST['wcpv_product_vendors'] ) ) {
            $tax_query[] = array(
                'taxonomy' => 'wcpv_product_vendors',
                'field'    => 'id',
                'terms'    => $_POST['wcpv_product_vendors'],
            );
        }

        // featured
        if ( ! empty( $_POST['featured'] ) ) {
            $tax_query[] = array(
                'taxonomy' => 'product_visibility',
                'field'    => 'name',
                'terms'    => 'featured',
                'operator' => 'IN',
            );
        }

        if(isset($_POST['id'])) {
            $orderby = isset( $_POST['orderby'] ) ? $_POST['orderby'] : 'popularity';
        } else $orderby = 'date';

        $order = isset( $_POST['order'] ) ? $_POST['order'] : null;

        switch ( $orderby ) {
            case 'id':
                $args['orderby'] = 'ID';
                break;
            case 'menu_order':
                $args['orderby'] = 'menu_order title';
                break;
            case 'name':
                $args['orderby'] = 'name';
                $args['order']   = ( 'DESC' === $order ) ? 'DESC' : 'ASC';
                break;
            case 'relevance':
                $args['orderby'] = 'relevance';
                $args['order']   = 'DESC';
                break;
            case 'rand':
                $args['orderby'] = 'rand'; // @codingStandardsIgnoreLine
                break;
            case 'date':
                $args['orderby'] = 'date ID';
                $args['order']   = ( 'ASC' === $order ) ? 'ASC' : 'DESC';
                break;
            case 'price':
                $callback = 'DESC' === $order ? 'order_by_price_desc_post_clauses' : 'order_by_price_asc_post_clauses';
                add_filter( 'posts_clauses', array( $this, $callback ) );
                break;
            case 'popularity':
                add_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
                break;
            case 'rating':
                add_filter( 'posts_clauses', array( $this, 'order_by_rating_post_clauses' ) );
                break;
        }

        if ( ! empty( $_POST['tag'] ) ) {
            $args = array(
                'tag' => array( $_POST['tag'] ),
            );
        }

        // Filter by on sale products.
        if ( isset( $_POST['include'] ) ) {
            $args['include'] = json_decode($_POST['include']);
        }

        // search
        if ( ! empty( $_POST['q'] ) ) {
            $args['s'] = $_POST['q'];
            add_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
        }

        // search
        if ( ! empty( $_POST['id'] ) ) {
            $tax_query[] = array(
                'taxonomy' => 'product_cat',
                'field'    => 'term_id',
                'terms'    => $_POST['id'],
            );
        }

        // Build tax_query if taxonomies are set.
        if ( ! empty( $tax_query ) ) {
            if ( ! empty( $args['tax_query'] ) ) {
                $args['tax_query'] = array_merge( $tax_query, $args['tax_query'] ); // WPCS: slow query ok.
            } else {
                $args['tax_query'] = $tax_query; // WPCS: slow query ok.
            }
        }

        // Page filter.
        if ( ! empty( $_POST['page'] ) ) {
            $args['page'] = $_POST['page'];
        }

        $args['post_status'] = 'publish';

        $args['post_type'] = array( 'product', 'product_variation' );

        $products = wc_get_products( $args );
        $results = array();

        foreach ($products as $i => $product) {
            $results[] = $this->reformat_product_result($product);
        }

        remove_filter( 'posts_clauses', array( $this, 'order_by_price_asc_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_price_desc_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_popularity_post_clauses' ) );
        remove_filter( 'posts_clauses', array( $this, 'order_by_rating_post_clauses' ) );

        return $results;

    }

    public function reformat_product_result($product, $user = null) {
        $available_variations = $product->get_type() == 'variable' ? $product->get_available_variations() : null;
        $variation_attributes = $product->get_type() == 'variable' ? $product->get_variation_attributes() : null;

        $variation_options = array();
        $emptyValuesKeys = array();
        if ($available_variations != null) {
            $values = array();

            foreach ( $available_variations as $key => $value ) {
                foreach ( $value['attributes'] as $atr_key => $atr_value ) {
                    $available_variations[$key]['option'][] = array(
                        'key' => $atr_key,
                        'value' => $this->attribute_slug_to_title($atr_key, $atr_value) //make it name
                    );

                    $values[] = $this->attribute_slug_to_title($atr_key, $atr_value);
                    if (empty($atr_value)) {
                        $emptyValuesKeys[] = $atr_key;
                    }

                    $variation = wc_get_product( $value['variation_id'] );

                    $available_variations[$key]['minmax_quantity'] = (function ($variation) {
                        $min_qty = get_post_meta( $variation->get_id(), 'min_quantity_var', true );   // min is empty = parse to "1"
                        $max_qty = get_post_meta( $variation->get_id(), 'max_quantity_var', true );   // max is empty = parse to "999"
                        $sold_individually = $variation->get_sold_individually();

                        if (!is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php')) {
                            $min_qty = 1;
                            $max_qty = !$sold_individually ? 999 : 1;
                        }

                        return [
                            'min_quantity' => (int) (empty($min_qty) ? 1 : $min_qty),
                            'max_quantity' => (int) (empty($max_qty) ? 999 : $max_qty),
                        ];
                    })($variation);

                    unset($available_variations[$key]['min_qty']);
                    unset($available_variations[$key]['max_qty']);

                    $regular_price = $variation->get_regular_price();
                    $sale_price = $variation->get_sale_price();

                    $available_variations[$key]['formated_price'] = $regular_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $regular_price ) ))) : strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_price() ) )));
                    $available_variations[$key]['formated_sales_price'] = $sale_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $sale_price ) ))) : null;
                    $available_variations[$key]['meta_data'] = $variation->get_meta_data();
                }

                $available_variations[$key]['image_id'] = null;
            }

            if ($variation_attributes) {
                foreach ( $variation_attributes as $attribute_name => $options ) {

                    $new_options = array();
                    foreach (array_values($options) as $key => $value) {
                        $new_options[] = $this->attribute_slug_to_title($attribute_name, $value);
                    }
                    if (!in_array('attribute_' . $attribute_name, $emptyValuesKeys)) {
                        $options = array_intersect ( array_values($new_options) , $values );
                    }
                    $variation_options[] = array(
                        'name' => wc_attribute_label( $attribute_name ),
                        'options'   => array_values($options),
                        'attribute' => wc_attribute_label($attribute_name),
                    );
                }
            }
        }

        /* Used for only Grocery APP */
        $children = array();
        if ( $product->get_type() == 'grouped' ) {
            $ids = array_values( $product->get_children( 'view' ) );
            $args = array(
                'include' => $ids,
            );
            $children = empty($args['include']) ? array() : $this->get_grouped_products($args);
        }

        $meta_data = $product->get_meta_data();

        $result = array(
            'id' => $product->get_id(),
            'name' => $product->get_name(),
            'sku' => $product->get_sku( 'view' ),
            'type' => $product->get_type(),
            'status' => $product->get_status(),
            'permalink'  => $product->get_permalink(),
            'description' => $product->get_description(),
            'short_description' => $product->get_short_description(),
            'formated_price' => $product->get_regular_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_regular_price() ) ))) : strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_price() ) ))),
            'formated_sales_price' => $product->get_sale_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_sale_price() ) ))) : null,
            'price' => (double)$product->get_price(),
            'regular_price'  => (double)$product->get_regular_price(),
            'sale_price'     => (double)$product->get_sale_price(),
            // 'stock_status'   => $product->get_stock_quantity() <= 0 && $product->get_stock_status() === 'instock' ? 'outofstock' : $product->get_stock_status(),
            'stock_status' => $product->get_stock_status(),
            'stock_quantity' => $product->get_stock_quantity(),
            'sold_individually' => is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php') ? false : $product->get_sold_individually(),
            'minmax_quantity'   => (function ($product) {
                $sold_individually = $product->get_sold_individually();

                if ($product->get_type() === 'variation') {
                    $min_qty = get_post_meta( $product->get_id(), 'min_quantity_var', true );   // min is empty = parse to "1"
                    $max_qty = get_post_meta( $product->get_id(), 'max_quantity_var', true );   // max is empty = parse to "999"
                } else {
                    $min_qty = get_post_meta( $product->get_id(), 'min_quantity', true );   // min is empty = parse to "1"
                    $max_qty = get_post_meta( $product->get_id(), 'max_quantity', true );   // max is empty = parse to "999"
                } 

                if (!is_plugin_active('minmax-quantity-for-woocommerce/woocommerce-minmax-quantity.php')) {
                    $min_qty = 1;
                    $max_qty = !$sold_individually ? 999 : 1;
                } else if ($sold_individually && empty($min_qty) && empty($max_qty)) {
                    $min_qty = 1;
                    $max_qty = 1;
                } else {
                    $min_qty = empty($min_qty) ? 1 : $min_qty;
                    $max_qty = empty($max_qty) ? 999 : $max_qty;
                }

                return [
                    'min_quantity' => (int) (empty($min_qty) ? 1 : $min_qty),
                    'max_quantity' => (int) (empty($max_qty) ? 999 : $max_qty),
                ];
            })($product),
            'on_sale' => $product->is_on_sale( 'view' ),
            'average_rating'        => wc_format_decimal( $product->get_average_rating(), 2 ),
            'rating_count'          => $product->get_rating_count(),
            'related_ids'           => array_map( 'absint', array_values( wc_get_related_products( $product->get_id() ) ) ),
            'upsell_ids'            => array_map( 'absint', $product->get_upsell_ids( 'view' ) ),
            'cross_sell_ids'        => array_map( 'absint', $product->get_cross_sell_ids( 'view' ) ),
            'parent_id'             => $product->get_parent_id( 'view' ),
            'images'                => $this->get_images($product),
            'attributes'            => $this->get_attributes( $product ),
            'attributes_v2'         => $this->get_attributes_v2( wc_get_product(cek_raw('product_id')) , 'reformat' ),
            'availableVariations'   => $available_variations,
            'variationAttributes'   => $variation_attributes,
            'meta_data'             => $meta_data,
            'variationOptions'      => $variation_options,
            'grouped_products'      => $product->get_children(),
            'children'              => $children,
            'total_sales'           => rv_total_sales($product),
            'manage_stock'          => $product->get_manage_stock(),
            //'categories'            => wc_get_object_terms( $product->get_id(), 'product_cat', 'term_id' ),
            'tags'               => wc_get_object_terms( $product->get_id(), 'product_tag', 'name' ),
            //'cashback_amount'       => woo_wallet()->cashback->get_product_cashback_amount($product) //UnComment Whne cashback need only
        );

        if (is_plugin_active('woocommerce-memberships/woocommerce-memberships.php') && !is_null($user)) {
            $service_membership_discount = new WC_Memberships_Member_Discounts();

            if (wc_memberships_user_has_member_discount ($product, $user)) {
                $price = $service_membership_discount->get_discounted_price($product->get_price(), $product, $user->ID);

                $result['price'] = (double) $price;
                $result['formated_sales_price'] = strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $price ) )));
                $result['sale_price'] = (double) $price;
            }
        }

        $wsPriceKey = 'wholesale_customer_wholesale_price';
        $check = array_search($wsPriceKey,array_column($meta_data,'key'));

        if ($check !== false) {
            $ws = [['price' => $meta_data[$check]->value]];
            $result['is_variant'] = false;
        } else {
            $result['is_variant'] = true;
            $wsRaw = [];
            for ($i=0; $i < count($meta_data); $i++) {
                $value = $meta_data[$i];
                if ($value->key == 'wholesale_customer_variations_with_wholesale_price') {
                $product_variation = (new WC_Product_Variation($value->value))->get_meta_data();
                $data = array_map(function ($v) use ($value)
                {
                    return [
                    'id'=>$value->value,
                    'price'=>$v->value,
                    ];
                },array_filter($product_variation,function ($v) use ($wsPriceKey)
                {
                    return $v->key == $wsPriceKey;
                }));
                // $data = $product_variation;
                array_push($wsRaw,$data);
                }
            }

            $ws = '';

            if (!empty($wsRaw)) {
                $ws = call_user_func_array('array_merge', $wsRaw);
            } // handling
        }

        $result['wholesales'] = $ws;

        return $result;
    }

    public function attribute_slug_to_title( $attribute ,$slug ) {
        global $woocommerce;
        $value = $slug;
        if ( taxonomy_exists( esc_attr( str_replace( 'attribute_', '', $attribute ) ) ) ) {
            $term = get_term_by( 'slug', $slug, esc_attr( str_replace( 'attribute_', '', $attribute ) ) );
            if ( ! is_wp_error( $term ) && isset($term->name) )
                $value = $term->name;
        } else {
            //$value = apply_filters( 'woocommerce_variation_option_name', $slug );
        }
        return $value;
    }

    public function get_grouped_products( $args ) {

        $args['status'] = 'publish';

        $args['post_type'] = array( 'product', 'product_variation' );

        $query = new WC_Product_Query( $args );

        $products = $query->get_products();

        $results = array();

        foreach ($products as $i => $product) {

            $results[] = array(
                'id' => $product->get_id(),
                'name' => $product->get_name(),
                'sku' => $product->get_sku( 'view' ),
                'type' => $product->get_type(),
                'status' => $product->get_status(),
                'description' => $product->get_description(),
                'short_description' => $product->get_short_description(),
                'formated_price' => $product->get_regular_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_regular_price() ) ))) : strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_price() ) ))),
                'formated_sales_price' => $product->get_sale_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_sale_price() ) ))) : null,
                'price' => (float)$product->get_price(),
                'regular_price' => (float)$product->get_regular_price(),
                'sale_price' => (float)$product->get_sale_price(),
                'stock_status' => $product->get_stock_status(),
                'stock_quantity'     => $product->get_stock_quantity(),
                'on_sale' => $product->is_on_sale( 'view' ),
                'average_rating'        => wc_format_decimal( $product->get_average_rating(), 2 ),
                'rating_count'          => $product->get_rating_count(),
                'images' => $this->get_images($product),
                'attributes'            => $this->get_attributes( $product ),
                //'cashback_amount'       => woo_wallet()->cashback->get_product_cashback_amount($product)
            );
        }

        return $results;

    }

    public function get_product_vendor( $id ) {

        $vendor = array();
        if (is_plugin_active('dc-woocommerce-multi-vendor/dc_product_vendor.php')) {

            global $WCMp;

            if ( 'product' === get_post_type( $id ) || 'product_variation' === get_post_type( $id ) ) {
                $parent = get_post_ancestors( $id );
                if ( $parent ) $id = $parent[ 0 ];

                $seller = get_post_field( 'post_author', $id);
                $user = get_user_by( 'id', $seller );
                $store_user = new WCMp_Vendor($user->ID);

                $vendor_profile_image = get_user_meta($user->ID, '_vendor_profile_image', true);

                $vendor = array(
                    'id' => $user->ID,
                    'name' => $user->display_name,
                    'icon' => (isset($vendor_profile_image) && $vendor_profile_image > 0) ? wp_get_attachment_url($vendor_profile_image) : get_avatar_url($user->ID, array('size' => 120))
                );

                return $vendor;
            }

            return null;

        }

        if (function_exists('wcfmmp_get_store')) {

            global $WCFM, $WCFMmp;

            $vendor_id = $WCFM->wcfm_vendor_support->wcfm_get_vendor_id_from_product( $id );

            $store_user  = wcfmmp_get_store( $vendor_id );
            $store_info = $store_user->get_shop_info();

            $vendor = array(
                'id' => $vendor_id,
                'name' => $store_info['store_name'],
                'icon' => $store_user->get_avatar()
            );

            return $vendor;

        }

        else if(is_plugin_active( 'dokan-lite/dokan.php') || is_plugin_active( 'dokan/dokan.php' )){

            if ( 'product' === get_post_type( $id ) || 'product_variation' === get_post_type( $id ) ) {
                $parent = get_post_ancestors( $id );
                if ( $parent ) $id = $parent[ 0 ];

                $seller = get_post_field( 'post_author', $id);
                $author = get_user_by( 'id', $seller );

                $store_user   = dokan()->vendor->get( $author->ID );
                $store_info   = $store_user->get_shop_info();

                $vendor = array(
                    'id' => $author->ID,
                    'name' => $store_info[ 'store_name' ],
                    'icon' => $store_user->get_avatar()
                );

                return $vendor;
            }

            return null;

        }

        return null;

    }

    /**
     * Handle numeric price sorting.
     *
     * @param array $args Query args.
     * @return array
     */
    public function order_by_price_asc_post_clauses( $args ) {
        $args['join']    = $this->append_product_sorting_table_join( $args['join'] );
        $args['orderby'] = ' wc_product_meta_lookup.min_price ASC, wc_product_meta_lookup.product_id ASC ';
        return $args;
    }

    /**
     * Handle numeric price sorting.
     *
     * @param array $args Query args.
     * @return array
     */
    public function order_by_price_desc_post_clauses( $args ) {
        $args['join']    = $this->append_product_sorting_table_join( $args['join'] );
        $args['orderby'] = ' wc_product_meta_lookup.max_price DESC, wc_product_meta_lookup.product_id DESC ';
        return $args;
    }

    /**
     * WP Core does not let us change the sort direction for individual orderby params - https://core.trac.wordpress.org/ticket/17065.
     *
     * This lets us sort by meta value desc, and have a second orderby param.
     *
     * @param array $args Query args.
     * @return array
     */
    public function order_by_popularity_post_clauses( $args ) {
        $args['join']    = $this->append_product_sorting_table_join( $args['join'] );
        $args['orderby'] = ' wc_product_meta_lookup.total_sales DESC, wc_product_meta_lookup.product_id DESC ';
        return $args;
    }

    /**
     * Order by rating post clauses.
     *
     * @param array $args Query args.
     * @return array
     */
    public function order_by_rating_post_clauses( $args ) {
        $args['join']    = $this->append_product_sorting_table_join( $args['join'] );
        $args['orderby'] = ' wc_product_meta_lookup.average_rating DESC, wc_product_meta_lookup.product_id DESC ';
        return $args;
    }

    /**
     * Join wc_product_meta_lookup to posts if not already joined.
     *
     * @param string $sql SQL join.
     * @return string
     */
    private function append_product_sorting_table_join( $sql ) {
        global $wpdb;

        if ( ! strstr( $sql, 'wc_product_meta_lookup' ) ) {
            $sql .= " LEFT JOIN {$wpdb->wc_product_meta_lookup} wc_product_meta_lookup ON $wpdb->posts.ID = wc_product_meta_lookup.product_id ";
        }
        return $sql;
    }

    public function add_meta_query( $args, $meta_query ) {
        if ( empty( $args['meta_query'] ) ) {
            $args['meta_query'] = array();
        }

        $args['meta_query'][] = $meta_query;

        return $args['meta_query'];
    }

    public function handling_custom_meta_query_keys( $wp_query_args, $query_vars, $data_store_cpt ) {

        // Price filter.
        if ( ! empty( $_REQUEST['min_price'] ) || ! empty( $_REQUEST['max_price'] ) ) {
            $wp_query_args['meta_query'] = $this->add_meta_query( $wp_query_args, wc_get_min_max_price_meta_query( $_REQUEST ) );  // WPCS: slow query ok.
        }

        // Filter product by stock_status.
        if ( ! empty( $_REQUEST['stock_status'] ) ) {
            $wp_query_args['meta_query'] = $this->add_meta_query( // WPCS: slow query ok.
                $wp_query_args, array(
                    'key'   => '_stock_status',
                    'value' => $_REQUEST['stock_status'],
                )
            );
        }

        // Filter by sku.
        if ( ! empty( $_REQUEST['sku'] ) ) {
            $skus = explode( ',', $_REQUEST['sku'] );
            // Include the current string as a SKU too.
            if ( 1 < count( $skus ) ) {
                $skus[] = $_REQUEST['sku'];
            }

            $wp_query_args['meta_query'] = $this->add_meta_query( $wp_query_args, array(
                'key'     => '_sku',
                'value'   => $skus,
                'compare' => 'IN',
            ) );
        }

        return $wp_query_args;
    }

    public function get_variation_ids( $product ) {
        $variations = array();

        foreach ( $product->get_children() as $child_id ) {
            $variation = wc_get_product( $child_id );
            if ( ! $variation || ! $variation->exists() ) {
                continue;
            }

            $variations[] = $variation->get_id();
        }

        return $variations;
    }

    public function get_variation_data( $product ) {
        $variations = array();

        foreach ( $product->get_children() as $child_id ) {
            $variation = wc_get_product( $child_id );
            if ( ! $variation || ! $variation->exists() ) {
                continue;
            }

            $variations[] = array(
                'id'                 => $variation->get_id(),
                'permalink'          => $variation->get_permalink(),
                'sku'                => $variation->get_sku(),
                'price' => strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_price() ) ))),
                'regular_price' => strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_regular_price() ) ))),
                'sale_price' => strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_sale_price() ) ))),
                'on_sale'            => $variation->is_on_sale(),
                'purchasable'        => $variation->is_purchasable(),
                'visible'            => $variation->is_visible(),
                'virtual'            => $variation->is_virtual(),
                'downloadable'       => $variation->is_downloadable(),
                'download_limit'     => '' !== $variation->get_download_limit() ? (int) $variation->get_download_limit() : -1,
                'download_expiry'    => '' !== $variation->get_download_expiry() ? (int) $variation->get_download_expiry() : -1,
                'stock_quantity'     => $variation->get_stock_quantity(),
                'in_stock'           => $variation->is_in_stock(),
                'image'              => $this->get_images( $variation ),
                'attributes'         => $this->get_attributes( $variation ),
                //'cashback_amount'    => woo_wallet()->cashback->get_product_cashback_amount($variation)
            );
        }

        return $variations;
    }

    public function get_images( $product ) {
        $images         = array();
        $attachment_ids = array();

        // Add featured image.
        if ( $product->get_image_id() ) {
            $attachment_ids[] = $product->get_image_id();
        }

        // Add gallery images.
        $attachment_ids = array_merge( $attachment_ids, $product->get_gallery_image_ids() );

        // Build image data.
        foreach ( $attachment_ids as $position => $attachment_id ) {
            $attachment_post = get_post( $attachment_id );
            if ( is_null( $attachment_post ) ) {
                continue;
            }

            $attachment = wp_get_attachment_image_src( $attachment_id, 'full' );
            if ( ! is_array( $attachment ) ) {
                continue;
            }

            $images[] = array(
                'id'                => (int) $attachment_id,
                'src'               => current( $attachment ),
                'name'              => get_the_title( $attachment_id ),
                'alt'               => get_post_meta( $attachment_id, '_wp_attachment_image_alt', true ),
                'position'          => (int) $position,
            );
        }

        // Set a placeholder image if the product has no images set.
        if ( empty( $images ) ) {
            $images[] = array(
                'id'                => 0,
                'src'               => wc_placeholder_img_src(),
                'name'              => __( 'Placeholder', 'woocommerce' ),
                'alt'               => __( 'Placeholder', 'woocommerce' ),
                'position'          => 0,
            );
        }

        return $images;
    }

    public function get_attribute_taxonomy_name( $slug, $product ) {
        $attributes = $product->get_attributes();

        if ( ! isset( $attributes[ $slug ] ) ) {
            return str_replace( 'pa_', '', $slug );
        }

        $attribute = $attributes[ $slug ];

        // Taxonomy attribute name.
        if ( $attribute->is_taxonomy() ) {
            $taxonomy = $attribute->get_taxonomy_object();
            return $taxonomy->attribute_label;
        }

        // Custom product attribute name.
        return $attribute->get_name();
    }

    /**
     * Get default attributes.
     *
     * @param WC_Product $product Product instance.
     *
     * @return array
     */
    public function get_default_attributes( $product ) {
        $default = array();

        if ( $product->is_type( 'variable' ) ) {
            foreach ( array_filter( (array) $product->get_default_attributes(), 'strlen' ) as $key => $value ) {
                if ( 0 === strpos( $key, 'pa_' ) ) {
                    $default[] = array(
                        'id'     => wc_attribute_taxonomy_id_by_name( $key ),
                        'name'   => $this->get_attribute_taxonomy_name( $key, $product ),
                        'option' => $value,
                    );
                } else {
                    $default[] = array(
                        'id'     => 0,
                        'name'   => $this->get_attribute_taxonomy_name( $key, $product ),
                        'option' => $value,
                    );
                }
            }
        }

        return $default;
    }

    /**
     * Get attribute options.
     *
     * @param int   $product_id Product ID.
     * @param array $attribute  Attribute data.
     *
     * @return array
     */
    public function get_attribute_options( $product_id, $attribute ) {
        if ( isset( $attribute['is_taxonomy'] ) && $attribute['is_taxonomy'] ) {
            return wc_get_product_terms(
                $product_id, $attribute['name'], array(
                    'fields' => 'names',
                )
            );
        } elseif ( isset( $attribute['value'] ) ) {
            return array_map( 'trim', explode( '|', $attribute['value'] ) );
        }

        return array();
    }

    public function get_attribute_options_v2( $product_id, $attribute ) {
        if ( isset( $attribute['is_taxonomy'] ) && $attribute['is_taxonomy'] ) {
            // if ($flag === true) {
            //     $product = wc_get_product($product_id);
            //     $available_variations = $product->get_available_variations();

            //     $variations_slug = array_map(function ($a) use ($attribute) {
            //         $res_slug = $a['attributes']['attribute_' . $attribute['name']];

            //         if (!is_null($res_slug)) {
            //             return $res_slug;
            //         }
            //     }, $available_variations);
            // }

            $result = [];
            $terms = wc_get_product_terms($product_id, $attribute['name'], array('fields' => 'all'));

            foreach ($terms as $value) {
                array_push($result, [
                    'name' => $value->name,
                    'slug' => $value->slug,
                    // 'available' => $flag ? in_array($value->slug, $variations_slug) : true
                ]);
            }

            return $result;
        } elseif ( isset( $attribute['value'] ) ) {
            $result = [];
            $terms = explode('|', $attribute['value']);

            foreach ($terms as $value) {
                array_push($result, [
                    'name' => trim($value),
                    'slug' => sanitize_title($value)
                    // 'available' => true,
                ]);
            }

            return $result;

            // return array_map( 'trim', explode( '|', $attribute['value'] ) );
        }

        return array();
    }

    /**
     * Get the attributes for a product or product variation.
     *
     * @param WC_Product|WC_Product_Variation $product Product instance.
     *
     * @return array
     */
    public function get_attributes( $product ) {
        $attributes = array();

        if ( $product->is_type( 'variation' ) ) {
            $_product = wc_get_product( $product->get_parent_id() );
            foreach ( $product->get_variation_attributes() as $attribute_name => $attribute ) {
                $name = str_replace( 'attribute_', '', $attribute_name );

                if ( empty( $attribute ) && '0' !== $attribute ) {
                    continue;
                }

                // Taxonomy-based attributes are prefixed with `pa_`, otherwise simply `attribute_`.
                if ( 0 === strpos( $attribute_name, 'attribute_pa_' ) ) {
                    $option_term  = get_term_by( 'slug', $attribute, $name );
                    $attributes[] = array(
                        'id'     => wc_attribute_taxonomy_id_by_name( $name ),
                        'name'   => $this->get_attribute_taxonomy_name( $name, $_product ),
                        'option' => $option_term && ! is_wp_error( $option_term ) ? $option_term->name : $attribute,
                    );
                } else {
                    $attributes[] = array(
                        'id'     => 0,
                        'name'   => $this->get_attribute_taxonomy_name( $name, $_product ),
                        'option' => $attribute,
                    );
                }
            }
        } else {
            foreach ( $product->get_attributes() as $key => $attribute ) {
                $attributes[] = array(
                    'id'        => $attribute['is_taxonomy'] ? wc_attribute_taxonomy_id_by_name( $attribute['name'] ) : 0,
                    'name'      => $this->get_attribute_taxonomy_name( $attribute['name'], $product ),
                    'slug'      => $attribute['name'],
                    'position'  => (int) $attribute['position'],
                    'visible'   => (bool) $attribute['is_visible'],
                    'variation' => (bool) $attribute['is_variation'],
                    'options'   => $this->get_attribute_options( $product->get_id(), $attribute ),
                );
            }
        }

        return $attributes;
    }

    public function get_attributes_v2( $product, $action = 'product' ) {
        $attributes = array();

        if ( $product->is_type( 'variation' ) && $action === 'product' ) {
            $_product = wc_get_product( $product->get_parent_id() );
            foreach ( $product->get_variation_attributes() as $attribute_name => $attribute ) {
                $name = str_replace( 'attribute_', '', $attribute_name );

                if ( empty( $attribute ) && '0' !== $attribute ) {
                    continue;
                }

                // Taxonomy-based attributes are prefixed with `pa_`, otherwise simply `attribute_`.
                if ( 0 === strpos( $attribute_name, 'attribute_pa_' ) ) {
                    $option_term  = get_term_by( 'slug', $attribute, $name );

                    $attributes[] = array(
                        'id'      => wc_attribute_taxonomy_id_by_name( $name ),
                        'name'    => $this->get_attribute_taxonomy_name( $name, $_product ),
                        // 'options' => $option_term && ! is_wp_error( $option_term ) ? $option_term->name : $attribute,
                        'options' => [
                            [
                                'name' => $option_term && ! is_wp_error( $option_term ) ? $option_term->name : $attribute,
                                'slug' => $option_term && ! is_wp_error( $option_term ) ? $option_term->slug : $attribute,
                            ]
                        ] 
                    );
                } else {
                    $attributes[] = array(
                        'id'      => 0,
                        'name'    => $this->get_attribute_taxonomy_name( $name, $_product ),
                        // 'options' => $attribute,
                        'options' => [
                            [
                                'name' => $attribute,
                                'slug' => sanitize_title($attribute),
                            ]
                        ],
                    );
                }
            }
        } else {
            // $flag = false;

            foreach ( $product->get_attributes() as $attribute ) {
                // if ($attribute['is_visible'] && $attribute['is_variation'] && !isset($flag_check)) {
                //     $flag = true;
                // }

                $attributes[] = array(
                    'id'        => $attribute['is_taxonomy'] ? wc_attribute_taxonomy_id_by_name( $attribute['name'] ) : 0,
                    'name'      => $this->get_attribute_taxonomy_name( $attribute['name'], $product ),
                    'slug'      => sanitize_title($attribute['name']),
                    'position'  => (int) $attribute['position'],
                    'visible'   => (bool) $attribute['is_visible'],
                    'variation' => (bool) $attribute['is_variation'],
                    'options'   => $this->get_attribute_options_v2( $product->get_id(), $attribute ),
                    // 'options'   => $this->get_attribute_options_v2( $product->get_id(), $attribute, $flag ),
                );

                // if ($flag === true) {
                //     $flag = false;
                //     $flag_check = true;
                // }
            }
        }

        return $attributes;
    }

    public function get_categories(){

        $taxonomy     = 'product_cat';
        $orderby      = 'name';
        $show_count   = 1;      // 1 for yes, 0 for no
        $pad_counts   = 0;      // 1 for yes, 0 for no
        $hierarchical = 1;      // 1 for yes, 0 for no
        $title        = '';
        $empty        = 0;

        $args = array(
             'taxonomy'     => $taxonomy,
             //'orderby'      => $orderby,
             'show_count'   => $show_count,
             'pad_counts'   => $pad_counts,
             'hierarchical' => $hierarchical,
             'title'     => $title,
             'hide_empty'   => $empty,
             'menu_order' => 'asc',
        );

        $categories = get_categories( $args );

        if (($key = array_search('uncategorized', array_column($categories, 'slug'))) !== false) {
            unset($categories[$key]);
        }

        $data = array();

        foreach ($categories as $key => $value) {

            $image_id = get_term_meta( $value->term_id, 'thumbnail_id', true );
            $image = '';

            if ( $image_id ) {
                $image = wp_get_attachment_url( $image_id );
            }

            $data[] = array(
                'id' => $value->term_id,
                'name' => $value->name,
                'description' => $value->description,
                'parent' => $value->parent,
                'count' => $value->count,
                'image' => $image,
            );

        }

        return $data;

    }

    public function get_vendor_categories($id) {

        $ids = array($id);

        $categories = array();

        if( !empty($ids) ) {
            global $wpdb;

            $unique = implode('', $ids);

            $categories = get_transient( 'dokan-store-category-'.$unique );

            if( true ) {
                $categories = $wpdb->get_results( $wpdb->prepare( "SELECT t.term_id, t.name, tt.parent, tt.count, tt.description FROM $wpdb->terms as t
                    LEFT JOIN $wpdb->term_taxonomy as tt on t.term_id = tt.term_id
                    LEFT JOIN $wpdb->term_relationships AS tr on tt.term_taxonomy_id = tr.term_taxonomy_id
                    LEFT JOIN $wpdb->posts AS p on tr.object_id = p.ID
                    WHERE tt.taxonomy = 'product_cat'
                    AND p.post_type = 'product'
                    AND p.post_status = 'publish'
                    AND p.post_author = %d GROUP BY t.term_id", implode(',', array_map('intval', $ids))
                ) );
                set_transient( 'dokan-store-category-'.$unique , $categories );
            }

        }

        $data = array();

        foreach ($categories as $key => $value) {

            $image_id = get_term_meta( $value->term_id, 'thumbnail_id', true );
            $image = '';

            if ( $image_id ) {
                $image = wp_get_attachment_url( $image_id );
            }

            $data[] = array(
                'id' => (int)$value->term_id,
                'name' => $value->name,
                'description' => $value->description,
                'parent' => (int)$value->parent,
                'count' => (int)$value->count,
                'image' => $image,
            );

        }

        return $data;
    }


    /**
     * AJAX apply coupon on checkout page.
     */
    public function apply_coupon()
    {

        //check_ajax_referer( 'apply-coupon', 'security' );

        wc_clear_notices();

        $notice = '';

        if (!empty($_POST['coupon_code'])) {
            WC()->cart->add_discount(sanitize_text_field($_POST['coupon_code']));
        } else {
            wc_add_notice( WC_Coupon::get_generic_coupon_error( WC_Coupon::E_WC_COUPON_PLEASE_ENTER ), 'error' );
        }

        $notices = wc_get_notices();

        foreach ($notices as $key => $value) {
            $notice = $value[0]['notice'];
        }

        wp_send_json($notice);

        die();
    }

    /**
     * AJAX remove coupon on cart and checkout page.
     */
    public function remove_coupon()
    {

        //check_ajax_referer( 'remove-coupon', 'security' );

        $coupon = wc_clean($_POST['coupon']);

        if (!isset($coupon) || empty($coupon)) {
            wc_add_notice(__('Sorry there was a problem removing this coupon.', 'woocommerce'), 'error');

        } else {

            WC()->cart->remove_coupon($coupon);

            wc_add_notice(__('Coupon has been removed.', 'woocommerce'));
        }

        wc_print_notices();

        die();
    }

    /**
     * AJAX update shipping method on cart page.
     */
    public function update_shipping_method()
    {

        //check_ajax_referer( 'update-shipping-method', 'security' );

        if (!defined('WOOCOMMERCE_CART')) {
            define('WOOCOMMERCE_CART', true);
        }

        $chosen_shipping_methods = WC()->session->get('chosen_shipping_methods');

        if (isset($_POST['shipping_method']) && is_array($_POST['shipping_method'])) {
            foreach ($_POST['shipping_method'] as $i => $value) {
                $chosen_shipping_methods[$i] = wc_clean($value);
            }
        }

        WC()->session->set('chosen_shipping_methods', $chosen_shipping_methods);


        $data = WC()->cart;
        WC()->cart->calculate_totals();

        foreach (WC()->cart->get_cart() as $cart_item_key => $cart_item) {
            $_product = apply_filters('woocommerce_cart_item_product', $cart_item['data'], $cart_item, $cart_item_key);
            $product_id = apply_filters('woocommerce_cart_item_product_id', $cart_item['product_id'], $cart_item, $cart_item_key);

            if (has_post_thumbnail($product_id)) {
                $image = get_the_post_thumbnail_url($product_id, 'medium');
            } elseif (($parent_id = wp_get_post_parent_id($product_id)) && has_post_thumbnail($parent_id)) {
                $image = get_the_post_thumbnail_url($parent_id, 'medium');
            } else {
                $image = wc_placeholder_img('medium');
            }

            $data->cart_contents[$cart_item_key]['name'] = apply_filters('woocommerce_cart_item_name', $_product->get_name(), $cart_item, $cart_item_key);
            $data->cart_contents[$cart_item_key]['thumb'] = $image;
            $data->cart_contents[$cart_item_key]['remove_url'] = wc_get_cart_remove_url($cart_item_key);
            $data->cart_contents[$cart_item_key]['price'] = $_product->get_price();
            $data->cart_contents[$cart_item_key]['tax_price'] = wc_get_price_including_tax($_product);
            $data->cart_contents[$cart_item_key]['regular_price'] = $_product->get_regular_price();
            $data->cart_contents[$cart_item_key]['sales_price'] = $_product->get_sale_price();

        }

        $data->cart_nonce = wp_create_nonce('woocommerce-cart');

        $data->cart_totals = WC()->cart->get_totals();

        //$data->shipping = WC()->shipping->load_shipping_methods($packages);

        $packages = WC()->shipping->get_packages();
        $first = true;

        $shipping = array();
        foreach ($packages as $i => $package) {
            $chosen_method = isset(WC()->session->chosen_shipping_methods[$i]) ? WC()->session->chosen_shipping_methods[$i] : '';
            $product_names = array();

            if (sizeof($packages) > 1) {
                foreach ($package['contents'] as $item_id => $values) {
                    $product_names[$item_id] = $values['data']->get_name() . ' &times;' . $values['quantity'];
                }
                $product_names = apply_filters('woocommerce_shipping_package_details_array', $product_names, $package);
            }

            $shipping[] = array(
                'package' => $package,
                'available_methods' => $package['rates'],
                'show_package_details' => sizeof($packages) > 1,
                'show_shipping_calculator' => is_cart() && $first,
                'package_details' => implode(', ', $product_names),
                'package_name' => apply_filters('woocommerce_shipping_package_name', sprintf(_nx('Shipping', 'Shipping %d', ($i + 1), 'shipping packages', 'woocommerce'), ($i + 1)), $i, $package),
                'index' => $i,
                'chosen_method' => $chosen_method,
                'shipping' => $this->get_rates($package)
            );

            $first = false;
        }

        $data->chosen_shipping = WC()->session->get('chosen_shipping_methods');

        $data->shipping = $shipping;


        wp_send_json($data);


        die();
    }

    /**
     * AJAX receive updated cart_totals div.
     */
    public function get_cart_totals()
    {

        if (!defined('WOOCOMMERCE_CART')) {
            define('WOOCOMMERCE_CART', true);
        }

        WC()->cart->calculate_totals();

        woocommerce_cart_totals();

        die();
    }

    public function get_rates($package){

        $shipping = array();

        //if($package['rates'])
        foreach ($package['rates'] as $i => $method) {
            $shipping[$i]['id'] = $method->get_id();
            $shipping[$i]['label'] = $method->get_label();
            $shipping[$i]['cost'] = $method->get_cost();
            $shipping[$i]['method_id'] = $method->get_method_id();
            $shipping[$i]['taxes'] = $method->get_taxes();
        }

        return $shipping;

    }

    public function updateCartQty() {


        $cart_item_key = $_REQUEST['key'];
        $qty = (int)$_REQUEST['quantity'];

        global $woocommerce;
        $woocommerce->cart->set_quantity($cart_item_key, $qty);

        $this->cart();

    }

    /**
     * AJAX add to cart.
     */
    public function add_to_cart()
    {
        ob_start();

        $product_id = apply_filters('woocommerce_add_to_cart_product_id', absint($_POST['product_id']));
        $quantity = empty($_POST['quantity']) ? 1 : wc_stock_amount($_POST['quantity']);
        $passed_validation = apply_filters('woocommerce_add_to_cart_validation', true, $product_id, $quantity);
        $product_status = get_post_status($product_id);

        $variation_id = isset($_POST['variation_id']) ? absint($_POST['variation_id']) : '';
        $variations = !empty($_POST['variation']) ? (array)$_POST['variation'] : '';

        $status = WC()->cart->add_to_cart($product_id, $quantity, $variation_id, $variations);

        $this->cart();

        die();
    }

    public function add_product_to_cart() {

        wc_clear_notices();

        ob_start();

        //$product_id        = 161;
        $product_id        = apply_filters( 'woocommerce_add_to_cart_product_id', absint( $_POST['product_id'] ) );
        $product           = wc_get_product( $product_id );
        $quantity          = empty( $_POST['quantity'] ) ? 1 : wc_stock_amount( wp_unslash( $_POST['quantity'] ) );
        $passed_validation = apply_filters( 'woocommerce_add_to_cart_validation', true, $product_id, $quantity );
        $product_status    = get_post_status( $product_id );
        $variation_id = isset($_POST['variation_id']) ? absint($_POST['variation_id']) : '';
        $variation = !empty($_POST['variation']) ? (array)$_POST['variation'] : '';

        if ( $product && 'variation' === $product->get_type() ) {
            $variation_id = $product_id;
            $product_id   = $product->get_parent_id();
            $variation    = $product->get_variation_attributes();
        }

        if ( $passed_validation && false !== WC()->cart->add_to_cart( $product_id, $quantity, $variation_id, $variation ) && 'publish' === $product_status ) {

            do_action( 'woocommerce_ajax_added_to_cart', $product_id );

            $this->cart();

        } else {

            $notice = wc_get_notices();

            if(isset($notice['error'])) {
                wp_send_json_error( $notice['error'], 400 );
            } else {
                $notice = array(
                    'success' => false,
                    'data' => array(
                        'notice' => 'Sorry, this product cannot be purchased.'
                    )
                );
                wp_send_json_error( $notice, 400 );
            }

        }

    }

    public function remove_cart_item()
    {

        if (!defined('WOOCOMMERCE_CART')) {
            define('WOOCOMMERCE_CART', true);
        }

        $status = WC()->cart->remove_cart_item($_REQUEST['item_key']);

        $this->cart();

    }

    public function payment()
    {

        if (WC()->cart->needs_payment()) {
            // Payment Method
            $available_gateways = WC()->payment_gateways->get_available_payment_gateways();

        } else {
            $available_gateways = array();
        }

        wp_send_json($available_gateways);

        die(0);
    }

    public function info()
    {

        $data = WC();

        wp_send_json($data);

        die(0);
    }

    /**
     * Get a matching variation based on posted attributes.
     */
    public function get_variation()
    {
        ob_start();

        if (empty($_POST['product_id']) || !($variable_product = wc_get_product(absint($_POST['product_id']), array('product_type' => 'variable')))) {
            die();
        }

        $variation_id = $variable_product->get_matching_variation(wp_unslash($_POST));

        if ($variation_id) {
            $variation = $variable_product->get_available_variation($variation_id);
        } else {
            $variation = false;
        }

        wp_send_json($variation);

        die();
    }

    /**
     * Feature a product from admin.
     */
    public function feature_product()
    {
        if (current_user_can('edit_products') && check_admin_referer('woocommerce-feature-product')) {
            $product_id = absint($_GET['product_id']);

            if ('product' === get_post_type($product_id)) {
                update_post_meta($product_id, '_featured', get_post_meta($product_id, '_featured', true) === 'yes' ? 'no' : 'yes');

                delete_transient('wc_featured_products');
            }
        }

        wp_safe_redirect(wp_get_referer() ? remove_query_arg(array('trashed', 'untrashed', 'deleted', 'ids'), wp_get_referer()) : admin_url('edit.php?post_type=product'));
        die();
    }

    /**
     * Delete variations via ajax function.
     */
    public function remove_variations()
    {
        check_ajax_referer('delete-variations', 'security');

        if (!current_user_can('edit_products')) {
            die(-1);
        }

        $variation_ids = (array)$_POST['variation_ids'];

        foreach ($variation_ids as $variation_id) {
            $variation = get_post($variation_id);

            if ($variation && 'product_variation' == $variation->post_type) {
                wp_delete_post($variation_id);
            }
        }

        die();
    }

    /**
     * Get customer details via ajax.
     */
    public function get_customer_details()
    {
        ob_start();

        check_ajax_referer('get-customer-details', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $user_id = (int)trim(stripslashes($_POST['user_id']));
        $type_to_load = esc_attr(trim(stripslashes($_POST['type_to_load'])));

        $customer_data = array(
            $type_to_load . '_first_name' => get_user_meta($user_id, $type_to_load . '_first_name', true),
            $type_to_load . '_last_name' => get_user_meta($user_id, $type_to_load . '_last_name', true),
            $type_to_load . '_company' => get_user_meta($user_id, $type_to_load . '_company', true),
            $type_to_load . '_address_1' => get_user_meta($user_id, $type_to_load . '_address_1', true),
            $type_to_load . '_address_2' => get_user_meta($user_id, $type_to_load . '_address_2', true),
            $type_to_load . '_city' => get_user_meta($user_id, $type_to_load . '_city', true),
            $type_to_load . '_postcode' => get_user_meta($user_id, $type_to_load . '_postcode', true),
            $type_to_load . '_country' => get_user_meta($user_id, $type_to_load . '_country', true),
            $type_to_load . '_state' => get_user_meta($user_id, $type_to_load . '_state', true),
            $type_to_load . '_email' => get_user_meta($user_id, $type_to_load . '_email', true),
            $type_to_load . '_phone' => get_user_meta($user_id, $type_to_load . '_phone', true),
        );

        $customer_data = apply_filters('woocommerce_found_customer_details', $customer_data, $user_id, $type_to_load);

        wp_send_json($customer_data);
    }

    /**
     * Add order item via ajax.
     */
    public function add_order_item()
    {
        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $item_to_add = sanitize_text_field($_POST['item_to_add']);
        $order_id = absint($_POST['order_id']);

        // Find the item
        if (!is_numeric($item_to_add)) {
            die();
        }

        $post = get_post($item_to_add);

        if (!$post || ('product' !== $post->post_type && 'product_variation' !== $post->post_type)) {
            die();
        }

        $_product = wc_get_product($post->ID);
        $order = wc_get_order($order_id);
        $order_taxes = $order->get_taxes();
        $class = 'new_row';

        // Set values
        $item = array();

        $item['product_id'] = $_product->id;
        $item['variation_id'] = isset($_product->variation_id) ? $_product->variation_id : '';
        $item['variation_data'] = $item['variation_id'] ? $_product->get_variation_attributes() : '';
        $item['name'] = $_product->get_title();
        $item['tax_class'] = $_product->get_tax_class();
        $item['qty'] = 1;
        $item['line_subtotal'] = wc_format_decimal($_product->get_price_excluding_tax());
        $item['line_subtotal_tax'] = '';
        $item['line_total'] = wc_format_decimal($_product->get_price_excluding_tax());
        $item['line_tax'] = '';
        $item['type'] = 'line_item';

        // Add line item
        $item_id = wc_add_order_item($order_id, array(
            'order_item_name' => $item['name'],
            'order_item_type' => 'line_item'
        ));

        // Add line item meta
        if ($item_id) {
            wc_add_order_item_meta($item_id, '_qty', $item['qty']);
            wc_add_order_item_meta($item_id, '_tax_class', $item['tax_class']);
            wc_add_order_item_meta($item_id, '_product_id', $item['product_id']);
            wc_add_order_item_meta($item_id, '_variation_id', $item['variation_id']);
            wc_add_order_item_meta($item_id, '_line_subtotal', $item['line_subtotal']);
            wc_add_order_item_meta($item_id, '_line_subtotal_tax', $item['line_subtotal_tax']);
            wc_add_order_item_meta($item_id, '_line_total', $item['line_total']);
            wc_add_order_item_meta($item_id, '_line_tax', $item['line_tax']);

            // Since 2.2
            wc_add_order_item_meta($item_id, '_line_tax_data', array('total' => array(), 'subtotal' => array()));

            // Store variation data in meta
            if ($item['variation_data'] && is_array($item['variation_data'])) {
                foreach ($item['variation_data'] as $key => $value) {
                    wc_add_order_item_meta($item_id, str_replace('attribute_', '', $key), $value);
                }
            }

            do_action('woocommerce_ajax_add_order_item_meta', $item_id, $item);
        }

        $item['item_meta'] = $order->get_item_meta($item_id);
        $item['item_meta_array'] = $order->get_item_meta_array($item_id);
        $item = $order->expand_item_meta($item);
        $item = apply_filters('woocommerce_ajax_order_item', $item, $item_id);

        include('admin/meta-boxes/views/html-order-item.php');

        // Quit out
        die();
    }

    /**
     * Add order fee via ajax.
     */
    public function add_order_fee()
    {

        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $order_id = absint($_POST['order_id']);
        $order = wc_get_order($order_id);
        $order_taxes = $order->get_taxes();
        $item = array();

        // Add new fee
        $fee = new stdClass();
        $fee->name = '';
        $fee->tax_class = '';
        $fee->taxable = $fee->tax_class !== '0';
        $fee->amount = '';
        $fee->tax = '';
        $fee->tax_data = array();
        $item_id = $order->add_fee($fee);

        include('admin/meta-boxes/views/html-order-fee.php');

        // Quit out
        die();
    }

    /**
     * Add order shipping cost via ajax.
     */
    public function add_order_shipping()
    {

        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $order_id = absint($_POST['order_id']);
        $order = wc_get_order($order_id);
        $order_taxes = $order->get_taxes();
        $shipping_methods = WC()->shipping() ? WC()->shipping->load_shipping_methods() : array();
        $item = array();

        // Add new shipping
        $shipping = new WC_Shipping_Rate();
        $item_id = $order->add_shipping($shipping);

        include('admin/meta-boxes/views/html-order-shipping.php');

        // Quit out
        die();
    }

    /**
     * Add order tax column via ajax.
     */
    public function add_order_tax()
    {
        global $wpdb;

        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $order_id = absint($_POST['order_id']);
        $rate_id = absint($_POST['rate_id']);
        $order = wc_get_order($order_id);
        $data = get_post_meta($order_id);

        // Add new tax
        $order->add_tax($rate_id, 0, 0);

        // Return HTML items
        include('admin/meta-boxes/views/html-order-items.php');

        die();
    }

    /**
     * Remove an order item.
     */
    public function remove_order_item()
    {
        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $order_item_ids = $_POST['order_item_ids'];

        if (!is_array($order_item_ids) && is_numeric($order_item_ids)) {
            $order_item_ids = array($order_item_ids);
        }

        if (sizeof($order_item_ids) > 0) {
            foreach ($order_item_ids as $id) {
                wc_delete_order_item(absint($id));
            }
        }

        die();
    }

    /**
     * Remove an order tax.
     */
    public function remove_order_tax()
    {

        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $order_id = absint($_POST['order_id']);
        $rate_id = absint($_POST['rate_id']);

        wc_delete_order_item($rate_id);

        // Return HTML items
        $order = wc_get_order($order_id);
        $data = get_post_meta($order_id);
        include('admin/meta-boxes/views/html-order-items.php');

        die();
    }

    /**
     * Reduce order item stock.
     */
    public function reduce_order_item_stock()
    {
        check_ajax_referer('order-item', 'security');
        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }
        $order_id = absint($_POST['order_id']);
        $order_item_ids = isset($_POST['order_item_ids']) ? $_POST['order_item_ids'] : array();
        $order_item_qty = isset($_POST['order_item_qty']) ? $_POST['order_item_qty'] : array();
        $order = wc_get_order($order_id);
        $order_items = $order->get_items();
        $return = array();
        if ($order && !empty($order_items) && sizeof($order_item_ids) > 0) {
            foreach ($order_items as $item_id => $order_item) {
                // Only reduce checked items
                if (!in_array($item_id, $order_item_ids)) {
                    continue;
                }
                $_product = $order->get_product_from_item($order_item);
                if ($_product->exists() && $_product->managing_stock() && isset($order_item_qty[$item_id]) && $order_item_qty[$item_id] > 0) {
                    $stock_change = apply_filters('woocommerce_reduce_order_stock_quantity', $order_item_qty[$item_id], $item_id);
                    $new_stock = $_product->reduce_stock($stock_change);
                    $item_name = $_product->get_sku() ? $_product->get_sku() : $order_item['product_id'];
                    $note = sprintf(__('Item %s stock reduced from %s to %s.', 'woocommerce'), $item_name, $new_stock + $stock_change, $new_stock);
                    $return[] = $note;
                    $order->add_order_note($note);
                    $order->send_stock_notifications($_product, $new_stock, $order_item_qty[$item_id]);
                }
            }
            do_action('woocommerce_reduce_order_stock', $order);
            if (empty($return)) {
                $return[] = __('No products had their stock reduced - they may not have stock management enabled.', 'woocommerce');
            }
            echo implode(', ', $return);
        }
        die();
    }

    /**
     * Increase order item stock.
     */
    public function increase_order_item_stock()
    {
        check_ajax_referer('order-item', 'security');
        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }
        $order_id = absint($_POST['order_id']);
        $order_item_ids = isset($_POST['order_item_ids']) ? $_POST['order_item_ids'] : array();
        $order_item_qty = isset($_POST['order_item_qty']) ? $_POST['order_item_qty'] : array();
        $order = wc_get_order($order_id);
        $order_items = $order->get_items();
        $return = array();
        if ($order && !empty($order_items) && sizeof($order_item_ids) > 0) {
            foreach ($order_items as $item_id => $order_item) {
                // Only reduce checked items
                if (!in_array($item_id, $order_item_ids)) {
                    continue;
                }
                $_product = $order->get_product_from_item($order_item);
                if ($_product->exists() && $_product->managing_stock() && isset($order_item_qty[$item_id]) && $order_item_qty[$item_id] > 0) {
                    $old_stock = $_product->get_stock_quantity();
                    $stock_change = apply_filters('woocommerce_restore_order_stock_quantity', $order_item_qty[$item_id], $item_id);
                    $new_quantity = $_product->increase_stock($stock_change);
                    $item_name = $_product->get_sku() ? $_product->get_sku() : $order_item['product_id'];
                    $note = sprintf(__('Item %s stock increased from %s to %s.', 'woocommerce'), $item_name, $old_stock, $new_quantity);
                    $return[] = $note;
                    $order->add_order_note($note);
                }
            }
            do_action('woocommerce_restore_order_stock', $order);
            if (empty($return)) {
                $return[] = __('No products had their stock increased - they may not have stock management enabled.', 'woocommerce');
            }
            echo implode(', ', $return);
        }
        die();
    }

    /**
     * Add some meta to a line item.
     */
    public function add_order_item_meta()
    {
        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        $meta_id = wc_add_order_item_meta(absint($_POST['order_item_id']), __('Name', 'woocommerce'), __('Value', 'woocommerce'));

        if ($meta_id) {
            echo '<tr data-meta_id="' . esc_attr($meta_id) . '"><td><input type="text" name="meta_key[' . $meta_id . ']" /><textarea name="meta_value[' . $meta_id . ']"></textarea></td><td width="1%"><button class="remove_order_item_meta button">&times;</button></td></tr>';
        }

        die();
    }

    /**
     * Remove meta from a line item.
     */
    public function remove_order_item_meta()
    {
        check_ajax_referer('order-item', 'security');

        if (!current_user_can('edit_shop_orders')) {
            die(-1);
        }

        global $wpdb;

        $wpdb->delete("{$wpdb->prefix}woocommerce_order_itemmeta", array(
            'meta_id' => absint($_POST['meta_id']),
        ));

        die();
    }

    public function fetch_wishlist() {

        $results = array();

        $user_id = get_current_user_id();

        if(get_current_user_id() == 0) {
            wp_send_json(array());
        }

        $ids = array_values(get_option('dotapp_wishlist' . $user_id, array()));

        $page = $_REQUEST['page'] ? $_REQUEST['page'] : 1;

        if(!empty($ids)) {

            $args = array(
                'include' => $ids,
                'page' => $page
            );

            $results = $this->get_products($args);

        }

        wp_send_json($results);

    }

    public function get_related_products()
    {

        $arr = $_REQUEST['related_ids'];
        $myArray = explode(',', $arr);


        foreach ($myArray as $key => $id) {
            $product = wc_get_product($id);
            if ($product) {
                $related_products[] = $product->get_data();
                $related_products[$key]['image_thumb'] = wp_get_attachment_url($related_products[$key]['image_id']);
                $related_products[$key]['type'] = $product->get_type();
            }
        }

        if (!$related_products) {

            $myArray = array();


            wp_send_json($myArray);

            die();

        }

        wp_send_json($related_products);

        die();

    }

    public function cart()
    {

        if (!defined('WOOCOMMERCE_CART')) {
            define('WOOCOMMERCE_CART', true);
        }

        $data = WC()->cart;
        WC()->cart->calculate_shipping();
        WC()->cart->calculate_totals();


        foreach (WC()->cart->get_cart() as $cart_item_key => $cart_item) {

            $_product = apply_filters('woocommerce_cart_item_product', $cart_item['data'], $cart_item, $cart_item_key);
            $product_id = apply_filters('woocommerce_cart_item_product_id', $cart_item['product_id'], $cart_item, $cart_item_key);

            if (has_post_thumbnail($product_id)) {
                $image = get_the_post_thumbnail_url($product_id, 'medium');
            } elseif (($parent_id = wp_get_post_parent_id($product_id)) && has_post_thumbnail($parent_id)) {
                $image = get_the_post_thumbnail_url($parent_id, 'medium');
            } else {
                $image = wc_placeholder_img_src('medium');
            }

            if ($data->cart_contents[$cart_item_key]['variation_id'] !== 0) {
                $variation_image = get_the_post_thumbnail_url($data->cart_contents[$cart_item_key]['variation_id'], 'medium');
                if(!empty($variation_image)) {
                    $image = $variation_image;
                }
            }

            //$data->cart_contents[$cart_item_key]['name'] = apply_filters( 'woocommerce_cart_item_name', $_product->get_name(), $cart_item, $cart_item_key );
            if ($data->cart_contents[$cart_item_key]['data']->post->post_title)
                $data->cart_contents[$cart_item_key]['name'] = $data->cart_contents[$cart_item_key]['data']->post->post_title;
            else
                $data->cart_contents[$cart_item_key]['name'] = apply_filters('woocommerce_cart_item_name', $_product->get_name(), $cart_item, $cart_item_key);

            $data->cart_contents[$cart_item_key]['thumb'] = $image;
            $data->cart_contents[$cart_item_key]['remove_url'] = wc_get_cart_remove_url($cart_item_key);


            $data->cart_contents[$cart_item_key]['price'] = (int)wc_get_price_to_display( $_product, array( 'price' => $_product->get_price() ) );
            $data->cart_contents[$cart_item_key]['regular_price'] = (int)wc_get_price_to_display( $_product, array( 'price' => $_product->get_regular_price() ) );

            $data->cart_contents[$cart_item_key]['formated_price'] = strip_tags(wc_price(wc_get_price_to_display( $_product, array( 'price' => $_product->get_price() ) )));
            $data->cart_contents[$cart_item_key]['formated_sales_price'] = $_product->get_sale_price() ? strip_tags(wc_price(wc_get_price_to_display( $_product, array( 'price' => $_product->get_sale_price() ) ))) : null;

        }

        $data->cartContents = array_values($data->cart_contents);

        $data->cart_nonce = wp_create_nonce('woocommerce-cart');

        $cart_totals = WC()->cart->get_totals();

        foreach ($cart_totals as $key => $value) {
            $cart_totals[$key] = strip_tags(wc_price($value));
        }

        $data->cart_totals = $cart_totals;

        $data->currency = get_woocommerce_currency();

        $packages = WC()->shipping->get_packages();
        $first = true;

        $shipping = array();
        foreach ($packages as $i => $package) {
            $chosen_method = isset(WC()->session->chosen_shipping_methods[$i]) ? WC()->session->chosen_shipping_methods[$i] : '';
            $product_names = array();

            if (sizeof($packages) > 1) {
                foreach ($package['contents'] as $item_id => $values) {
                    $product_names[$item_id] = $values['data']->get_name() . ' &times;' . $values['quantity'];
                }
                $product_names = apply_filters('woocommerce_shipping_package_details_array', $product_names, $package);
            }

            $shipping[] = array(
                'package' => $package,
                'available_methods' => $package['rates'],
                'show_package_details' => sizeof($packages) > 1,
                'show_shipping_calculator' => is_cart() && $first,
                'package_details' => implode(', ', $product_names),
                'package_name' => apply_filters('woocommerce_shipping_package_name', sprintf(_nx('Shipping', 'Shipping %d', ($i + 1), 'shipping packages', 'woocommerce'), ($i + 1)), $i, $package),
                'index' => $i,
                'chosen_method' => $chosen_method,
                'shipping' => $this->get_rates($package),
                'shippingMethods' => array_values($this->get_rates($package))
            );

            $first = false;
        }

        $data->chosen_shipping = WC()->session->get('chosen_shipping_methods');

        $data->shipping = $shipping;

        $fees = WC()->cart->get_fees();

        $cart_fees = array();
        foreach ($fees as $key => $value) {
            $cart_fees[] = array(
                'id' => $value->id,
                'name' => $value->name,
                'total' => strip_tags(wc_price($value->total))
            );
        }

        $data->cart_fees = $cart_fees;

        $coupon_discount_totals = WC()->cart->get_coupon_discount_totals();

        $coupons = array();
        foreach ($coupon_discount_totals as $key => $value) {
            $coupons[] = array(
                'code' => $key,
                'amount' => strip_tags(wc_price($value))
            );
        }

        $data->coupons = $coupons;

        // REWARD POINTS STARTS //
        if(is_plugin_active( 'woocommerce-points-and-rewards/woocommerce-points-and-rewards.php' )){

            global $wc_points_rewards;

            $cls = new WC_Points_Rewards_Cart_Checkout();

            $discount_available = $cls->get_discount_for_redeeming_points();

            $points  = WC_Points_Rewards_Manager::calculate_points_for_discount( $discount_available );

            $message = get_option( 'wc_points_rewards_redeem_points_message' );

            $message = str_replace( '{points}', number_format_i18n( $points ), $message );

            // the maximum discount available given how many points the customer has
            $message = str_replace( '{points_value}', wc_price( $discount_available ), $message );

            // points label
            $message = str_replace( '{points_label}', $wc_points_rewards->get_points_label( $points ), $message );

            $data->points = array(
                'points' => $points,
                'discount_available' => $discount_available,
                'message' => $message,
            );

            $data->purchase_point = $this->get_point_purchase();

        }
        // REWARD POINTS STARTS //


        wp_send_json($data);

        die();
    }

    public function nonce()
    {

        $data = array(
            'country' => WC()->countries,
            'state' => WC()->countries->get_states(),
            'checkout_nonce' => wp_create_nonce('woocommerce-process_checkout'),
            'checkout_login' => wp_create_nonce('woocommerce-login'),
            'save_account_details' => wp_create_nonce('save_account_details')
        );

        wp_send_json($data);
    }

    public function userdata()
    {
        if (is_user_logged_in()) {
            $user = wp_get_current_user();
            $user->status = true;
            $user->url = wp_logout_url();
            $user->avatar = get_avatar($user->ID, 128);
            $user->avatar_url = get_avatar_url($user->ID);

            wp_send_json($user);
        }

        $user->status = false;

        wp_send_json($user);

    }

    public function passwordreset()
    {

        $data = array(
            'nonce' => wp_create_nonce('lost_password'),
            'url' => wp_lostpassword_url()
        );

        wp_send_json($data);

    }

    public function pagecontent()
    {
        global $post;
        $id = $_REQUEST['page_id'];
        $post = get_post($id);
        wp_send_json($post);
    }

    function facebook_connect()
    {
        if (!$_REQUEST['access_token'] && $_REQUEST['access_token'] != '') {
            $response = array(
                'msg' => "Login failed",
                'status' => false
            );
            wp_send_json($response);
        } else {
            $access_token = $_REQUEST['access_token'];
            $fields = 'email,name,first_name,last_name,picture';
            $url = 'https://graph.facebook.com/me/?fields=' . $fields . '&access_token=' . $access_token;

            $response = wp_remote_get( $url );

            $body = wp_remote_retrieve_body( $response );

            $result = json_decode($body, true);

            if (isset($result["email"])) {
                $email = $result["email"];
                $email_exists = email_exists($email);
                if ($email_exists) {
                    $user = get_user_by('email', $email);
                    $user_id = $user->ID;
                    $user_name = $user->user_login;
                }

                if (!$user_id && $email_exists == false) {
                    $i = 0;
                    $user_name = strtolower($result['first_name'] . '.' . $result['last_name']);
                    while (username_exists($user_name)) {
                        $i++;
                        $user_name = strtolower($result['first_name'] . '.' . $result['last_name']) . '.' . $i;
                    }

                    $random_password = wp_generate_password($length = 12, $include_standard_special_chars = false);
                    $userdata = array(
                        'user_login' => $user_name,
                        'user_email' => $email,
                        'user_pass' => $random_password,
                        'display_name' => $result["name"],
                        'first_name' => $result['first_name'],
                        'last_name' => $result['last_name']
                    );
                    $user_id = wp_insert_user($userdata);
                    if ($user_id) $user_account = 'user registered.';
                } else {
                    if ($user_id) $user_account = 'user logged in.';
                }

                $expiration = time() + apply_filters('auth_cookie_expiration', 91209600, $user_id, true);
                $cookie = wp_generate_auth_cookie($user_id, $expiration, 'logged_in');
                wp_set_auth_cookie($user_id, true);

                $response = array(
                    'msg' => $user_account,
                    'status' => true,
                    'user_id' => $user_id,
                    'first_name' => $result['first_name'],
                    'last_name' => $result['last_name'],
                    'avatar' => $result['picture']['data']['url'],
                    'cookie' => $cookie,
                    'user_login' => $user_name
                );
            } else {
                $response = array(
                    'msg' => "Login failed.",
                    'status' => false
                );
            }
        }

        wp_send_json($response);
    }

    function google_connect()
    {
        if (!$_POST['access_token'] || !$_POST['email']) {
            $response['msg'] = "Google tocken is not valid";
            $response['status'] = false;
            wp_send_json($response);
        } else {
            if (isset($_POST['email'])) {
                $email = $_POST['email'];
                $first_name = $_POST['first_name'];
                $last_name = $_POST['last_name'];
                $display_name = $_POST['display_name'];
                $email_exists = email_exists($email);
                if ($email_exists) {
                    $user = get_user_by('email', $email);
                    $user_id = $user->ID;
                    $user_name = $user->user_login;
                }

                if (!$user_id && $email_exists == false) {
                    $user_name = $email;
                    $i = 0;
                    while (username_exists($user_name)) {
                        $i++;
                        $user_name = strtolower($first_name . '.' . $last_name) . '.' . $i;
                    }

                    $random_password = wp_generate_password($length = 12, $include_standard_special_chars = false);
                    $userdata = array(
                        'user_login' => $user_name,
                        'user_email' => $email,
                        'user_pass' => $random_password,
                        'display_name' => $display_name,
                        'first_name' => $first_name,
                        'last_name' => $last_name
                    );
                    $user_id = wp_insert_user($userdata);
                    if ($user_id) $user_account = 'user registered.';
                } else {
                    if ($user_id) $user_account = 'user logged in.';
                }

                $expiration = time() + apply_filters('auth_cookie_expiration', 91209600, $user_id, true);
                $cookie = wp_generate_auth_cookie($user_id, $expiration, 'logged_in');
                wp_set_auth_cookie($user_id, true);
                $response = array(
                    'msg' => $user_account,
                    'status' => true,
                    'user_id' => $user_id,
                    'cookie' => $cookie,
                    'last_login' => $user_name
                );

            } else {
                $response = array(
                    'msg' => "Your 'access_token' did not return email of the user. Without 'email' user can't be logged in or registered. Get user email extended permission while joining the Facebook app.",
                    'status' => false
                );
            }
        }

        wp_send_json($response);
    }

    public function checkout_form(){

        $allowed_countries = WC()->countries->get_allowed_countries();
        $state = WC()->countries->get_states();

        foreach ($allowed_countries as $key => $value) {
            $regions = array();

            foreach ($state[$key] as $state_key => $state_value) {
                $regions[] = array(
                    'label' => $state_value,
                    'value' => (string)$state_key,
                );
            }

            $countries[] = array(
                'label' => $value,
                'value' => $key,
                'regions' => $regions
            );
        }

        global $woocommerce;
        $fieldgroups = WC()->checkout->checkout_fields;
        $fields = array();
        foreach ($fieldgroups as $field_name => $field_options )  {
             foreach($field_options as $field_option_key => $field_option_value) {

                 if($fieldgroups[$field_name][$field_option_key]['type'] === 'country') {
                    $field_option_value['dotapp_options'] = $countries;
                 }

                 $field_option_value['value'] = WC()->checkout()->get_value($field_option_key);
                 $field_option_value['key'] = $field_option_key;

                 if($fieldgroups[$field_name][$field_option_key]['options'] != null) {
                     foreach ($fieldgroups[$field_name][$field_option_key]['options'] as $key => $value ) {
                         $field_option_value['dotapp_options'][] = array(
                            'key' => $key,
                            'value' => $value
                         );
                     }
                 }

                 $fields[$field_name][] = $field_option_value;
             }
        }

        $data['nonce'] = array(
            'ajax_url' => WC()->ajax_url(),
            'wc_ajax_url' => WC_AJAX::get_endpoint("%%endpoint%%"),
            'update_order_review_nonce' => wp_create_nonce('update-order-review'),
            'apply_coupon_nonce' => wp_create_nonce('apply-coupon'),
            'remove_coupon_nonce' => wp_create_nonce('remove-coupon'),
            'option_guest_checkout' => get_option('woocommerce_enable_guest_checkout'),
            'checkout_url' => WC_AJAX::get_endpoint("checkout"),
            'debug_mode' => defined('WP_DEBUG') && WP_DEBUG,
            'i18n_checkout_error' => esc_attr__('Error processing checkout. Please try again.', 'woocommerce'),
        );

        $data['checkout_nonce'] = wp_create_nonce('woocommerce-process_checkout');
        $data['_wpnonce'] = wp_create_nonce('woocommerce-process_checkout');
        $data['checkout_login'] = wp_create_nonce('woocommerce-login');
        $data['save_account_details'] = wp_create_nonce('save_account_details');
        $data['stripe_confirm_pi'] = wp_create_nonce('wc_stripe_confirm_pi');

        $data['user_logged'] = is_user_logged_in();

        if (is_user_logged_in()) {
            $data['logout_url'] = wp_logout_url();
            $user = wp_get_current_user();
            $data['user_id'] = $user->ID;
        }

        $data['terms'] = wc_terms_and_conditions_checkbox_enabled();
        if ($data['terms']) {
            $data['show_terms'] = true;
            $data['terms'] = wc_terms_and_conditions_checkbox_enabled();
            $data['terms_text'] = wc_get_terms_and_conditions_checkbox_text();
            $data['terms_url'] = wc_get_page_permalink('terms');
            $postid = url_to_postid($data['terms_url']);
            $data['terms_content'] = get_post_field('post_content', $postid);
        }

        $response = array('fieldgroups' => $fields, 'data' => $data);

        wp_send_json($response);

    }

    public function get_balance() {
        if ( ! function_exists( 'is_plugin_active' ) ) {
            include_once( ABSPATH . 'wp-admin/includes/plugin.php' );
        }
        if(is_plugin_active('woo-wallet/woo-wallet.php')) {
            return woo_wallet()->wallet->get_wallet_balance( '', 'edit' );
        } else {
            return '0';
        }
    }

    public function get_wallet() {

        $page = isset( $_REQUEST['page'] ) ? absint( $_REQUEST['page'] ) : 1;

        $per_page = 100;
        $offset = ( $page-1 ) * $per_page;

        $args = array('limit' => $offset . ',' . $per_page);

        /*$data = array(
            'balance' => woo_wallet()->wallet->get_wallet_balance( '', 'edit' ),
            'transactions' => get_wallet_transactions( $args ),
            'woo_wallet_topup' => wp_create_nonce( 'woo_wallet_topup' )
        );*/

        $data = get_wallet_transactions( $args );

        wp_send_json($data);

    }

    function wc_custom_user_redirect( $redirect, $user ) {

        $redirect = wp_get_referer() ? wp_get_referer() : $redirect;
        return $redirect;

    }

    function getCustomerDetail() {
        $user_id = get_current_user_id();
        $customer = new WC_Customer( $user_id );
        $data = $this->get_formatted_item_data_customer( $customer );
        wp_send_json($data);
    }

    public function get_formatted_item_data_customer( $object ) {
        $data        = $object->get_data();
        $format_date = array( 'date_created', 'date_modified' );

        // Format date values.
        foreach ( $format_date as $key ) {
            $datetime              = $data[ $key ];
            $data[ $key ]          = wc_rest_prepare_date_response( $datetime, false );
            $data[ $key . '_gmt' ] = wc_rest_prepare_date_response( $datetime );
        }

        return array(
            'id'                 => $object->get_id(),
            'date_created'       => $data['date_created'],
            'date_created_gmt'   => $data['date_created_gmt'],
            'date_modified'      => $data['date_modified'],
            'date_modified_gmt'  => $data['date_modified_gmt'],
            'email'              => $data['email'],
            'first_name'         => $data['first_name'],
            'last_name'          => $data['last_name'],
            'role'               => $data['role'],
            'username'           => $data['username'],
            'billing'            => $data['billing'],
            'shipping'           => $data['shipping'],
            'is_paying_customer' => $data['is_paying_customer'],
            'orders_count'       => $object->get_order_count(),
            'total_spent'        => $object->get_total_spent(),
            'avatar_url'         => $object->get_avatar_url(),
            'meta_data'          => $data['meta_data'],
            'nonce'              => $this->get_nonce()
        );
    }

    function getOrder() {

        $data = array();

        $id = $_REQUEST['id'] ? $_REQUEST['id'] : null;

        if($id) {
            $order = wc_get_order( $id );
            $data  = $this->get_formatted_item_data( $order );
        } else wp_send_json((object)$data);

        wp_send_json($data);
    }

    function getOrders() {

        $user_id = get_current_user_id();
        $data = array();


        $page = $_REQUEST['page'] ? $_REQUEST['page'] : 1;

        if($user_id) {

            $customer_orders = wc_get_orders( array(
                'meta_key' => '_customer_user',
                'orderby' => 'date',
                'order' => 'DESC',
                'customer_id' => $user_id,
                'page' => $page,
                'limit' => 10,
                'parent' => 0
            ) );

            foreach ($customer_orders as $key => $value) {

                //For WC Marketplace Sub Orders
                /*$sub_orders = get_wcmp_suborders($value->get_id());

                if(empty($sub_orders)) {
                    $data[]  = $this->get_formatted_item_data( $value );
                } else {
                    foreach ($sub_orders as $skey => $svalue) {
                        $data[]  = $this->get_formatted_item_data( $svalue );
                    }
                }*/

                $data[]  = $this->get_formatted_item_data( $value );
            }

        }

        wp_send_json($data);
    }

    public function get_formatted_item_data( $object ) {
        $data              = $object->get_data();
        $format_decimal    = array( 'discount_total', 'discount_tax', 'shipping_total', 'shipping_tax', 'shipping_total', 'shipping_tax', 'cart_tax', 'total', 'total_tax' );
        $format_date       = array( 'date_created', 'date_modified', 'date_completed', 'date_paid' );
        $format_line_items = array( 'line_items', 'tax_lines', 'shipping_lines', 'fee_lines', 'coupon_lines' );

        // Format decimal values.
        foreach ( $format_decimal as $key ) {
            $data[ $key ] = wc_format_decimal( $data[ $key ], $this->request['dp'] );
        }

        // Format date values.
        foreach ( $format_date as $key ) {
            $datetime              = $data[ $key ];
            $data[ $key ]          = wc_rest_prepare_date_response( $datetime, false );
            $data[ $key . '_gmt' ] = wc_rest_prepare_date_response( $datetime );
        }

        // Format the order status.
        $data['status'] = 'wc-' === substr( $data['status'], 0, 3 ) ? substr( $data['status'], 3 ) : $data['status'];

        // Format line items.
        foreach ( $format_line_items as $key ) {
            $data[ $key ] = array_values( array_map( array( $this, 'get_order_item_data' ), $data[ $key ] ) );
        }

        // Refunds.
        $data['refunds'] = array();
        foreach ( $object->get_refunds() as $refund ) {
            $data['refunds'][] = array(
                'id'     => $refund->get_id(),
                'reason' => $refund->get_reason() ? $refund->get_reason() : '',
                'total'  => '-' . wc_format_decimal( $refund->get_amount(), $this->request['dp'] ),
            );
        }

        $payment_description = wc_get_payment_gateway_by_order($object)->description;
        return array(
            'id'                   => $object->get_id(),
            'parent_id'            => $data['parent_id'],
            'number'               => $data['number'],
            'order_key'            => $data['order_key'],
            'created_via'          => $data['created_via'],
            'version'              => $data['version'],
            'status'               => $data['status'],
            'currency'             => $data['currency'],
            'date_created'         => $data['date_created'],
            'date_created_gmt'     => $data['date_created_gmt'],
            'date_modified'        => $data['date_modified'],
            'date_modified_gmt'    => $data['date_modified_gmt'],
            'discount_total'       => $data['discount_total'],
            'discount_tax'         => $data['discount_tax'],
            'shipping_total'       => $data['shipping_total'],
            'shipping_tax'         => $data['shipping_tax'],
            'cart_tax'             => $data['cart_tax'],
            'subtotal_items'       => (string) $object->get_subtotal(),
            'total'                => $data['total'],
            'total_tax'            => $data['total_tax'],
            'prices_include_tax'   => $data['prices_include_tax'],
            'customer_id'          => $data['customer_id'],
            'customer_ip_address'  => $data['customer_ip_address'],
            'customer_user_agent'  => $data['customer_user_agent'],
            'customer_note'        => $data['customer_note'],
            'billing'              => $data['billing'],
            'shipping'             => $data['shipping'],
            'payment_method'       => $data['payment_method'],
            'payment_method_title' => $data['payment_method_title'],
            'payment_description'  => strip_tags( $payment_description ),
            'transaction_id'       => $data['transaction_id'],
            'date_paid'            => $data['date_paid'],
            'date_paid_gmt'        => $data['date_paid_gmt'],
            'date_completed'       => $data['date_completed'],
            'date_completed_gmt'   => $data['date_completed_gmt'],
            'cart_hash'            => $data['cart_hash'],
            'meta_data'            => $data['meta_data'],
            'line_items'           => $data['line_items'],
            'tax_lines'            => $data['tax_lines'],
            'shipping_lines'       => $data['shipping_lines'],
            'fee_lines'            => $data['fee_lines'],
            'coupon_lines'         => $data['coupon_lines'],
            'refunds'              => $data['refunds'],
            'decimals'             => wc_get_price_decimals(),
        );
    }

    public function get_order_item_data( $item ) {
        $data           = $item->get_data();
        $format_decimal = array( 'subtotal', 'subtotal_tax', 'total', 'total_tax', 'tax_total', 'shipping_tax_total' );

        // Format decimal values.
        foreach ( $format_decimal as $key ) {
            if ( isset( $data[ $key ] ) ) {
                $data[ $key ] = wc_format_decimal( $data[ $key ], $this->request['dp'] );
            }
        }

        // Add SKU and PRICE to products.
        if ( is_callable( array( $item, 'get_product' ) ) ) {
            $data['sku']   = $item->get_product() ? $item->get_product()->get_sku() : null;
            $data['price'] = $item->get_quantity() ? $item->get_total() / $item->get_quantity() : 0;
        }

        // Format taxes.
        if ( ! empty( $data['taxes']['total'] ) ) {
            $taxes = array();

            foreach ( $data['taxes']['total'] as $tax_rate_id => $tax ) {
                $taxes[] = array(
                    'id'       => $tax_rate_id,
                    'total'    => $tax,
                    'subtotal' => isset( $data['taxes']['subtotal'][ $tax_rate_id ] ) ? $data['taxes']['subtotal'][ $tax_rate_id ] : '',
                );
            }
            $data['taxes'] = $taxes;
        } elseif ( isset( $data['taxes'] ) ) {
            $data['taxes'] = array();
        }

        // Remove names for coupons, taxes and shipping.
        if ( isset( $data['code'] ) || isset( $data['rate_code'] ) || isset( $data['method_title'] ) ) {
            unset( $data['name'] );
        }

        // Remove props we don't want to expose.
        unset( $data['order_id'] );
        unset( $data['type'] );

        return $data;
    }

    public function getProductDetail() {

        $id = $_REQUEST['product_id'] ? $_REQUEST['product_id'] : false;
        $data = array();
        if($product = wc_get_product( $id )) {

            $args = array();
            $related_ids = array_values( wc_get_related_products( $product->get_id() ) );
            $upsell_ids = array_values( $product->get_upsell_ids( 'view' ) );
            $cross_sell_ids = array_values( $product->get_cross_sell_ids( 'view' ) );

            $args = array(
                'include' => $related_ids,
            );
            $data['relatedProducts'] = empty($args['include']) ? array() : $this->get_products($args);
            $args = array(
                'include' => $upsell_ids,
            );
            $data['upsellProducts'] = empty($args['include']) ? array() : $this->get_products($args);
            $args = array(
                'include' => $cross_sell_ids,
            );
            $data['crossProducts'] = empty($args['include']) ? array() : $this->get_products($args);

        }

        wp_send_json($data);

    }

    public function getProductReviews() {

        $id = $_REQUEST['product_id'] ? $_REQUEST['product_id'] : 21;
        $page = $_REQUEST['page'] ? $_REQUEST['page'] : 1;

        $data = array();

        if($product = wc_get_product( $id )) {

            $args = array ('status' => 'approve', 'post_type' => 'product', 'post_id' => $id, 'paged' => $page, 'number'  => '100',);
            $comments = get_comments( $args );

            foreach ( $comments as $i => $value ) {
                $data[] = array(
                    'id' => $value->comment_ID,
                    'author' => $value->comment_author,
                    'email' => $value->comment_author_email,
                    'content' => $value->comment_content,
                    'rating' =>get_comment_meta( $value->comment_ID, 'rating', true ),
                    'avatar' => get_avatar_url($value->comment_author_email, array('size' => 450)),
                    'date' => $value->comment_date
                );
            }

        }

        wp_send_json($data);

    }

    /* WC Marketplace */
    public function get_wcmap_vendor_details() {
        $id = $_REQUEST['id'];
        $vendor = get_wcmp_vendor($id);
        $vendor_term_id = get_user_meta( $vendor->id, '_vendor_term_id', true );
        $vendor_review_info = wcmp_get_vendor_review_info($vendor_term_id);
        $avg_rating = number_format(floatval($vendor_review_info['avg_rating']), 1);
        $rating_count = $vendor_review_info['total_rating'];
        $data = array(
            'id' => $vendor->id,
            'login' => $vendor->user_data->data->user_login,
            'first_name' => get_user_meta($vendor->id, 'first_name', true),
            'last_name' => get_user_meta($vendor->id, 'last_name', true),
            'nice_name'  => $vendor->user_data->data->user_nicename,
            'display_name'  => $vendor->user_data->data->display_name,
            'email'  => $vendor->user_data->data->email,
            'url'  => $vendor->user_data->data->user_url,
            'registered'  => $vendor->user_data->data->user_registered,
            'status'  => $vendor->user_data->data->user_status,
            'roles'  => $vendor->user_data->roles,
            'allcaps'  => $vendor->user_data->allcaps,
            'timezone_string'  => get_user_meta($vendor->id, 'timezone_string', true),
            'longitude'  => get_user_meta($vendor->id, '_store_lng', true),
            'latitude'  => get_user_meta($vendor->id, '_store_lat', true),
            'gmt_offset'  => get_user_meta($vendor->id, 'gmt_offset', true),
            'shop' => array(
                'url'  => $vendor->permalink,
                'title'  => $vendor->page_title,
                'slug'  => $vendor->page_slug,
                'description'  => $vendor->description,
                'image'  => wp_get_attachment_image_src( $vendor->image, 'medium', false ),
                'banner'  => wp_get_attachment_image_src( $vendor->banner, 'large', false ),
            ),
            'address' => array(
                'address_1'  => $vendor->address_1,
                'address_2'  => $vendor->address_2,
                'city'  => $vendor->city,
                'state'  => $vendor->state,
                'country'  => $vendor->country,
                'postcode'  => $vendor->postcode,
                'phone'  => $vendor->phone,
            ),
            'social' => array(
                'facebook'  => $vendor->fb_profile,
                'twitter'  => $vendor->twitter_profile,
                'google_plus'  => $vendor->google_plus_profile,
                'linkdin'  => $vendor->linkdin_profile,
                'youtube'  => $vendor->youtube,
                'instagram'  => $vendor->instagram,
            ),
            'payment' => array(
                'payment_mode'  => $vendor->payment_mode,
                'bank_account_type'  => $vendor->bank_account_type,
                'bank_name'  => $vendor->bank_name,
                'bank_account_number'  => $vendor->bank_account_number,
                'bank_address'  => $vendor->bank_address,
                'account_holder_name'  => $vendor->account_holder_name,
                'aba_routing_number'  => $vendor->aba_routing_number,
                'destination_currency'  => $vendor->destination_currency,
                'iban'  => $vendor->iban,
                'paypal_email'  => $vendor->paypal_email,
            ),
            'message_to_buyers'  => $vendor->message_to_buyers,
            'rating_count' => $rating_count,
            'avg_rating' => $avg_rating,
        );

        wp_send_json($data);

        die();
    }

    // Dokan Features
    public function get_vendors_list(){

        $paged    = $_REQUEST['page'];
        $per_page = $_REQUEST['per_page'];
        $length  = absint( $per_page );
        $offset  = ( $paged - 1 ) * $length;

        // Get all vendors
        $vendor_paged_args = array (
            'role'  => 'seller',
            'orderby' => 'registered',
            'offset'  => $offset,
            'number'  => $per_page,
            'status'     => 'approved',
        );

        $show_products = 'yes';

        if ($show_products == 'yes') $vendor_total_args['query_id'] = 'vendors_with_products';

        $vendor_query = New WP_User_Query( $vendor_paged_args );
        $all_vendors = $vendor_query->get_results();

        $vendors = array();
        foreach ( $all_vendors as $i => $value ) {

            $store_info = dokan_get_store_info( $all_vendors[$i]->ID );
            $store_info['payment'] = null;
            $vendors[] = array(
                'id' => $all_vendors[$i]->ID,
                'store_info' => $store_info,
                'store_name' => $store_info['store_name'],
                'banner_url' => wp_get_attachment_url( $store_info['banner'] ),
                'logo' => wp_get_attachment_url( $store_info['banner'] ),
            );

        }

        wp_send_json(  $vendors );

    }

    // WCFM Features
    public function get_wcfm_vendor_list($distance) {

        global $WCFM, $WCFMmp, $wpdb;

        $search_term     = isset( $_REQUEST['search_term'] ) ? sanitize_text_field( $_REQUEST['search_term'] ) : '';
        $search_category = isset( $_REQUEST['wcfmmp_store_category'] ) ? sanitize_text_field( $_REQUEST['wcfmmp_store_category'] ) : '';
        $pagination_base = isset( $_REQUEST['pagination_base'] ) ? sanitize_text_field( $_REQUEST['pagination_base'] ) : '';
        $paged           = isset( $_REQUEST['page'] ) ? absint( $_REQUEST['page'] ) : 1;
        $per_row         = isset( $_REQUEST['per_row'] ) ? absint( $_REQUEST['per_row'] ) : 3;
        $per_page        = isset( $_REQUEST['per_page'] ) ? absint( $_REQUEST['per_page'] ) : 10;
        $includes        = isset( $_REQUEST['includes'] ) ? sanitize_text_field( $_REQUEST['includes'] ) : '';
        $excludes        = isset( $_REQUEST['excludes'] ) ? sanitize_text_field( $_REQUEST['excludes'] ) : '';
        $orderby         = isset( $_REQUEST['orderby'] ) ? sanitize_text_field( $_REQUEST['orderby'] ) : 'newness_asc';
        $has_orderby     = isset( $_REQUEST['has_orderby'] ) ? sanitize_text_field( $_REQUEST['has_orderby'] ) : '';
        $has_product     = isset( $_REQUEST['has_product'] ) ? sanitize_text_field( $_REQUEST['has_product'] ) : '';
        $sidebar         = isset( $_REQUEST['sidebar'] ) ? sanitize_text_field( $_REQUEST['sidebar'] ) : '';
        $theme           = isset( $_REQUEST['theme'] ) ? sanitize_text_field( $_REQUEST['theme'] ) : 'simple';
        $search_data     = array();

        if( isset( $_REQUEST['search_data'] ) ) {
            $search_data     = array('distance' => $distance);
            parse_str($_REQUEST['search_data'], $search_data);
        }

        $length  = absint( $per_page );
        $offset  = ( $paged - 1 ) * $length;

        $search_data['excludes'] = $excludes;

        if( $includes ) $includes = explode(",", $includes);
        else $includes = array();

        $stores = $WCFMmp->wcfmmp_vendor->wcfmmp_search_vendor_list( true, $offset, $length, $search_term, $search_category, $search_data, $has_product, $includes );

        $store_data = array();
        foreach ( $stores as $store_id => $store_name ) {

            $store_user = wcfmmp_get_store( $store_id );

            $banner = $store_user->get_list_banner();
            if( !$banner ) {
                $banner = isset( $WCFMmp->wcfmmp_marketplace_options['store_list_default_banner'] ) ? $WCFMmp->wcfmmp_marketplace_options['store_list_default_banner'] : $WCFMmp->plugin_url . 'assets/images/default_banner.jpg';
                $banner = apply_filters( 'wcfmmp_list_store_default_bannar', $banner );
            }

            $store_info = $store_user->get_shop_info();
            $store_info['payment'] = null;
            $store_info['commission'] = null;
            $store_info['withdrawal'] = null;

            $store_data[] = array(
                'id' => $store_id,
                'name' => isset( $store_info['store_name'] ) ? esc_html( $store_info['store_name'] ) : __( 'N/A', 'wc-multivendor-marketplace' ),
                'icon' => $store_user->get_avatar(),
                'banner' => $banner,
                //'store_name' => apply_filters( 'wcfmmp_store_title', $store_name , $store_id ),
                'address' => $store_user->get_address_string(),
                'description' => $store_user->get_shop_description(),
                'latitude'    => isset( $store_info['store_lat'] ) ? esc_attr( $store_info['store_lat'] ) : null,
                'longitude'    => isset( $store_info['store_lng'] ) ? esc_attr( $store_info['store_lng'] ) : null,
                'average_rating' => (float)wc_format_decimal( get_user_meta( $vendor_id, '_wcfmmp_total_review_count', true ), 2 ),
                'rating_count' => (int)$store_user->get_total_review_count(),
                'is_close' => $this->wcfmmp_is_store_close($store_id),
            );
        }

        return $store_data;
    }

    /* Reward Points */
    public function get_point_purchase() {

        $points_earned = 0;

        foreach ( WC()->cart->get_cart() as $item_key => $item ) {
            $points_earned += apply_filters( 'woocommerce_points_earned_for_cart_item', WC_Points_Rewards_Product::get_points_earned_for_product_purchase( $item['data'] ), $item_key, $item ) * $item['quantity'];
        }

        // reduce by any discounts.  One minor drawback: if the discount includes a discount on tax and/or shipping
        //  it will cost the customer points, but this is a better solution than granting full points for discounted orders
        if ( version_compare( WC_VERSION, '2.3', '<' ) ) {
            $discount = WC()->cart->discount_cart + WC()->cart->discount_total;
        } else {
            $discount = WC()->cart->discount_cart;
        }

        $discount_amount = min( WC_Points_Rewards_Manager::calculate_points( $discount ), $points_earned );

        // apply a filter that will allow users to manipulate the way discounts affect points earned
        $points_earned = apply_filters( 'wc_points_rewards_discount_points_modifier', $points_earned - $discount_amount, $points_earned, $discount_amount );

        // check if applied coupons have a points modifier and use it to adjust the points earned
        $coupons = WC()->cart->get_applied_coupons();

        if ( ! empty( $coupons ) ) {

            $points_modifier = 0;

            // get the maximum points modifier if there are multiple coupons applied, each with their own modifier
            foreach ( $coupons as $coupon_code ) {

                $coupon = new WC_Coupon( $coupon_code );
                $coupon_id = version_compare( WC_VERSION, '3.0', '<' ) ? $coupon->id : $coupon->get_id();
                $wc_points_modifier = get_post_meta( $coupon_id, '_wc_points_modifier' );

                if ( ! empty( $wc_points_modifier[0] ) && $wc_points_modifier[0] > $points_modifier ) {
                    $points_modifier = $wc_points_modifier[0];
                }
            }

            if ( $points_modifier > 0 ) {
                $points_earned = round( $points_earned * ( $points_modifier / 100 ) );
            }
        }

        return apply_filters( 'wc_points_rewards_points_earned_for_purchase', $points_earned, WC()->cart );
    }

    public function ajax_maybe_apply_discount() {

        // bail if the discount has already been applied
        $existing_discount = WC_Points_Rewards_Discount::get_discount_code();

        // bail if the discount has already been applied
        if ( ! empty( $existing_discount ) && WC()->cart->has_discount( $existing_discount ) )          {
            wc_add_notice( 'Discount already applied', 'error' );
            wc_print_notices();
            die;
        }

        // Get discount amount if set and store in session
        WC()->session->set( 'wc_points_rewards_discount_amount', ( ! empty( $_POST['discount_amount'] ) ? absint( $_POST['discount_amount'] ) : '' ) );

        // generate and set unique discount code
        $discount_code = WC_Points_Rewards_Discount::generate_discount_code();

        // apply the discount
        WC()->cart->add_discount( $discount_code );

        wc_print_notices();
        die;
    }

    public function getPointsHistory(){

        $per_page = 20;
        $pagenum = 1;

        if ( isset( $_REQUEST['pagenum'] ))
        $pagenum = $_REQUEST['pagenum'];

        $args = array(
            'orderby' => array(
                'field' => 'date',
                'order' => 'DESC',
            ),
            'per_page'         => $per_page,
            'paged'            => $pagenum,
            'calc_found_rows' => true,
        );

        $args['user'] = get_current_user_id();

        $data = array(
            'items' => WC_Points_Rewards_Points_Log::get_points_log_entries( $args ),
            'points' => WC_Points_Rewards_Manager::get_users_points($args['user']),
            'points_vlaue' => WC_Points_Rewards_Manager::get_users_points_value($args['user']),
        );

        wp_send_json($data);
    }
    /* Reward Points */

    public function getProducts(){

        $products = $this->get_products();

        wp_send_json($products);
    }

    public function getProduct() {

        if(isset($_REQUEST['product_id'])) {
            $id = $_REQUEST['product_id'];
            $product = wc_get_product($id);
        } else if (isset($_REQUEST['sku'])) {
            $sku = $_REQUEST['sku'];
            $id = wc_get_product_id_by_sku($sku);
            $product = wc_get_product($id);
        }

        if($product) {

            $available_variations = $product->get_type() == 'variable' ? $product->get_available_variations() : null;
            $variation_attributes = $product->get_type() == 'variable' ? $product->get_variation_attributes() : null;

            $variation_options = array();
            $emptyValuesKeys = array();
            if($available_variations != null) {
                $values = array();
                foreach ( $available_variations as $key => $value ) {
                    foreach ( $value['attributes'] as $atr_key => $atr_value ) {
                        $available_variations[$key]['option'][] = array(
                            'key' => $atr_key,
                            'value' => $this->attribute_slug_to_title($atr_key, $atr_value) //make it name
                        );
                        $values[] = $this->attribute_slug_to_title($atr_key, $atr_value);
                        if(empty($atr_value))
                        $emptyValuesKeys[] = $atr_key;

                        $variation = wc_get_product( $value['variation_id'] );

                        $regular_price = $variation->get_regular_price();
                        $sale_price = $variation->get_sale_price();

                        $available_variations[$key]['formated_price'] = $regular_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $regular_price ) ))) : strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $variation->get_price() ) )));
                        $available_variations[$key]['formated_sales_price'] = $sale_price ? strip_tags(wc_price(wc_get_price_to_display( $variation, array( 'price' => $sale_price ) ))) : null;
                    }
                    $available_variations[$key]['image_id'] = null;
                }
                if($variation_attributes)
                foreach ( $variation_attributes as $attribute_name => $options ) {

                    $new_options = array();
                    foreach (array_values($options) as $key => $value) {
                        $new_options[] = $this->attribute_slug_to_title($attribute_name, $value);
                    }
                    if (!in_array('attribute_' . $attribute_name, $emptyValuesKeys)) {
                        $options = array_intersect ( array_values($new_options) , $values );
                    }
                    $variation_options[] = array(
                        'name' => wc_attribute_label( $attribute_name ),
                        'options'   => (array)$options,
                        'attribute' => wc_attribute_label($attribute_name),
                    );
                }
            }

            $results = array(
                'id' => $product->get_id(),
                'name' => $product->get_name(),
                'sku' => $product->get_sku( 'view' ),
                'type' => $product->get_type(),
                'status' => $product->get_status(),
                'permalink'  => $product->get_permalink(),
                'description' => $product->get_description(),
                'short_description' => $product->get_short_description(),
                'formated_price' => $product->get_regular_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_regular_price() ) ))) : strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_price() ) ))),
                'formated_sales_price' => $product->get_sale_price() ? strip_tags(wc_price(wc_get_price_to_display( $product, array( 'price' => $product->get_sale_price() ) ))) : null,
                'price' => (int)$product->get_price(),
                'regular_price' => (int)$product->get_regular_price(),
                'sale_price' => (int)$product->get_sale_price(),
                'stock_status' => $product->get_stock_status(),
                'stock_quantity'     => $product->get_stock_quantity(),
                'on_sale' => $product->is_on_sale( 'view' ),
                'average_rating'        => wc_format_decimal( $product->get_average_rating(), 2 ),
                'rating_count'          => $product->get_rating_count(),
                'related_ids'           => array_map( 'absint', array_values( wc_get_related_products( $product->get_id() ) ) ),
                'upsell_ids'            => array_map( 'absint', $product->get_upsell_ids( 'view' ) ),
                'cross_sell_ids'        => array_map( 'absint', $product->get_cross_sell_ids( 'view' ) ),
                'parent_id'             => $product->get_parent_id( 'view' ),
                'images' => $this->get_images($product),
                'attributes'            => $this->get_attributes( $product ),
                'availableVariations'   => $available_variations,
                'variationAttributes'   => $variation_attributes,
                'meta_data'             => $product->get_meta_data(),
                'variationOptions'      => $variation_options,
                'total_sales'           => (int)$product->get_total_sales(),
                'vendor'                => $this->get_product_vendor($product->get_id()),
                'grouped_products'      => $product->get_children(),
                'children'              => $children,
                //'categories'            => wc_get_object_terms( $product->get_id(), 'product_cat', 'term_id' ),
                //'tags'               => wc_get_object_terms( $product->get_id(), 'product_tag', 'name' ),
                //'cashback_amount'       => woo_wallet()->cashback->get_product_cashback_amount($product) //UnComment Whne cashback need only
            );

            wp_send_json($results);

        } else wp_send_json((object)array());

    }

    public function get_vendors($distance = 10) {

        switch ($this->which_vendor()) {
            case 'dokan':
                return $this->get_dokan_vendor_list($distance);
                break;
            case 'wcfm':
                return $this->get_wcfm_vendor_list($distance);
                break;
            case 'wc_marketplace':
                return $this->get_wc_marketplace_vendor_list();
                break;
            case 'product_vendor':
                return $this->get_product_vendor_list();
                break;
            default:
                return array();
        }
    }

    private function which_vendor() {
        if ( ! function_exists( 'is_plugin_active' ) ) {
            include_once( ABSPATH . 'wp-admin/includes/plugin.php' );
        }
        if(is_plugin_active( 'dokan-lite/dokan.php') || is_plugin_active( 'dokan/dokan.php' )){
            return 'dokan';
        }
        else if(is_plugin_active( 'dc-woocommerce-multi-vendor/dc_product_vendor.php' )){
            return 'wc_marketplace';
        }
        else if(is_plugin_active( 'wc-multivendor-marketplace/wc-multivendor-marketplace.php' )){
            return 'wcfm';
        } else if(is_plugin_active( 'woocommerce-product-vendors/woocommerce-product-vendors.php' )){
            return 'product_vendor';
        }
        else return null;
    }

    public function get_product_vendor_list(){
        $terms = get_terms( 'wcpv_product_vendors', array( 'hide_empty' => false ) );

        $vendors = array();
        $vendor_data = array();
        foreach ( $terms as $term ) {

            $vendor_data = get_term_meta( $term->term_id, 'vendor_data', true );

            $image_icon = wp_get_attachment_image_src( $vendor_data['logo'], 'medium', false );
            $icon = $image_icon ? $image_icon[0] : '';

            $vendors[] = array(
                'id' => $term->term_id,
                'product_vendor' => $term->term_id,
                'name' => $term->name,
                'icon' => $icon,
                'banner' => null,
                'address' => null,
                'description' => $term->description,
                'latitude'   => null,
                'longitude'   => null,
                'average_rating' => null,
                'rating_count' => null,
                'count' => $term->count,
                'wcpv_product_vendors' => $term->term_id,
            );
        }

        return $vendors;
    }

    public function get_dokan_vendor_list($distance){

        $post = $_POST;
        $_GET = $_POST;

        $vendors  = array();
        $paged    = isset( $_REQUEST['page'] ) ? absint( $_REQUEST['page'] ) : 1;
        $per_page = isset( $_REQUEST['per_page'] ) ? absint( $_REQUEST['per_page'] ) : 100;
        $length   = absint( $per_page );
        $offset   = ( $paged - 1 ) * $length;
        $search_term     = isset( $_REQUEST['search'] ) ? sanitize_text_field( wp_unslash( $_REQUEST['search'] ) ) : '';

        // Get all vendors
        $seller_args = array (
            'role__in'   => array( 'seller', 'administrator' ),
            'orderby' => 'registered',
            'offset'  => $offset,
            'number'  => $per_page,
            'status'     => 'approved',
        );

        if ( '' != $search_term ) {
            $seller_args['meta_query'] = array(
                array(
                    'key'     => 'dokan_store_name',
                    'value'   => $search_term,
                    'compare' => 'LIKE',
                ),
            );
        }

        $show_products = 'yes';

        if ($show_products == 'yes') $vendor_total_args['query_id'] = 'vendors_with_products';

        $post = $_POST;

        if(isset($post['distance']) && isset($post['latitude']) && isset($post['longitude'])) {
            set_query_var( 'address', $post['address'] );
            set_query_var( 'distance', $post['distance'] );
            set_query_var( 'latitude', $post['latitude'] );
            set_query_var( 'longitude', $distance );
        }

        $all_vendors = dokan_get_sellers( apply_filters( 'dokan_seller_listing_args', $seller_args, $_GET ) );

        $vendors = array();
        foreach ( $all_vendors['users'] as $i => $value ) {

            $store_info = dokan_get_store_info( $value->ID );
            $store_info['payment'] = null;

            $store_user   = dokan()->vendor->get( $value->ID );
            $rating = $store_user->get_rating();

            // For Dokan Light
            $location = explode(',', $store_info['location']);
            $latitude = number_format((float)$location[0], 6);
            $longitude = number_format((float)$location[1], 6);

            //For Dokan Pro
            //$latitude = get_user_meta( $value->ID, 'dokan_geo_latitude', true );
            //$longitude = get_user_meta( $value->ID, 'dokan_geo_longitude', true );

            $vendors[] = array(
                'id' => $value->ID,
                'name' => $store_info['store_name'],
                'banner' => $store_user->get_banner(),
                'icon' => $store_user->get_avatar(),
                'address' => $store_info['address'],
                'description' => $store_info['address']['street_1'],
                'is_close' => dokan_is_store_open( $value->ID ),
                'latitude' => $latitude,
                'longitude' => $longitude,
                'average_rating' => $rating['count'] == 0 ? 0 : (float)$rating['rating'],
                'rating_count' => $rating['count'],
            );

        }

        return $vendors;
    }

    public function get_wc_marketplace_vendor_list(){

        $args = array(
            'number' => $_REQUEST['per_page'],
            'offset' => ( $_REQUEST['page'] - 1 ) * $_REQUEST['per_page']
        );

        if ( ! empty( $_REQUEST['orderby'] ) ) {
            $args['orderby'] = $_REQUEST['orderby'];
        }

        if ( ! empty( $_REQUEST['order'] ) ) {
            $args['order'] = $_REQUEST['order'];
        }

        if ( ! empty( $_REQUEST['status'] ) ) {
            if($_REQUEST['status'] == 'pending') $args['role'] = 'dc_pending_vendor';
            else $args['role'] = $this->post_type;
        }

        $object = array();
        $response = array();
        $store_data = array();

        $args = wp_parse_args($args, array('role' => 'dc_vendor', 'fields' => 'ids', 'orderby' => 'registered', 'order' => 'ASC'));

        $user_query = new WP_User_Query($args);
        if (!empty($user_query->results)) {
            foreach ( $user_query->results as $vendor_id) {
                $vendor = get_wcmp_vendor($vendor_id);
                $vendor_term_id = get_user_meta( $vendor->id, '_vendor_term_id', true );
                $vendor_review_info = wcmp_get_vendor_review_info($vendor_term_id);
                $avg_rating = number_format(floatval($vendor_review_info['avg_rating']), 1);
                $rating_count = $vendor_review_info['total_rating'];

                $image_icon = wp_get_attachment_image_src( $vendor->image, 'medium', false );
                $icon = $image_icon ? $image_icon[0] : '';

                $image_banner = wp_get_attachment_image_src( $vendor->image, 'medium', false );
                $banner = $image_banner ? $image_banner[0] : '';



                $store_data[] = array(
                    'id' => $vendor->id,
                    'name' => $vendor->page_title,
                    'icon' => $icon,
                    'banner' => $banner,
                    //'store_name' => apply_filters( 'wcfmmp_store_title', $store_name , $store_id ),
                    //'address' => $store_user->get_address_string(),
                    //'description' => $store_user->get_shop_description(),
                    'latitude'    => get_user_meta($vendor->id, '_store_lng', true),
                    'longitude'    => get_user_meta($vendor->id, '_store_lat', true),
                    'average_rating' => (float)wc_format_decimal( $avg_rating, 2 ),
                    'rating_count' => (int)$rating_count,
                );
            }
        }

        return $store_data;
    }

    function wcfmmp_is_store_close( $vendor_id ) {
        global $WCFM, $WCFMmp;

        $is_store_close = false;

        if( !$WCFM->wcfm_vendor_support->wcfm_vendor_has_capability( $vendor_id, 'store_hours' ) ) return $is_store_close;

        if( $vendor_id ) {
            $wcfm_vendor_store_hours = get_user_meta( $vendor_id, 'wcfm_vendor_store_hours', true );
            if( !empty( $wcfm_vendor_store_hours ) ) {
                $wcfm_store_hours_enable = isset( $wcfm_vendor_store_hours['enable'] ) ? 'yes' : 'no';
                if( $wcfm_store_hours_enable == 'yes' ) {
                    $wcfm_store_hours_disable_purchase = isset( $wcfm_vendor_store_hours['disable_purchase'] ) ? 'yes' : 'no';
                    if( $wcfm_store_hours_disable_purchase == 'yes' ) {
                        $wcfm_store_hours_off_days = isset( $wcfm_vendor_store_hours['off_days'] ) ? $wcfm_vendor_store_hours['off_days'] : array();
                        $wcfm_store_hours_day_times = isset( $wcfm_vendor_store_hours['day_times'] ) ? $wcfm_vendor_store_hours['day_times'] : array();

                        $current_time = current_time( 'timestamp' );

                        $today = date( 'N', $current_time );
                        $today -= 1;

                        $today_date = date( 'Y-m-d', $current_time );

                        // OFF Day Check
                        if( !empty( $wcfm_store_hours_off_days ) ) {
                            if( in_array( $today,  $wcfm_store_hours_off_days ) )  $is_store_close = true;
                        }

                        // Closing Hours Check
                        if( !$is_store_close && !empty( $wcfm_store_hours_day_times ) ) {
                            if( isset( $wcfm_store_hours_day_times[$today] ) ) {
                                $wcfm_store_hours_day_time_slots = $wcfm_store_hours_day_times[$today];
                                if( !empty( $wcfm_store_hours_day_time_slots ) ) {
                                    if( isset( $wcfm_store_hours_day_time_slots[0] ) && isset( $wcfm_store_hours_day_time_slots[0]['start'] ) ) {
                                        if( !empty( $wcfm_store_hours_day_time_slots[0]['start'] ) && !empty( $wcfm_store_hours_day_time_slots[0]['end'] ) ) {
                                            $is_store_close = true;
                                            foreach( $wcfm_store_hours_day_time_slots as $slot => $wcfm_store_hours_day_time_slot ) {
                                                $open_hours  = isset( $wcfm_store_hours_day_time_slot['start'] ) ? strtotime( $today_date . ' ' . $wcfm_store_hours_day_time_slot['start'] ) : '';
                                                $close_hours = isset( $wcfm_store_hours_day_time_slot['end'] ) ? strtotime( $today_date . ' ' . $wcfm_store_hours_day_time_slot['end'] ) : '';
                                                //wcfm_log( $current_time . " => " . $open_hours . " ::" . $close_hours );
                                                //wcfm_log( date( wc_date_format() . ' ' . wc_time_format(), $current_time ) . " => " . date( wc_date_format() . ' ' . wc_time_format(), $open_hours ) . " ::" . date( wc_date_format() . ' ' . wc_time_format(), $close_hours ) );
                                                if( $open_hours && $close_hours ) {
                                                    if( ( $current_time > $open_hours ) && ( $current_time < $close_hours ) )  {
                                                        $is_store_close = false;
                                                        break;
                                                    }
                                                } else {
                                                    $is_store_close = false;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return $is_store_close;
    }

    public function cancel_order() {
        $order_id = $_REQUEST['id'];
        $order = new WC_Order($order_id);
        if(get_current_user_id() == $order->get_user_id())
        $order->update_status('cancelled', 'order_note');
        $this->getOrder();
    }

    public function dokan_apply_for_vendor() {

        $user = wp_get_current_user();

        $shopurl = isset( $_POST['shopurl'] ) ? sanitize_text_field( wp_unslash( $_POST['shopurl'] ) ) : '';
        $check_user     = get_user_by( 'slug', $shopurl );
        if ( false !== $check_user ) {
            $response = array(
                array(
                'message' => 'Shop URL not available',
                'code' => '0'
            ));
            wp_send_json_error(  $response, 400 );
        }

        $this->dokan_save_vendor_info( $user );

        $customer = new WC_Customer( $user->ID );
        $data = $this->get_formatted_item_data_customer( $customer );
        wp_send_json($data);

    }

    public function dokan_save_vendor_info( $user ) {
        $post_data = wp_unslash( $_POST ); // WPCS: CSRF ok.

        $user->add_role( 'seller' );
        $user->remove_role( 'customer' );

        $social_profiles = array();

        foreach ( dokan_get_social_profile_fields() as $key => $item ) {
            $social_profiles[ $key ] = '';
        }

        $dokan_settings = array(
            'store_name'     => sanitize_text_field( wp_unslash( $post_data['shopname'] ) ),
            'social'         => $social_profiles,
            'payment'        => array(),
            'phone'          => sanitize_text_field( wp_unslash( $post_data['phone'] ) ),
            'show_email'     => 'no',
            'location'       => '',
            'find_address'   => '',
            'dokan_category' => '',
            'banner'         => 0,
        );

        // Intially add values on profile completion progress bar
        $dokan_settings['profile_completion']['store_name']     = 10;
        $dokan_settings['profile_completion']['phone']          = 10;
        $dokan_settings['profile_completion']['next_todo']      = 'banner_val';
        $dokan_settings['profile_completion']['progress']       = 20;
        $dokan_settings['profile_completion']['progress_vals']  = array(
            'banner_val'            => 15,
            'profile_picture_val'   => 15,
            'store_name_val'        => 10,
            'address_val'           => 10,
            'phone_val'             => 10,
            'map_val'               => 15,
            'payment_method_val'    => 15,
            'social_val' => array(
                'fb'        => 2,
                'gplus'     => 2,
                'twitter'   => 2,
                'youtube'   => 2,
                'linkedin'  => 2,
            ),
        );

        update_user_meta( $user->ID, 'dokan_profile_settings', $dokan_settings );
        update_user_meta( $user->ID, 'dokan_store_name', $dokan_settings['store_name'] );

        if(isset($post_data['shopurl'])) {
            wp_update_user( array(
                'ID'            => $user->ID,
                'user_nicename' => sanitize_user( $post_data['shopurl'] )
            ) );
        }

        return;
    }

    public function get_nonce() {
        return array(
            'woo_wallet_topup' => wp_create_nonce( 'woo_wallet_topup' )
        );
    }
}
