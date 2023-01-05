<?php
    require(plugin_dir_path(__FILE__) . '../helper.php');

    $revopos_status = query_check_plugin_active('Plugin-revo-kasir');

    $query_live_chat_status = query_revo_mobile_variable('"live_chat_status"', 'sort');
    $live_chat_status = empty($query_live_chat_status) ? 'hide' : $query_live_chat_status[0]->description;

    $guest_checkout = get_option('woocommerce_enable_guest_checkout') == 'yes' ? 'enable' : 'disable';

    $query_giftbox = query_revo_mobile_variable('"gift_box"', 'sort');
    $giftbox = empty($query_giftbox) ? 'hide' : $query_giftbox[0]->description;

    $query_checkout_native = query_revo_mobile_variable('"checkout_native"', 'sort');
    $checkout_native = empty($query_checkout_native) ? 'hide' : $query_checkout_native[0]->description;

    $query_sync_cart = query_revo_mobile_variable('"sync_cart"', 'sort');
    $sync_cart = empty($query_sync_cart) ? 'hide' : $query_sync_cart[0]->description;

    $query_blog_comment = query_revo_mobile_variable('"blog_comment_feature"', 'sort');
    $blog_comment_feature = empty($query_blog_comment) ? 'hide' : $query_blog_comment[0]->description;

    $query_guide_feature = query_revo_mobile_variable('"guide_feature"', 'sort');
    $guide_feature = empty($query_guide_feature) ? 'hide' : $query_guide_feature[0]->description;
    $guide_feature_image = empty($query_guide_feature) ? '' : (!empty($query_guide_feature[0]->image) ? $query_guide_feature[0]->image : '');

    // Product Settings
    $product_settings = array(
        [
            'label' => 'Show Sold Item Data',
            'name'  => 'show_sold_item_data'
        ],
        [
            'label' => 'Show Average Rating Data',
            'name'  => 'show_average_rating_data'
        ],
        [
            'label' => 'Show Rating Section',
            'name'  => 'show_rating_section'
        ],
        [
            'label' => 'Show Variation with Image',
            'name'  => 'show_variation_with_image'
        ],
        [
            'label' => 'Show Out of Stock Product',
            'name'  => 'show_out_of_stock_product'
        ]
    );

    $product_settings_datas = (function () use ($wpdb, $product_settings) {
        $slug_settings = array_map(fn ($a) => $a['name'], $product_settings);
        $slug_settings = "('" . implode("','", $slug_settings) . "')";

        $query = "SELECT * FROM revo_mobile_variable WHERE slug IN $slug_settings AND description = 'show'";

        $product_settings_datas = $wpdb->get_results($query, OBJECT);

        $result = [];
        foreach ($product_settings_datas as $data) {
            $result[$data->slug] = $data;
        }

        return $result;
    })();

    // Action
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        function check_image($image, $image_id, $allowed_mimes = [], $max_size = null)
        {
            $image_file_type = pathinfo($image, PATHINFO_EXTENSION);
            $image_data = wp_get_attachment_metadata($image_id);
            $is_upload_error = 0;

            if ($image_data['filesize'] > $max_size) {
                $alert = array(
                    'type' => 'error',
                    'title' => 'Uploads Error !',
                    'message' => 'your file is too large. max ' . size_format($max_size),
                );

                $is_upload_error = 1;
            }

            if (!in_array($image_file_type, $allowed_mimes)) {
                $alert = array(
                    'type' => 'error',
                    'title' => 'Uploads Error Logo !',
                    'message' => 'only ' . strtoupper(implode(', ', $allowed_mimes)) . ' files are allowed.',
                );

                $is_upload_error = 1;
            }

            if ($is_upload_error == 0) {
                $alert = array(
                    'type' => 'success',
                    'title' => 'upload success !',
                    'message' => $image,
                );
            }

            return $alert ?? [
                'type' => 'error',
                'title' => 'upload error',
                'message' => 'image not valid !',
            ];
        }

        if (isset($_POST['fileUploadUrl'])) {
            $alert = array(
                'type' => 'error',
                'title' => 'Failed to Change Logo !',
                'message' => 'Required Image',
            );

            $max_size = 2 * 1024 * 1024; //2mb
            $allowed_mimes = ['jpg', 'png', 'jpeg'];

            $res_upload = check_image($_POST['fileUploadUrl'], $_POST['fileUploadIds'], $allowed_mimes, $max_size);

            if ($res_upload['type'] === 'success') {
                if (empty($query_guide_feature)) {
                    $wpdb->insert('revo_mobile_variable', array(
                        'slug'  => 'guide_feature',
                        'title' => '',
                        'image' => $res_upload['message'],
                        'description' => 'hide'
                    ));
                } else {
                    $wpdb->query(
                        $wpdb->prepare("UPDATE revo_mobile_variable SET image='" . $res_upload['message'] . "' WHERE slug='guide_feature'")
                    );
                }

                $alert = array(
                    'type'  => 'success',
                    'title' => 'Success !',
                    'message' => 'Image Updated Successfully',
                );
            } else {
                $alert = $res_upload;
            }

            $_SESSION["alert"] = $alert;

            $query_guide_feature = query_revo_mobile_variable('"guide_feature"', 'sort');
            $guide_feature_image = empty($query_guide_feature) ? '' : (!empty($query_guide_feature[0]->image) ? $query_guide_feature[0]->image : '');
        }

        if (isset($_POST['typeQuery'])) {
            header('Content-type: application/json');

            switch ($_POST['typeQuery']) {
                case 'product_setting':
                    $status = $_POST["status"];
                    $action = $_POST["action"];
                    $get    = query_revo_mobile_variable('"' . $action . '"', 'sort');

                    if (empty($get)) {
                        $wpdb->insert('revo_mobile_variable', array(
                            'slug'  => $action,
                            'title' => '',
                            'image' => '',
                            'description' => $status
                        ));
                    } else {
                        $wpdb->query(
                            $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='{$action}'")
                        );
                    }
                    break;
                case 'livechat':
                    $get = query_revo_mobile_variable('"live_chat_status"', 'sort');
                    $status = $_POST["status"];

                    if (empty($get)) {
                        $wpdb->insert('revo_mobile_variable', array(
                            'slug' => 'live_chat_status',
                            'title' => '',
                            'image' => '',
                            'description' => $status
                        ));
                    } else {
                        $wpdb->query(
                            $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='live_chat_status'")
                        );
                    }
                    break;
                case 'guestcheckout':
                    $check = get_option('woocommerce_enable_guest_checkout');
                    $status = $_POST["status"] == 'show' ? 'yes' : 'no';

                    if (empty($check)) {
                        add_option('woocommerce_enable_guest_checkout', $status);
                    } else {
                        update_option('woocommerce_enable_guest_checkout', $status);
                    }
                    break;
                case 'giftbox':
                    $get = query_revo_mobile_variable('"gift_box"', 'sort');
                    $status = $_POST["status"];

                    if (empty($get)) {
                        $wpdb->insert('revo_mobile_variable', array(
                            'slug' => 'gift_box',
                            'title' => '',
                            'image' => '',
                            'description' => $status
                        ));
                    } else {
                        $wpdb->query(
                            $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='gift_box'")
                        );
                    }
                    break;
                case 'checkout_native':
                    $get = query_revo_mobile_variable('"checkout_native"', 'sort');
                    $status = $_POST["status"];

                    if (empty($get)) {
                        $wpdb->insert('revo_mobile_variable', array(
                            'slug' => 'checkout_native',
                            'title' => '',
                            'image' => '',
                            'description' => $status
                        ));
                    } else {
                        $wpdb->query(
                            $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='checkout_native'")
                        );
                    }

                    if ($status === 'show' || empty($get)) {
                        if (empty($query_sync_cart)) {
                            $wpdb->insert('revo_mobile_variable', array(
                                'slug' => 'sync_cart',
                                'title' => '',
                                'image' => '',
                                'description' => $status
                            ));
                        } else {
                            $wpdb->query(
                                $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='sync_cart'")
                            );
                        }
                    }
                    break;
                case 'sync_cart':
                    $get = query_revo_mobile_variable('"sync_cart"', 'sort');
                    $status = $_POST["status"];

                    if (empty($get)) {
                        $wpdb->insert('revo_mobile_variable', array(
                            'slug' => 'sync_cart',
                            'title' => '',
                            'image' => '',
                            'description' => $status
                        ));
                    } else {
                        $wpdb->query(
                            $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='sync_cart'")
                        );
                    }
                    break;
                case 'blog_comment_feature':
                    $get = query_revo_mobile_variable('"blog_comment_feature"', 'sort');
                    $status = $_POST["status"];

                    if (empty($get)) {
                        $wpdb->insert('revo_mobile_variable', array(
                            'slug' => 'blog_comment_feature',
                            'title' => '',
                            'image' => '',
                            'description' => $status
                        ));
                    } else {
                        $wpdb->query(
                            $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='blog_comment_feature'")
                        );
                    }
                    break;
                case 'guide_feature':
                    $get = query_revo_mobile_variable('"guide_feature"', 'sort');
                    $status = $_POST["status"];

                    if (empty($get)) {
                        $wpdb->insert('revo_mobile_variable', array(
                            'slug' => 'guide_feature',
                            'title' => '',
                            'image' => '',
                            'description' => $status
                        ));
                    } else {
                        $wpdb->query(
                            $wpdb->prepare("UPDATE revo_mobile_variable SET description='$status' WHERE slug='guide_feature'")
                        );
                    }

                    break;
            }

            http_response_code(200);
            return json_encode(['kode' => 'S']);
            die();
        }

        if (isset($_POST['other_action'])) {
            $data = $_POST;

            if (!empty($data['membership_category'])) {
                $check = get_option('revo_membership_selected_category');

                if (empty($check)) {
                    add_option('revo_membership_selected_category', $data['membership_category']);
                } else {
                    update_option('revo_membership_selected_category', $data['membership_category']);
                }
            }
        }
    }

    // other settings - categories
    $categories = json_decode( get_categorys() );
    $selected_category = get_option('revo_membership_selected_category');
?>

<!DOCTYPE html>
<html class="fixed">
<?php include(plugin_dir_path(__FILE__) . 'partials/_css.php'); ?>
<style>
    .onoffswitch {
        position: relative;
        width: 71px;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }

    .onoffswitch-checkbox {
        position: absolute;
        opacity: 0;
        pointer-events: none;
    }

    .onoffswitch-label {
        display: block;
        overflow: hidden;
        cursor: pointer;
        border: 2px solid #999999;
        border-radius: 22px;
    }

    .onoffswitch-inner {
        display: block;
        width: 200%;
        margin-left: -100%;
        transition: margin 0.3s ease-in 0s;
    }

    .onoffswitch-inner:before,
    .onoffswitch-inner:after {
        display: block;
        float: left;
        width: 50%;
        height: 27px;
        padding: 0;
        line-height: 27px;
        font-size: 14px;
        color: white;
        font-family: Trebuchet, Arial, sans-serif;
        font-weight: bold;
        box-sizing: border-box;
    }

    .onoffswitch-inner:before {
        content: "ON";
        padding-left: 9px;
        background-color: #22AB01;
        color: #FFFFFF;
    }

    .onoffswitch-inner:after {
        content: "OFF";
        padding-right: 9px;
        background-color: #F0F0F0;
        color: #767876;
        text-align: right;
    }

    .onoffswitch-switch {
        display: block;
        width: 12px;
        margin: 7.5px;
        background: #FFFFFF;
        position: absolute;
        top: 0;
        bottom: 0;
        right: 40px;
        border: 2px solid #999999;
        border-radius: 22px;
        transition: all 0.3s ease-in 0s;
    }

    .onoffswitch-checkbox:checked+.onoffswitch-label .onoffswitch-inner {
        margin-left: 0;
    }

    .onoffswitch-checkbox:checked+.onoffswitch-label .onoffswitch-switch {
        right: 0px;
    }
</style>

<body>
    <?php include(plugin_dir_path(__FILE__) . 'partials/_header.php'); ?>
    <div class="container-fluid">
        <?php include(plugin_dir_path(__FILE__) . 'partials/_alert.php'); ?>
        <section class="panel">
            <div class="inner-wrapper pt-0">
                <?php include(plugin_dir_path(__FILE__) . 'partials/_new_sidebar.php'); ?>

                <section role="main" class="content-body p-0">
                    <section class="panel">
                        <div class="panel-body">
                            <div class="row mb-4 pl-1">
                                <h4>Apps Setting</h4>
                            </div>

                            <div class="row">
                                <ul class="d-block nav nav-tabs nav-fill" id="tabNavigation" role="tablist">
                                    <li class="nav-item" role="tab" data-target="#tab-general"><a style="cursor: pointer">General</a></li>
                                    <li class="nav-item" role="tab" data-target="#tab-other"><a style="cursor: pointer">Other</a></li>
                                </ul>
                            </div>

                            <div class="row" id="app-settings">
                                <div class="tab-content px-0 w-100" id="tabContent">
                                    <div class="tab-pane fade" id="tab-general" role="tabpanel">
                                        <?php if ($revopos_status) : ?>
                                            <div class="col-md-12 border-bottom-primary mb-3 py-4">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <h5>Live Chat (Requires the RevoPOS App)</h5>
                                                    <div class="col-auto">
                                                        <div class="onoffswitch">
                                                            <input type="checkbox" <?= !$revopos_status ? 'disabled' : '' ?> name="onoffswitch" onchange="showLiveChat(event)" class="onoffswitch-checkbox" id="myonoffswitch" tabindex="0" <?= $live_chat_status == 'show' ? 'checked' : '' ?>>
                                                            <label class="onoffswitch-label" for="myonoffswitch">
                                                                <span class="onoffswitch-inner"></span>
                                                                <span class="onoffswitch-switch"></span>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- <small class="text-danger">WARNING : Plugin RevoPOS not installed or activated in your wordpress. Contact our admin first for use this feature</small> -->
                                            </div>
                                        <?php endif; ?>

                                        <div class="col-md-12 border-bottom-primary mb-3 py-4">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <h5>Allow Guest Checkout</h5>
                                                <div class="col-auto">
                                                    <div class="onoffswitch">
                                                        <input type="checkbox" name="onoffswitchcheckout" onchange="guestCheckout(event)" class="onoffswitch-checkbox" id="myonoffswitchcheckout" tabindex="0" <?= $guest_checkout == 'enable' ? 'checked' : '' ?>>
                                                        <label class="onoffswitch-label" for="myonoffswitchcheckout">
                                                            <span class="onoffswitch-inner"></span>
                                                            <span class="onoffswitch-switch"></span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-12 border-bottom-primary mb-3 py-4">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <h5>Animated Gift Box</h5>
                                                <div class="col-auto">
                                                    <div class="onoffswitch">
                                                        <input type="checkbox" name="onoffswitchgiftbox" onchange="giftbox(event)" class="onoffswitch-checkbox" id="myonoffswitchgiftbox" tabindex="0" <?= $giftbox == 'show' ? 'checked' : '' ?>>
                                                        <label class="onoffswitch-label" for="myonoffswitchgiftbox">
                                                            <span class="onoffswitch-inner"></span>
                                                            <span class="onoffswitch-switch"></span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <?php if (file_exists(__DIR__ . '/../custom/class/class-checkout-native.php')) : ?>
                                            <div class="col-md-12 border-bottom-primary mb-3 py-4">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <h5>Native Checkout</h5>
                                                    <div class="col-auto">
                                                        <div class="onoffswitch">
                                                            <input type="checkbox" name="onoffswitchcheckoutnative" onchange="checkoutNative(event)" class="onoffswitch-checkbox" id="myonoffswitchcheckoutnative" tabindex="0" <?= $checkout_native === 'show' ? "checked" : "" ?>>
                                                            <label class="onoffswitch-label" for="myonoffswitchcheckoutnative">
                                                                <span class="onoffswitch-inner"></span>
                                                                <span class="onoffswitch-switch"></span>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="col-md-12 border-bottom-primary mb-3 py-4">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <h5>Syncronize Cart</h5>
                                                    <div class="col-auto">
                                                        <div class="onoffswitch">
                                                            <input type="checkbox" name="onoffswitchsynccart" onchange="syncCart(event)" class="onoffswitch-checkbox" id="myonoffswitchsynccart" tabindex="0" <?= $sync_cart === 'show' ? "checked" : "" ?>>
                                                            <label class="onoffswitch-label" for="myonoffswitchsynccart">
                                                                <span class="onoffswitch-inner"></span>
                                                                <span class="onoffswitch-switch"></span>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        <?php endif; ?>

                                        <div class="col-md-12 border-bottom-primary mb-3 py-4">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <h5>Comments on Blogs</h5>
                                                <div class="col-auto">
                                                    <div class="onoffswitch">
                                                        <input type="checkbox" name="onoffswitchblogcomment" onchange="blogComment(event)" class="onoffswitch-checkbox" id="myonoffswitchblogcomment" tabindex="0" <?= $blog_comment_feature === 'show' ? "checked" : "" ?>>
                                                        <label class="onoffswitch-label" for="myonoffswitchblogcomment">
                                                            <span class="onoffswitch-inner"></span>
                                                            <span class="onoffswitch-switch"></span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-12 border-bottom-primary mb-3 py-4">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div class="d-flex align-items-center">
                                                    <h5 class="mb-0">Repeat Guide</h5>
                                                    <div class="d-flex align-items-center btn btn-outline-secondary ml-3 px-3 pb-2" style="font-size: 9px; border-radius: 25px;" data-toggle="modal" data-target="#modalGuide">
                                                        <i class="fa fa-picture-o" style="font-size: 14px;"></i>
                                                        <div class="pl-2">UPLOAD BACKGROUND IMAGE FOR GUIDE</div>
                                                    </div>
                                                </div>

                                                <div class="col-auto">
                                                    <div class="onoffswitch">
                                                        <input type="checkbox" name="myonoffswitchguidefeature" onchange="guideFeature(event)" class="onoffswitch-checkbox" id="myonoffswitchguidefeature" tabindex="0" <?= $guide_feature === 'show' ? "checked" : "" ?>>
                                                        <label class="onoffswitch-label" for="myonoffswitchguidefeature">
                                                            <span class="onoffswitch-inner"></span>
                                                            <span class="onoffswitch-switch"></span>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <?php foreach ($product_settings as $setting_key => $setting) : ?>
                                            <div class="col-md-12 mb-3 py-4 <?php echo array_key_last($product_settings) !== $setting_key ? 'border-bottom-primary' : '' ?> " >
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div class="d-flex align-items-center">
                                                        <h5 class="mb-0"><?= $setting['label'] ?></h5>
                                                    </div>

                                                    <div class="col-auto">
                                                        <div class="onoffswitch">
                                                            <input type="checkbox" name="onoffswitch<?= $setting['name'] ?>" onchange="productSettings(event, '<?= $setting['name'] ?>')" class="onoffswitch-checkbox" id="myonoffswitch<?= $setting['name'] ?>" tabindex="0" <?= isset($product_settings_datas[$setting['name']]) ? "checked" : "" ?>>
                                                            <label class="onoffswitch-label" for="myonoffswitch<?= $setting['name'] ?>">
                                                                <span class="onoffswitch-inner"></span>
                                                                <span class="onoffswitch-switch"></span>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        <?php endforeach; ?>
                                    </div>

                                    <div class="tab-pane fade py-4" id="tab-other" role="tabpanel">
                                        <div class="col-12">
                                            <form method="POST">
                                                <div class="form-group">
                                                    <div class="row justify-content-center">
                                                        <div class="col-md-3">
                                                            <label for="membership_category">Membership Plan Category</label>
                                                        </div>

                                                        <div class="col-md-9">
                                                            <select class="form-control" name="membership_category" id="membership_category">
                                                                <option disabled selected>Choose a category</option>
                                                                <?php foreach ($categories as $cat) : ?>
                                                                    
                                                                    <option value="<?php echo $cat->id ?>" <?php echo $selected_category == $cat->id ? 'selected' : '' ?> ><?php echo $cat->text ?></option>
                                                                <?php endforeach; ?>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="form-group" style="margin-top: 35px;">
                                                    <input type="hidden" name="other_action" value="other_action">
                                                    <button class="btn btn-primary">Save Changes</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>
                </section>
            </div>
        </section>
    </div>

    <div class="modal fade" id="modalGuide" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Setting Guide Image</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form action="#" method="POST">
                    <div class="modal-body py-4">
                        <div class="form-group">
                            <label for="">Choose Image</label>
                            <input class="form-control upload_file_button" placeholder="Select a Photo" required>
                            <input type="hidden" name="fileUploadUrl">
                            <input type="hidden" name="fileUploadIds">
                        </div>

                        <div class="form-group mt-4">
                            <div class="mb-2">Preview Image</div>

                            <?php if (!empty($guide_feature_image)) : ?>
                                <a class="lightbox" style="border:unset;" href="<?= $guide_feature_image ?>" data-plugin-options='{ "type":"image" }'>
                                    <img class="border" src="<?= $guide_feature_image ?>" alt="imagePreview" id="imagePreview" width="90" height="90" style="object-fit: cover; border-radius: 5px">
                                </a>
                            <?php else : ?>
                                <div class="text-danger">No image yet</div>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div class="modal-footer py-4">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>

<?php include(plugin_dir_path(__FILE__) . 'partials/_js.php');  ?>
<script>
    $(function () {
        const params = new Proxy(new URLSearchParams(window.location.search), {
            get: (searchParams, prop) => searchParams.get(prop),
        });

        let tabActive = params.tab_active;

        if (tabActive === null || tabActive === '') {
            tabActive = 'tab-general';
        }

        $(`div#tabContent #${tabActive}`).addClass('show active');
        $(`ul#tabNavigation li[data-target="#${tabActive}"]`).addClass('active');
    });

    $('#tabNavigation li').on('click', function(event) {
        event.preventDefault();
        $(this).tab('show');

        const target = $(this).data('target');
        const tabContent = document.querySelectorAll('div#tabContent div[role="tabpanel"]');

        const url = new URL(window.location);
        url.searchParams.set('tab_active', target.replace('#', ''));
        window.history.pushState(null, '', url.toString());

        tabContent.forEach((el) => {
            if ($(el).hasClass('show active')) {
                $(el).removeClass('show active');
            }

            if ($(el).attr('id') === target) {
                $(el).addClass('show active');
            }
        });
    });

    const confirmSwalAlert = (title = '', text = '', status, typeQuery, data = null) => {
        Swal.fire({
            icon: 'warning',
            title,
            text,
            showDenyButton: true,
            showCancelButton: false,
            allowOutsideClick: false,
            confirmButtonText: `YES`,
            denyButtonText: `NO`,
        }).then((result) => {
            if (result.isConfirmed) {
                if (data === null) {
                    data = {
                        status,
                        typeQuery
                    }
                }

                $.ajax({
                    url: "#",
                    method: "POST",
                    data,
                    datatype: "json",
                    async: true,
                    success: function(data) {
                        location.reload();
                    },
                    error: function(data) {
                        location.reload();
                    }
                });
            } else if (result.isDenied) {
                el.checked = status == "show" ? false : true;
            }
        });
    }

    function showLiveChat(e) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = "";
            swaltext = "Do you want to turn off Live Chat?";
        } else {
            swaltitle = "Live Chat requires the RevoPOS mobile app to reply the chats";
            swaltext = "Do you want to activate Live Chat?";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'livechat');
    }

    function guestCheckout(e) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = "Are you going to enable Guest Checkout?";
            swaltext = "(User can shop without login)";
        } else {
            swaltitle = "Are you going to disable Guest Checkout?";
            swaltext = "(User must login to be able to shop)";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'guestcheckout');
    }

    function giftbox(e) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = "Are you going to enable Animated Gift Box";
            swaltext = "(Animated Gift Box will appear if you have a coupon to use)";
        } else {
            swaltitle = "Are you going to disable Animated Gift Box";
            swaltext = "(Animated Gift Box will not appear even if you have a coupon that can be used)";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'giftbox');
    }

    function checkoutNative(e) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = "Are you going to enable Native Checkout method";
            swaltext = "(Native Checkout method just using default shipping and payment from woocommerce)";
        } else {
            swaltitle = "Are you going to disable Native Checkout method";
            swaltext = "(you will use webview checkout on your app)";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'checkout_native');
    }

    function syncCart(e) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = "Are you going to enable syncronize cart method";
            swaltext = "";
        } else {
            swaltitle = "Are you going to disable syncronize cart method";
            swaltext = "";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'sync_cart');
    }

    function blogComment(e) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = "Are you sure to show comment feature on detail blog page?";
            swaltext = "";
        } else {
            swaltitle = "are you sure to hide comment feature on detail blog page?";
            swaltext = "";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'blog_comment_feature');
    }

    function guideFeature(e) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = "Are you sure to enable guide feature?";
            swaltext = "";
        } else {
            swaltitle = "Are you sure to disable guide feature?";
            swaltext = "";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'guide_feature');
    }

    function productSettings(e, sub_action = null) {
        el = e.target;
        status = el.checked ? "show" : "hide";

        if (status === "show") {
            swaltitle = `Are you sure to enable ${sub_action.replaceAll('_', ' ')}?`;
            swaltext = "";
        } else {
            swaltitle = `Are you sure to disable ${sub_action.replaceAll('_', ' ')}?`;
            swaltext = "";
        }

        confirmSwalAlert(swaltitle, swaltext, status, 'product_setting', {
            status,
            typeQuery: 'product_setting',
            action: sub_action.toLowerCase()
        });
    }
</script>

</html>