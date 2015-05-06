<!DOCTYPE HTML>
<!--
	Landed by HTML5 UP
	html5up.net | @n33co
	Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
-->
<html>
	<head>
		<title>Freeze</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		<!--[if lte IE 8]><script src="css/ie/html5shiv.js"></script><![endif]-->
		<script src="js/jquery.min.js"></script>
		<script src="js/jquery.scrolly.min.js"></script>
		<script src="js/jquery.dropotron.min.js"></script>
		<script src="js/jquery.scrollex.min.js"></script>
		<script src="js/skel.min.js"></script>
		<script src="js/skel-layers.min.js"></script>
		<script src="js/init.js"></script>
		<noscript>
			<link rel="stylesheet" href="css/skel.css" />
			<link rel="stylesheet" href="css/style.css" />
			<link rel="stylesheet" href="css/style-xlarge.css" />
		</noscript>
		<!--[if lte IE 9]><link rel="stylesheet" href="css/ie/v9.css" /><![endif]-->
		<!--[if lte IE 8]><link rel="stylesheet" href="css/ie/v8.css" /><![endif]-->
	</head>
	<body>

		<!-- Header -->
			<header id="header" class="skel-layers-fixed">
				<h1 id="logo"><a href="index.php">Freeze</a></h1>
			</header>

		<!-- Main -->
			<div id="main" class="wrapper style1">
				<div class="container">
					<header class="major">
						<h2>Freeze</h2>
					</header>
					<div class="row 50%">

						<div class="12u$ 12u$(medium) important(medium)">

							<!-- Content -->
								<section id="content">
									
									<div class="row">
										<div class="12u">		
											<section class="box">
																																			
												<form name="cmd" action="">
													
													<div class="row uniform half ollapse-at-2">
														<div class="6u">
															<input name="cmd" type="text" size="100" maxlength="100" 
																<?php  
																	$cmd=$_GET['cmd'];
																	if (isset($cmd)) {
																		echo 'value="'.$cmd.'"';
																	} else {
																		echo 'placeholder="Entré un chemin (ex : /home/), par défaut \'/home/utroot/\'"';
																}?>
															/>
														</div>
													</div>
						
												</form>
												
											</section>
										</div>
										<div class="12u">
											<section class="box">		
															
												<h2>Affichage</h2>
												
												<?php 
													
													//récupération de la données
													$cmd=$_GET['cmd'];
													
													//création de la commande
													$cmd2='ls -l ';
													if (isset($cmd)) {
														$cmd=$cmd2.$cmd;
													} else {
														$cmd='ls -l /home/utroot/';
													}

													//execution de la commande													
													exec($cmd, $output);

													//comptage du nombre d'entré
													$count = count($output);
	
													//affichage du tableau
													
													echo'<div class="table-wrapper">
															<table>
																<thead>
																	<tr>
																		<th>Droit</th>
																		<th>Utilisateur</th>
																		<th>Group</th>
																		<th>Taille (en octect)</th>
																		<th>Jour</th>
																		<th>Mois</th>
																		<th>Heure/Années</th>
																		<th>Fichier/Dossier</th>
																	</tr>
																</thead>
																<tbody>';
																	//test si OK
																	if ($count==0)
																		echo "<tr>
																				  <td bgcolor='red'>Aucun fichier ou dossier</td>
																				  <td bgcolor='red'></td>
																				  <td bgcolor='red'></td>
																				  <td bgcolor='red'></td>
																				  <td bgcolor='red'></td>
																				  <td bgcolor='red'></td>
																				  <td bgcolor='red'></td>
																				  <td bgcolor='red'></td>
																			  </tr>";
																	else
																		
																		//suppréssion des espace et création d'un tableau dans un tableau
																		$i=1;
																		$count2=1;
																		while ($count2 < $count) {
																			$contenu_array[$i] = explode(" ",$output[$i]);
																			$i++;
																			$count2++;
																		}
																		
																		//on enlève les données vide ou à 0
																		$i=1;
																		$count2=1;
																		while ($count2 < $count) {
																			$array[$i] = array_filter($contenu_array[$i]);
																			$i++;
																			$count2++;
																		}
																		
																		//création d'un nouveau tableau avec des numéreau de possition à la suite
																		$array2 = array("");
																		$i=1;
																		$count2=1;
																		while ($count2 < $count) {
																			array_unshift($array[$i], $array2[$i]);
																			$i++;
																			$count2++;
																		}
																		
																		//affichage des données
																		$i=1;
																		$count2=1;
																		while ($count2 < $count) {
																			echo "<tr>
																						<td>".$array[$i][1]."</td>
																						<td>".$array[$i][3]."</td>
																						<td>".$array[$i][4]."</td>
																						<td>".$array[$i][5]."</td>
																						<td>".$array[$i][6]."</td>
																						<td>".$array[$i][7]."</td>
																						<td>".$array[$i][8]."</td>
																						<td>".$array[$i][9]."</td>
																				  </tr>";
																					
																			$i++;
																			$count2++;
																		}
																		
																		fclose($contenu);
																		
																echo'
																</tbody>
															</table>
														</div>';
														
														

													?>
																				
											</section>				
										</div>
									</div>
									
								</section>

						</div>
					</div>
				</div>
			</div>

		</body>
</html>