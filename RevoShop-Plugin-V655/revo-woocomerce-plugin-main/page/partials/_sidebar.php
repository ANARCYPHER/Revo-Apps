<aside id="sidebar-left" class="sidebar-left">

    <div class="sidebar-header">
        <div class="sidebar-title">
            Navigation
        </div>
        <div class="sidebar-toggle hidden-xs" data-toggle-class="sidebar-left-collapsed" data-target="html" data-fire-event="sidebar-left-toggle">
            <i class="fa fa-bars" aria-label="Toggle sidebar"></i>
        </div>
    </div>

    <div class="nano">
        <div class="nano-content bg-white">
            <nav id="menu" class="nav-main" role="navigation">
            
                <ul class="nav nav-main">
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-apps-setting' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-apps-setting', 'admin' ); ?>">
                            <i class="fa fa-home" aria-hidden="true"></i>
                            <span>Dashboard</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-intro-page' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-intro-page', 'admin' ); ?>">
                            <i class="fa fa-mobile" style="font-size: 22px" aria-hidden="true"></i>
                            <span>Intro Page</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-mobile-banner' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-mobile-banner', 'admin' ); ?>">
                            <i class="fa fa-image" aria-hidden="true"></i>
                            <span>Home Sliding Banner</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-mobile-categories' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-mobile-categories', 'admin' ); ?>">
                            <i class="fa fa-folder-open" aria-hidden="true"></i>
                            <span>Home Categories</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-mini-banner' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-mini-banner', 'admin' ); ?>">
                            <i class="fa fa-file-image-o " aria-hidden="true"></i>
                            <span>Home Additional Banner</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-flash-sale' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-flash-sale', 'admin' ); ?>">
                            <i class="fa fa-flash" aria-hidden="true"></i>
                            <span>Home Flash Sale</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-additional-products' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-additional-products', 'admin' ); ?>">
                            <i class="fa fa-shopping-cart" aria-hidden="true"></i>
                            <span>Home Additional Products</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-popular-categories' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-popular-categories', 'admin' ); ?>">
                            <i class="fa fa-thumbs-up" aria-hidden="true"></i>
                            <span>Popular Categories</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-empty-result-image' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-empty-result-image', 'admin' ); ?>">
                            <i class="fa fa-window-close" aria-hidden="true"></i>
                            <span>Empty Result Image</span>
                        </a>                        
                    </li>
                    <li class="w-100 <?php echo $_GET['page'] == 'revo-post-notification' ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page=revo-post-notification', 'admin' ); ?>">
                            <i class="fa fa-bell" aria-hidden="true"></i>
                            <span>Push Notification</span>
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