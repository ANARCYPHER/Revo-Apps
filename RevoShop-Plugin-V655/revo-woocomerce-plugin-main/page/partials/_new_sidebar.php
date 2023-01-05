<aside id="sidebar-left" class="sidebar-left">
    <div class="sidebar-header" style="height: auto;">
        <div class="sidebar-title text-center">
            <img src="<?php echo get_logo() ?>" class="img-fluid mr-3 py-3" style="width: 100px">
        </div>
        <!-- <div class="sidebar-toggle hidden-xs" data-toggle-class="sidebar-left-collapsed" data-target="html" data-fire-event="sidebar-left-toggle">
            <i class="fa fa-bars" aria-label="Toggle sidebar"></i>
        </div> -->
    </div>

    <div class="nano" style="min-height: 820px;">
        <div class="nano-content">
            <nav id="menu" class="nav-main" role="navigation">
                <ul class="nav nav-main mr-0">
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-apps-setting' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-apps-setting', 'admin'); ?>">
                            <i class="fa fa-home sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Dashboard</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-intro-page' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-intro-page', 'admin'); ?>">
                            <i class="fa fa-mobile sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Intro Page</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-searchbar' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-searchbar', 'admin'); ?>">
                            <i class="fa fa-search sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Home Search Bar Text</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-mobile-banner' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-mobile-banner', 'admin'); ?>">
                            <i class="fa fa-image sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Home Sliding Banner</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-mobile-categories' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-mobile-categories', 'admin'); ?>">
                            <i class="fa fa-folder-open sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Home Categories</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-mini-banner' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-mini-banner', 'admin'); ?>">
                            <i class="fa fa-file-image-o  sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Home Additional Banner</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-flash-sale' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-flash-sale', 'admin'); ?>">
                            <i class="fa fa-flash sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Home Flash Sale</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-additional-products' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-additional-products', 'admin'); ?>">
                            <i class="fa fa-shopping-cart sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Home Additional Products</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-popular-categories' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-popular-categories', 'admin'); ?>">
                            <i class="fa fa-thumbs-up sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Popular Categories</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-empty-result-image' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-empty-result-image', 'admin'); ?>">
                            <i class="fa fa-window-close sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Empty Result Image</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-post-notification' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-post-notification', 'admin'); ?>">
                            <i class="fa fa-bell sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Push Notification</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-color-setting' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-color-setting', 'admin'); ?>">
                            <i class="fa fa-paint-brush sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">App Color Setting</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-sosmed-setting' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-sosmed-setting', 'admin'); ?>">
                            <i class="fa fa-globe sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Social Media Setting</span>
                        </a>
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-apps-additional-setting' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url('admin.php?page=revo-apps-additional-setting', 'admin'); ?>">
                            <i class="fa fa-cogs sidebar-icon" aria-hidden="true"></i>
                            <span class="pl-1">Apps Setting</span>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>

        <script>
            // Maintain Scroll Position
            if (typeof localStorage !== 'undefined') {
                if (localStorage.getItem('sidebar-left-position') !== null) {
                    var initialPosition = localStorage.getItem('sidebar-left-position'),
                        sidebarLeft = document.querySelector('#sidebar-left .nano-content');

                    sidebarLeft.scrollTop = initialPosition;
                }
            }
        </script>
    </div>
</aside>