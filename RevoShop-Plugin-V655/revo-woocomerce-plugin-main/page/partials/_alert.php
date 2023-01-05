<?php if(isset($_SESSION["alert"])){ ?>
	<div class="alert text-capitalize <?php echo $_SESSION["alert"]['type'] == 'success' ? 'alert-success' : 'alert-danger'   ?>">
		<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
		<strong><?php echo $_SESSION["alert"]['title'] ?></strong> <?php echo $_SESSION["alert"]['message'] ?>
	</div>
<?php 
		unset ($_SESSION["alert"]);
	} 
?>