<head>
  <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700,800|Shadows+Into+Light" rel="stylesheet" type="text/css">

  <!-- Vendor CSS -->
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/vendor/bootstrap/css/bootstrap.css" />
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/extend/css/bootstrap4.min.css">

  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/vendor/font-awesome/css/font-awesome.css" />
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/vendor/magnific-popup/magnific-popup.css" />
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/vendor/bootstrap-datepicker/css/bootstrap-datepicker3.css" />

  <!-- Specific Page Vendor CSS -->
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/vendor/select2/css/select2.css" />
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/vendor/select2-bootstrap-theme/select2-bootstrap.min.css" />
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/vendor/jquery-datatables-bs3/assets/css/datatables.css" />

  <!-- Theme CSS -->
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/stylesheets/theme.css" />

  <!-- Skin CSS -->
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/stylesheets/skins/default.css" />

  <!-- Theme Custom CSS -->
  <link rel="stylesheet" href="<?php echo revo_url() ?>assets/stylesheets/theme-custom.css">

  <!-- Head Libs -->
  <script src="<?php echo revo_url() ?>assets/vendor/modernizr/modernizr.js"></script>

  <style>
    #wpcontent {
      padding-left: 0px;
    }

    .form-control {
      border: 1px solid #dedbdb !important;
    }

    .table-bordered {
      border: 1px solid #dee2e6 !important;
    }

    .modal-dialog {
      margin-top: 15% !important;
    }

    .modal {
      background-color: #00000052;
    }

    .font-weight-600 {
      font-weight: 600;
    }

    .select2-container {
      width: 100% !important;
      text-align: left !important;
    }

    .select2-container--bootstrap .select2-selection {
      font-size: 12px !important;
    }

    .panel-body {
      -webkit-box-shadow: unset;
      box-shadow: unset;
      border-radius: unset;
    }

    .select2-container--bootstrap .select2-selection--single .select2-selection__rendered {
      color: #a5a2a2;
      padding: 0;
    }

    .rounded {
      border-radius: 50% !important;
    }

    .inner-wrapper {
      border-radius: 10px;
      min-height: 55vw;
    }

    .sidebar-left .sidebar-header .sidebar-title {
      background: #1c1e2b;
    }

    .sidebar-left .nano-content {
      background: #1c1e2b;
      box-shadow: -5px 0 0 #1c1e2b inset;
    }

    .panel {
      font-size: 14px;
      height: 100%;
    }

    ul.nav-main>li.nav-active>a {
      box-shadow: 2px 0 0 #0088cc inset;
      background: #0088cc;
      color: #ffffff;
    }

    ul.nav-main li a {
      font-size: 14px;
    }

    ul.nav-main>li>a {
      padding: 12px 20px;
    }

    .sidebar-left {
      width: 270px;
    }

    .panel-body {
      height: 100%;
      padding: 25px;
    }

    .border-bottom-primary {
      margin-bottom: 50px;
      padding-bottom: 50px;
      border-bottom: 2px solid #f3f3f39e;
    }

    .form-control {
      font-size: 13px;
    }

    .wp-die-message,
    p {
      font-size: 14px;
    }

    .card {
      padding: .7em .5em 1em;
    }

    .btn {
      font-size: 13px;
      padding: 5px 15px;
    }

    .upload_file_button {
      caret-color: transparent;
      cursor: none;
      line-height: 200%;
      cursor: pointer;
    }
  </style>

  <?php if (strpos($_GET['page'], 'revo') !== false) : ?>
    <style>
      .modal{
        background: transparent !important;
        width: 100% !important;
        color: #000;
        text-align: start;
      }
    </style>
  <?php endif; ?>
</head>