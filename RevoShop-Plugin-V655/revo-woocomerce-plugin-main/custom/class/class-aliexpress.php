<?php

use Custom\Base;


class Revo_Aliexpress extends Base
{
    private $custom_plugin = 'ali2woo/ali2woo.php';

    public function rest_init()
    {
        $check_plugin = parent::checkPluginActive($this->custom_plugin);

        if ($check_plugin) {
            $this->register_routes();
        }
    }

    protected function register_routes()
    {
        register_rest_route($this->namespace, '/aliexpress/countries', array(
            'methods' => WP_REST_Server::READABLE,
            'callback' => array($this, 'rest_aliexpress_get_countries'),
        ));

        register_rest_route($this->namespace, '/aliexpress/shipping', array(
            'methods' => 'POST',
            'callback' => array($this, 'rest_aliexpress_shipping'),
        ));
    }

    public function rest_aliexpress_get_countries()
    {
        $countries = A2W_Shipping::get_countries();
        return $countries;
    }

    public function rest_aliexpress_shipping()
    {
        $country = cek_raw('country');
        $quantity = cek_raw('quantity');
        $product_id = cek_raw('product_id');

        if (!$country) {
            echo json_encode(A2W_ResultBuilder::buildError("load_product_shipping_info: country is required."));
            return;
        }

        $countries = A2W_Shipping::get_countries();
        $country_label = $countries[$country];

        if (empty($country_label)) {
            echo json_encode(A2W_ResultBuilder::buildError("This product can not be delivered to {$country_label}"));
            return;
        }

        $product = wc_get_product($product_id);

        if (!$product) {
            echo json_encode(A2W_ResultBuilder::buildError("load_product_shipping_info: bad product ID."));
            return;
        }

        $result = A2W_Utils::get_product_shipping_info($product, !empty($quantity) ? $quantity : 1, $country, false);

        $shipping_info = str_replace('{country}', $country_label, a2w_get_setting('aliship_product_not_available_message'));

        $normalized_methods = array();

        foreach ($result['items'] as $method) {
            $normalized_method = A2W_Shipping::get_normalized($method, $country, "select");

            if (!$normalized_method) {
                continue;
            }

            $normalized_methods[] = $normalized_method;
        }

        $result['items'] = $normalized_methods;

        echo json_encode(A2W_ResultBuilder::buildOk(array('products' => $result, 'shipping_info' => $shipping_info)));
    }
}
