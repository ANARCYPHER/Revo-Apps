<?php

namespace Custom;

use WP_Error;

class Base
{
    protected $namespace = 'revo-admin/v1';

    public function sendError($code, $message, $statusCode): WP_Error
    {
        return new WP_Error($code, $message, array('status' => $statusCode));
    }

    /**
     * Check plugin active or not
     * 
     * @return bool
     */
    public function checkPluginActive($plugin): bool
    {
        if (!is_plugin_active($plugin) && $plugin !== true) {
            return false;
        }

        return true;
    }
}