#!/usr/bin/perl

use strict;
use warnings;
use config;
use subrutinas;

if($#ARGV == -1){
	#EJECUTAR SIN ARGUMENTOS
	muestra_ayuda(0);
}else{
	#MANEJO DE ARGUMENTOS
	for(my $i=0;$i <= $#ARGV;$i++){
		if($ARGV[$i] eq "-h" || $ARGV[$i] eq "--help"){
			muestra_ayuda(0);
		}
		
		if($ARGV[$i] eq "-d" || $ARGV[$i] eq "--directory"){
			$j=$i+1;
			if(($j) <= $#ARGV){
				if(!(-d $ARGV[$j])){
					print "El directorio $ARGV[$j] no existe\n";
					escribe_bitacora("El directorio $ARGV[$j] no existe");
				}else{
					$directory = $ARGV[$j];
				}
			}else{
				muestra_ayuda(0);
				escribe_bitacora("Error al pasar argumentos de directoy");
			}
		}
		
		if($ARGV[$i] eq "-o" || $ARGV[$i] eq "--origin"){
			$j=$i+1;
			if(($j) <= $#ARGV){
				if(!(-d $ARGV[$j])){
					print "El directorio $ARGV[$j] no existe\n";
					escribe_bitacora("El directorio $ARGV[$j] no existe");
				}else{
					$origin = $ARGV[$j];
				}
			}else{
				muestra_ayuda(0);
				escribe_bitacora("Error al pasar argumentos de origin");
			}

		}
		
		if($ARGV[$i] eq "-l" || $ARGV[$i] eq "--log"){
			$j=$i+1;
			if(($j) <= $#ARGV){
				if(!(-d $ARGV[$j])){
					print "El directorio $ARGV[$j] no existe\n";
					escribe_bitacora("El directorio $ARGV[$j] no existe");
				}else{
					$log = $ARGV[$j];
				}
			}else{
				muestra_ayuda(0);
				escribe_bitacora("Error al pasar argumentos de log");
			}
		}
				
		if($ARGV[$i] eq "-b" || $ARGV[$i] eq "--batch"){
			for($j=$i+1;$j<=$#ARGV;$j++){
				$archivos=$archivos." ".$ARGV[$j];
			}
			divide_archivos();
			lee_archivos();
			escribirArchivoProcesado();
			escribirArchivoClaro();
		}
		
		if($ARGV[$i] eq "-c" || $ARGV[$i] eq "--continuos"){
			for($j=$i+1;$j<=$#ARGV;$j++){
				$archivos=$archivos." ".$ARGV[$j];
			}
			divide_archivos();
			inicia_demonio();
		}
		
	}
}

=pod

=head1 ARCHIVO PRINCIPAL

	Este es el archivo principal del script en el cual se hace la validacion de los parametros y de acuerdo a cada uno se realiza una accion:

=head2 Parametros

=head3 -h,--help

	Se llama a la subrutina muestra_ayuda().

=head3 -d, --directory

	Se hace la validacion de que exista el directorio especificado, en caso de que no exista se guarda en bitacora el error.

=head3 -o, --origin

	Se hace la validacion de que exista el directorio especificado, en caso de que no exista se guarda en bitacora el error.

=head3 -l, --log
	
	Se hace la validacion de que exista el directorio especificado, en caso de que no exista se guarda en bitacora el error.

=head3 -b, --batch

	Se llama a la subrutina divide_archivos(), lee_archivos(), escribirArchivoProcesado() y escribirArchivoClaro(). 

=head3 -c, --continuos

	Se llama a la subrutina divide_archivos e inicia_demonio().

=cut
