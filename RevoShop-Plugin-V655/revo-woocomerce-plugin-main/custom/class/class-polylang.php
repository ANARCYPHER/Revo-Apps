<?php

use Custom\Base;


class Revo_Polylang extends Base
{
    private $custom_plugin = 'polylang/polylang.php';

	public function rest_init()
	{
		$check_plugin = parent::checkPluginActive($this->custom_plugin);

		if ($check_plugin) {
			$this->register_routes();
		}
	}

    protected function register_routes()
    {
        register_rest_route($this->namespace, '/polylang/get-languages', array(
            'methods' => 'POST',
            'callback' => array($this, 'rest_polylang_get_languages'),
        ));

        register_rest_route($this->namespace, '/polylang/get-products', array(
            'methods' => 'POST',
            'callback' => array($this, 'rest_polylang_get_products'),
        ));

        register_rest_route($this->namespace, '/polylang/get-post', array(
            'methods' => 'POST',
            'callback' => array($this, 'rest_polylang_get_post'),
        ));
    }

    public function rest_polylang_get_languages($type = 'rest')
    {
        if (is_plugin_active('polylang/polylang.php')) {
            if (!function_exists('pll_default_language') || !function_exists('pll_the_languages')) {
                return [
                    'status' => 'error',
                    'message' => 'plugin polylang not active'
                ];
            }
        }

        if (cek_raw('get_lang_default')) {
            $def_lang = pll_default_language();

            return $def_lang;
        }

        $translations = pll_the_languages(array('raw' => true, 'hide_if_empty' => false));

        $result = [];
        foreach ($translations as $value) {
            $data = [
                'id' => $value['id'],
                'order'  => $value['order'],
                'slug'   => $value['slug'],
                'locale' => $value['locale'],
                'name' => $value['name'],
                'url'  => $value['url'],
                'flag' => $value['flag'],
                'current_lang' => $value['current_lang'],
                'no_translation' => $value['no_translation'],
            ];

            array_push($result, $data);
        }

        if ($type == 'rest') {
            echo json_encode($result);
            exit();
        } else {
            return $result;
        }
    }

    public function rest_polylang_get_products($type = 'rest')
    {
        $lang = cek_raw('lang');
        $per_page = cek_raw('per_page');
        $post_type = cek_raw('post_type');
        $parent = cek_raw('parent');

        if (is_plugin_active('polylang/polylang.php')) {

            if (!function_exists('pll_default_language') || !function_exists('pll_the_languages')) {
                return [
                    'status' => 'error',
                    'message' => 'plugin polylang not active'
                ];
            }
        
        }

        $result = [];
        if (in_array($post_type, ['category', 'tag'])) {
            $lang = $this->check_lang_exist($lang);

            if ($post_type === 'category') {
                $terms = $this->get_categories($lang, 'product_cat');
            } else {
                $terms = $this->get_tags($lang, 'product_tag');
            }

            foreach ($terms as $term) {
                $image_id = get_term_meta($term->term_id, 'thumbnail_id', true);

                if ($image_id) {
                    $image_url = wp_get_attachment_url($image_id);
                    $attachment_post = get_post($image_id);

                    if (!empty($parent)) {
                        $image = [
                            'id'                => (int) $image_id,
                            'date_created'      => wc_rest_prepare_date_response($attachment_post->post_date, false),
                            'date_created_gmt'  => wc_rest_prepare_date_response(strtotime($attachment_post->post_date_gmt)),
                            'date_modified'     => wc_rest_prepare_date_response($attachment_post->post_modified, false),
                            'date_modified_gmt' => wc_rest_prepare_date_response(strtotime($attachment_post->post_modified_gmt)),
                            'src'               => $image_url,
                            'name'              => get_the_title($image_id),
                            'alt'               => get_post_meta($image_id, '_wp_attachment_image_alt', true),
                        ];
                    }
                }

                if (!empty($parent) && $post_type == 'category') {
                    if ($term->parent == $parent) {
                        $menu_order = get_term_meta( $term->term_id, 'order', true );
                        $display_type = get_term_meta( $term->term_id, 'display_type', true );

                        $links = [
                            'self' => [
                                [
                                    'href' => rest_url(sprintf('/%s/%s/%d', 'wc/v3', 'products/categories', $term->term_id)),
                                ]
                            ],
                            'collection' => [
                                [
                                    'href' => rest_url(sprintf('/%s/%s', 'wc/v3', 'products/categories')),
                                ]
                            ]
                        ];
        
                        if ($term->parent) {
                            $links['up'] = [
                                [
                                    'href' => rest_url(sprintf('/%s/%s/%d', 'wc/v3', 'products/categories', $term->parent))
                                ]
                            ];
                        }

                        array_push($result, [
                            "id" => $term->term_id,
                            "name" => $term->name,
                            "slug" => $term->slug,
                            "parent" => $term->parent,
                            "description" => $term->description,
                            "display" => $display_type ? $display_type : "default",
                            "image" => $image ?? null,
                            "menu_order" => (int) $menu_order,
                            "count" => $term->count,
                            "_links" => $links
                        ]);
                    }
                } else {
                    array_push($result, [
                        "id" => $term->term_id,
                        "title" => $term->name,
                        "description" => $term->description,
                        "parent" => $term->parent,
                        "count" => $term->count,
                        "image" => $image_url ?? "",
                    ]);
                }
            }
        } else {
            $revo_loader = load_Revo_Flutter_Mobile_App_Public();

            $result = $revo_loader->get_products([
                'lang' => $lang,
                'limit' => $per_page
            ]);
        }


        if ($type == 'rest') {
            echo json_encode($result);
            exit();
        } else {
            return $result;
        }
    }

    public function rest_polylang_get_post($type = 'rest')
    {
        $lang = cek_raw('lang');
        $per_page = cek_raw('per_page');
        $post_type = cek_raw('post_type');
        $post_id = cek_raw('post_id');
        $parent = cek_raw('parent');

        if (is_plugin_active('polylang/polylang.php')) {

            if (!function_exists('pll_default_language') || !function_exists('pll_the_languages')) {
                return [
                    'status' => 'error',
                    'message' => 'plugin polylang not active'
                ];
            }
        
        }

        $lang = $this->check_lang_exist($lang);

        $result = [];
        if (in_array($post_type, ['category', 'tag'])) {
            if ($post_type === 'category') {
                $terms = $this->get_categories($lang, 'category');
            } else {
                $terms = $this->get_tags($lang, 'post_tag');
            }

            foreach ($terms as $term) {
                $image_id = get_term_meta($term->term_id, 'thumbnail_id', true);

                if ($image_id) {
                    $image_url = wp_get_attachment_url($image_id);
                    $attachment_post = get_post($image_id);

                    if (!empty($parent)) {
                        $image = [
                            'id'                => (int) $image_id,
                            'date_created'      => wc_rest_prepare_date_response($attachment_post->post_date, false),
                            'date_created_gmt'  => wc_rest_prepare_date_response(strtotime($attachment_post->post_date_gmt)),
                            'date_modified'     => wc_rest_prepare_date_response($attachment_post->post_modified, false),
                            'date_modified_gmt' => wc_rest_prepare_date_response(strtotime($attachment_post->post_modified_gmt)),
                            'src'               => $image_url,
                            'name'              => get_the_title($image_id),
                            'alt'               => get_post_meta($image_id, '_wp_attachment_image_alt', true),
                        ];
                    }
                }

                if (!empty($parent) && $post_type == 'category') {
                    if ($term->parent == $parent) {
                        $menu_order = get_term_meta( $term->term_id, 'order', true );
                        $display_type = get_term_meta( $term->term_id, 'display_type', true );

                        $links = [
                            'self' => [
                                [
                                    'href' => rest_url(sprintf('/%s/%s/%d', 'wc/v3', 'products/categories', $term->term_id)),
                                ]
                            ],
                            'collection' => [
                                [
                                    'href' => rest_url(sprintf('/%s/%s', 'wc/v3', 'products/categories')),
                                ]
                            ]
                        ];
        
                        if ($term->parent) {
                            $links['up'] = [
                                [
                                    'href' => rest_url(sprintf('/%s/%s/%d', 'wc/v3', 'products/categories', $term->parent))
                                ]
                            ];
                        }

                        array_push($result, [
                            "id" => $term->term_id,
                            "name" => $term->name,
                            "slug" => $term->slug,
                            "parent" => $term->parent,
                            "description" => $term->description,
                            "display" => $display_type ? $display_type : "default",
                            "image" => $image ?? null,
                            "menu_order" => (int) $menu_order,
                            "count" => $term->count,
                            "_links" => $links
                        ]);
                    }
                } else {
                    array_push($result, [
                        "id" => $term->term_id,
                        "title" => $term->name,
                        "description" => $term->description,
                        "parent" => $term->parent,
                        "count" => $term->count,
                        "image" => $image_url ?? "",
                    ]);
                }
            }
        } else {
            $args = [
                'lang' => $lang,
                'posts_per_page' => $per_page,
            ];

            if (!empty($post_id)) {
                $args['include'] = $post_id;
            }

            $posts = get_posts( $args );

            if ($lang != ($def_lang = pll_default_language()) && count($posts) <= 0) {
                $args['lang'] = $def_lang;
                $posts = get_posts( $args );
            }

            $WP_post_controller = new WP_REST_Posts_Controller('post');

            foreach ($posts as $post) {
                $response = $WP_post_controller->prepare_item_for_response( $post, [] );
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

    private function check_lang_exist($lang)
    {
        $languages = pll_the_languages([
            'raw' => true,
            'hide_if_empty' => false
        ]);

        if (empty($lang) || !array_key_exists($lang, $languages)) {
            $lang = pll_default_language();
        }

        return $lang;
    }

    private function get_categories($lang, $taxonomy)
    {
        $categories = get_categories([
            'lang' => $lang,
            'taxonomy' => $taxonomy,
            'hide_empty' => false
        ]);

        if ($lang != ($def_lang = pll_default_language()) && count($categories) <= 0) {
            $categories = get_categories([
                'lang' => $def_lang,
                'taxonomy' => $taxonomy,
                'hide_empty' => false
            ]);
        }

        return $categories;
    }

    private function get_tags($lang, $taxonomy)
    {
        $tags = get_tags([
            "lang" => $lang,
            'taxonomy' => $taxonomy,
            'hide_empty' => false
        ]);

        if ($lang != ($def_lang = pll_default_language()) && count($tags) <= 0) {
            $tags = get_categories([
                'lang' => $def_lang,
                'taxonomy' => $taxonomy,
                'hide_empty' => false
            ]);
        }

        return $tags;
    }
}