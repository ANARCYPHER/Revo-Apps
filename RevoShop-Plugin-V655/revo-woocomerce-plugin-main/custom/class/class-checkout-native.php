<?php

use Custom\Base;

class Revo_CheckoutNative extends Base
{
	private $vendor;

	private $custom_plugin = true;

	public function rest_init()
	{
		$check_plugin = parent::checkPluginActive($this->custom_plugin);

		$this->vendor = array(
			'wholesale' 	=> is_plugin_active('woocommerce-wholesale-prices/woocommerce-wholesale-prices.bootstrap.php'),
			'point_rewards' => is_plugin_active('woocommerce-points-and-rewards/woocommerce-points-and-rewards.php'),
			'bogo_coupon'   => is_plugin_active('wt-smart-coupons-for-woocommerce/wt-smart-coupon.php'),
		);

		if ($check_plugin) {
			$this->register_routes();
			$this->init_hooks();
		}
	}

	public function register_routes()
	{
		register_rest_route($this->namespace, '/get-cart', array(
			'methods' => 'POST',
			'callback' => array($this, 'rest_get_cart'),
		));

		register_rest_route($this->namespace, '/cart', array(
			'methods' => 'POST',
			'callback' => array($this, 'rest_cart'),
		));

		register_rest_route($this->namespace, '/checkout-datas', array(
			'methods' => 'POST',
			'callback' => array($this, 'rest_checkout_datas'),
		));

		register_rest_route($this->namespace, '/place-order', array(
			'methods' => 'POST',
			'callback' => array($this, 'rest_place_order'),
		));

		// register_rest_route( $this->namespace, '/shipping-methods', array(
		//   'methods' => 'POST',
		//   'callback' => 'rest_shipping_methods',
		// ));
	}

	private function init_hooks()
	{
		// add_action('woocommerce_after_cart_item_quantity_update', array($this, 'check_update_cart_quantity'), 12, 4);
		add_action('revo_native_checkout_add_bogo_meta', array($this, 'add_custom_meta'), 11, 2);

		if (strpos($_SERVER['REDIRECT_URL'], 'place-order') !== false) {
			add_action('woocommerce_add_order_item_meta', array($this, 'product_custom_meta'), 10, 3);

			add_filter('woocommerce_get_shop_coupon_data', array($this, 'get_discount_data'), 10, 2);
		}
	}

	public function add_custom_meta($cart_items, $order_id)
	{
		$order = new WC_Order($order_id);

		// add custom meta coupon
		if ($this->vendor['point_rewards']) {
			$coupons = $order->get_coupons();

			foreach ($coupons as $coupon) {
				$coupon_code = $coupon->get_code();

				if (strpos($coupon_code, 'wc_points_redemption') !== false) {
					$x_coupon_code = explode('_', $coupon_code);
					$points = $x_coupon_code[(array_key_last($x_coupon_code) - 1)];
					$amount = end($x_coupon_code);

					$user_points = WC_Points_Rewards_Manager::get_users_points(get_current_user_id());

					if ($user_points < $points) {
						return;
					}

					WC_Points_Rewards_Manager::decrease_points($order->get_customer_id(), $points, 'order-redeem', array('discount_code' => $coupon_code, 'discount_amount' => $amount), $order_id);

					add_post_meta($order_id, '_wc_points_logged_redemption', [
						'points' => (int) $points,
						'amount' => (int) $amount,
						'discount_code' => $coupon_code
					]);

					update_post_meta($order_id, '_wc_points_redeemed', (string) $points);

					break;
				}
			}
		}

		// add custom meta bogo
		if ($this->vendor['bogo_coupon']) {
			$items = $order->get_items();

			$products_giveaway = array_map(function ($cart_item) {
				if (isset($cart_item['free_gift_coupon']) && isset($cart_item['free_product']) && 'wt_give_away_product' == $cart_item['free_product']) {
					return $cart_item;
				}
			}, $cart_items);

			$products_giveaway = array_values(array_filter($products_giveaway, fn ($a) => $a != null));

			if (!empty($products_giveaway)) {
				foreach ($items as $line_item_id => $item) {

					foreach ($products_giveaway as $giveaway) {
						if ($giveaway['product_id'] == $item->get_product_id() && $giveaway['variation_id'] == $item->get_variation_id()) {
							wc_add_order_item_meta($line_item_id, 'free_product', $giveaway['free_product'], true);
							wc_add_order_item_meta($line_item_id, 'free_gift_coupon', $giveaway['free_gift_coupon'], true);
						}
					}
				}
			}
		}
	}

	// generate the coupon data required for the discount
	public function get_discount_data($data, $code)
	{
		if (strpos($code, 'wc_points_redemption') !== false) {
			$amount = end(explode('_', $code));

			$user_points = WC_Points_Rewards_Manager::get_users_points(get_current_user_id());

			if ($user_points <= 0 || $user_points < $amount) {
				return $data;
			}

			$data = array(
				'id'                         => true,
				'type'                       => 'fixed_cart',
				'amount'                     => $amount,
				'coupon_amount'              => $amount, // 2.2
				'individual_use'             => false,
				'usage_limit'                => '',
				'usage_count'                => '',
				'expiry_date'                => '',
				'apply_before_tax'           => true,
				'free_shipping'              => false,
				'product_categories'         => array(),
				'exclude_product_categories' => array(),
				'exclude_sale_items'         => false,
				'minimum_amount'             => '',
				'maximum_amount'             => '',
				'customer_email'             => '',
			);

			return $data;
		}
	}

	// add meta data to order lines item
	public function product_custom_meta($item_id, $cart_item_key, $values)
	{
		$user_id = wp_validate_auth_cookie(cek_raw('cookie'), 'logged_in');

		if ($user_id != 0) {
			$user = get_userdata($user_id);

			if (in_array('wholesale_customer', $user->roles)) {
				if (!$this->vendor['wholesale']) {
					return;
				}

				wc_add_order_item_meta($item_id, '_wwp_wholesale_priced', 'yes', true);
				wc_add_order_item_meta($item_id, '_wwp_wholesale_role', 'wholesale_customer', true);
			}
		}
	}

	// check quanity free product
	public function check_update_cart_quantity($cart_item_key, $quantity, $old_quantity, $cart)
	{
		$cart_item_data = $cart->cart_contents[$cart_item_key];

		if ($cart_item_data['free_product']) {
			$cart->cart_contents[$cart_item_key]['quantity'] = $old_quantity;

			return;
		}
	}

	public function rest_get_cart($type = 'rest')
	{
		$cookie = cek_raw('cookie');

		$result = ['status' => 'error', 'message' => 'you must include cookie!'];

		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			$user = get_userdata($user_id);

			if (!$user_id || !$user) {
				return [
					'status' => 'error',
					'message' => 'Invalid authentication cookie. Please log out and try to login again!'
				];
			}

			wp_set_current_user($user_id, $user->user_login);
			wp_set_auth_cookie($user_id);

			$cart_items = includes_frontend(function () {
				$cart_items = [];

				if (null === WC()->cart) {
					WC()->cart = new WC_Cart();

					$cart_items = WC()->cart->get_cart();
				}

				return $cart_items;
			});

			$result = [];
			if (!empty($cart_items)) {
				foreach ($cart_items as $cart) {
					$product_id = $cart['variation_id'] == 0 ? $cart['product_id'] : $cart['variation_id'];
					$product = wc_get_product($product_id);

					$image = wp_get_attachment_url($product->get_image_id(), 'full');

					$data = [
						'product_id' => $cart['product_id'],
						'name' => $product->get_name(),
						'sku' => $product->get_sku(),
						'price' => $cart['line_subtotal'] / $cart['quantity'],
						'quantity' => (int)($cart['quantity']),
						'variation_id' => $cart['variation_id'],
						'variation' => $cart['variation'],
						'subtotal_order' => number_format(($cart['line_subtotal'] + $cart['line_subtotal_tax']), '2', '.', ''),
						"line_subtotal" => $cart['line_subtotal'],
						"line_subtotal_tax" => $cart['line_subtotal_tax'],
						"line_total" => $cart['line_total'],
						"line_tax" => $cart['line_tax'],
						"image" => $image ? $image : "",
					];

					array_push($result, $data);
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

	public function rest_cart($type = 'rest')
	{
		$cookie = cek_raw('cookie');
		$action = cek_raw('action');
		$line_items = cek_raw('line_items');

		$result = ['status' => 'error', 'message' => 'you must include cookie !'];

		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			$user = get_userdata($user_id);

			if (!$user_id || !$user) {
				return [
					'status' => 'error',
					'message' => 'Invalid authentication cookie. Please log out and try to login again!'
				];
			}

			includes_frontend(null, true);

			$cart_handler 	 = new WC_Cart();
			$session_handler = new WC_Session_Handler();

			WC()->session  = $session_handler;
			WC()->cart 	   = $cart_handler;
			WC()->customer = new WC_Customer($user_id, true);

			$wc_session_data = $session_handler->get_session($user_id);

			$cart_usermeta = get_user_meta($user_id,'_woocommerce_persistent_cart_1',true);
			$cart_exist    = empty($cart_usermeta) ? [] : array_values( maybe_unserialize( $wc_session_data['cart'] ) );

			$result = ['status' => 'error', 'message' => 'you must include line_items !'];

			if (!empty($line_items) || $action === 'sync') {
				if ($action === 'create' && !empty($cart_exist)) {
					foreach ($cart_exist as $cart_val) {
						$line_items[] = [
							'product_id'   => $cart_val['product_id'],
							'quantity' 	   => $cart_val['quantity'],
							'variation_id' => $cart_val['variation_id'] != 0 ? $cart_val['variation_id'] : null,
							'variation'    => $cart_val['variation'],
						];
					}
				} elseif ($action === 'sync') {
					$web_cart  = [];
					$sync_cart = [];

					if (empty($line_items)) {
						$line_items = [];
					}

					if (!empty($cart_usermeta)) {
						foreach ($cart_exist as $cart) {
							array_push($web_cart, [
								'product_id'    => $cart['product_id'],
								'quantity'      => $cart['quantity'],
								'variation_id'  => $cart['variation_id'] != 0 ? $cart['variation_id'] : null,
								'variation'     => $cart['variation'],
								'sync_cart'     => true
							]);
						}
					}

					$before_sync_cart = array_merge($web_cart, $line_items);

					if (empty($before_sync_cart)) {
						return [];
					}

					foreach ($before_sync_cart as $cart) {
						$cart = (object) $cart;

						if (!is_null($cart->variation_id) && !empty($cart->variation_id)) {
							$key_search = $cart->variation_id;
							$col_search = 'variation_id';
						} else {
							$key_search = $cart->product_id;
							$col_search = 'product_id';
						}

						$key_sync_cart = array_search($key_search, array_column($sync_cart, $col_search));

						if ($key_sync_cart !== false) {
							if ($sync_cart[$key_sync_cart]->quantity <= $cart->quantity) {
								$sync_cart[$key_sync_cart]->quantity = $cart->quantity;
							}
						} else {
							array_push($sync_cart, $cart);
						}
					}

					$line_items = $sync_cart;
					$action = 'create';

					$cart_handler->empty_cart(true);
				}

				foreach ($line_items as $line_item) {
					$line_item 	  = (object) $line_item;
					$quantity     = $line_item->quantity;
					$product_id   = absint($line_item->product_id);
					$variation_id = $line_item->variation_id ?? null;
					$cart_data    = $line_item->cart_data ?? [];

					if (empty($product_id) || empty($quantity)) {
						return [
							'status' => 'error',
							'message' => 'product_id or quantity cannot be empty !'
						];
					}

					if ($action === 'create') {
						if (!is_null($variation_id) && $variation_id != 0) {
							$product_variable = new WC_Product_Variable($product_id);
							$list_variations  = $product_variable->get_available_variations();
							$variable_key 	  = array_search($variation_id, array_column($list_variations, 'variation_id'));

							if ($variable_key === false) {
								return [
									'status'  => 'error',
									'message' => 'product variation not found !'
								];
							}

							if (isset($line_item->sync_cart) && $line_item->sync_cart) {
								$attribute = $line_item->variation;
							} elseif (isset($line_item->variation) && !empty($line_item->variation)) {
								$attribute = [];

								foreach ($line_item->variation as $variation) {
									$attribute['attribute_' . $variation->column_name] = $variation->value;
								}
							} else {
								$attributes = $list_variations[$variable_key]['attributes'];
								$attribute  = new stdClass;

								foreach ($attributes as $att_key => $att) {
									if (empty($att)) {
										$check_att_key = explode('attribute_', $att_key)[1];

										$default_att = $product_variable->get_variation_attributes()[$check_att_key][0];
									}

									$attribute->$att_key = !empty($att) ? $att : $default_att;
								}
							}

							$cart_handler->add_to_cart($product_id, $quantity, $variation_id, (array) $attribute, (array) $cart_data);
						} else {
							$cart_handler->add_to_cart($product_id, $quantity, 0, [], (array) $cart_data);
						}
					} elseif ($action === 'update') {
						if ($variation_id !== 0 && !is_null($variation_id)) {
							$cart_key = array_search($variation_id, array_column($cart_exist, 'variation_id'));
						} else {
							$cart_key = array_search($product_id, array_column($cart_exist, 'product_id'));
						}

						if ($cart_key !== false) {
							$cart_exist[$cart_key]['quantity'] = $quantity;
						}
					} elseif ($action === 'delete') {
						if ($variation_id !== 0 && !is_null($variation_id)) {
							$cart_key = array_search($variation_id, array_column($cart_exist, 'variation_id'));
						} else {
							$cart_key = array_search($product_id, array_column($cart_exist, 'product_id'));
						}

						if ($cart_key !== false) {
							unset($cart_exist[$cart_key]);
							$cart_exist = array_values($cart_exist);
						}
					}
				}

				$new_data = $this->cart_items($wc_session_data, $user_id, ($action === 'create' ? $cart_handler->cart_contents : $cart_exist));

				if (isset($sync_cart)) {
					$cart_items = array_values($new_data);

					if (!empty($cart_items)) {
						foreach ($cart_items as $cart) {
							if (!is_null($cart['variation_id']) && !empty($cart['variation_id'])) {
								$product_type = 'variation';
								$product_id   = $cart['variation_id'];
							} else {
								$product_type = 'simple';
								$product_id = $cart['product_id'];
							}

							$attribute_value = "";
							$raw_attributes  = $cart['variation'];
							$variation_selected = [];

							foreach ($raw_attributes as $raw_key => $raw) {
								$attribute_value .= $raw;
								$attribute_value .= array_key_last($raw_attributes) != $raw_key ? ' - ' : '';

								array_push($variation_selected, [
									'id' => $cart['variation_id'],
									'column_name' => explode('attribute_', $raw_key)[1],
									'value' => $raw,
								]);
							}

							$addon_data[$product_type][$product_id] = [
								'product_id'   		 => $cart['product_id'],
								'quantity'     		 => $cart['quantity'],
								'variation_id' 		 => $cart['variation_id'] == 0 ? null : $cart['variation_id'],
								'variation_selected' => $variation_selected,
								'variation_value'    => $attribute_value
							];
						}

						$revo_loader = load_Revo_Flutter_Mobile_App_Public();

						$result = $revo_loader->get_products_cart([
							'addon_data' => $addon_data
						]);
					}

					return $result;
				}

				$result = [
					'status'  => 'success',
					'action'  => $action,
					'message' => 'cart items ' . $action . ' successfully',
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

	public function rest_checkout_datas($type = 'rest')
	{
		$result = $this->rest_shipping_methods('result');

		if ($result['status'] !== 'error') {
			$line_items = $result['line_items'];
			$shipping_lines = $result['shipping_lines'];

			// user data
			if (!cek_raw('cookie')) {
				$user_meta  = [];
				$state_name = "";
			} else {
				$user_meta  = get_user_meta(get_current_user_id());
				$state_name = WC()->countries->get_states($user_meta['billing_country'][0])[$user_meta['billing_state'][0]];
			}

			$user_data = [
				'billing_first_name'   => $user_meta['billing_first_name'][0] ? $user_meta['billing_first_name'][0] : "",
				'billing_last_name'    => $user_meta['billing_last_name'][0] ? $user_meta['billing_last_name'][0] : "",
				'billing_company'      => $user_meta['billing_company'][0] ? $user_meta['billing_company'][0] : "",
				'billing_country'      => $user_meta['billing_country'][0] ? $user_meta['billing_country'][0] : "",
				'billing_country_name' => WC()->countries->countries[$user_meta['billing_country'][0]] ? WC()->countries->countries[$user_meta['billing_country'][0]] : "",
				'billing_address_1'    => $user_meta['billing_address_1'][0] ? $user_meta['billing_address_1'][0] : "",
				'billing_address_2'    => $user_meta['billing_address_2'][0] ? $user_meta['billing_address_2'][0] : "",
				'billing_city'         => $user_meta['billing_city'][0] ? $user_meta['billing_city'][0] : "",
				'billing_state'        => $user_meta['billing_state'][0] ? $user_meta['billing_state'][0] : "",
				'billing_state_name'   => !empty($state_name) ? $state_name : ($user_meta['billing_state'][0] ? $user_meta['billing_state'][0] : ""),
				'billing_postcode'     => $user_meta['billing_postcode'][0] ? $user_meta['billing_postcode'][0] : "",
				'billing_phone'        => $user_meta['billing_phone'][0] ? $user_meta['billing_phone'][0] : "",
				'billing_email'        => $user_meta['billing_email'][0] ? $user_meta['billing_email'][0] : "",
			];

			// payment methods
			$res_payment_gateways = [];
			$payment_gateways = WC()->payment_gateways->get_available_payment_gateways();
			$payment_method_allowed = ['bacs', 'cheque', 'cod', 'midtrans', 'midtrans_sub_gopay', 'xendit_ovo', 'razorpay'];

			// terawallet
			if (is_plugin_active('woo-wallet/woo-wallet.php') && !empty(cek_raw('cookie'))) {
				array_push($payment_method_allowed, 'wallet');
			}

			foreach ($payment_gateways as $gateway) {
				if ($gateway->is_available() && in_array($gateway->id, $payment_method_allowed)) {
					if ($gateway->id === 'wallet') {
						$user_balance = woo_wallet()->wallet->get_wallet_balance(get_current_user_id(), '');
						$gateway->description = 'Balance ' . $user_balance;
					}

					array_push($res_payment_gateways, [
						'id'    => $gateway->id,
						'title' => $gateway->title,
						'description' => $gateway->description ?? "",
					]);
				}
			}

			// points redemption plugin
			if ($this->vendor['point_redemption']) {
				if (!empty(cek_raw('line_items'))) {
					list($point_ratio, $monetary_value) = explode(':', get_option('wc_points_rewards_redeem_points_ratio', ''));

					$user_points 	= WC_Points_Rewards_Manager::get_users_points(get_current_user_id());
					$subtotal_order = 0;

					if ($user_points > 0) {
						$count_ratio = (($user_points / $point_ratio) * $monetary_value);

						$subtotal_order = array_sum(array_column($line_items, 'subtotal_order'));

						if ($count_ratio < $subtotal_order) {
							$subtotal_order = $count_ratio;
						}
					}
				} else {
					$subtotal_order = WC_Points_Rewards_Cart_Checkout::get_discount_for_redeeming_points(false, null, true);
				}
				$points = WC_Points_Rewards_Manager::calculate_points_for_discount($subtotal_order);

				$point_redemption = [
					'point_redemption' => $points,
					'total_discount'   => (int) $subtotal_order,
					'discount_coupon'  => $points != 0 ? 'wc_points_redemption_' . (get_current_user_id() ?? random_int(1000, 9999)) . '_' . wp_date('Y_m_d_h_i') . "_{$points}_{$subtotal_order}" : "",
				];
			}

			$result = [
				'user_data' 	    => $user_data,
				'line_items' 	    => $line_items,
				'shipping_lines'    => $shipping_lines,
				'payment_methods'   => $res_payment_gateways,
				'points_redemption' => $point_redemption ?? [
					'point_redemption' => 0,
					'total_discount'   => 0,
					'discount_coupon'  => "",
				]
			];
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}

	public function rest_shipping_methods($type = 'rest')
	{
		$cookie = cek_raw('cookie');
		$products = cek_raw('line_items');
		$country_id = cek_raw('country_id');
		$state_id = cek_raw('state_id');
		$city = cek_raw('city');
		$subdistrict = cek_raw('subdistrict');
		$postcode = cek_raw('postcode');
		$coupon_code = cek_raw('coupon_code');

		if (!empty($cookie)) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			$user = get_userdata($user_id);

			if (!$user_id || !$user) {
				return [
					'status' => 'error',
					'message' => 'Invalid authentication cookie. Please log out and try to login again!'
				];
			}

			wp_set_current_user($user_id, $user->user_login);
			wp_set_auth_cookie($user_id);
		} else {
			$user_id = 0;
		}

		$query_sync_cart = query_revo_mobile_variable('"sync_cart"', 'sort');
		$check_sync_cart = empty($query_sync_cart) ? false : ($query_sync_cart[0]->description === 'hide' ? false : true);

		$cart_items = [];
		if (!empty($products)) {
			includes_frontend();

			foreach ($products as $p) {
				$variation = [];

				foreach ($p->variation as $value) {
					$variation['attribute_' . $value->column_name] = $value->value;
				}

				array_push($cart_items, [
					'key'		   => substr(str_replace(['+', '/', '='], '', base64_encode(random_bytes(32))), 0, 32),
					'product_id'   => $p->product_id,
					'quantity'     => $p->quantity,
					'variation_id' => $p->variation_id,
					'variation'    => $variation
				]);
			}
		} else if ($check_sync_cart && $user_id != 0) {
			$cart_items = includes_frontend(function () {
				$cart_items = [];

				if (null === WC()->cart) {
					WC()->cart = new WC_Cart();

					$cart_items = WC()->cart->get_cart();
				}

				return $cart_items;
			});
		}

		$result = ['status' => 'error', 'message' => 'you must include products !'];
		if (!empty($cart_items)) {
			// line items
			$line_items = [];
			$group_line_items = [];

			$subtotal_order = 0;
			$subtotal_order_with_coupon = 0;

			foreach ($cart_items as $item) {
				$item = (array) $item;

				$product_id = $item['product_id'];
				$variation_id = $item['variation_id'];

				$product = wc_get_product((is_null($item['variation_id']) || $item['variation_id'] === 0) ? $product_id : $variation_id);
				$price = $product->get_price();
				$image = wp_get_attachment_url($product->get_image_id(), 'full');

				if (array_key_exists('free_product', $item)) {
					$price = $item['line_subtotal'] + $item['line_subtotal_tax'];
				}

				// define wholesale price
				if ($this->vendor['wholesale'] && !is_null($user)) {
					$wholesale_price = get_post_meta($product_id, 'wholesale_customer_wholesale_price', true);

					if (!empty($wholesale_price) && in_array('wholesale_customer', $user->roles)) {
						$price = $wholesale_price;
					}
				}

				if (!is_null($variation_id) && $variation_id !== 0) {
					$attribute = "";

					$raw_attributes = $item['variation'];

					foreach ($raw_attributes as $raw_key => $raw) {
						$attribute .= !empty($raw) ? $raw : '';
						$attribute .= array_key_last($raw_attributes) !== $raw_key ? ' - ' : '';
					}
				} else {
					$attribute = "";
				}

				// coupon code
				if (!empty($coupon_code)) {
					$coupon_free_shipping = false;

					$coupon = new WC_Coupon($coupon_code);
					$coupon_data = $coupon->get_data();

					if ($coupon_data['id'] != 0) {
						$coupon_amount = $coupon_data['amount'];
						$discount_type = $coupon_data['discount_type'];

						if ($discount_type === 'percent') {
							$coupon_price = ($item['quantity'] * $price) - (($price * $item['quantity']) * $coupon_amount / 100);
						} else if ($discount_type === 'fixed_product') {
							$coupon_price = ($item['quantity'] * $price) - $coupon_amount * $item['quantity'];
						}

						$subtotal_order_with_coupon += $coupon_price;

						if ($coupon_data['free_shipping']) {
							$coupon_free_shipping = true;
						}
					}
				}

				$data = [
					'product_id' => $product->get_type() === 'variation' ? $product->get_parent_id() : $product->get_id(),
					'name' => $product->get_name(),
					'sku' => $product->get_sku(),
					'price' => (string) number_format($price, '2', '.', ''),
					'quantity' => (int) $item['quantity'],
					'variation_id' => $item['variation_id'],
					'variation' => $attribute,
					'subtotal_order' => (float) number_format($item['quantity'] * $price, '2', '.', ''),
					'image' => $image ? $image : '',
					'weight' => ((int) $product->get_weight() * $item['quantity']),
					'shipping_class_id' => $product->get_shipping_class_id(),
					'subtotal_coupon' => $coupon_price <= 0 ? 0 : $coupon_price,
					'data' => $product
				];

				array_push($line_items, $data);
				$group_line_items[$product->get_shipping_class_id()][] = $data;

				$subtotal_order += ($item['quantity'] * $price);
			}

			if (!empty($coupon_code) && $discount_type === 'fixed_cart') {
				$subtotal_order_with_coupon = $subtotal_order - $coupon_amount;
			}

			// shipping zones
			$data_store = WC_Data_Store::load('shipping-zone');
			$raw_zones  = $data_store->get_zones();
			$shipping_zone = null;

			foreach ($raw_zones as $raw_zone) {
				$zone = new WC_Shipping_Zone($raw_zone);
				$zone_data = $zone->get_data();

				$billing_country  = $user_id === 0 ? $country_id : get_user_meta($user_id, 'billing_country')[0];
				$billing_state    = $user_id === 0 ? $state_id : get_user_meta($user_id, 'billing_state')[0];
				$billing_postcode = $user_id === 0 ? $postcode : get_user_meta($user_id, 'billing_postcode')[0];

				if (count($zone_data['zone_locations']) >= 1) {
					foreach ($zone_data['zone_locations'] as $location) {
						if ($location->code === $billing_country . ':' . $billing_state) {
							$shipping_zone = $zone;
						} else if ($location->code === $billing_country) {
							$shipping_zone = $zone;
						} else if ($location->type === 'postcode' && $location->code === $billing_postcode) {
							$shipping_zone = $zone;
						}

						if (!is_null($shipping_zone)) {
							break;
						}
					}
				} else {
					$shipping_zone = $zone;
				}

				if (!is_null($shipping_zone)) {
					break;
				}
			}

			if (is_null($shipping_zone)) {
				$shipping_zone = new WC_Shipping_Zone(0);
			}

			// shipping methods
			$result 		  = [];
			$shipping_methods = $shipping_zone->get_shipping_methods();

			foreach ($shipping_methods as $shipping_method) {
				if ($shipping_method->enabled === 'no') {
					continue;
				}

				$rate_id 	 = $shipping_method->get_rate_id();
				$instance_id = end(explode(':', $rate_id));

				$method_title = $shipping_method->get_title();
				$method_title = empty($method_title) ? $shipping_method->get_method_title() : $method_title;

				$data = $shipping_method->instance_settings;
				$total_cost = 0;

				$shipping_package = [
					'contents' => (function ($cart_items) {
						foreach ($cart_items as $cart) {
							$cart['data'] = wc_get_product($cart['variation_id'] != null ? $cart['variation_id'] : $cart['product_id']);
							$result[$cart['key']] = $cart;
						}

						return $result;
					})($cart_items),
					'applied_coupons' => !empty($coupon_code) ? [$coupon_code] : [],
					'contents_cost' => $subtotal_order,
					'user' => [
						'ID' => $user_id
					],
					'destination' => [
						'country'   => !empty($cookie) ? get_user_meta($user_id, 'billing_country')[0]   : $country_id,
						'state'     => !empty($cookie) ? get_user_meta($user_id, 'billing_state')[0] 	 : $state_id,
						'city'      => !empty($cookie) ? get_user_meta($user_id, 'billing_city')[0] 	 : $city,
						'postcode'  => !empty($cookie) ? get_user_meta($user_id, 'billing_postcode')[0]  : $postcode,
						'address'   => !empty($cookie) ? get_user_meta($user_id, 'billing_address_1')[0] : "$city, $subdistrict $postcode",
						'address_1' => !empty($cookie) ? get_user_meta($user_id, 'billing_address_1')[0] : "$city, $subdistrict $postcode",
						'address_2' => !empty($cookie) ? get_user_meta($user_id, 'billing_address_2')[0] : $subdistrict,
					],
					'cart_subtotal' => $subtotal_order,
					'rates' =>  []
				];

				if (!in_array(explode(':', $rate_id)[0], ['flat_rate', 'local_pickup', 'free_shipping', 'woongkir'])) {
					continue;
				} elseif ($method_title === 'Woongkir' && is_plugin_active('woongkir/woongkir.php')) {
					$woongkir_class = new Woongkir_Shipping_Method($instance_id);
					$woongkir_class->calculate_shipping($shipping_package);

					foreach ($woongkir_class->rates as $value) {
						$data = $value->meta_data['_woongkir_data'];

						if ($value->get_shipping_tax() !== null) {
							$data['cost'] += $value->get_shipping_tax();
						}

						$data['cost'] = (int) $data['cost'];
						$data['method_title'] = strtoupper($data['courier'] . ' - ' . $data['service']);

						$woongkir_services[] = $data;
					}

					array_push($result, [
						'method_id'    => $rate_id,
						'method_title' => 'other_courier',
						'cost'		   => 0,
						'couriers' 	   => $woongkir_services ?? [],
					]);

					continue;
				} else {
					// free shipping
					if ($shipping_method instanceof WC_Shipping_Free_Shipping) {
						$requires = $data['requires'];

						if ($data['ignore_discounts'] === 'no' && !empty($coupon_code)) {
							$subtotal_order = $subtotal_order_with_coupon;
						}

						if ($requires === 'coupon' && !$coupon_free_shipping) {
							continue;
						} elseif ($requires === 'min_amount' && $subtotal_order < $data['min_amount']) {
							continue;
						} elseif ($requires === 'either' && ($subtotal_order >= $data['min_amount'] == false) && !$coupon_free_shipping) {
							continue;
						} elseif ($requires === 'both') {
							if (($subtotal_order < $data['min_amount'] && !$coupon_free_shipping) || ($subtotal_order < $data['min_amount'] && $coupon_free_shipping) || ($subtotal_order >= $data['min_amount'] && !$coupon_free_shipping)) {
								continue;
							}
						}
					}
					// flat rate
					elseif ($shipping_method instanceof WC_Shipping_Flat_Rate) {
						$shipping_handler = new WC_Shipping_Flat_Rate($instance_id);
						$shipping_handler->calculate_shipping($shipping_package);

						foreach($shipping_handler->rates as $rate) { 
							$tax = 0;

							if ( !empty($rate->taxes) ) {
								$tax = array_sum($rate->taxes);
							}

							$total_cost = $rate->cost + $tax;
						}	
					}
					// local pickup
					elseif ($shipping_method instanceof WC_Shipping_Local_Pickup) {
						$shipping_handler = new WC_Shipping_Local_Pickup($instance_id);
						$shipping_handler->calculate_shipping($shipping_package);

						foreach($shipping_handler->rates as $rate) {
							$tax = 0;

							if ( !empty($rate->taxes) ) {
								$tax = array_sum($rate->taxes);
							}

							$total_cost = $rate->cost + $tax;
						}
					}
				}

				array_push($result, [
					'method_id'    => $rate_id,
					'method_title' => $method_title,
					'cost' 		   => (int) $total_cost,
					'couriers' 	   => []
				]);
			}

			if ($type === 'result') {
				$result = [
					'line_items' => $line_items,
					'shipping_lines' => $result
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

	public function rest_place_order($type)
	{
		$cookie = cek_raw('cookie');
		$billing_address = cek_raw('billing_address');
		$products = cek_raw('line_items');
		$shipping_lines = cek_raw('shipping_lines');
		$payment_method = cek_raw('payment_method');
		$coupons = cek_raw('coupon_lines');
		$order_notes = cek_raw('order_notes');
		$partial_payment = cek_raw('wallet_partial_payment');

		if (empty($billing_address) || empty($shipping_lines) || empty($payment_method)) {
			return ['status' => 'error', 'message' => 'billing_address, shipping_lines, and payment required !'];
		}

		if (!empty($cookie)) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			$user = get_userdata($user_id);

			if (!$user_id || !$user) {
				return ['status' => 'error', 'message' => 'Invalid authentication cookie. Please log out and try to login again!'];
			}

			wp_set_current_user($user_id, $user->user_login);
			wp_set_auth_cookie($user_id);
		}

		// funtion from helper.php
		includes_frontend();

		// define cart contents
		$query_sync_cart = query_revo_mobile_variable('"sync_cart"', 'sort');
		$check_sync_cart = empty($query_sync_cart) ? false : ($query_sync_cart[0]->description === 'hide' ? false : true);

		$cart_items = [];
		if (!empty($products)) {
			WC()->cart->empty_cart(true);

			foreach ($products as $p) {
				$variation = [];

				foreach ($p->variation as $value) {
					$variation['attribute_' . $value->column_name] = $value->value;
				}

				array_push($cart_items, [
					'product_id'   => $p->product_id,
					'quantity'     => $p->quantity,
					'variation_id' => $p->variation_id,
					'variation'    => $variation
				]);

				WC()->cart->add_to_cart($p->product_id, $p->quantity, $p->variation_id, $variation);
			}
		} else if ($check_sync_cart && $user_id != 0) {
			$session_handler = new WC_Session_Handler();
			$session = $session_handler->get_session($user_id);

			$cart_items = array_values(maybe_unserialize($session['cart']));
		}

		$result = ['status' => 'error', 'message' => 'you must include products !'];

		if (!empty($cart_items)) {
			// format & validation address
			if (!is_email($billing_address->billing_email)) {
				return ['status' => 'error', 'message' => 'Invalid billing email address !'];
			}

			$address = array(
				'first_name' => $billing_address->billing_first_name,
				'last_name'  => $billing_address->billing_last_name,
				'company'    => $billing_address->billing_company,
				'email'      => $billing_address->billing_email,
				'phone'      => $billing_address->billing_phone,
				'address_1'  => $billing_address->billing_address_1,
				'address_2'  => $billing_address->billing_address_2,
				'city'       => $billing_address->billing_city,
				'state'      => $billing_address->billing_state,
				'postcode'   => $billing_address->billing_postcode,
				'country'    => $billing_address->billing_country
			);

			// start create order
			$order = wc_create_order();
			$order->set_customer_id($user_id ?? 0);
			$order->set_created_via('rest-api');

			// add products
			foreach ($cart_items as $item) {
				$item = (array) $item;

				$product_id = (is_null($item['variation_id']) || $item['variation_id'] === 0) ? $item['product_id'] : $item['variation_id'];
				$product 	= wc_get_product($product_id);
				$price 		= $product->get_price();

				if (array_key_exists('free_product', $item)) {
					$price = $item['line_subtotal'] != 0 ? $item['line_subtotal'] / $item['quantity'] : 0;
				}

				// define wholesale price
				if ($this->vendor['wholesale'] && !is_null($user)) {
					$wholesale_price = get_post_meta($product_id, 'wholesale_customer_wholesale_price', true);

					if (!empty($wholesale_price) && in_array('wholesale_customer', $user->roles)) {
						$price = $wholesale_price;
					}
				}

				$product_list[] = $product->get_name() . ' &times; ' . $item['quantity'];

				$order->add_product($product, $item['quantity'], [
					'total' => $price * $item['quantity'],
					'subtotal' => $price * $item['quantity'],
				]);
			}

			// terawallet - partial payment (add fee_lines)
			if ($partial_payment) {
				$user_balance = apply_filters('woo_wallet_partial_payment_amount', woo_wallet()->wallet->get_wallet_balance(get_current_user_id(), ''));

				if ($user_balance <= 0) {
					$order->delete(true);

					return [
						'status'  => 'error',
						'message' => 'Your wallet balance is low. Please add balance to proceed with this transaction - partial payment'
					];
				}

				$fee_data = [
					'id' => '_via_wallet_partial_payment',
					'name' => __('Via wallet', 'woo-wallet'),
					'amount' => (float) -1 * $user_balance,
					'taxable' => false,
					'tax_class' => 'non-taxable'
				];

				WC()->cart->fees_api()->add_fee($fee_data);

				$fee = new WC_Order_Item_Fee();
				$fee->set_name($fee_data['name']);
				$fee->set_total_tax(0);
				$fee->set_taxes([]);
				$fee->set_amount($fee_data['amount']);
				$fee->set_total($fee_data['amount']);
				$fee->save();

				$fee->add_meta_data('_legacy_fee_key', '_via_wallet_partial_payment');

				$order->add_item($fee);
			}

			// add & update billing and shipping addresses
			$order->set_address($address, 'billing');
			$order->set_address($address, 'shipping');

			if ($user_id !== 0) {
				foreach ($billing_address as $billing_key => $billing_data) {
					update_user_meta($user_id, $billing_key, $billing_data);
				}
			}

			// add shipping methods
			$shipping = new WC_Order_Item_Shipping();
			$shipping->set_method_title($shipping_lines->method_title);
			$shipping->set_method_id($shipping_lines->method_id);
			$shipping->set_total($shipping_lines->cost);
			$shipping->add_meta_data('Items', implode(', ', $product_list), true);
			$order->add_item($shipping);

			// add payment method
			$order->set_payment_method($payment_method->id);
			$order->set_payment_method_title($payment_method->title);

			// define wholesale metas
			if ($this->vendor['wholesale'] && !is_null($user)) {
				if (in_array('wholesale_customer', $user->roles)) {
					$order->add_meta_data('is_vat_exempt', 'no');
					$order->add_meta_data('wwp_wholesale_role', 'wholesale_customer');
					$order->add_meta_data('_wwpp_order_type', 'wholesale');
					$order->add_meta_data('_wwpp_wholesale_order_type', 'wholesale_customer');
				}
			}

			// apply coupons
			if (!empty($coupons)) {
				foreach ($coupons as $coupon) {
					$order->apply_coupon($coupon->code);
				}
			}

			// order notes
			if (!empty($order_notes)) {
				$order->set_customer_note($order_notes);
			}

			// set status, calculate, and save
			$order->set_status('wc-on-hold');
			$order->calculate_totals();

			// terawallet - full payment
			if ($payment_method->id === 'wallet' && is_plugin_active('woo-wallet/woo-wallet.php')) {
				$transaction_id = woo_wallet()->wallet->debit($order->get_customer_id(), $order->get_total(), 'For order payment #' . $order->get_order_number());

				if ($transaction_id === false) {
					$order->update_status('wc-pending');

					return [
						'status'  => 'error',
						'message' => 'Your wallet balance is low. Please add balance to proceed with this transaction - Full Payment'
					];
				}

				$order->update_status('wc-processing');
				$order->set_transaction_id($transaction_id);
			}

			// save order
			$order->save();

			// payments gateway
			if (in_array($payment_method->id, ['midtrans', 'midtrans_sub_gopay']) && is_plugin_active('midtrans-woocommerce/midtrans-gateway.php')) {
				$order->update_status('wc-pending');

				if ($payment_method->id === 'midtrans') {
					$midtrans_class = new WC_Gateway_Midtrans();
				} else {
					$midtrans_class = new WC_Gateway_Midtrans_Sub_Gopay();
				}

				$pg_response = $midtrans_class->process_payment($order->get_id());

				$payment_link = $pg_response['redirect'];
			} else if ($payment_method->id === 'xendit_ovo' && is_plugin_active('woo-xendit-virtual-accounts/woocommerce-xendit-pg.php')) {
				$xendit_class = new WC_Xendit_OVO();
				$pg_response  = $xendit_class->process_payment($order->get_id());   // auto update status to pending

				$payment_link = $pg_response['redirect'];
			} else if ($payment_method->id === 'razorpay' && is_plugin_active('woo-razorpay/woo-razorpay.php')) {
				$order->update_status('wc-pending');

				$razor_class = new WC_Razorpay();
				$pg_response = $razor_class->process_payment($order->get_id());

				$payment_link = $pg_response['redirect'];
			}

			// terawallet add meta_data to order
			if ($partial_payment) {
				$order = $this->wallet_partial_payment($order->get_id());
			}

			// result
			$result = $order->get_data();
			$result['payment_link'] = isset($payment_link) ? $payment_link : "";

			do_action('revo_native_checkout_add_bogo_meta', $cart_items, $order->get_id());

			WC()->cart->empty_cart(true);

			if (is_plugin_active('indeed-affiliate-pro/indeed-affiliate-pro.php')) {
				// debug_backtrace => Uap_Woo (create_referral) -> Referral_main (save_referral_unverified) -> Uap_DB (save_referral)

				$obj = new Uap_Woo();
				$obj->create_referral($order->get_id());
			}

			add_action('woocommerce_new_order', 'notif_new_order',  10, 1);
		}

		if ($type == 'rest') {
			echo json_encode($result);
			exit();
		} else {
			return $result;
		}
	}

	private function wallet_partial_payment($order_id)
	{
		$order = wc_get_order($order_id);

		$fees = $order->get_fees();
		foreach ($fees as $fee) {
			if ('Via wallet' === $fee['name']) {
				$fee_tax = $fee->get_total_tax();

				$fee->set_total_tax(0);
				$fee->set_taxes([]);
				$fee->save();
			}
		}

		if (isset($fee_tax)) {
			$order->set_cart_tax($order->get_cart_tax() + absint($fee_tax));

			$get_taxes = array_values($order->get_taxes())[0];
			if (isset($get_taxes)) {
				$get_taxes->set_tax_total($get_taxes->get_tax_total() + absint($fee_tax));
			}

			$order->set_total($order->get_total() + absint($fee_tax));

			$order->save();
		}

		woo_wallet()->wallet->wallet_partial_payment($order->get_id());

		return $order;
	}

	private function cart_items($wc_session_data, $user_id = null, $data = []) {
		global $wpdb;

		$updated_cart = [];

		foreach($data as $val) {
			if (isset($val['data'])) {
				unset($val['data']);
			}

			$updated_cart[$val['key']] = $val;
		}

		// overwrite session cart with new value
		if ($wc_session_data) {
			$wc_session_data['cart'] = serialize($updated_cart);
			$serialize_data = maybe_serialize($wc_session_data);

			$table_name = $wpdb->prefix . 'woocommerce_sessions';

			$wpdb->query("UPDATE $table_name SET session_value = '$serialize_data' WHERE session_key = $user_id");
		}

		// update usermeta
		$full_user_meta['cart'] = $updated_cart;
		update_user_meta($user_id, '_woocommerce_persistent_cart_1', $full_user_meta);

		return $updated_cart;
	}
}
