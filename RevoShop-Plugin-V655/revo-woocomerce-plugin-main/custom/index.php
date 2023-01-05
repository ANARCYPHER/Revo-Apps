<?php

require_once __DIR__ . '/Base.php';

function register_custom_plugin_routes()
{
    foreach (glob(__DIR__ . '/class/*.php') as $path_class) {
        require_once $path_class;
    }

    $classes = [
        'Revo_CheckoutNative',
        'Revo_Polylang',
        'Revo_Aliexpress',
    ];

    foreach ($classes as $class) {
        if (class_exists($class)) {
            $obj = new $class();
            $obj->rest_init();
        }
    }
}

add_action('rest_api_init', 'register_custom_plugin_routes');
