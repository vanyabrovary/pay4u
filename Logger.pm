package Logger;

use strict;

BEGIN {
	use Exporter();
	our ( @ISA, @EXPORT);
	@ISA 		 = qw( Exporter );
	@EXPORT 	 = qw( $log );
	unless (Log::Log4perl->initialized()) {
		use Log::Log4perl;
		my $logs = q(
  			log4perl.category.Logger				= sub { return Logger->get_level(); }
  			log4perl.appender.Logfile           			= Log::Log4perl::Appender::File
  			log4perl.appender.Logfile.filename  			= sub { return Logger->get_cfg(); }
  			log4perl.appender.Logfile.layout    			= Log::Log4perl::Layout::PatternLayout
	  		log4perl.appender.Logfile.layout.ConversionPattern	= [%p] %d \(+%r\) %m%n
  			log4perl.appender.Logfile.autoflush 			= 1
  			log4perl.appender.Syncer            			= Log::Log4perl::Appender::Synchronized
  			log4perl.appender.Syncer.appender   			= Logfile
		);		
		Log::Log4perl::init_once( \$logs );
		use Cfg;
		sub get_cfg()   { $cfg->{LOG}->{file}; }
		sub get_level() { $cfg->{LOG}->{level}.', Logfile'; }
		our $log = Log::Log4perl::get_logger("Logger");
		$SIG{__WARN__} = sub { $log->warn(@_) };
		$SIG{__DIE__}  = sub {  };
	}
}

1;
