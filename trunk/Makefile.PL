use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	NAME              => 'Apache::Syntax::Highlight::Universal',
	VERSION_FROM      => 'lib/Apache/Syntax/Highlight/Universal.pm', # finds $VERSION
	PREREQ_PM         => {
                         'mod_perl'                		=> 1.24,
                         'Syntax::Highlight::Universal' => 0.4,
                         'File::MimeInfo'				=> 0.11,
                         'CGI.pm'						=> 3.08
                        }, # e.g., Module::Name => 1.1
	($] >= 5.005 ?     ## Add these new keywords supported since 5.005
		(ABSTRACT_FROM => 'lib/Apache/Syntax/Highlight/Universal.pm', # retrieve abstract from module
		 AUTHOR        => 'Daniel S. Haischt <me@daniel.stefan.haischt.name>') : ()),
);
