package subrutinas;

use strict;
use warnings;
use POSIX qw(setsid);
use config;
use Exporter;
use SnortUnified(qw(:ALL));
use Data::Dumper;
use String::Util qw(trim);

our @ISA = qw(Exporter);
our @EXPORT=qw(muestra_ayuda inicia_demonio divide_archivos escribe_bitacora lee_archivos escribirArchivoProcesado escribirArchivoClaro);

sub divide_archivos{
	@archivos=split(/\s+/,$archivos);
	shift @archivos;
	foreach my $i (0 .. $#archivos){
		if(!(-e $origin.$archivos[$i])){
			print "El archivo $origin"."$archivos[$i] no existe\n";
			escribe_bitacora("El archivo $origin"."$archivos[$i] no existe");
			exit 0;
		}
	}
}

sub muestra_ayuda{
	my $exit_status = shift;
	system("clear");
	print << "END"
				Ayuda
		SINOPSIS
		perl script.pl
			-h
			-b [archivo1] [archivo2].....
			-c [archivo1] [archivo2].....
			-l [ruta]
			-d [ruta]
			-o [ruta] 
		DESCRIPCION
		-h, --help	Ayuda del programa
	
		-b, --batch	Modo por lotes
			Procesara uno o varios archivos para obtener los incidentes

		-c, --continuos	Modo Continuo
			El programa se ejecutara como un demonio del sistema y revisara de manera continua el directorio en busca de nuevos eventos en el archivo
	
		-d, --directory	Directorio en el cual se guardaran los archivos generados
			Si no se especifica se guardan en el directorio de ejecucion del script
	
		-o, --origin	Directorio que contiene los archivos unified2 a procesar
			Si no se especifica se guardaran en el directorio de ejecucion del script
	
		-l, --log	Directorio que contiene las bitacoras de la ejecucion de la herramienta
			Si no se especifica el directorio corresponde al directorio de ejecucion del script


END
;
	exit $exit_status;
}

sub demonio{
	open STDIN, '/dev/null' or die escribe_bitacora("No se puede leer /dev/null:$!");
	open STDOUT, '>>/dev/null' or die escribe_bitacora("No se puede escribir /dev/null:$!");	
	open STDERR, '>>/dev/null' or die escribe_bitacora("No se puede escribir /dev/null:$!");
	defined(my $pid = fork) or die escribe_bitacora("No se puede crear el proceso: $!");
	exit if $pid;
	setsid or die "No se puede iniciar una sesion nueva: $!";
	umask 0;
}

sub inicia_demonio{
	demonio();
	escribe_bitacora("Se inicio el demonio");
	while(1){
		lee_archivos();
		escribirArchivoProcesado();
		escribirArchivoClaro();
		sleep($espera);
	}

}

sub escribe_bitacora{
	my($arg1)=@_;
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	$mon++;
	open(LOG,">>$log"."$nom_log");
	print LOG "$mday/$mon/$year $hour:$min:$sec $arg1\n";
	close LOG;
}

sub obtenerIncidentes{
	escribe_bitacora("Se inicia el Script");
	my $rutaLog = shift;
    	my @datos;
    	my $llave;
    	my $record;
    	my $protocolo;
    	my $alerta;
    	my $tipo;
    	my $idAnterior;
    	my $idEncontrado;
    	my $datos;
    	my $UF_Data = openSnortUnified($rutaLog);
    	my $idHash;
    	my $ip;
    	my $idIncidente=1;
    	my $aux;
    	my $contador;
    	my $index;
    	my $registro;
    	
	while ( $record = readSnortUnifiedRecord() ) {
		@datos = Dumper($record);
		#Obteniendo el Tipo de registro

           	$tipo =  $record->{'TYPE'};

        	#Obteniendo el id del evento

           	$idEncontrado =  $record->{'event_id'};
	
	    	#print "id Anterior: ".$idAnterior."\n";
	    	#print "id Encontrada: ".$idEncontrado."\n";
	    	#print "Tipo: ".$tipo."\n";

        	# Detectando un nuevo registro
        	if($tipo ne 2 && $tipo ne 110 && (! defined $idAnterior  || $idEncontrado eq $idAnterior )){
	       		$protocolo = $record->{'protocol'};
			#print "Protocolo: ".$protocolo."\n";
			$alerta = $record->{'sig_id'};
			#print "Alerta: ".$alerta."\n";
			$ip = $record->{'sip'};
			#print "IP: ".$ip."\n\n";
			$llave=$ip."-".$alerta."-".$protocolo;
			if(defined $registro){		
		        	$registro = $registro. pack('NN',$record->{'TYPE'},$record->{'SIZE'}).$record->{'raw_record'};
			}else{
		        	$registro = pack('NN',$record->{'TYPE'},$record->{'SIZE'}).$record->{'raw_record'};
			}
        	}
        
		#Detectando Unified2 Packet o Unified2 Extra Data del mismo registro
        	elsif($tipo eq 2 || $tipo eq 110  && (!defined $idAnterior || $idEncontrado eq $idAnterior )  ){
	        	$registro = $registro. pack('NN',$record->{'TYPE'},$record->{'SIZE'}).$record->{'raw_record'};

        	}elsif(!defined $idAnterior || $idEncontrado ne $idAnterior){
	        	#Meter al hash el registro
			#Checando si existe el incidente
			my $flag = 0;
			foreach my $key (keys %primerEvento){
                		if($llave eq $key){
                        		$flag = 1;
                		}
        		}
			if($flag eq 0){
				$primerEvento{$llave} = $registro;		
				$ultimoEvento{$llave} = $registro;
				$contadorEventos{$llave} = $idIncidente."   $separador  1"; 
				$idIncidente++;
			}else{
				$ultimoEvento{$llave} = $registro;
				$aux  = $contadorEventos{$llave};
				$index = index($aux,$separador);
				$contador = substr $aux, $index+3;
				$contador++;
				$aux = substr $aux, 0,$index+3;
				$contadorEventos{$llave} = $aux.$contador;
			}		    
			$registro = undef;
                	if($tipo ne 2 && $tipo ne 110){
				$protocolo = $record->{'protocol'};
	                	#print "Protocolo: ".$protocolo."\n";
	                	$alerta = $record->{'sig_id'};
	                	#print "Alerta: ".$alerta."\n";
	                	$ip = $record->{'sip'};
	                	#print "IP: ".$ip."\n\n";
				$llave = $ip."-".$alerta."-".$protocolo;
		        	$registro = pack('NN',$record->{'TYPE'},$record->{'SIZE'}).$record->{'raw_record'};
			}


		}
        	$idAnterior = $idEncontrado;
    	}
    	closeSnortUnified();
}

sub lee_archivos{
	foreach my $i (@archivos){
		obtenerIncidentes($i);
	}
}

sub escribirArchivoProcesado{
	open WRITE, ">$nombre_Procesado" 
		or die escribe_bitacora("Error al crear el archivo $nombre_Procesado");
        foreach my $key (keys %primerEvento){
		print WRITE $primerEvento{$key};	
		print WRITE $ultimoEvento{$key};	
        }
	close(WRITE);
}

sub escribirArchivoClaro{
	open WRITE, ">$nombre_Claro" 
		or die escribe_bitacora("Error al crear el archivo $nombre_Claro");
        foreach my $key (keys %contadorEventos){
                print WRITE $contadorEventos{$key}."\n";
        }
	close(WRITE);
}

=pod

=head1 ARCHIVO subrutinas.pl

	Este archivo contiene todas las subrutinas utilizadas en script.pl

=head2 Subrutinas

=head3 divide_archivos:

	Divide la variable $archivos considerando como separador el espacio en blanco y guarda cada elemento resultante como un elemento en el arreglo @archivos.

=head3 muestra_ayuda:

	Despliega en pantalla la leyenda de ayuda del script.

=head3 demonio:

	Crea el proceso del demonio.

=head3 inicia_demonio:

	Inicia el procesamiento de los archivos unified2 como un demonio del sistema cada cierto tiempo predefinido en el archivo de configuracion.

=head3 escribe_bitacora:

	Escribe en el archivo de la bitacora los eventos que se consideran relevantes a registrar.

=head3 obtenerIncidentes:

	Procesa los archivos Unified2 para obtener los incidentes asi como su primer y ultimo evento.

=head3 lee_archivos:

	Envia de uno en uno los archivos a procesar a la subrutina obtenerIncidentes.

=head3 escribirArchivoProcesado:

	Recorre los hash de primer y ultimo evento para escribirlos en formato Unified2 en el archivo Unified2Procesado. 

=head3 escribirArchivoClaro:

	Recorre el hash %contadorEventos para escibir en texto claro el resumen del procesamiento.
 
=cut

1;
