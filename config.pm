package config;

use warnings;
use strict;
use Exporter;

our @ISA=qw(Exporter);
our @EXPORT=qw($directory $log $nom_log $origin $j $archivos @archivos $espera %primerEvento %ultimoEvento %contadorEventos $nombre_Procesado $nombre_Claro $separador);

our $directory="";
our $log="";
our $nom_log="bitacora.log";
our $origin="";
our $j=0;
our $archivos="";
our @archivos;
our $espera=30;
our %primerEvento;
our %ultimoEvento;
our %contadorEventos;
our $nombre_Procesado="Unified2Procesado";
our $nombre_Claro="Unified2Claro.txt";
our $separador="|";

=pod

=head1 ARCHIVO DE CONFIGURACION

	Este es el archivo de configuracion para el archivo script.pl el cual contiene todas las variables globales utilizadas en el script.

=head2 Variables:

=head3	directory:
		
	Almacena la ruta de los archivos resultantes despues de ejecutar el script.

=head3 nombre_Procesado:

	Nombre del archivo procesado en formato Unified2.

=head3 nombre_Claro:

	Nombre del archivo procesado en texto claro.

=head3	log:

	Almacena la ruta de la bitacora del script.

=head3	nom_log:

	Almacena el nombre de la bitacora.

=head3 origin:

	Almacena la ruta de los archivos a leer al ejecutar el script.

=head3 j:

	Es utilizada como contador.

=head3 archivos:

	Escalar - contiene en un string el nombre(s) de los archivos a procesar.
	Arreglo - contiene en un arreglo el nombre(s) de cada uno de los archivos a procesar.

=head3 espera:

	Tiempo (milisegundos) de espera para ejecutar el demonio.

=head3 primerEvento

	Hash en el que se almacena el primer evento de un incidente.

=head3 ultimoEvento
	
	Hash en el que se almacena el ultimo evento de un incidente.

=head3 contadorEventos

	 Hash en el que se va realizando la cuenta de la eventos encontrados de cada incidente.

=head3 separador
	
	Caracter que se usa como separador en el archivo de texto claro procesado (Unified2Claro.txt).

=cut

1;

