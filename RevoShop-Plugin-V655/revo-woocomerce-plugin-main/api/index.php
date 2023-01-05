<?php  
	function rest_home(){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$lang = $_GET['lang'] ?? '';

		$rest_slider = rest_slider('get');
		$rest_categories = rest_categories('get');

		$query_ac = "SELECT slug, title, image, description, update_at FROM `revo_mobile_variable` WHERE slug = 'app_color'";
		$data_ac = $wpdb->get_results($query_ac, OBJECT);

		$categories = get_categories([
			'taxonomy' => 'product_cat',
			'hide_empty' => false,
			'orderby' => 'name',
			'order' => 'ASC',
			'lang' => $lang
		]);

		if (!empty($categories)) {
			$categories = array_map(function ($category) {
				$thumbnail_id = get_term_meta($category->term_id, 'thumbnail_id', true);
				$image = wp_get_attachment_url( $thumbnail_id ); 

				return [
					'id'    => $category->term_id,
					'name'  => $category->name,
					'slug'  => $category->slug,
					'image' => [
						'src' => $image ? $image : ""
					]
				];
			}, $categories);
		}

		$result['app_color'] = $data_ac;
		$result['main_slider'] = $rest_slider;
		$result['mini_categories'] = $rest_categories;
		$result['mini_banner'] = rest_mini_banner('result');
		$result['popup_promo'] = rest_mini_banner_specific('result', 'PopUp Promo');
		$result['flash_sale']  = rest_mini_banner_specific('result', 'Flash Sale');
		$result['general_settings'] = rest_get_general_settings('result');
		
		$get_intro = rest_get_intro_page('result');
		$result = array_merge($result, $get_intro);
		$revo_loader = load_Revo_Flutter_Mobile_App_Public();

		$result['categories'] = $categories; 
		$result['new_product'] = $revo_loader->get_products(['limit' => 8, 'order_by' => 'date', 'order' => 'DESC', 'lang' => $lang]);
		$result['products_flash_sale'] = rest_product_flash_sale('result',$revo_loader);
		$result['products_special'] = rest_additional_products('result','special',$revo_loader);
		$result['products_our_best_seller'] = rest_additional_products('result','our_best_seller',$revo_loader);
		$result['products_recomendation'] = rest_additional_products('result','recomendation',$revo_loader);
		$result['aftership'] = rest_get_aftership();

		echo json_encode($result);
		exit();
	}

	function rest_product_details(){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		// $req = (Object) array_merge($_POST,$_GET,$_);
		$revo_loader = load_Revo_Flutter_Mobile_App_Public();
		$search = cek_raw('product_id') ?? get_page_by_path( cek_raw('slug'), OBJECT, 'product' );
		$product = wc_get_product($search);
		//return ['products'=>$revo_loader->get_products(),'id'=>cek_raw('product_id')];
		return $revo_loader->reformat_product_result($product);
	}

	function rest_product_lists(){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		$revo_loader = load_Revo_Flutter_Mobile_App_Public();
		

		$args = [
			'limit'=> cek_raw('perPage') ?? 1,
			'page'=> cek_raw('page') ?? 10,
			'featured' => cek_raw('featured'),
			'category' => cek_raw('category'),
			'orderby' => cek_raw('orderby') ?? 'date',
			'order'  => cek_raw('order') ?? 'DESC',
		];

		if ($parent = cek_raw('parent')) {
			$args['parent'] = $parent;
		}
		if ($include = cek_raw('include')) {
			$args['include'] = $include;
		}
		if ($search = cek_raw('search')) {
			$args['like_name'] = $search;
		}
		
		$products = wc_get_products( $args );
		$results = array();
		foreach ($products as $i => $product) {
			array_push($results,$revo_loader->reformat_product_result($product));
		}

		echo json_encode($results);
		exit;
	}

	function rest_list_product($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$revo_loader = load_Revo_Flutter_Mobile_App_Public();		

		$args = [
			'include' => cek_raw('include'),
			'exclude' => cek_raw('exclude'),
			'page' => cek_raw('page') ?? 1,
			'limit' => cek_raw('per_page') ?? 10,
			'parent' => cek_raw('parent'),
			'search' => cek_raw('search'),
			'category' => cek_raw('category'),
			'slug_category' => cek_raw('slug_category'),
			'slug' => cek_raw('slug'),
			'id' => cek_raw('id'),
			'featured' => cek_raw('featured'),
			'order' => cek_raw('order') ?? 'DESC',
			'order_by' => cek_raw('order_by') ?? 'date',
			'attribute' => cek_raw('attribute'),
			'price_range' => cek_raw('price_range'),
			'sku' => cek_raw('sku'),
			'exclude_sku' => cek_raw('exclude_sku'),
			'lang' => cek_raw('lang')
		];

		$result = $revo_loader->get_products($args);

		if ($type == 'rest') {

			echo json_encode($result);

			exit();

		}else{

			return $result;

		}

	}

	function rest_additional_products($type = 'rest',$product_type,$revo_loader){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$lang = $_GET['lang'] ?? '';

		$where = '';

		if ($product_type == 'special') {
			$where = "AND type = 'special'";
		}elseif ($product_type == 'our_best_seller') {
			$where = "AND type = 'our_best_seller'";
		}elseif ($product_type == 'recomendation') {
			$where = "AND type = 'recomendation'";
		}

		$products = $wpdb->get_results("SELECT * FROM `revo_extend_products` WHERE is_deleted = 0 AND is_active = 1 $where  ORDER BY id DESC", OBJECT);

		$result = [];
		$list_products = [];
		foreach ($products as $key => $value) {

			if (!empty(json_decode($value->products))) {
				$_POST['include'] = $value->products;
				$list_products = $revo_loader->get_products( array (
					'lang' => $lang 
				) );
			}

			array_push($result, [
				'title' => $value->title,
				'description' => $value->description,
				'products' => $list_products,
			]);

		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_get_aftership(){
		return [
			'plugin_active' => is_plugin_active('aftership-woocommerce-tracking/aftership-woocommerce-tracking.php'), 
			'aftership_domain' => $GLOBALS['AfterShip']->custom_domain ?? ""
		];
	}

	function rest_product_flash_sale($type = 'rest',$revo_loader){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		$lang = $_GET['lang'] ?? '';

		cek_flash_sale_end();
		$date = date('Y-m-d H:i:s');
		$data_flash_sale = $wpdb->get_results("SELECT * FROM `revo_flash_sale` WHERE is_deleted = 0 AND start <= '".$date."' AND end >= '".$date."' AND is_active = 1  ORDER BY id DESC LIMIT 1", OBJECT);

		$result = [];
		$list_products = [];
		foreach ($data_flash_sale as $key => $value) {
			if (!empty($value->products)) {
				$_POST['include'] = $value->products;
				$list_products = $revo_loader->get_products( array( 
					'lang' => $lang
				) );
			}
			array_push($result, [
				'id' => (int) $value->id,
				'title' => $value->title,
				'start' => $value->start,
				'end' => $value->end,
				'image' => $value->image,
				'products' => $list_products,
			]);
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function index_home(){
		$rest_slider = rest_slider('get');
		$rest_categories = rest_categories('get');

		$result['slider'] = $rest_slider;
		$result['categories'] = $rest_categories;

		echo json_encode($result);
		exit();
	}

	function rest_slider($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$lang = $_GET['lang'] ?? '';

		$data_banner = $wpdb->get_results("SELECT * FROM revo_mobile_slider WHERE is_deleted = 0 AND product_id is not null ORDER BY order_by DESC", OBJECT);

		$result = [];
		foreach ($data_banner as $key => $value) {
			$type = explode('|', $value->product_name)[0];
			$product_name = explode('|', $value->product_name)[1] ?? '';
			$link_to = $type == 'cat' ? 'category' : ($type == 'blog' ? 'blog' : ($type == 'URL' ? 'URL' : ($type == 'attribute' ? 'attribute' : 'product')));

			if (empty($product_name)) {
				$product_name = $type;
			}

			if (in_array($link_to, ['blog', 'product', 'category'])) {
				if ($link_to !== 'category') {
					$p = get_posts([
						'lang' => $lang,
						'include' => [$value->product_id],
						'post_type' => $link_to == 'blog' ? 'post' : $link_to
					]);
				} else {
					$p = get_terms([
						'taxonomy' => 'product_cat',
						'lang' => $lang,
						'include' => [$value->product_id],
						'hide_empty' => false
					]);
				}
				
				if (count($p) <= 0) {
					continue;
				}
			}

			array_push($result, [
				'link_to' => $link_to,
				'name' => $product_name,
				'product' => (int) $value->product_id,
				'title_slider' => $value->title,
				'image' => $value->images_url,
			]);
		}

		// if (empty($result)) {
		// 	for ($i=0; $i < 3; $i++) { 
		// 		array_push($result, [
		// 			'product' => (int) '0',
		// 			'title_slider' => '',
		// 			'image' => revo_url().'assets/extend/images/default_banner.png',
		// 		]);
		// 	}
		// }

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_mini_banner($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$lang = $_GET['lang'] ?? '';

		$where = '';
		if (isset($_GET['blog_banner'])) {
			$where = "AND type = 'Blog Banner' ";
		}
		$data_banner = $wpdb->get_results("SELECT * FROM revo_list_mini_banner WHERE is_deleted = 0 AND product_id is not null $where ORDER BY order_by ASC", OBJECT);
		
		$result = [];
		if (isset($_GET['blog_banner'])) {
			foreach ($data_banner as $key => $value) {
				$type = explode('|', $value->product_name)[0];
				$name = explode('|', $value->product_name)[1];
				$link_to = $type == 'cat' ? 'category' : ($type == 'blog' ? 'blog' : ($type == 'URL' ? 'URL' : ($type == 'attribute' ? 'attribute' : 'product')));
				$product_name = $type == 'cat' || $type == 'blog' || $type == 'attribute' || $type == 'URL' ? $name : $type;

				if (in_array($link_to, ['blog', 'product', 'category'])) {
					if ($link_to !== 'category') {
						$p = get_posts([
							'lang' => $lang,
							'include' => [$value->product_id],
							'post_type' => $link_to == 'blog' ? 'post' : $link_to
						]);
					} else {
						$p = get_terms([
							'taxonomy' => 'product_cat',
							'lang' => $lang,
							'include' => [$value->product_id],
							'hide_empty' => false
						]);
					}
					
					if (count($p) <= 0) {
						$value->type = '';
					}
				}

				if ($value->type == 'Blog Banner') {
					$result[] = array(
						'link_to' => $link_to,
						'name' => $product_name,
						'product' => (int) $value->product_id,
						'title_slider' => ($value->title != NULL ? $value->title : ''),
						'type' => $value->type,
						'image' => $value->image,
					);
				} else{
					$result[] = array(
						'link_to' => '',
						'name' => '',
						'product' => (int) '0',
						'title_slider' => '',
						'type' => 'Blog Banner',
						'image' => revo_url().'assets/extend/images/defalt_mini_banner.png',
					);
				}

				break;
			}
		} else {
			$result_1 = [];
			$type_1 = 'Special Promo';
			$result_2 = [];
			$type_2 = 'Love These Items';
			
			foreach ($data_banner as $key => $value) {
				$type = explode('|', $value->product_name)[0];
				$product_name = explode('|', $value->product_name)[1] ?? '';
				$link_to = $type == 'cat' ? 'category' : ($type == 'blog' ? 'blog' : ($type == 'URL' ? 'URL' : ($type == 'attribute' ? 'attribute' : 'product')));

				if (empty($product_name)) {
					$product_name = $type;
				}

				if (in_array($link_to, ['blog', 'product', 'category'])) {
					if ($link_to !== 'category') {
						$p = get_posts([
							'lang' => $lang,
							'include' => [$value->product_id],
							'post_type' => $link_to == 'blog' ? 'post' : $link_to
						]);
					} else {
						$p = get_terms([
							'taxonomy' => 'product_cat',
							'lang' => $lang,
							'include' => [$value->product_id],
							'hide_empty' => false
						]);
					}
					
					if (count($p) <= 0) {
						continue;
					}
				}

				if ($value->type == $type_1) {
					array_push($result_1, [
						'link_to' => $link_to,
						'name' => $product_name,
						'product' => (int) $value->product_id,
						'title_slider' => isset($value->title) ? $value->title : '',
						'type' => $value->type,
						'image' => $value->image,
					]);
				}

				if ($value->type == $type_2) {
					array_push($result_2, [
						'link_to' => $link_to,
						'name' => $product_name,
						'product' => (int) $value->product_id,
						'title_slider' => isset($value->title) ? $value->title : '',
						'type' => $value->type,
						'image' => $value->image,
					]);
				}
			}

			if (count($result_1) < 4) {
				$total_result_1 = 4 - count($result_1);
				for ($i=0; $i < $total_result_1; $i++) { 
					array_push($result_1, [
						'link_to' => '',
						'name' => '',
						'product' => (int) '0',
						'title_slider' => '',
						'type' => $type_1,
						'image' => revo_url().'assets/extend/images/defalt_mini_banner.png',
					]);
				}
			}

			if (count($result_2) < 4) {
				$total_result_2 = 4 - count($result_2);
				for ($i=0; $i < $total_result_2; $i++) {
					array_push($result_2, [
						'link_to' => '',
						'name' => '',
						'product' => (int) '0',
						'title_slider' => '',
						'type' => $type_2,
						'image' => revo_url().'assets/extend/images/defalt_mini_banner.png',
					]);
				}
			}

			$result = array_merge($result_1, $result_2);
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}

	function rest_mini_banner_specific($type = 'rest', $type_banner){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$lang = $_GET['lang'] ?? '';

		$data_banner = $wpdb->get_row("SELECT * FROM revo_list_mini_banner WHERE type = '$type_banner' AND is_deleted = 0", OBJECT);

		$result = [];

		if (!is_null($data_banner)) {
			$type = explode('|', $data_banner->product_name)[0];
			$name = explode('|', $data_banner->product_name)[1];
			$link_to = $type == 'cat' ? 'category' : ($type == 'blog' ? 'blog' : ($type == 'URL' ? 'URL' : ($type == 'attribute' ? 'attribute' : 'product')));
			$product_name = $type == 'cat' || $type == 'blog' || $type == 'attribute' || $type == 'URL' ? $name : $type;

			if (in_array($link_to, ['blog', 'product', 'category'])) {
				if ($link_to !== 'category') {
					$p = get_posts([
						'lang' => $lang,
						'include' => [$data_banner->product_id],
						'post_type' => $link_to == 'blog' ? 'post' : $link_to
					]);
				} else {
					$p = get_terms([
						'taxonomy' => 'product_cat',
						'lang' => $lang,
						'include' => [$data_banner->product_id],
						'hide_empty' => false
					]);
				}
			} else {
				$p = $data_banner;
			}

			if ($data_banner && count($p)) {
				array_push($result, [
					'link_to' => $link_to,
					'name' => $product_name,
					'product' => (int) $data_banner->product_id,
					'title_slider' => ($data_banner->title != NULL ? $data_banner->title : ''),
					'type' => $data_banner->type,
					'image' => $data_banner->image,
				]);
			} else {
				array_push($result, [
					'link_to' => '',
					'name' => '',
					'product' => (int) '0',
					'title_slider' => '',
					'type' => $type_banner,
					'image' => '',
				]);
			}
		} else {
			array_push($result, [
				'link_to' => '',
				'name' => '',
				'product' => (int) '0',
				'title_slider' => '',
				'type' => $type_banner,
				'image' => '',
			]);
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}

	function rest_categories($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$lang = $_GET['lang'] ?? '';

		$data_banner = $wpdb->get_results("SELECT * FROM revo_list_categories WHERE is_deleted = 0 ORDER BY order_by DESC", OBJECT);

		$result = [];
		if (isset($_GET['show_popular'])) {
			array_push($result, [
				'categories' => (int) '9911',
				'title_categories' => 'Popular Categories',
				'image' => revo_url().'assets/extend/images/popular.png',
			]);
		} else {
			array_push($result, [
				'categories' => (int) '0',
				'title_categories' => 'view_more',
				'image' => revo_url().'assets/extend/images/viewMore.png',
			]);
		}

		foreach ($data_banner as $key => $value) {
			$term = get_terms([
				'taxonomy' => 'product_cat',
				'lang' => $lang,
				'include' => [$value->category_id],
				'hide_empty' => false
			]);

			if (count($term) && ((int) $value->category_id) != 0) {
				array_push($result, [
					'categories' => (int) $value->category_id,
					'title_categories' => json_decode($value->category_name)->title,
					'image' => $value->image,
				]);
			}
		}

		if (empty($result)) {
			for ($i=0; $i < 5; $i++) { 
				array_push($result, [
					'categories' => (int) '0',
					'title_categories' => 'Dummy Categories',
					'image' => revo_url().'assets/extend/images/default_categories.png',
				]);
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_categories_list($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$result = [];

		$taxonomy     = 'product_cat';
        $orderby      = 'name';  
        $show_count   = 1;      // 1 for yes, 0 for no
        $pad_counts   = 0;      // 1 for yes, 0 for no
        $hierarchical = 1;      // 1 for yes, 0 for no  
        $title        = '';  
        $empty        = 0;

		// wpml active
		if (is_plugin_active('sitepress-multilingual-cms/sitepress.php')) {
            $languages = apply_filters( 'wpml_active_languages', NULL );
            $lang = apply_filters('wpml_default_language', NULL );

			if ( !empty(cek_raw('lang')) ) { 
				if ( cek_raw('lang') != $lang && array_key_exists(cek_raw('lang'), $languages) ) {
					do_action( 'wpml_switch_language', cek_raw('lang') );

					$args['number'] = 1;
                	$check_cat_exist = get_categories( $args );

					if ($check_cat_exist >= 1) {
						$lang = cek_raw('lang');
					}
				}	
			}

			do_action( 'wpml_switch_language', $lang );
        }

        $args = array(
             'taxonomy'     => $taxonomy,
             //'orderby'      => $orderby,
             'show_count'   => $show_count,
             'pad_counts'   => $pad_counts,
             'hierarchical' => $hierarchical,
             'title'     => $title,
             'hide_empty'   => $empty,
             'menu_order' => 'asc',
             'parent' => 0
        );

		// polylang active
		if (is_plugin_active('polylang/polylang.php')) {
			if (function_exists('pll_default_language') || function_exists('pll_the_languages')) {
				$languages = pll_the_languages([
					'raw' => true,
					'hide_if_empty' => false
				]);

				$lang = pll_default_language();
			
				if ( !empty(cek_raw('lang')) ) {
					if ( cek_raw('lang') != $lang && array_key_exists(cek_raw('lang'), $languages) ) {
						$args['number'] = 1;
	                	$check_cat_exist = get_categories( $args );

						if ($check_cat_exist >= 1) {
							$lang = cek_raw('lang');
						}
					}
				}

				$args['lang'] = $lang;
			}
		}

        if (cek_raw('page')) {
        	$args['offset'] = cek_raw('page');
        }

        if (cek_raw('limit')) {
        	$args['number'] = cek_raw('limit');
        }

        if (!cek_raw('parent')) {
        	$data_categories = get_popular_categories();
			if (!empty($data_categories)) {
				array_push($result, [
					'id' => (int) '9911',
					'title' => 'Popular Categories',
					'description' => '',
					'parent' => 0,
					'count' => 0,
					'image' => revo_url().'assets/extend/images/popular.png',
				]);
			}

       	 	$categories = get_categories( $args );

	 		foreach ($categories as $key => $value) {
	 			if ($value->name != 'Uncategorized') {
	 				$image_id = get_term_meta( $value->term_id, 'thumbnail_id', true );
		            $image = '';

		            if ( $image_id ) {
		                $image = wp_get_attachment_url( $image_id );
		            }

		            $terms = get_terms([
				        'taxonomy'    => 'product_cat',
				        'hide_empty'  => false,
				        'parent'      => $value->term_id
				    ]);

		            array_push($result, [
						'id' => $value->term_id,
		                'title' => wp_specialchars_decode($value->name),
		                'description' => $value->description,
		                'parent' => $value->parent,
		                'count' => count($terms),
		                'image' => $image,
					]);
	 			}
	        }
        }else{
        	$categories = get_terms([
					        'taxonomy'    => 'product_cat',
					        'hide_empty'  => 1,
					        'parent'      => cek_raw('parent')
					    ]);

        	foreach ($categories as $value) {
        		$image_id = get_term_meta( $value->term_id, 'thumbnail_id', true );
	            $image = '';

	            if ( $image_id ) {
	                $image = wp_get_attachment_url( $image_id );
	            }

        		array_push($result, [
							'id' => $value->term_id,
			                'title' => wp_specialchars_decode($value->name),
			                'description' => $value->description,
			                'parent' => $value->parent,
			                'count' => 0,
			                'image' => $image,
						]);
        	}
        }

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function popular_categories($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$lang = $_GET['lang'] ?? '';

		$data_categories = get_popular_categories();

		$result = [];
		if (!empty($data_categories)) {
			foreach ($data_categories as $key) {
				$categories = json_decode($key->categories);
				$list = [];

				if (is_array($categories)) {
					for ($i=0; $i < count($categories); $i++) { 
						$image = wp_get_attachment_url(get_term_meta($categories[$i], 'thumbnail_id',true));
						$name  = get_terms(['taxonomy' => 'product_cat', 'include' => $categories[$i], 'hide_empty' => false, 'lang' => $lang])[0]->name;

						if (!empty($name)) {
							$list[] = [
								'id' => $categories[$i], 
								'name' => !empty($name) ? $name : "", 
								'image' => ($image == false ? revo_url().'assets/extend/images/defalt_mini_banner.png' : $image)
							];
						}
					}

					if (!empty($list)) {
						$result[] = array(
							'title' => $key->title,
							'categories' => $list,
						);
					}
				}
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_flash_sale($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		cek_flash_sale_end();
		$date = date('Y-m-d H:i:s');
		$data_flash_sale = $wpdb->get_results("SELECT * FROM `revo_flash_sale` WHERE is_deleted = 0 AND start <= '".$date."' AND end >= '".$date."' AND is_active = 1  ORDER BY id DESC LIMIT 1", OBJECT);

		$result = [];
		$list_products = [];
		foreach ($data_flash_sale as $key => $value) {
			if (!empty($value->products)) {
				$get_products = json_decode($value->products);
				if (is_array($get_products)) {
					$list_products = implode(",",$get_products);
				}
			}
			array_push($result, [
				'id' => (int) $value->id,
				'title' => $value->title,
				'start' => $value->start,
				'end' => $value->end,
				'image' => $value->image,
				'products' => implode(",",json_decode($value->products)),
			]);
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_extend_products($type = 'rest'){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$where = '';

		$typeGet = '';
		if (isset($_GET['type'])) {
			$typeGet = $_GET['type'];
			
			if ($typeGet == 'special') {
				$where = "AND type = 'special'";
			}

			if ($typeGet == 'our_best_seller') {
				$where = "AND type = 'our_best_seller'";
			}

			if ($typeGet == 'recomendation') {
				$where = "AND type = 'recomendation'";
			}
		}

		$products = $wpdb->get_results("SELECT * FROM `revo_extend_products` WHERE is_deleted = 0 AND is_active = 1 $where  ORDER BY id DESC", OBJECT);

		$result = [];
		$list_products = "";
		if (!empty($products)) {
			foreach ($products as $key => $value) {
				if (!empty($value->products)) {
					$get_products = json_decode($value->products);
					if (is_array($get_products)) {
						$list_products = implode(",",$get_products);
					}
				}
				array_push($result, [
					'title' => $value->title,
					'description' => $value->description,
					'products' => $list_products,
				]);

			}
		}else{
			array_push($result, [
				'title' => $typeGet,
				'description' => "",
				'products' => "",
			]);
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_get_barcode($type = 'rest'){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$code = cek_raw('code');

		if (!empty($code)) {
			$table_name = $wpdb->prefix . 'postmeta';

			$get = $wpdb->get_row("SELECT * FROM `$table_name` WHERE `meta_value` LIKE '$code'", OBJECT);
			if (!empty($get)) {
				$result['id'] = (int)$get->post_id;
			}else{
				$result = ['status' => 'error','message' => 'code not found !'];
			}
		}else{
			$result = ['status' => 'error','message' => 'code required !'];
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_hit_products($type = 'rest'){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$cookie = cek_raw('cookie');

		$result = ['status' => 'error','message' => 'Login required !'];
		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			if (!$user_id) {
				$result = ['status' => 'error','message' => 'User Tidak ditemukan !'];
			}else{
				$id_product = cek_raw('product_id');
				$ip_address = cek_raw('ip_address');
				
				$result = ['status' => 'error','message' => 'Tidak dapat Hit Products !'];

				if (!empty($id_product) AND !empty($ip_address)) {
					
					$date = date('Y-m-d');

					$products = $wpdb->get_results("SELECT * FROM `revo_hit_products` WHERE products = '$id_product' AND type = 'hit' AND ip_address = '$ip_address' AND user_id = '$user_id' AND created_at LIKE '%$date%'", OBJECT);

					if (empty($products)) {
						
						$wpdb->insert('revo_hit_products',                  
				        [
				            'products' => $id_product,
				            'ip_address' => $ip_address,
				            'user_id' => $user_id,
				        ]);

						if (empty($wpdb->show_errors())) {
							
							$result = ['status' => 'success','message' => 'Berhasil Hit Products !'];

						}else{

							$result = ['status' => 'error','message' => 'Server Error 500 !'];

						}

					}else{

						$result = ['status' => 'error','message' => 'Hit Product Hanya Bisa dilakukan sekali sehari !'];

					}

				}
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_insert_review($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$result = ['status' => 'error','message' => 'Login required !'];

		$cookie = cek_raw('cookie');

		if (!$cookie) {
			return $result;
		}

		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

		if (!$user_id) {
			return ['status' => 'error','message' => 'User Tidak ditemukan !'];
		}

		// validation dan simpan image
		if (cek_raw('image')) {
			$images_upload = [];
			$upload_dir = wp_upload_dir();
			$upload_path = str_replace( '/', DIRECTORY_SEPARATOR, $upload_dir['path'] ) . DIRECTORY_SEPARATOR;
			$count_image_upload = count(cek_raw('image'));

			$obj_photo_review = new VI_WOO_PHOTO_REVIEWS_DATA();
			$max_size  = $obj_photo_review->get_params('photo', 'maxsize') ?? 2000;
			$max_files = $obj_photo_review->get_params('photo', 'maxfiles') ?? 2;

			$images = is_array(cek_raw('image')) ? cek_raw('image') : [cek_raw('image')];

			if ($max_files < $count_image_upload) {
				return ['status' => 'error','message' => "Max images: {$max_files} !"];
			}

			foreach ($images as $value) {
				$img = str_replace('data:image/jpeg;base64,', '', $value);
				$img = str_replace(' ', '+', $img);
				$decoded = base64_decode( $img );
				$filename = time() . rand(1000, 9999) . '.jpeg';
				$file_size = strlen($decoded);

				if (round($file_size / 1024.4) > $max_size) {
					if (count($images_upload) >= 1) {
						foreach ($images_upload as $name) {
							wp_delete_file($upload_path . '/' . $name);
						}
					}

					return ['status' => 'error', 'message' => "Max sizes per file: {$max_size} kb !"];
				}

				file_put_contents($upload_path . $filename, $decoded);

				array_push($images_upload, $filename);
			}
		}

		$user = get_userdata($user_id);

		$comment_id = wp_insert_comment([
			'comment_post_ID'      => cek_raw('product_id'), // <=== The product ID where the review will show up
			'comment_author'       => $user->first_name.' '.$user->last_name,
			'comment_author_email' => $user->user_email, // <== Important
			'comment_author_url'   => '',
			'comment_content'      => cek_raw('comments'),
			'comment_type'         => '',
			'comment_parent'       => 0,
			'user_id'              => $user_id, // <== Important
			'comment_author_IP'    => '',
			'comment_agent'        => '',
			'comment_date'         => date('Y-m-d H:i:s'),
			'comment_approved'     => 0,
		]);

		// HERE inserting the rating (an integer from 1 to 5)
		update_comment_meta($comment_id, 'rating', cek_raw('rating'));

		if (cek_raw('image')) {
			$attach_ids = [];
			
			foreach ($images_upload as $filename) {
				$attachment = [
					'post_mime_type' => 'image/jpeg',
					'post_title'     => preg_replace( '/\.[^.]+$/', '', basename( $filename ) ),
					'post_content'   => '',
					'post_status'    => 'inherit',
					'guid'           => $upload_dir['url'] . '/' . basename( $filename )
				];

				$attach_id = wp_insert_attachment($attachment, $upload_dir['path'] . '/' . $filename);
				array_push($attach_ids, $attach_id);
			}

			update_comment_meta( $comment_id, 'reviews-images', wc_clean($attach_ids));	
		}

		$result = ['status' => 'success','message' => 'insert rating success !'];

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else{
			return $result;
		}
	}

	function rest_get_hit_products($type = 'rest'){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$cookie = cek_raw('cookie');

		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			if (!$user_id) {
				$result = ['status' => 'error','message' => 'User Tidak ditemukan !'];
			}else{

				$products = $wpdb->get_results("SELECT * FROM `revo_hit_products` WHERE user_id = '$user_id' AND type = 'hit' GROUP BY products ORDER BY created_at DESC", OBJECT);
    
				$list_products = '';

				if (!empty($products)) {
				    $list_products = [];
					foreach ($products as $key => $value) {
						$list_products[] = $value->products;
					}
                    if(!empty($list_products)){
                        $list_products = implode(",",$list_products);
                    }
				}else{
					
					// $where = array(
					// 			'limit' => 10,
					// 			'orderby' => 'rand',
					// 		);

					// $list_products = get_products_id($where);

					// $list_products = implode(",",$list_products);

				}

				$result = [
							'status' => 'success',
							'products' => $list_products,
						];
			}
		}else{
			$result = ['status' => 'error','message' => 'Login required !'];
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_intro_page_status($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		$get = query_revo_mobile_variable('"intro_page_status"','sort');
		$status = $_GET['status'];
		if (empty($get)) {
			$wpdb->insert('revo_mobile_variable', array(
				'slug' => 'intro_page_status',
				'title' => '',
				'image' => query_revo_mobile_variable('"splashscreen"')[0]->image,
				'description' => $status
			));
		}else {
			$wpdb->query(
				$wpdb
				->prepare("
					UPDATE revo_mobile_variable 
					SET description='$status' 
					WHERE slug='intro_page_status'
				")
			);
		}
		return $status;
	}

	function rest_get_general_settings($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$query_pp = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'privacy_policy'";
		$data_pp = $wpdb->get_row($query_pp, OBJECT);
		$query_tc = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'term_condition'";
		$data_tc = $wpdb->get_row($query_tc, OBJECT);

		$result['wa'] = data_default_MV('kontak_wa');
		$result['sms'] = data_default_MV('kontak_sms');
		$result['phone'] = data_default_MV('kontak_phone');
		$result['about'] = data_default_MV('about');
		$result['privacy_policy'] = $data_pp ?? data_default_MV('privacy_policy');
		$result['term_condition'] = $data_tc ?? data_default_MV('term_condition');
		$result['cs'] = data_default_MV('cs');
		$result['logo'] = data_default_MV('logo');
		$result['sosmed_link'] = data_default_MV('sosmed_link');
		$result['barcode_active'] = false;
		$result['buynow_button_style'] = query_revo_mobile_variable('"buynow_button_style"', 'sort')[0]->description ?? 'gradation';

		$query_checkout = query_revo_mobile_variable('"checkout_native"','sort');
		$result['checkout'] = empty($query_checkout) ? false : ($query_checkout[0]->description === 'hide' ? false : true);

		$query_sync_cart = query_revo_mobile_variable('"sync_cart"','sort');
        $result['sync_cart'] = empty($query_sync_cart) ? false : ($query_sync_cart[0]->description === 'hide' ? false : true);

		$result['livechat_to_revopos'] = is_plugin_active('Plugin-revo-kasir-main/index.php') ? (is_plugin_active('Revo-woocomerce-plugin-main/index.php') ? (query_revo_mobile_variable('"live_chat_status"','sort')[0]->description == "show" ? true : false ) : false) : false;

		$result['guest_checkout'] = get_option( 'woocommerce_enable_guest_checkout' ) == "yes" ? "enable" : "disable";
		$result['terawallet'] = query_check_plugin_active('woo-wallet');

		$query_GiftBox = query_revo_mobile_variable('"gift_box"','sort');
		$result['gift_box'] = empty($query_GiftBox) ? 'hide' : $query_GiftBox[0]->description;

		$query_blog_comment = query_revo_mobile_variable('"blog_comment_feature"','sort');
		$result['blog_comment_feature'] = empty($query_blog_comment) ? false : ($query_blog_comment[0]->description === 'hide' ? false : true);

		$result['product_settings'] = (function () use ($wpdb) {
			$slug_settings = array( 'show_sold_item_data', 'show_average_rating_data', 'show_rating_section', 'show_variation_with_image', 'show_out_of_stock_product' );
	
			$product_settings_datas = $wpdb->get_results("SELECT slug, description FROM revo_mobile_variable WHERE description = 'show' AND slug IN " . "('" . implode("','", $slug_settings) . "')", OBJECT);
			$product_settings_datas = array_map(fn ($data) => $data->slug, $product_settings_datas);
	
			$result = [];
			foreach ($slug_settings as $slug) {
				if (in_array($slug, $product_settings_datas)) {
					$result[$slug] = true;
					continue;
				}

				$result[$slug] = false;
			}
	
			return $result;
		})();
		
		$result['photoreviews_active'] = is_plugin_active('woo-photo-reviews/woo-photo-reviews.php');
		$obj_photo_reviews = $result['photoreviews_active'] ? new VI_WOO_PHOTO_REVIEWS_DATA() : "";
		$result['photoreviews_maxfiles'] = $result['photoreviews_active'] ? $obj_photo_reviews->get_params('photo', 'maxfiles') : 0;
		$result['photoreviews_maxsize'] = $result['photoreviews_active'] ? $obj_photo_reviews->get_params('photo', 'maxsize') : 0;

		if ( is_plugin_active( 'yith-woocommerce-barcodes-premium/init.php' ) ) {
			$result['barcode_active'] = true;			
		}
		
	    $get = query_revo_mobile_variable('"kontak","about","cs","privacy_policy","logo","empty_image","term_condition","searchbar_text","sosmed_link"','sort');

		if (!empty($get)) {
			foreach ($get as $key) {

				if ($key->slug == 'kontak') {
					$result[$key->title] = [
											  'slug' => $key->slug, 
											  "title" => $key->title,
											  "image" => $key->image,
											  "description" => $key->description
											];
				}else{
					if ($key->slug == 'empty_image') {
						$result[$key->slug][] = [
											  'slug' => $key->slug, 
											  "title" => $key->title,
											  "image" => $key->image,
											  "description" => $key->description
											];
					}else{
						$result[$key->slug] = [
											  'slug' => $key->slug, 
											  "title" => $key->title,
											  "image" => $key->image,
											  "description" => $key->description
											];
					}
				}

				if ($key->slug == 'searchbar_text') {

					$result[$key->slug] = [
						'slug' => $key->slug, 
						"title" => $key->title,
						"description" => json_decode($key->description)
					];
				}

				if ($key->slug == 'sosmed_link') {

					$result[$key->slug] = [
						'slug' => $key->slug, 
						"title" => $key->title,
						"description" => json_decode($key->description)
					];
				}
			}

			$result["link_playstore"] = [
							  'slug' => "playstore", 
							  "title" => "link playstore",
							  "image" => "",
							  "description" => "https://play.google.com/store"
							];
			$currency = get_woocommerce_currency_symbol();

			$result["currency"] = [
							  'slug' => "currency", 
							  "title" => generate_currency(get_option('woocommerce_currency')),
							  "image" => generate_currency(wp_specialchars_decode(get_woocommerce_currency_symbol($currency))),
							  "description" => generate_currency(wp_specialchars_decode($currency)),
							  "position" => get_option('woocommerce_currency_pos')
							];

			$result["format_currency"] = [
							'slug' => wc_get_price_decimals(), 
							"title" => wc_get_price_decimal_separator() != ',' || wc_get_price_decimal_separator() != '.' ? ',' : wc_get_price_decimal_separator(),
							"image" => wc_get_price_thousand_separator() != ',' || wc_get_price_thousand_separator() != '.' ? '.' : wc_get_price_thousand_separator(),
							"description" => "Slug : Number of decimals , title : Decimal separator, image : Thousand separator"
						];
		}

		if (empty($result['empty_image'])) {
			$result['empty_image'][] = data_default_MV('empty_images_1');
			$result['empty_image'][] = data_default_MV('empty_images_2');
			$result['empty_image'][] = data_default_MV('empty_images_3');
			$result['empty_image'][] = data_default_MV('empty_images_4');
			$result['empty_image'][] = data_default_MV('empty_images_5');
		}

		if ($intro_page) {
			for ($i=1; $i < 4; $i++) { 
				$result['intro'][] = data_default_MV('intro_page_'.$i);
			}
		}

		if (is_plugin_active('woongkir/woongkir.php')) {
			$dropdown_woongkir = 'dropdown_woongkir';
		}

		$result['additional_billing_address'] = [
			[
				'name' => 'city',
				'type' => isset($dropdown_woongkir) ? $dropdown_woongkir : 'textfield'
			],
			[
				'name' => 'address_2',
				'type' => isset($dropdown_woongkir) ? $dropdown_woongkir : 'textfield'
			],
		];

		$query_guide_feature = query_revo_mobile_variable('"guide_feature"','sort');
        $result['guide_feature'] = [
			'status' => empty($query_guide_feature) ? false : ($query_guide_feature[0]->description === 'hide' ? false : true),
			'image'  => empty($query_guide_feature) ? '' : (!empty($query_guide_feature[0]->image) ? $query_guide_feature[0]->image : ''),
		];

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function generate_currency($currency){

		if ($currency == 'AED') {
			$result = 'د.إ';
		} else {
			$result = $currency;
		}

		return $result;

	}

	function rest_get_intro_page($type = 'rest'){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$get = query_revo_mobile_variable('"intro_page","splashscreen"','sort');

		$result['splashscreen'] = data_default_MV('splashscreen');
		$result['intro_page_status'] = query_revo_mobile_variable('"intro_page_status"','sort')[0]->description;

	    	$intro_page = true;
		if (!empty($get)) {
			foreach ($get as $key) {

				if ($key->slug == 'splashscreen') {
					$result['splashscreen'] =  [
						'slug' => $key->slug,
						"title" => '',
						"image" => $key->image,
						"description" => $key->description
					];
				}

				if ($key->slug == 'intro_page') {
					$result['intro'][] = [
						'slug' => $key->slug,
						"title" => json_decode($key->title)->title,
						"image" => $key->image,
						"description" => json_decode($key->description)->description
					];

				    $intro_page = false;
				}
			}
		}

		if ($intro_page) {
			for ($i=1; $i < 4; $i++) { 
				$result['intro'][] = data_default_MV('intro_page_'.$i);
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_add_remove_wistlist($type = 'rest'){
		$cookie = cek_raw('cookie');
		$product_id = cek_raw('product_id');

		$result = ['type' => 'you must include cookie !', 'message' => 'error'];

		if (!empty($cookie)) {
			$result['product_id'] = $product_id;
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$user_id) {
				return ['type' => 'users not found !', 'message' => 'error'];
			}

			if (empty($product_id)) {
				return ['type' => 'empty Product id !', 'message' => 'error'];
			}

			$get_hit_product = query_hit_products($product_id, $user_id);

			if (@cek_raw('check')) {
				if ($get_hit_product->is_wistlist == 0) { 
					$result['type'] = 'check';
					$result['message'] = false;
				} else {
					$result['type'] = 'check';
					$result['message'] = true;
				}
			} else {
				global $wpdb;

				if ($get_hit_product->is_wistlist == 0) {
					$wpdb->insert('revo_hit_products', [
						'products' => $result['product_id'],
						'ip_address' => '',
						'type' => 'wistlist',
						'user_id' => $user_id,
					]);
					
					if (empty($wpdb->show_errors())) {
						$result['type'] = 'add';
						$result['message'] = 'success';
					} else {
						$result['type'] = 'add';
						$result['message'] = 'error';
					}
				} else {
					$product_id = $result['product_id'];
					$wpdb->query($wpdb->prepare("DELETE FROM `revo_hit_products` WHERE products = '$product_id' AND user_id = '$user_id' AND type = 'wistlist'"));

					if (empty($wpdb->show_errors())) {
						$result['type'] = 'remove';
						$result['message'] = 'success';
					} else {
						$result['type'] = 'remove';
						$result['message'] = 'error';
					}
				}
			}
		}


		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}
	
	function rest_list_wistlist($type = 'rest'){

		$cookie = cek_raw('cookie');

		$result = ['status' => 'error', 'message' => 'you must include cookie !'];

		if (!empty($cookie)) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$user_id) {
				return ['status' => 'error', 'message' => 'users not found !'];
			}

			$list_products = '';
			$get_hit_products = query_all_hit_products($user_id);

			if (!empty($get_hit_products)) {
				$list_products = [];

				foreach ($get_hit_products as $key) {
					$list_products[] = $key->products;
				}

				if (is_array($list_products)) {
					$list_products = implode(",", $list_products);
				}
			}

			$result = [
				'products' => $list_products
			];
		}


		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_key_firebase($type = 'rest'){
		
		$key = access_key();
		$result = array(
					 	"serverKey" => 'AAAALwNKHLc:APA91bGY_AkY01vJ_aGszm7yIjLaNbaAM1ivPlfigeFscdSVuUx3drCRGxyIRgLTe7nLB-5_5rF_ShlmqVXCUmrSd_uaJdcEV43MLxUeFrzmKCzyZzBB7AUlziIGxIH0phtw5VNqgY2Z',
					 	"apiKey" => 'AIzaSyCYkikCSaf91MbO6f3xEkUgFRDqHeNZgNE',
		              	"authDomain" => 'revo-woo.firebaseapp.com',
		              	"databaseURL" => 'https://revo-woo.firebaseio.com',
		              	"projectId" => 'revo-woo',
		              	"storageBucket" => 'revo-woo.appspot.com',
		              	"messagingSenderId" => '201918651575',
		              	"appId" => '1:201918651575:web:dda924debfb0121cf3c132',
		              	"measurementId" => 'G-HNR4L3Z0JE',
				);

		if (isset($key->firebase_servey_key)) {
			$result['serverKey'] = $key->firebase_servey_key;
		}

		if (isset($key->firebase_api_key)) {
			$result['apiKey'] = $key->firebase_api_key;
		}

		if (isset($key->firebase_auth_domain)) {
			$result['authDomain'] = $key->firebase_auth_domain;
		}

		if (isset($key->firebase_database_url)) {
			$result['authDomain'] = $key->firebase_database_url;
		}

		if (isset($key->firebase_database_url)) {
			$result['databaseURL'] = $key->firebase_database_url;
		}

		if (isset($key->firebase_project_id)) {
			$result['projectId'] = $key->firebase_project_id;
		}

		if (isset($key->firebase_storage_bucket)) {
			$result['storageBucket'] = $key->firebase_storage_bucket;
		}

		if (isset($key->firebase_messaging_sender_id)) {
			$result['messagingSenderId'] = $key->firebase_messaging_sender_id;
		}

		if (isset($key->firebase_app_id)) {
			$result['appId'] = $key->firebase_app_id;
		}

		if (isset($key->firebase_measurement_id)) {
			$result['measurementId'] = $key->firebase_measurement_id;
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_token_user_firebase($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$data['token'] = cek_raw('token');
		$cookie = cek_raw('cookie');

		$result = ['status' => 'error','message' => 'Gagal Input Token !'];
		$insert = true;

		if (!empty($data['token'])) {
			if ($cookie) {
				$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
				if ($user_id) {
					$data['user_id'] = $user_id;
					$get = get_user_token(" WHERE user_id = '$user_id'  ");
					if (!empty($get)) {
						$insert = false;
						$wpdb->update('revo_token_firebase',$data,['user_id' => $user_id]);
						if (@$wpdb->show_errors == false) {
				            $result = ['status' => 'success','message' => 'Update Token Berhasil !'];
				        }
					}
				}

			}

			if ($insert) {
					
				$data_delete = $data['token'];
				$wpdb->query($wpdb->prepare("DELETE FROM revo_token_firebase WHERE token = '$data_delete'"));

				$wpdb->insert('revo_token_firebase',$data);
				if (@$wpdb->show_errors == false) {
		            $result = ['status' => 'success','message' => 'Insert Token Berhasil !'];
		        }
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_check_variation($type = 'rest'){	
		$cookie     = cek_raw('cookie');
		$product_id = cek_raw('product_id');
		$variation  = cek_raw('variation');

		$result = ['status' => 'error', 'variation_id' => 0];

		if (!empty($cookie)) {
			$user = get_userdata(wp_validate_auth_cookie($cookie, 'logged_in'));
		}

		if (!empty($product_id)) {
			if ($variation) {
				$data = [];
				foreach ($variation as $key) {
					$key->column_name = str_replace(" ", "-", strtolower($key->column_name));
					$data['attribute_' . $key->column_name] .= $key->value;
				}

				if ($data) {
					$product_object = wc_get_product($product_id);

					if (!$product_object) {
						return ['status' => 'error', 'message' => 'product not found !'];
					}

					// main SC
					$data_store = new WC_Product_Data_Store_CPT();
					$variation_id = $data_store->find_matching_product_variation($product_object, $data);

					// optional => uncomment the code below if main SC not working
					// $product_variations = $product_object->get_available_variations();
					// $product_attributes = $product_object->get_attributes();

					// if (count($product_variations) == 1) {
					// 	$match = false;

					// 	$attributes = $product_variations[0]['attributes'];

					// 	// check string empty or same values
					// 	if ($attributes == $data) {
					// 		$match = true;
					// 	} else {
					// 		// find a matching variation
					// 		if (count($product_attributes) == count($data)) {
					// 			$match = true;

					// 			foreach ($data as $key => $value) {
					// 				$data_key[] = $key;
					// 				$data_val[] = $value;
					// 			}

					// 			foreach ($product_attributes as $attribute_key => $attribute_value) {
					// 				if (!in_array('attribute_' . $attribute_key, $data_key)) {
					// 					$match = false;
					// 					break;
					// 				}

					// 				$options = wc_get_product_terms($product_id, $attribute_value['name'], array('fields' => 'all'));

					// 				$attribute_options = [""];
					// 				foreach ($options as $value) {
					// 					array_push($attribute_options, $value->slug);
					// 				}

					// 				if (!in_array($data['attribute_' . $attribute_key], $attribute_options)) {
					// 					$match = false;
					// 					break;
					// 				}
					// 			}
					// 		}
					// 	}

					// 	if ($match) {
					// 		$variation_id = $product_variations[0]['variation_id'];
					// 	}
					// } else {
					// 	$data_store = new WC_Product_Data_Store_CPT();
					// 	$variation_id = $data_store->find_matching_product_variation($product_object, $data);
					// }

					// result
				    if (isset($variation_id) && $variation_id) {
				    	$revo_loader = load_Revo_Flutter_Mobile_App_Public();
		
				    	$variableProduct = wc_get_product($variation_id);
				    	$result['status'] = 'success';
				    	$result['data'] = $revo_loader->reformat_product_result($variableProduct);
				    	$result['variation_id'] = $variation_id;
				    }
				}
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}

	function rest_list_orders($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$cookie = cek_raw('cookie');
		$page = cek_raw('page');
		$limit = cek_raw('limit');
		$order_by = cek_raw('order_by');
		$order_id = cek_raw('order_id');
		$status = cek_raw('status');
		$search = cek_raw('search');

		$result = [];
		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			$revo_loader = load_Revo_Flutter_Mobile_App_Public();
			if ($order_id) {
				$customer_orders = wc_get_order($order_id);
				if ($customer_orders) {
					$get = $revo_loader->get_formatted_item_data($customer_orders);
					if (isset($get["line_items"])) {
						for ($i=0; $i < count($get["line_items"]); $i++) { 
							if($get["line_items"][$i]["product_id"] != 0){

                				if ($get["line_items"][$i]["variation_id"] > 0) {
                				  $data_product_id = "variation_id";
                				} else {
                				  $data_product_id = "product_id";
                				}
							
                				$image_id = wc_get_product($get["line_items"][$i][$data_product_id])->get_image_id();
								// $image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
								$get["line_items"][$i]['image'] = wp_get_attachment_image_url( $image_id, 'full' );
							} else {
								$get["line_items"][$i]['image'] = null;
							}
						}
					}

					if ($meta_link = $customer_orders->get_meta('Xendit_invoice_url')) {
						$payment_link = $meta_link;
					} else if ($customer_orders->get_meta('_mt_payment_url')) {
						$payment_link = $meta_link;
					} else if ($customer_orders->get_payment_method_title() === 'razorpay') {
						$payment_link = get_site_url() . "/checkout/order-pay/" . $customer_orders->get_id() . "/?key=" . $customer_orders->get_order_key();
					} else {
						$payment_link = "";
					}

					if ($get['customer_id'] == $user_id) {
						$get['payment_link'] = $payment_link;
						$result[] = $get;
					}
				}
			} else {
				if (empty($search)) {
					$where = array(
						'meta_key' => '_customer_user',
						'orderby'  => 'date',
						'order' => ($order_by ? $order_by : "DESC"),
						'customer_id' => $user_id,
						'page' => ($page ? $page : "1"),
						'limit' => ($limit ? $limit : "10"),
						'parent' => 0
					);

					if ($status) {
						// Order status. Options: pending, processing, on-hold, completed, cancelled, refunded, failed,trash. Default is pending.
						$where['status'] = $status;
					}

					$customer_orders = wc_get_orders($where);

					foreach ($customer_orders as $value) {
						$get = $revo_loader->get_formatted_item_data( $value );

						if ($get) {
							// Payment link 
							if ($meta_link = $value->get_meta('Xendit_invoice_url')) {
								$payment_link = $meta_link;
							} else if ($meta_link = $value->get_meta('_mt_payment_url')) {
								$payment_link = $meta_link;
							} else if ($value->get_payment_method_title() === 'razorpay') {
								$payment_link = get_site_url() . "/checkout/order-pay/" . $value->get_id() . "/?key=" . $value->get_order_key();
							} else {
								$payment_link = "";
							}

							if (isset($get["line_items"])) {
								for ($i=0; $i < count($get["line_items"]); $i++) { 
									$show = true;
									if($get["line_items"][$i]["product_id"] != 0){

                    					if ($get["line_items"][$i]["variation_id"] > 0) {
                    					  $data_product_id = "variation_id";
                    					} else {
                    					  $data_product_id = "product_id";
                    					}

										$image_id = wc_get_product($get["line_items"][$i][$data_product_id])->get_image_id();
										// $image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
										$get["line_items"][$i]['image'] = wp_get_attachment_image_url( $image_id, 'full' );
									} else {
										$get["line_items"][$i]['image'] = null;
									}
								}
							}

							$get['payment_link'] = $payment_link;
							$result[] = $get;
						}
					}
				} else {
					$table_post = $wpdb->prefix . 'postmeta';
					$table_order_item = $wpdb->prefix . 'woocommerce_order_items';

					$pagination = '';
					if (!empty($page) || !empty($limit)) {
						$page = ($page - 1) * $limit;

						$pagination = "LIMIT $page, $limit";
					}

					$where = "WHERE pm.post_id LIKE '%{$search}%' OR pm.meta_key = '_billing_phone' AND pm.meta_value LIKE '%{$search}%' OR oi.order_item_name LIKE '%{$search}%'";

					$post_meta_query = $wpdb->get_results("SELECT pm.post_id, oi.order_item_name FROM {$table_post} pm INNER JOIN {$table_order_item} oi ON pm.post_id = oi.order_id {$where} GROUP BY pm.post_id {$pagination}", OBJECT);

					foreach ($post_meta_query as $query) {
						$_order = wc_get_order($query->post_id);
						if (!$_order) {
							continue;
						}

						$get = $revo_loader->get_formatted_item_data($_order);

						if ($get) {
							if (!empty($status) && $status !== $get['status']) {
								continue;
							}

							if (isset($get["line_items"])) {
								for ($i=0; $i < count($get["line_items"]); $i++) { 
									$show = true;
									if($get["line_items"][$i]["product_id"] != 0){
										$image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
										$get["line_items"][$i]['image'] = wp_get_attachment_image_url( $image_id, 'full' );
									} else {
										$get["line_items"][$i]['image'] = null;
									}
								}
							}

							// Payment link 
							if ($meta_link = $_order->get_meta('Xendit_invoice_url')) {
								$payment_link = $meta_link;
							} else if ($meta_link = $_order->get_meta('_mt_payment_url')) {
								$payment_link = $meta_link;
							} else if ($_order->get_payment_method_title() === 'razorpay') {
								$payment_link = get_site_url() . "/checkout/order-pay/" . $_order->get_id() . "/?key=" . $_order->get_order_key();
							} else {
								$payment_link = "";
							}

							$get['payment_link'] = $payment_link;
							$result[] = $get;
						}
					}
				}
			}
		}


		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_list_review($type = 'rest'){
		$result = ['status' => 'error', 'message' => 'Login required !'];

		$cookie = cek_raw('cookie');
		$limit = cek_raw('limit');
		$post_id = cek_raw('post_id');
		$limit = cek_raw('limit');
		$page = cek_raw('page');

		$args = [
			'number'      => $limit, 
            'status'      => 'approve', 
            'post_status' => 'publish', 
            'post_type'   => 'product',
		];

		if ($post_id) {
			$args['post_id'] = $post_id;
		}

		if ($limit) {
			$args['number'] = $limit;
		}

		if ($page) {
			$args['offset'] = $page;
		}

		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			if ($user_id) {
				$args['user_id'] = $user_id;

				$comments = get_comments( $args );

				$result = [];
				foreach ($comments as $comment) {
					$product = wc_get_product($comment->comment_post_ID);

					$image_src = [];
					if (!empty($images = get_comment_meta($comment->comment_ID , 'reviews-images', true))) {
						foreach ($images as $image) {
							$res_image = wp_get_attachment_image_src($image, 'full');

							array_push($image_src, $res_image[0]);
						}
					}

					array_push($result, [
						'product_id' => $comment->comment_post_ID, 
						'title_product' => $product->get_name(), 
						'image_product' => wp_get_attachment_image_src($product->get_image_id(), 'full')[0], 
						'content' => $comment->comment_content, 
						'star' => get_comment_meta( $comment->comment_ID, 'rating', true ), 
						'comment_author' => $comment->comment_author, 
						'user_id' => $comment->user_id,
						'comment_date' => $comment->comment_date,  
						'image_review' => count($image_src) ? $image_src : '', 
					]);
				}
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_list_notification($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$result = ['status' => 'error','message' => 'Login required !'];

		$cookie = cek_raw('cookie');

		if ($cookie) {

			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			$data_notification = $wpdb->get_results("SELECT * FROM revo_notification WHERE user_id = '$user_id' AND type = 'order'  AND is_read = 0 ORDER BY created_at DESC", OBJECT);

			$revo_loader = load_Revo_Flutter_Mobile_App_Public();
			$result = [];
			foreach ($data_notification as $key => $value) {
				$order_id = (int) $value->target_id;
				$imageProduct="";
				if ($order_id && $imageProduct=="") {
					$customer_orders = wc_get_order($order_id);
					if ($customer_orders) {
						$get  = $revo_loader->get_formatted_item_data($customer_orders);
						if (isset($get["line_items"])) {
							for ($i=0; $i < count($get["line_items"]); $i++) { 
								$image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
								$imageProduct = wp_get_attachment_image_url( $image_id, 'full' ) ?? get_logo();
							}
						}
					}
				}

				array_push($result, [
					'user_id' => (int) $value->product_id,
					'order_id' => (int) $value->target_id,
					'status' => $value->message,
					'image' => $imageProduct,
					'created_at' => $value->created_at,
				]);
			}

		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_list_notification_new($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$result = ['status' => 'error','message' => 'Login required !'];

		$cookie = cek_raw('cookie');

		if ($cookie) {

			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$user_id) {
				return [
					'status' => 'error',
					'message' => 'Invalid authentication cookie. Please log out and try to login again!'
				];
			}

			$result = [];

            $notifications  = $wpdb->get_results("SELECT * FROM revo_push_notification WHERE user_id LIKE '%\"$user_id\"%' AND type = 'push_notif' or user_id = $user_id AND type = 'order' ORDER BY created_at DESC", OBJECT);

			foreach ($notifications as $notif) {
				if ($notif->type === 'order') {
					$_description = json_decode($notif->description, true);
					$order = wc_get_order($_description['order_id']);

					if (!empty($order)) {
						
						$_product = array_values( $order->get_items() )[0]->get_data();
						$product  = wc_get_product( $_product['variation_id'] == 0 ? $_product['product_id'] : $_product['variation_id'] );
						
						$description  = [
							"title" => "Order #" . $_description['order_id'],
							"link_to" => $_description['order_id'],
							"description" => $_description['status'],
							"image" => get_logo(),
						];
					
						if ($product) {
							$product_image_id = $product->get_image_id();
							$product_image = wp_get_attachment_image_url( $product_image_id, 'full' );
						
							if ($product_image !== false) {
								$description['image'] = $product_image;
							}
						}
					
						$is_read = is_null($notif->user_read) ? 0 : 1;
					
					}

				}

				if ($notif->type === 'push_notif') {
					$users_read  = json_decode($notif->user_read, true)['users'];
					$description = unserialize($notif->description);

					if ($description === false) {
						$description = json_decode($notif->description, true);
					}

					if ( base64_encode(base64_decode($description['description'], true)) === $description['description']){ 
						$description['description'] = base64_decode($description['description']);
					}

					$is_read = is_null($users_read) || !in_array($user_id, $users_read) ? 0 : 1;
				}

				array_push($result, [
					'id' => $notif->id,
					'type' => $notif->type,
					'user_id' => $user_id,
					'description' => $description,
					'is_read' => $is_read,	 // 1 = read, 0 = unread
					'created_at' => $notif->created_at,
				]);
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}
	
	function rest_read_notification($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$result = ['status' => 'error','message' => 'Login required !'];

		$cookie = cek_raw('cookie');
		$id = cek_raw('id');
		$type = cek_raw('type');

		if ($cookie) {
			// $data['is_read'] = 1;
			// $wpdb->update('revo_notification', $data, [
			// 	'id' => $id,
			// 	'user_id' => $user_id,
			// ]);

			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$user_id) {
				return [
					'status' => 'error',
					'message' => 'Invalid authentication cookie. Please log out and try to login again!'
				];
			}

			$get_row = $wpdb->get_row("SELECT id, type, user_id, user_read FROM revo_push_notification WHERE id = $id");

			if (!empty($get_row)) {
				$users_id 	= $type === 'order' ? (array) $get_row->user_id : json_decode($get_row->user_id, true)['users'];
				$users_read = $type === 'order' ? (array) $get_row->user_read : json_decode($get_row->user_read, true)['users'];

				if (in_array($user_id, $users_id) && !in_array($user_id, $users_read)) {
					$data = [];

					if ($type === 'order') {
						$data['user_read'] = $user_id;
					}

					if ($type === 'push_notif') {
						if (is_null($users_read)) {
							$data['user_read'] = json_encode(["users" => ["$user_id"]]);
						} else {
							array_push($users_read, (string) $user_id);
							$data['user_read'] = json_encode(["users" => $users_read]);
						}
					}

					$wpdb->update('revo_push_notification', $data, ['id' => $id]);
				}
			}

			if (@$wpdb->show_errors == false) {
				$result = ['status' => 'success','message' => 'Berhasil Dibaca !'];
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function notif_new_order($order_id){

		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$order = wc_get_order($order_id);

		$order_number = $order->get_order_number();

		$order_created = wc_get_order($order_number)->get_date_created()->date("Y-m-d H:i:s");
		$date = new DateTime('now', new DateTimeZone(wp_timezone()->getName()));

		$user_id = $order->get_user_id();
		$title = 'ORDER: #' . $order_number;
        $message = 'YOUR ORDER ' . strtoupper($order->status);

		// $wpdb->insert('revo_notification', [
		// 	'type' => "order",
		// 	'target_id' => $order_number,
		// 	'message' => $order->status,
		// 	'user_id' => $user_id,
		// ]);

		$wpdb->insert('revo_push_notification', [
			'type' => "order",
			'description' => json_encode(['order_id' => $order_number, 'status' => $order->status]),
			'user_id' => $user_id,
			'created_at' => $date->format('Y-m-d H:i:s')
		]);

		$get = '';
		$get = get_user_token(" WHERE user_id = '$user_id' ");

		if (!empty($get)) {
			foreach ($get as $key) {

				$token = $key->token;
				$notification = array(
					'title' => $title,
					'body'  => $message,
					'icon'  => get_logo(),
				);
				// 'click_action' => '', 
				$extend['id'] = $order_number;
				$extend['type'] = "order";

				send_FCM($token,$notification,$extend);
			}
		}

		if (is_plugin_active('Plugin-revo-kasir-main/index.php')) {
			$title_pos = 'ORDER: #' . $order_number;
        	$message_pos = 'ORDER STATUS IS ' . strtoupper($order->status);

			$wpdb->insert('revo_notification', [
				'type' => "order",
				'target_id' => $order_number,
				'message' => $order->status,
				'user_id' => $user_id,
			]);

			$get_pos = '';
			$get_pos = pos_get_user_token();

			if (!empty($get_pos)) {
				foreach ($get_pos as $key) {
					$token_pos = $key->token;
					$notification_pos = array(
						'title' => $title_pos, 
						'body' => $message_pos, 
						'icon' => get_logo(), 
					);
					// 'click_action' => '', 
					
					$extend_pos['id'] = $order_number;
					$extend_pos['type'] = "order";

					$extend_pos['created_at'] = $order_created;
					$extend_pos['now'] = $date->format('Y-m-d H:i:s');

					$date = new DateTime( $date->format('Y-m-d H:i:s') );
            		$date2 = new DateTime( $order_created );

            		$diff = $date->getTimestamp() - $date2->getTimestamp();

					$extend_pos['diff'] = $diff;
					
					$extend_pos['is_neworder'] = $diff <= 4 ? true : false;
					
					send_FCM($token_pos,$notification_pos,$extend_pos);
				}
			}
		}
	}

	function rest_disabled_service($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$result = ['status' => 'error','message' => 'Cabut License Gagal !'];

		$query = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'license_code'";
  		$get = $wpdb->get_row($query, OBJECT);
  		if (!empty($get->description)) {
  			$get = json_decode($get->description);
  			if (!empty($get)) {
  				if ($get = $get->license_code == cek_raw('code')) {
  					if ($get) {
						$data = data_default_MV('license_code');
						$wpdb->update('revo_mobile_variable',$data,['slug' => 'license_code']);
						if (@$wpdb->show_errors == false) {
				            $result = ['status' => 'success','message' => 'Cabut License Berhasil !'];
				        }
					}
  				}
  			}
  		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_topup_woowallet($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$cookie;
		if (isset($_GET['cookie'])){
			$cookie = $_GET['cookie'];
		}

		if ($cookie) {
			$userId = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$userId) {
				echo "Invalid authentication cookie. Please try to login again!";
				return;
			}
			// Check user and authentication
			$user = get_userdata($userId);
			if ($user) {        
				wp_set_current_user($userId, $user->user_login);
				wp_set_auth_cookie($userId);
			}
		}
            

		$urlAccount = get_permalink( get_option('woocommerce_myaccount_page_id') ).'woo-wallet/add';
		wp_redirect( $urlAccount );
		exit();
	}
    
    function rest_transfer_woowallet($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');
		$cookie;
		if (isset($_GET['cookie'])){
			$cookie = $_GET['cookie'];
		}

		if ($cookie) {
			$userId = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$userId) {
				echo "Invalid authentication cookie. Please try to login again!";
				return;
			}
			// Check user and authentication
			$user = get_userdata($userId);
			if ($user) {        
				wp_set_current_user($userId, $user->user_login);
				wp_set_auth_cookie($userId);
			}
		}
            

		$urlAccount = get_permalink( get_option('woocommerce_myaccount_page_id') ).'woo-wallet/transfer';
		wp_redirect( $urlAccount );
		exit();
	}
	
	function rest_data_attribute_bycategory($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$category = cek_raw('category');
		
		if (!empty($category)) {
            $categories = explode(',', $category);
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
        
        $args['status'] = 'publish';
		
		$result = array();
		
		foreach( wc_get_products($args) as $product ){
		    		
			$all_prices[] = $product->get_price();
				
			foreach( $product->get_attributes() as $taxonomy => $attribute ){
				$attribute_name = wc_attribute_label( $taxonomy );
				
				foreach ( $attribute->get_terms() as $term ){
				
				    $args['tax_query'] = array(
						array(
							'taxonomy'        => $taxonomy,
							'field'           => 'slug',
							'terms'           =>  array($term->name),
							'operator'        => 'IN',
						),
					);

					$products = wc_get_products( $args );
					
				    $data_filter[] = array($taxonomy, $attribute_name, $term->term_id, $term->name, count($products));
				    $data_taxonomy[] = array($taxonomy, $attribute_name);
				    
				}
				
			}
			
		}
		
		$data_taxonomy = array_map("unserialize", array_unique(array_map("serialize", $data_taxonomy)));

		$data_filter = array_map("unserialize", array_unique(array_map("serialize", $data_filter)));
		    
		for ($i=0; $i < (count($data_filter)-1); $i++) { 
		    
		    $taxonomy = $data_filter[$i][0];
		    $attribute_name = $data_filter[$i][1];
		    $term_id = $data_filter[$i][2];
		    $name = $data_filter[$i][3];
		    $count = $data_filter[$i][4];
		    
		    if(!empty($taxonomy)){
		        $result['data_filter'][$taxonomy][] = array('attribute_name' => $attribute_name, 'term_id' => $term_id, 'name' => $name, 'product_count' => $count);
		    }
            
        }
		
		$result['range_price'] = ['min_price' => floor(min($all_prices)), 'max_price' => ceil(max($all_prices))];

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_data_woo_discount_rules( $type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$woo_discount = get_option('woo-discount-config-v2')['calculate_discount_from'];

		if (!empty($woo_discount)) {
			$result['calculate_discount_from'] = !empty($woo_discount) ? $woo_discount : 'sale_price';

			
			$table_name = $wpdb->prefix . 'wdr_rules';

			$get_rules = $wpdb->get_results("SELECT * FROM `$table_name` WHERE `enabled` = 1", OBJECT);

			if (!empty($get_rules)) {

				foreach($get_rules as $value) {

					$rules = json_decode($value->bulk_adjustments);

					$operator = $rules->operator;

					$ranges = $rules->ranges;

					if ($operator == 'product_cumulative') {
						$result['discount_rules'] = array('operator' => $operator, 'ranges' => $ranges);
					} 
					elseif ($operator == 'variation') {
						$result['discount_rules'] = array('operator' => $operator, 'ranges' => $ranges);
					} 
					elseif ($operator == 'product') {
						$result['discount_rules'] = array('operator' => $operator, 'ranges' => $ranges);
					}

				}

			} else {
				$result = ['status' => 'error','message' => 'data not found !'];
			}

		} else {
			$result = ['status' => 'error','message' => 'plugin woo discount rules not installed !'];
		}
		
		return $result;
		
	}
	
	function rest_list_user_chat($type = 'rest'){

		$result = check_live_chat();

		if ($result == 1) {

			$cookie = cek_raw('cookie');
			$search = cek_raw('search');
			$incoming_chat = cek_raw('incoming_chat');
			
			$result = ['status' => 'error','message' => 'Login required !'];
		
			if ($cookie) {
				require (plugin_dir_path( __FILE__ ).'../helper.php');
				$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
				$user = get_userdata($user_id);
				
				if (in_array('administrator', $user->roles) || in_array('shop_manager', $user->roles)) {
					$first_admin = get_users([
						'role' => 'administrator',
						'orderby' => [
							'ID' => 'ASC'
						]
					])[0];
					
					$user_id = $first_admin->ID;
				}

				$result = ['status' => 'error','message' => 'User Not Found !'];
				if ($user_id) {
					$get = get_conversations($user_id);
					$result = [];
					$revo_loader = load_Revo_Flutter_Mobile_App_Public();
					foreach ($get as $index => $key) {
					    $user_message_id = $key->receiver_id;
					    if($key->status == 'seller'){
					        $user_message_id = $key->sender_id;
					    }
					
						$user = get_userdata($user_message_id);
						
						$role = "";

						if ($user) {
							if ($user->roles[0] == "administrator") {
								$role = " (admin)";
							} elseif ($user->roles[0] == "customer") {
								$role = " (cust)";
							}

							$username = $user->display_name.$role;
						} else {
							$username = "[ account has been deleted ]";
						}

						$photo = get_avatar_url($user_message_id);
						
						// if($key->status == 'seler'){
							// $_POST['disabled_cookie'] = true;
						    // $get = $revo_loader->get_wcfm_vendor_list(1,$user_message_id);
						// 
    						// if (!empty($get)) {
    						    // $photo = $get[0]['icon'];
    						    // $username = $get[0]['name'];
    						// }
						// }
							
						if (!empty($search) && strpos($username, $search) || (empty($search))) {
							
							$result[$index]['id'] = $key->id;
							$result[$index]['receiver_id'] = $user_message_id;
							$result[$index]['photo'] = $photo;
							$result[$index]['user_name'] = $username;
							$result[$index]['status'] = $key->status;
							$result[$index]['last_message'] = $key->last_message;
							$result[$index]['time'] = $key->created_chat;
							$result[$index]['unread'] = $key->unread;

						}
					}

					if ($incoming_chat && !empty($incoming_chat)) {
						$result_incoming = array_filter($result, function ($arr) {
							return $arr['unread'] >= 1;
						});

						$result_incoming_re_index = array_values($result_incoming);

						usort($result_incoming_re_index, function ($a, $b) {
							$t1 = strtotime($a['time']);
							$t2 = strtotime($b['time']);
							return $t2 - $t1;
						});

						$result = $result_incoming_re_index[0] ?? (object)[];
					}
				}
			}
		
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_detail_chat($type = 'rest'){

		$cookie = cek_raw('cookie');
		$chat_id = cek_raw('chat_id');
		$receiver_id = cek_raw('receiver_id');

		// $result = ['status' => 'error','message' => 'Login required !'];

		if ($cookie) {
			require (plugin_dir_path( __FILE__ ).'../helper.php');
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			$user = get_userdata($user_id);
	
			// $result = ['status' => 'error','message' => 'User Not Found !'];
			$first_admin = get_users([
				'role' => 'administrator',
				'orderby' => [
					'ID' => 'ASC'
				]
			])[0];

			if (!in_array('administrator', $user->roles) && !in_array('shop_manager', $user->roles)) {
				$receiver_id = $first_admin->ID;
			} elseif (in_array('administrator', $user->roles) || in_array('shop_manager', $user->roles)) {
				$user_id = $first_admin->ID;
			}

			if ($user_id && $receiver_id && empty($chat_id)) {
				$get_message = get_conversations($user_id,$receiver_id);
				if (empty($get_message)) {
					$wpdb->insert('revo_conversations',                  
			        [
			            'sender_id' => $user_id,
			            'receiver_id' => $receiver_id,
			        ]);

					$chat_id = $wpdb->insert_id;
				} else {
					$chat_id = $get_message->id;
				}
			}

			if ($user_id && $chat_id) {
				$results = get_conversations_detail($user_id,$chat_id);
				$revo_loader = load_Revo_Flutter_Mobile_App_Public();

				$i = 0;

				foreach ($results as $index => $key) {

					$date = substr($key->created_at, 0, 10);
					$time = substr($key->created_at, -8, -3);

					$key->time = $time;

					if (empty($key->image)) {
						$key->image = NULL;
					}

					if ($key->type == 'product') {
						$product = wc_get_product($key->post_id);

						$product_data = [
							'id' 	=> $key->post_id > 0 ? $key->post_id : 0,
							'name'  => 'Product Deleted',
							'price' => 0,
							'image_first' => revo_url().'/assets/extend/images/noimage.png'
						];

						if ($key->post_id > 0 && $product) {
							$image_first = wp_get_attachment_image_url( $product->get_image_id(), 'full' );

							$product_data['id'] = $product->get_id();
							$product_data['name'] = $product->get_name();
							$product_data['price'] = $product->get_price();
							$product_data['image_first'] = $image_first == false ? revo_url() . '/assets/extend/images/noimage.png' : $image_first;
						}

						$key->subject = array(
							'id'   => (int) $product_data['id'], 
							'name' => $product_data['name'],
							'status' => 'Product', 
							'price'  => (double) $product_data['price'],
							'image_first' => $product_data['image_first']
						);

					} elseif ($key->type == 'order') {

						$customer_orders = wc_get_order($key->post_id);
						if ($customer_orders) {
							$get  = $revo_loader->get_formatted_item_data($customer_orders);
							if (isset($get["line_items"])) {
								for ($i=0; $i < count($get["line_items"]); $i++) { 
										$image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
										$get["line_items"][$i]['image'] = wp_get_attachment_image_url( $image_id, 'full' );
								}
							}

							$image_first = $get['line_items'][0]['image'];

							$key->subject = array(
								'id' => $get['id'],
								'name' => 'Order ID : ' . $get['id'],
								'status' => $get['status'], 
								'price' => $get['total'],
								'image_first' => $image_first == false ? revo_url().'/assets/extend/images/noimage.png' : $image_first
							);

						}

					} else {
						$key->subject = null;
					}

					$chat[$date][] = $key;
					$chat_date[] = $date;

				}

				$dates = array_values(array_unique($chat_date));

				foreach ($dates as $date) {
					$result[] = array(
						'date' => $date,
						'chat' => $chat[$date],
					);
				}
			}
		}

		if (empty($result)) {
			$result = [];
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_insert_chat($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		
		$cookie = cek_raw('cookie');
		$message = cek_raw('message');
		// seller_id & product_id opsional
		$post_id = cek_raw('post_id');
		$receiver_id = cek_raw('receiver_id'); 
		$type = !empty(cek_raw('type')) ? cek_raw('type') : "chat";
		$image = cek_raw('image');

		// $result = ['status' => 'error','message' => 'Target ID Required ! product_id & receiver_id'];
		// if (!empty($post_id) AND !empty($receiver_id)) {

		$result = ['status' => 'error','message' => 'Login required !'];
		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			$user = get_userdata($user_id);

			$result = ['status' => 'error','message' => 'User Not Found !'];
			if ($user_id) {

				$first_admin = get_users([
					'role' => 'administrator',
					'orderby' => [
						'ID' => 'ASC'
					]
				])[0];

				if (!in_array('administrator', $user->roles) && !in_array('shop_manager', $user->roles)) {
					$receiver_id = $first_admin->ID;
				} elseif (in_array('administrator', $user->roles) || in_array('shop_manager', $user->roles)) {
					$user_id = $first_admin->ID;
				}


				$result = ['status' => 'error','message' => 'Receiver_id & Type Required'];
				if (!empty($receiver_id) && !empty($type)) {
					$get_message = get_conversations($user_id,$receiver_id);
					$result = ['status' => 'error','message' => 'system error !'];
					if (empty($get_message)) {
						$wpdb->insert('revo_conversations',                  
						[
							'sender_id' => $user_id,
							'receiver_id' => $receiver_id,
						]);

						$conversation_id = $wpdb->insert_id;
					}else{
						$conversation_id = $get_message->id;
					}	

					if ($conversation_id && (!empty($message) || !empty($image))) {	
						$date = new DateTime('now', new DateTimeZone(wp_timezone()->getName()));
						$wpdb->insert('revo_conversation_messages',                  
						[
							'conversation_id' => $conversation_id,
							'sender_id' => $user_id,
							'receiver_id' => $receiver_id,
							'message' => $message,
							'type' => $type,
							'image' => $image,
							'post_id' => $post_id,
							'is_read' => 1,
							'created_at' => $date->format('Y-m-d H:i:s')
						]);

						// send push notif chat
						$notification = array(
							'title' => "New Message", 
							'body' => (isset($message) ? $message : ''), 
							/* 'icon' => get_logo(), 
								'image' => (isset($data_notif->image) ? $data_notif->image : get_logo()) */
							);

						$where_receiver_id = ($receiver_id == $first_admin->ID ? wp_validate_auth_cookie($cookie, 'logged_in') : $receiver_id);

							$extend['id'] = $where_receiver_id;
							$extend['type'] = "chat";
							$extend['click_action'] = (isset($conversation_id) ? 'chat/'.$conversation_id : '');

						$where = "where user_id = $where_receiver_id";
						
						if ($receiver_id == $first_admin->ID) {
							$get = pos_get_user_token();
						} else {
							$get = get_user_token($where);
						}

						foreach ($get as $key) {

							$status_send = send_FCM($key->token,$notification,$extend);
					
							if ($status_send == 'error') {
							$alert = array(
									'type' => 'error', 
									'title' => 'Failed to Send Notification !',
									'message' => "Try Again Later", 
								);
							}   
						}
					}

					$result = ['status' => 'success','message' => 'success input message !'];
				}
			}
		}

		
		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_list_users($type = 'rest'){
		
		$cookie = cek_raw('cookie');
		$role = cek_raw('role');
		
		if ($cookie) {

			require (plugin_dir_path( __FILE__ ).'../helper.php');
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			$args = array(
				// 'role'    => 'administrator'
				'role'    => $role
			);

			$users = get_users( $args );
	
			foreach ($users as $user) {
	
				$data = array(
					'id_user' => $user->data->ID,
					'display_name' => $user->data->display_name,
					'photo' => get_avatar_url($user->data->ID)
				);
	
				$result[] = $data;

			}

		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_delete_account($type = 'rest'){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$cookie = cek_raw('cookie');

		$result = ['status' => 'error','message' => 'you must include cookie !'];
		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$user_id) {
				return ['status' => 'error','message' => 'User Tidak ditemukan !'];
			}

			$result = ['status' => 'error','message' => 'User gagal dihapus'];

			require_once (ABSPATH . 'wp-admin/includes/user.php');

			if (wp_delete_user( $user_id )) {
				$result = ['status' => 'success','message' => 'User berhasil dihapus'];
			}

			// $table_name1 = $wpdb->prefix . 'users';
			// $wpdb->query($wpdb->prepare("DELETE FROM $table_name1 WHERE id = $user_id"));

			// $table_name2 = $wpdb->prefix . 'usermeta';
			// $wpdb->query($wpdb->prepare("DELETE FROM $table_name2 WHERE user_id = $user_id"));
			
			// $result = ['status' => 'success','message' => 'User berhasil dihapus'];
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_post_customer_address($type = 'rest'){
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$cookie = cek_raw('cookie');

		$result = ['status' => 'error','message' => 'you must include cookie !'];

		if ($cookie) {
			$params  = json_decode(file_get_contents('php://input'));
			$action  = $params->action ?? 'billing'; // shipping / billing
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

			if (!$user_id) {
				$result = ['status' => 'success', 'message' => 'User tidak ditemukan'];	
			} else {
				$metas = [
					"{$action}_first_name" => $params->first_name,
					"{$action}_last_name" => $params->last_name,
					"{$action}_company" => $params->company,
					"{$action}_address_1" => $params->address_1,
					"{$action}_address_2" => $params->address_2,
					"{$action}_city" => $params->city,
					"{$action}_postcode" => $params->postcode,
					"{$action}_country" => $params->country,
					"{$action}_state" => $params->state,
					"{$action}_phone" => $params->phone,
					"{$action}_email" => $params->email,
				];
				
				foreach($metas as $key => $value) {
					if (!is_null($value)) {
						update_user_meta($user_id, $key, $value);
					}
				}

				$result = ['status' => 'success','message' => 'Data berhasil diubah'];
			}
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_show_reviews_product($type = 'rest'){
		$product_id = $_GET['product'];

		$result = ['status' => 'error','message' => 'you must include parameter product !'];

		if (isset($product_id) && $product_id != "") {
    		$reviews = get_comments(['post_id' => $product_id]);

			$datas = [];
			foreach ($reviews as $review) {
				$image_src = [];
				if (!empty($images = get_comment_meta($review->comment_ID , 'reviews-images', true))) {
					foreach ($images as $image) {
						$res_image = wp_get_attachment_image_src($image, 'full');

						array_push($image_src, $res_image[0]);
					}
				}

				$data = [
					'id' => (int) $review->comment_ID,
					'date_created' => wc_rest_prepare_date_response($review->comment_date),
					'date_created_gmt' => wc_rest_prepare_date_response( $review->comment_date_gmt ),
					'product_id' => (int) $review->comment_post_ID,
					'product_name' => get_the_title( (int) $review->comment_post_ID ),
					'product_permalink' => get_permalink( (int) $review->comment_post_ID ),
					'status' => $review->comment_approved ? 'approved' : 'hold',
					'reviewer' => $review->comment_author,
					'reviewer_email' => $review->comment_author_email,
					'review' => ! empty( $request['context'] ) ? $request['context'] : wpautop( $review->comment_content ),
					'rating' => (int) get_comment_meta( $review->comment_ID, 'rating', true ),
					'verified' => wc_review_is_from_verified_owner( $review->comment_ID ),
					'image' => count($image_src) ? $image_src : '',
					'reviewer_avatar_urls' => rest_get_avatar_urls( $review->comment_author_email ),
					'_links' => [
						'self' => [
							'href' => rest_url( sprintf( '/%s/%s/%d', 'wc/v3', 'products/reviews', $review->comment_ID ) ),
						],
						'collection' => [
							'href' => rest_url( sprintf( '/%s/%s', 'wc/v3', 'products/reviews' ) ),
						],
						'up' => [
							'href' => rest_url( sprintf( '/%s/products/%d', 'wc/v3', $review->comment_post_ID ) )
						],
						'reviewer' => [
							'embeddable' => true,
							'href' => rest_url( 'wp/v2/users/' . $review->user_id ),
						]
					]
				];

				array_push($datas, $data);
			}

			$result = rest_ensure_response( $datas );
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_products_attributes(){
        require (plugin_dir_path( __FILE__ ).'../helper.php');

        $attribute_slug = cek_raw('slug');

        $results = [];
        $get_attribute_taxonomies = wc_get_attribute_taxonomy_ids();

        if (count($get_attribute_taxonomies)) {
            foreach ($get_attribute_taxonomies as $taxonomy => $id) {
                $attribute = wc_get_attribute($id);
                
                if ((isset($attribute_slug) && $attribute_slug != '') && $attribute->slug != $attribute_slug) {
                    continue;
                }

                $attribute->terms = get_terms([
                    'taxonomy' => $attribute->slug, 
                    'hide_empty' => false
                ]);

                array_push($results, $attribute);
            }
        }

        return $results;
    }

	function rest_list_product_custom($type = 'rest'){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$revo_loader = load_Revo_Flutter_Mobile_App_Public();

		$args = [
			'include' => cek_raw('include'),
			'page' => cek_raw('page') ?? 1,
			'limit' => cek_raw('per_page') ?? 10,
			'parent' => cek_raw('parent'),
			'search' => cek_raw('search'),
			'category' => cek_raw('category'),
			'slug' => cek_raw('slug'),
			'id' => cek_raw('id'),
			'featured' => cek_raw('featured'),
			'order' => cek_raw('order') ?? 'DESC',
			'order_by' => cek_raw('order_by') ?? 'date',
			'attribute' => cek_raw('attribute'),
			'price_range' => cek_raw('price_range'),
			'sku' => cek_raw('sku'),
			'exclude_sku' => cek_raw('exclude_sku')
		];

		$result = $revo_loader->get_products_custom($args);

		if ($type == 'rest') {

			echo json_encode($result);

			exit();

		}else{

			return $result;

		}

	}

	function rest_home_custom(){

		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$rest_slider = rest_slider('get');
		$rest_categories = rest_categories('get');

		$query_ac = "SELECT slug, title, image, description, update_at FROM `revo_mobile_variable` WHERE slug = 'app_color'";
		$data_ac = $wpdb->get_results($query_ac, OBJECT);

		$result['app_color'] = $data_ac;
		$result['main_slider'] = $rest_slider;
		$result['mini_categories'] = $rest_categories;
		$result['mini_banner'] = rest_mini_banner('result');
		$result['general_settings'] = rest_get_general_settings('result');
		$get_intro = rest_get_intro_page('result');
		$result = array_merge($result,$get_intro);

		$revo_loader = load_Revo_Flutter_Mobile_App_Public();
		$result['products_flash_sale'] = rest_product_flash_sale('result',$revo_loader);
		$result['products_special'] = rest_additional_products('result','special',$revo_loader);
		$result['products_our_best_seller'] = rest_additional_products('result','our_best_seller',$revo_loader);
		$result['products_recomendation'] = rest_additional_products('result','recomendation',$revo_loader);

		echo json_encode($result);
		exit();
	}

	function rest_product_flash_sale_custom($type = 'rest', $revo_loader){
		require (plugin_dir_path( __FILE__ ).'../helper.php');
		cek_flash_sale_end();
		$date = date('Y-m-d H:i:s');
		$data_flash_sale = $wpdb->get_results("SELECT * FROM `revo_flash_sale` WHERE is_deleted = 0 AND start <= '".$date."' AND end >= '".$date."' AND is_active = 1  ORDER BY id DESC LIMIT 1", OBJECT);

		$result = [];
		$list_products = [];
		foreach ($data_flash_sale as $key => $value) {
			if (!empty($value->products)) {
				$_POST['include'] = $value->products;
				$list_products = $revo_loader->get_products(['cookie' => cek_raw('cookie') ?? null, 'exclude_sku' => cek_raw('cookie') ?? null]);
			}
			array_push($result, [
				'id' => (int) $value->id,
				'title' => $value->title,
				'start' => $value->start,
				'end' => $value->end,
				'image' => $value->image,
				'products' => $list_products,
			]);
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_additional_products_custom($type = 'rest',$product_type,$revo_loader){
		
		require (plugin_dir_path( __FILE__ ).'../helper.php');

		$where = '';

		if ($product_type == 'special') {
			$where = "AND type = 'special'";
		}elseif ($product_type == 'our_best_seller') {
			$where = "AND type = 'our_best_seller'";
		}elseif ($product_type == 'recomendation') {
			$where = "AND type = 'recomendation'";
		}

		$products = $wpdb->get_results("SELECT * FROM `revo_extend_products` WHERE is_deleted = 0 AND is_active = 1 $where  ORDER BY id DESC", OBJECT);

		$result = [];
		$list_products = [];
		foreach ($products as $key => $value) {

			if (!empty($value->products)) {
				$_POST['include'] = $value->products;
				$list_products = $revo_loader->get_products(['cookie' => cek_raw('cookie') ?? null, 'exclude_sku' => cek_raw('cookie') ?? null]);
			}


			array_push($result, [
				'title' => $value->title,
				'description' => $value->description,
				'products' => $list_products,
			]);

		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_list_blog($type = 'rest'){
		$lang = $_GET['lang'] ?? '';
		$page = $_GET['page'];
		$post_id = $_GET['post_id'];
		$per_page = $_GET['per_page'];
		$search = $_GET['search'];
	
		$args = [];
		$result = [];
	
		if (isset($per_page) && $per_page != '') {
			$args['posts_per_page'] = $per_page;
		}
	
		if (isset($page) && $page != '') {
			$args['paged'] = $page;
		}
	
		if (isset($post_id) && $post_id != '') {
			$args['include'] = $post_id;
		}
	
		if (isset($search) && $search != '') {
			$args['s'] = $search;
		}
		
		if (is_plugin_active('polylang/polylang.php')) {
			if (function_exists('pll_default_language') && function_exists('pll_the_languages')) {	
				$languages = pll_the_languages([
					'raw' => true,
					'hide_if_empty' => false
				]);
	
				$res_lang = pll_default_language();
	
				if (isset($lang) && $lang != '') {
					if (array_key_exists($lang, $languages) ) { 
						$countPosts = pll_count_posts($lang, [
							'post_type' => 'post'
						]);
	
						if ($countPosts >= 1) {
							$res_lang = $lang;
						}
					}
				}
	
				$args['lang'] = $res_lang;
	
				$posts = get_posts( $args ); 
			}
		} else if (is_plugin_active('sitepress-multilingual-cms/sitepress.php')) {
			$languages = apply_filters( 'wpml_active_languages', NULL );
			$res_lang = apply_filters('wpml_default_language', NULL );
	
			if ( isset($lang) && $lang != '' ) {
				if ( $lang != $res_lang && array_key_exists($lang, $languages) ) { 
					do_action( 'wpml_switch_language', $lang );
	
					$check_post_exist = get_posts([
						'posts_per_page' => 1,
						'suppress_filters' => false
					]);
	
					if ($check_post_exist >= 1) {
						$res_lang = $lang;
					}
				}
			}
	
			do_action( 'wpml_switch_language', $res_lang );
	
			$args['suppress_filters'] = false;
	
			$posts = get_posts( $args );
		} else {
			$posts = get_posts( $args );
		}
	
		if (!empty($posts)) {
			$WP_post_controller = new WP_REST_Posts_Controller('post');
			$request = $type;
	
			foreach ($posts as $post) {
				$response = $WP_post_controller->prepare_item_for_response( $post, $request );
				array_push($result, $WP_post_controller->prepare_response_for_collection( $response ));
			}
		}
	
		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}

	function rest_apply_coupon(){
		$cookie = cek_raw('cookie');
		$coupon_code = cek_raw('coupon_code');
		$products = cek_raw('products');

		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
		$user = get_user_by('id', $user_id);

		if (!$user_id || !$user) {
			return [
				'status' => 'error',
				'message' => 'Login is required'
			];
		}

		if (empty($coupon_code)) {
			return [
				'status' => 'error',
				'message' => 'Please enter a coupon code.'
			];
		}

		if (empty($products)) {
			return [
				'status' => 'error',
				'message' => 'Your cart is currently empty.'
			];
		}

		wp_set_current_user($user_id, $user->user_login);
        wp_set_auth_cookie($user_id);

		$c = new WC_Coupon($coupon_code);
		$coupon = $c->get_data();

		if (!empty($coupon['email_restrictions'])){

			$email_restrictions = substr($coupon['email_restrictions'][0],0,1);
			$email_user = $user->data->user_email;

			$email_restric = false;

			if ($email_restrictions == "*") {

				$email_allowed = str_replace($email_restrictions,"",$coupon['email_restrictions'][0]);

				$count_email_char = strlen($email_allowed);

				if (substr($email_user,-$count_email_char) == $email_allowed) {

					$email_restric = true;

				}

			} elseif ($email_user == $coupon['email_restrictions'][0]) {
				
				$email_restric = true;

			}
		} else {

			$email_restric = true;

		}

		if ($email_restric) {
			
			$product_ids = [];	
			foreach ($products as $product_item) {
				array_push($product_ids, $product_item->id);
			}

			usort($products, function ($a, $b) {
				return $a->id - $b->id;
			});

			$get_products = wc_get_products([
				'status'  => 'publish',
				'include' => $product_ids,
				'orderby' => 'id',
				'order'   => 'ASC',
				'limit'   => -1
			]);

			$wc_discount_class = new WC_Discounts('api');
			$items = [];

			foreach ( $get_products as $key => $product ) {
				if ( !is_null($products[$key]->variation_id) && $products[$key]->variation_id > 0) {
					$variable_product = wc_get_product($products[$key]->variation_id);
					$price = $variable_product->get_price();
				} else {
					$price = $product->get_price();
				}

				$item                = new stdClass();
				$item->key           = $product->get_id();
				$item->object        = $product;
				$item->product       = $product;
				$item->quantity      = $products[$key]->quantity;
				$item->price         = wc_add_number_precision_deep( (float) $price * (float) $item->quantity );

				array_push($items, $item);
			}

			$wc_discount_class->set_items($items);
			$response = $wc_discount_class->is_coupon_valid($c);

			if (!is_object( $response )) {

				$wc_discount_class->apply_coupon( $c );
				$coupon_discount_amounts = $wc_discount_class->get_discounts_by_coupon();

				$discount_amount = $coupon_discount_amounts[$coupon_code];
				
				$coupon_detail = array_merge($coupon, [
					'discount_amount' => $discount_amount
				]);

				return $coupon_detail;
			}

			return [
				'code' => $response->get_error_code(),
				'message' => strip_tags($response->get_error_message()),
				"data" => $response->get_error_data()
			];

		} else {

			return [
				'code' => 'invalid_coupon',
				'message' => 'you not allowed to use this coupon',
				"data" => array('status'=>400)
			];

		}
	}

	function rest_apply_coupon_v2(){
		$user_id  = cek_raw('user_id');
        $products = cek_raw('line_items');
        $coupon_code = cek_raw('coupon_code');

        if (empty($coupon_code)) {
            return [
                'status' => 'error',
                'message' => 'Please enter a coupon code.'
            ];
        }

        if (empty($user_id) || empty($products)) {
            return [
                'status' => 'error',
                'message' => 'You must include user_id and line_items !'
            ];
        }

        $user = get_user_by('id', $user_id);
        if (!$user) {
            return [
                'status' => 'error',
                'message' => 'User not found !'
            ];
        }

        wp_set_current_user($user_id, $user->user_login);
        wp_set_auth_cookie($user_id);

        $c = new WC_Coupon($coupon_code);
        $coupon = $c->get_data();

        if(!empty($coupon['email_restrictions'])){
            $email_restrictions = substr($coupon['email_restrictions'][0],0,1);
            $email_user = $user->data->user_email;

            $email_restric = false;

            if ($email_restrictions == "*") {
                $email_allowed = str_replace($email_restrictions,"",$coupon['email_restrictions'][0]);

                $count_email_char = strlen($email_allowed);

                if (substr($email_user,-$count_email_char) == $email_allowed) {
                    $email_restric = true;
                }
            } elseif ($email_user == $coupon['email_restrictions'][0]) {
                $email_restric = true;
            }
        } else {
            $email_restric = true;
        }

        if ($email_restric) {
            $product_ids = [];
            foreach ($products as $product_item) {
                $product_ids[] = $product_item->product_id;
            }

            usort($products, function ($a, $b) {
                return $a->product_id - $b->product_id;
            });

            $get_products = wc_get_products([
                'status'  => 'publish',
                'include' => $product_ids,
                'orderby' => 'id',
                'order'   => 'ASC',
                'limit'   => -1
            ]);

            $wc_discount_class = new WC_Discounts('api');
            $items = [];

            foreach ( $get_products as $key => $product ) {
                if ( !is_null($products[$key]->variation_id) && $products[$key]->variation_id > 0) {
                    $variable_product = wc_get_product($products[$key]->variation_id);
                    $price = $variable_product->get_price();
                } else {
                    $price = $product->get_price();
                }

                $item                = new stdClass();
                $item->key           = $product->get_id();
                $item->object        = $product;
                $item->product       = $product;
                $item->quantity      = $products[$key]->quantity;
                $item->price         = wc_add_number_precision_deep( (float) $price * (float) $item->quantity );

                array_push($items, $item);
            }

            $wc_discount_class->set_items($items);
            $response = $wc_discount_class->is_coupon_valid($c);

            if (!is_object( $response )) {
                $wc_discount_class->apply_coupon( $c );
                $coupon_discount_amounts = $wc_discount_class->get_discounts_by_coupon();
                $discount_amount = $coupon_discount_amounts[strtolower($coupon_code)];

                return [
                    'status' => 'success',
                    'message' => (string) $discount_amount
                ];
            }
        }

        return [
            'code' => 'error',
            'message' => "can't use this coupon"
        ];
	}

	function rest_list_coupons($type = 'rest'){

		$cookie = cek_raw('cookie');

		$result = ['status' => 'error', 'message' => 'you must include cookie!'];

		if ($cookie) {
			global $wpdb;

			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			$user = get_user_by('id', $user_id);

			if (!$user_id || !$user) {
				return [
					'status' => 'error',
					'message' => 'Login is required'
				];
			}

			wp_set_current_user($user_id, $user->user_login);
			wp_set_auth_cookie($user_id);

			$coupon_codes = $wpdb->get_col("SELECT post_name FROM $wpdb->posts WHERE post_type = 'shop_coupon' AND post_status = 'publish' ORDER BY id desc");

			$wjecf_active = is_plugin_active('woocommerce-auto-added-coupons/woocommerce-jos-autocoupon.php');

			if ($wjecf_active) {

				$wjecf_class = new WJECF_Controller();
				
			}

			$wc_discount_class = new WC_Discounts('api');

			foreach ($coupon_codes as $code) {		
				$c = new WC_Coupon($code);

				$coupon = $c->get_data();

				if ((empty($coupon['date_expires']) || date('Y-m-d H:i:s') < $c->get_date_expires('date')) && $coupon['id'] > 0) {

					if ($wjecf_active) {

						if ($coupon['usage_limit'] && ($coupon['usage_limit'] > $coupon['usage_count'])) {
							if ($wjecf_class->coupon_is_valid(true, $c, $wc_discount_class)) {
								$list_coupons[] = $c->get_data();
							}
						} else {
							if ($wjecf_class->coupon_is_valid(true, $c, $wc_discount_class)) {
								$list_coupons[] = $c->get_data();
							}
						}
						
					} else {

						$list_coupons[] = $c->get_data();

					}

				}					
			}

			$result = $list_coupons;
		}


		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		}else{
			return $result;
		}
	}

	function rest_states($type = 'rest') {
		$state_id = $_GET['code'];
	
		$result = ['status' => 'error', 'message' => 'you must include code !'];
	
		if (!is_plugin_active('woongkir/woongkir.php')) {
			return ['status' => 'error', 'message' => 'Plugin woongkir inactive !'];
		}
	
		if (!is_null($state_id) && !empty($state_id)) {
			$province = woongkir_get_json_data('state', [ 'value' => strtoupper($state_id) ]);
	
			$result = ['status' => 'error', 'message' => 'province not found !'];
	
			if (!empty($province)) {
				$args = [
					'state' => $province['value']
				];
		
				$result = [
					'code'   => $province['value'],
					'name'   => $province['label'],
					'cities' => get_json_data(WOONGKIR_URL . 'data/', WOONGKIR_PATH . 'data/', 'woongkir-city', $args)
				];		
			}
		}
	
		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}
		
	function rest_cities($type = 'rest') {
		$city_id = $_GET['id'];
	
		$result = ['status' => 'error', 'message' => 'you must include id !'];
	
		if (!is_plugin_active('woongkir/woongkir.php')) {
			return ['status' => 'error', 'message' => 'Plugin woongkir inactive !'];
		}
	
		if (!is_null($city_id) && !empty($city_id)) {
			$city = woongkir_get_json_data('city', ['id' => $city_id]);
	
			$result = ['status' => 'error', 'message' => 'city not found !'];
	
			if (!empty($city)) {
				$args = [
					'state' 	=> $city['state'],
					'state_id'  => $city['state_id'],
					'city' 	    => $city['value'],
					'city_id' 	=> $city['id'],
				];
		
				$result = [
					'city_id' 	    => $city['id'],
					'city' 	    	=> $city['value'],
					'state' 	    => $city['state'],
					'state_id'      => $city['state_id'],
					'subdistricts' 	=> get_json_data(WOONGKIR_URL . 'data/', WOONGKIR_PATH . 'data/', 'woongkir-address_2', $args)
				];		
			}
		}
	
		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}

	function rest_get_memberships_products($request) {

		$cookie   	   = $request->get_param('cookie');
		$slug_category = $request->get_param('slug_category');
		$category_id   = $request->get_param('category_id');

		if (!is_plugin_active('woocommerce-memberships/woocommerce-memberships.php')) {
			return [
				'status'  => 'error',
				'message' => 'requires plugin woocommerce-memberships'
			];
		}

		if (empty($cookie)) {
			return [
				'status'  => 'error',
				'message' => 'you must include cookie !'
			];
		}

		$user = get_userdata(wp_validate_auth_cookie($cookie, 'logged_in'));

		if (!empty($slug_category)) {
			$args['slug_category'] = $slug_category;
		}

		if (!empty($category_id)) {
			$args['category_id'] = $category_id;
		}

		$revo_loader 	  = load_Revo_Flutter_Mobile_App_Public();
		$membership_plans = wc_memberships_get_membership_plans();

		$response = $revo_loader->get_products(array_merge($args, [
			'membership' => true
		]));

		if (!empty($response)) {
			foreach ($response as $key => $product) {
				$addon_data = [
					'plan_name' => '',
					'status'	=> false,
					'end_date'  => ''
				];

				foreach ($membership_plans as $plan) {
					if ($plan->has_product($product['id'])) {
						$user_membership = wc_memberships_get_user_membership($user->ID, $plan->id);

						if (is_null($user_membership)) {
							$addon_data['plan_name'] = $plan->get_name();

							break;
						}

						$user_membership_status = $user_membership->get_status();

						if ($user_membership_status === 'active') {
							$date = $user_membership->get_local_end_date('Y-m-d H:i:s');

							if (is_null($date)) {
								$date = 'unlimited';
							}
						} else if ($user_membership_status === 'cancelled') {
							$date = $user_membership->get_local_cancelled_date('Y-m-d H:i:s');
						} else {
							$date = $user_membership->get_local_end_date('Y-m-d H:i:s');
						}

						$addon_data = [
							'plan_name' => $plan->name,
							'status'	=> wc_memberships_is_user_active_member($user->ID, $plan->id),
							'end_date'  => $date
						];

						break;
					}
				}

				$response[$key]['membership'] = $addon_data;
			}
		}

		return $response;

	}
