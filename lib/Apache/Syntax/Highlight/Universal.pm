package Apache::Syntax::Highlight::Universal;

require 5.005;
use strict;
use vars qw($VERSION);
$VERSION = '0.0.2';

use mod_perl;
use constant MP2 => ($mod_perl::VERSION >= 1.99);

use Syntax::Highlight::Universal;
use IO::File;

my $_HTML_401_DOCTYPE = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n";
my $_XHTML_10_DOCTYPE = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";

my $_HTML_INTRO = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
 	. "<head>\n"
  	. "<title>Highlighted source generate by Apache::Syntax::Highlight::Universal</title>\n"
	. "<meta name=\"generator\" content=\"Apache::Syntax::Highlight::Universal\"";
		
my $_HTML_SIMPLE_OUTRO = "</body></html>";
my $_HTML_CODE_OUTRO = "</pre></body></html>";

my $_ERROR_INTRO = "<p style=\"color:red; padding: 10px 10px 10px 20px; border: solid 1px #FF0000; background: #FFFFFF\">\n";
my $_ERROR_OUTRO = "</p>\n";

# mimetype to highlight format mapping
my %default_formats = (
	# mime types that are evaluating as text/plain:
	# - *.vb
	# - *.jsl
	# - *.4th
	# - *.fs
	# - *.jsp
	# - *.aspx
	# - *.cfc
	# - *.cfm
	# - *.vbs
	# - *.prg
	# - *.jsql/*.sqlj
	# - *.bat
	# - *.conf
	# - *.jj
	# - *.properties
	# - *.lex
	# - *.yacc
	# - *.nsi
	# - *.abap
	# - *.aut/*.au3
	# - *.awk
	# - *.cob
	# - *.e
	# - *.lisp
	# - *.m3
	# - *.rex
	# - *.ml
	# *.v
	'text/xml'							=> 'xml',
	'application/x-shellscript'			=> 'shell',
	'application/x-perl'				=> 'perl',
	'text/x-csrc'						=> 'c',
	'text/x-c++src'						=> 'cpp',
	'text/x-java'						=> 'java',
	'text/x-idl'						=> 'idl',
	'text/x-pascal'						=> 'pas',
	'text/x-csharp'						=> 'csharp',
	'TODO'								=> 'jsnet',
	'TODO'								=> 'vbnet',
	'TODO'								=> 'forth',
	'text/x-fortran'					=> 'fortran',
	'TODO'								=> 'vbasic',
	'text/html'							=> 'html',
	'text/css'							=> 'css',
	'TODO'								=> 'html-css',			# Huh, what's this???
	'TODO'								=> 'svg-css',			# Huh, what's this???
	'TODO'								=> 'jsp',
	'application/x-php'					=> 'php',
	'TODO'								=> 'php-body',			# Huh, what's this???
	'TODO'								=> 'xhtml-trans',		# Can't be determined automatically - I guess ...
	'TODO'								=> 'xhtml-strict',		# Can't be determined automatically - I guess ...
	'TODO'								=> 'xhtml-frameset',	# Can't be determined automatically - I guess ...
	'application/x-asp'					=> 'TODO',
	'TODO'								=> 'asp.vb',
	'TODO'								=> 'asp.js',
	'TODO'								=> 'asp.ps',
	'image/svg+xml'						=> 'svg',
	'TODO'								=> 'coldfusion',
	'application/x-javascript'			=> 'jScript',
	'application/x-applix-spreadsheet'	=> 'actionscript',		# Note: This mimetype isn't valid!
	'TODO'								=> 'vbScript',
	'text/x-dtd'						=> 'dtd',
	'text/x-xslt'						=> 'xslt',
	'TODO'								=> 'xmlschema',
	'TODO'								=> 'relaxng',
	'TODO'								=> 'xlink',
	'TODO'								=> 'clarion',			# Huh, what's this???
	'TODO'								=> 'Clipper',
	'TODO'								=> 'foxpro',
	'TODO'								=> 'jsql',
	'TODO'								=> 'paradox',
	'text/x-sql'						=> 'sql',
	'TODO'								=> 'mysql',				# Can't be determined automatically - I guess ...
	'TODO'								=> 'batch',
	'TODO'								=> 'apache',
	'TODO'								=> 'config',
	'TODO'								=> 'hrc',				# evaluates as text/xml
	'TODO'								=> 'hrd',
	'TODO'								=> 'delphiform',
	'TODO'								=> 'javacc',
	'TODO'								=> 'javaProperties',
	'TODO'								=> 'lex',
	'TODO'								=> 'yacc',
	'text/x-makefile'					=> 'makefile',
	'application/octet-steram'			=> 'regedit',			# Is this correct?
	'TODO'								=> 'resources',			# Huh, what's this???
	'text/x-tex'						=> 'TeX',
	'TODO'								=> 'dcl',				# Huh, what's this???
	'model/vrml'						=> 'vrml',
	'TODO'								=> 'rarscript',
	'TODO'								=> 'nsi',
	'TODO'								=> 'iss',				# Huh, what's this???
	'TODO'								=> 'isScript',			# Huh, what's this???
	'TODO'								=> 'c1c',				# Huh, what's this???
	'text/x-adasrc'						=> 'ada',
	'TODO'								=> 'abap4',
	'TODO'								=> 'AutoIT',
	'TODO'								=> 'awk',
	'TODO'								=> 'dssp',				# Huh, what's this???
	'TODO'								=> 'adsp',				# Huh, what's this???
	'TODO'								=> 'baan',				# Huh, what's this (an erp)???
	'TODO'								=> 'cobol',
	'TODO'								=> 'cache',				# Huh, what's this (the DB)???
	'TODO'								=> 'eiffel',
	'TODO'								=> 'icon',				# Huh, what's this???
	'TODO'								=> 'lisp',
	'text/x-objcsrc'					=> 'matlab',			# Note: This mimetype isn't valid!
	'TODO'								=> 'modula2',
	'TODO'								=> 'picasm',
	'text/x-python'						=> 'python',
	'TODO'								=> 'rexx',
	'application/x-ruby'				=> 'ruby',
	'application/smil'					=> 'sml',				# Note: This mimetype isn't valid!
	'text/x-tcl'						=> 'tcltk',
	'TODO'								=> 'ocaml',
	'TODO'								=> 'sicstusProlog',		# Can't be determined automatically - I guess ...
	'TODO'								=> 'turboProlog',		# Can't be determined automatically - I guess ...
	'TODO'								=> 'verilog',
	'TODO'								=> 'vhdl',				# Huh, what's this???
	'TODO'								=> 'z80',				# Can't be determined automatically - I guess ...
	'TODO'								=> 'asm80',				# Can't be determined automatically - I guess ...
	'TODO'								=> 'filesbbs',			# Huh, what's this???
	'text/x-patch'						=> 'diff',
	'message/news'						=> 'messages',
	'text/plain'						=> 'text'
);

BEGIN {
	# Tests mod_perl version and uses the appropriate components
	if (MP2) {
		require Apache2::Const;
		Apache2::Const->import(-compile => qw(DECLINED OK));
		require Apache2::RequestRec;
		require Apache2::RequestIO;
		require Apache2::RequestUtil;
	}
	else {
		require Apache::Constants;
		Apache::Constants->import(qw(DECLINED OK));
	}
}

sub handler {
	my $r = shift;
	my $str;  # buffered output
	
	return (MP2 ? Apache2::Const::DECLINED : Apache::Constants::DECLINED) if $r->args =~ /download/i;

	my $debug = $r->dir_config('HighlightDebug') eq 'On' ? 1 : 0;
	my $sln = ($r->dir_config('HighlightShowLineNumbers') =~ /^on$/i || $r->args =~ /ShowLineNumbers/i) ? 1 : 0;
	my $wants_caching = $r->dir_config('HighlightEnableCaching') eq 'On' ? 1 : 0;
	my $wants_precompiled_config = $r->dir_config('HighlightEnablePrecompiledConfig') eq 'On' ? 1 : 0;
	my $wants_xhtml = ($r->dir_config('HighlightEnableXHTMLEncoding') eq 'On' || $r->args =~ /EnableXHTML/i) ? 1 : 0;
	my $mime_type = &_mimeType($r->filename);
	my $send_xhtml = ((defined $r->headers_in->{Accept} &&
		$r->headers_in->{Accept} =~ /application\/xhtml\+xml/ &&
		$r->headers_in->{Accept} !~ /application\/xhtml\+xml\s*;\s*q=0/)) || $wants_xhtml == 1;
	my $content_type = $send_xhtml ? 'application/xhtml+xml' : 'text/html';
	
	print STDERR "[$$] Generating output with content type: " . $content_type . ".\n" if $debug;
	print STDERR "[$$] Generating highlight...\n" if $debug;
	
	#assembling of HTML markup starts here
	if ($send_xhtml) {
		$str = $_XHTML_10_DOCTYPE . $_HTML_INTRO . " />\n";
	} else {
		$_HTML_INTRO =~ s/(xmlns)?(.*)/<html>/;
		$str = $_HTML_401_DOCTYPE . $_HTML_INTRO . ">\n";
	}
		
	my $formatter = Syntax::Highlight::Universal->new;
	
	# Open file to highlight
	my $fh = new IO::File($r->filename);
	my $source = "";

	while (my $line = <$fh>) { $source .= $line . "\n"; }
	undef $fh;
	
	if ($wants_caching == 1) {
		if (defined ($r->dir_config('HighlightCacheDir')) &&
			-e $r->dir_config('HighlightCacheDir')) {
				$formatter->setCacheDir($r->dir_config('HighlightCacheDir'));
		} else {
			if (! -e $r->dir_config('HighlightCacheDir')) {
				$formatter->setCacheDir('/tmp');
			}
		}
		
		if (defined ($r->dir_config('HighlightCachePrefixLen'))) {
			$formatter->setCachePrefixLen($r->dir_config('HighlightCachePrefixLen'));
		}
	}
	
	if ($wants_precompiled_config == 1) {
		if (defined ($r->dir_config('HighlightPrecompiledConfig')) &&
			-e $r->dir_config('HighlightPrecompiledConfig')) {
				$formatter->setPrecompiledConfig($r->dir_config('HighlightPrecompiledConfig'));
		} elsif (defined ($r->dir_config('HighlightConfigFile')) &&
					-e $r->dir_config('HighlightConfigFile')) {
						$formatter->addConfig($r->dir_config('HighlightConfigFile'));
						
						print STDERR "[$$] You did specify to use a precompiled configuration file. "
							. "Unfortunatly you did specify a configuration file but not a corresponding precompiled version. "
							. "I will use your config which will be compiled once after one an initial highlighting cycle.\n";	
		} else {
			eval {
				print STDERR "[$$] No config found. Trying to use the default one.\n";
				
				$formatter->addConfig('hrc/proto.hrc');
			};
			
		    if ($@) {
				print STDERR "[$$] No config found. You need to provide either a path to a config file or a path to a precompiled config file.\n";
				
				$str .= "</head><body>\n";
				$str .= &_errorMsg("No config found. Please read you server logs for any details.");
				$str .= $_HTML_SIMPLE_OUTRO;
				
				# Can't proceed any further because of the missing config.
				$r->content_type($content_type);
				MP2 ? 1 : $r->send_http_header;
				$r->print($str);
				return MP2 ? Apache2::Const::OK : Apache::Constants::OK;			
		    }
		}			
	} else {
		if (defined ($r->dir_config('HighlightConfigFile')) &&
			-e $r->dir_config('HighlightConfigFile')) {
				$formatter->addConfig($r->dir_config('HighlightConfigFile'));
		} else {
			eval {
				print STDERR "[$$] No config found. Trying to use the default one.\n";
				
				$formatter->addConfig('hrc/proto.hrc');
			};
			
			if ($@) {
				print STDERR "[$$] You need to provide a path to a valid config file.\n";
				
				$str .= "</head><body>\n";
				$str .= &_errorMsg("You need to provide a path to a valid config file.");
				$str .= $_HTML_SIMPLE_OUTRO;
				
				# Can't proceed any further because of the missing config.
				$r->content_type($content_type);
				MP2 ? 1 : $r->send_http_header;
				$r->print($str);
				return MP2 ? Apache2::Const::OK : Apache::Constants::OK;						
			}
		}
	}
	
	if (defined ($r->dir_config('HighlightCSS'))) {
		$str .= "<link rel=\"stylesheet\" href=\"" . $r->dir_config('HighlightCSS') . "\" type=\"text/css\"";
		$str .= $send_xhtml ?
			" />\n</head><body><pre class=\"" . $default_formats{$mime_type} . "\">\n" :
			">\n</head><body><pre class=\"" . $default_formats{$mime_type} . "\">\n";
	} else {
		$str .= "<!-- You should specify a CSS stylesheet -->\n"
			 . "</head><body><pre class=\"" . $default_formats{$mime_type} . "\">\n";
		print STDERR "[$$] You did not specify any CSS stylsheet which is required to highlight your source code.\n";
	}
	
	if (defined ($r->dir_config('HighlightFormat')) || $r->args =~ /format/i) {
		# I am using CGI to parse the query string into an array
		# because it is not possible to do so using the mod_perl 2 API
		# and because the mod_perl docs are stating $r->args in an array
		# context should never have been a part of the mod_perl 1 API.
		require CGI;
		my $q = new CGI;
		my %req_args = map { $_ => $q->param($_) } $q->param;
		my $format = $req_args{format} || $r->dir_config('HighlightFormat');

		print STDERR "[$$] Got " . scalar (keys (%req_args)) . " keys during the HTTP request.\n" if $debug;		
		print STDERR "[$$] Hash contents:\n" . &_printRequestHash(\%req_args) . "\n" if $debug;
		print STDERR "[$$] Determined " . $format . " as a format definition for coloror.\n" if $debug;
		
		if ($format eq 'auto') {			
			print STDERR "[$$] Determined " . $mime_type . " as a mimetype for " . $r->filename . ".\n" if $debug;
			
			if ($sln) {
				my @lines = split /^/m, $formatter->highlight($default_formats{$mime_type}, $source) if defined ($mime_type);
				&_addLineNumbers(\@lines);
				$str .= join ('', @lines);
			} else {
				$str .= $formatter->highlight($default_formats{$mime_type}, $source) if defined ($mime_type);
			}
		} else {
			if ($sln) {
				my @lines = split /^/m, $formatter->highlight($format, $source);
				&_addLineNumbers(\@lines);
				$str .= join ('', @lines);
			} else {
				$str .= $formatter->highlight($format, $source);
			}
		}
	} else {
		# try to determine the mime type
		print STDERR "[$$] Determined " . $mime_type . " as a mimetype for " . $r->filename . ".\n" if $debug;
		
		if (defined ($mime_type)) {
			if ($sln) {
				my @lines = split /^/m, $formatter->highlight($default_formats{$mime_type}, $source);
				&_addLineNumbers(\@lines);
				$str .= join ('', @lines);
			} else {
				$str .= $formatter->highlight($default_formats{$mime_type}, $source);
			}
		} else {
			if ($sln) {
				my @lines = split /^/m, $formatter->highlight("default", $source);
				&_addLineNumbers(\@lines);
				$str .= join ('', @lines);
			} else {
				$str .= $formatter->highlight("default", $source);
			}
		}
	}
	
	if ($wants_precompiled_config == 1) {
		if (! -e $r->dir_config('HighlightPrecompiledConfig') &&
			-e $r->dir_config('HighlightConfigFile')) {
			$formatter->precompile($r->dir_config('HighlightConfigFile'));
		}
	}
	
	if ($debug) {
		if ($send_xhtml) {
			$str .= "</pre>"
				. "<p align=\"center\">\n"
      			. "<a href=\"http://validator.w3.org/check/referer\">"
      			. "<img src=\"http://www.w3.org/Icons/valid-xhtml10\" alt=\"Valid XHTML 1.0!\" height=\"31\" width=\"88\" border=\"0\" /></a>"
    			. "</p>";
		} else {
			$str .= "</pre>"
				. "<p align=\"center\">\n"
      			. "<a href=\"http://validator.w3.org/check/referer\">"
      			. "<img src=\"http://validator.w3.org/images/vh401\" alt=\"Valid HTML 4.01!\" height=\"31\" width=\"88\" border=\"0\"></a>"
    			. "</p>";
		}
	}
	
	$str .= $debug ? $_HTML_SIMPLE_OUTRO : $_HTML_CODE_OUTRO;

	# Output code to client
	$r->content_type($content_type);
	MP2 ? 1 : $r->send_http_header;
	$r->print($str);
	return MP2 ? Apache2::Const::OK : Apache::Constants::OK;	
}

sub _addLineNumbers {
	my ($lines_ref)  = @_;
	my $line_number = 1;
	my $line_numbers = scalar (@$lines_ref);
	
	@$lines_ref = map {
		'&nbsp;<span class="def_LineNumber">' .
		$line_number++ .
		'&nbsp;' x (length ($line_numbers) - length ($line_number - 1)) .
		'</span>&nbsp;' .
		$_
	} @$lines_ref;
	
	@$lines_ref;
}

sub _errorMsg {
	my ($errorMessage) = @_;
	
	return $_ERROR_INTRO . $errorMessage . $_ERROR_OUTRO;
}

sub _mimeType {
	my ($fileName) = @_;
	my $mime_type;
	
	require File::MimeInfo::Magic;
	$mime_type = File::MimeInfo::Magic::mimetype($fileName);
	
	return $mime_type || die "Unable to determine mime type.";
}

sub _printRequestHash {
	my ($reqHashRef) = @_;
	my %reqHash = %$reqHashRef;
	my $hashContents;
	
#	while (my ($k, $v) = each %$reqHashRef) {
#		$hashContents .= "$k => $v\n";
#	}
	
	$hashContents .= join "\n", map {"\t$_ => $reqHash{$_}"} keys %reqHash;
	
	$hashContents;
}

1;

__END__

=pod

=head1 NAME

Apache::Syntax::Highlight::Universal - mod_perl 1.0/2.0 extension to 
highlight any code

=head1 SYNOPSIS

In F<httpd.conf> (mod_perl 1):

   PerlModule Apache::Syntax::Highlight::Universal

   <FilesMatch "\.((p|P)(l|L|m|M)|t)$">
      SetHandler perl-script
      PerlHandler Apache::Syntax::Highlight::Universal
      PerlSetVar HighlightConfigFile hrc/proto.hrc
      PerlSetVar HighlightCacheDir /tmp/highlighter
      PerlSetVar HighlightCSS http://path.to/highlight.css
      PerlSetVar HighlightFormat auto
      PerlSetVar HighlightEnableCaching On
   </FilesMatch>
   
In F<httpd.conf> (mod_perl 2):

   PerlModule Apache2
   PerlModule Apache::Syntax::Highlight::Universal

   <FilesMatch "\.((p|P)(l|L|m|M)|t)$">
      SetHandler perl-script
      PerlResponseHandler Apache::Syntax::Highlight::Universal
      PerlSetVar HighlightConfigFile hrc/proto.hrc
      PerlSetVar HighlightCacheDir /tmp/highlighter
      PerlSetVar HighlightCSS http://path.to/highlight.css
      PerlSetVar HighlightFormat auto
      PerlSetVar HighlightEnableCaching On
   </FilesMatch>

=head1 DESCRIPTION

Apache::Syntax::Highlight::Universal is a mod_perl (1.0 and 2.0) module that
provides syntax highlighting for any code. This module is a wrapper around
L<Syntax::Highlight::Universal|Syntax::Highlight::Universal>. Originally this
module was inspired by L<Apache::Syntax::Highlight::Perl|Apache::Syntax::Highlight::Perl>
written by Enrico Sorcinelli.

=head1 MOD_PERL 2 COMPATIBILITY

Apache::Syntax::Highlight::Universal is fully compatible with both mod_perl
generations 1.0 and 2.0.

If you have mod_perl 1.0 and 2.0 installed on the same system and the two uses
the same per libraries directory, to use mod_perl 2.0 version make sure to load
first C<Apache2> module which will perform the necessary adjustments to
C<@INC>:

   PerlModule Apache2
   PerlModule Apache::Syntax::Highlight::Universal

Of course, notice that if you use mod_perl 2.0, there is no need to pre-load
the L<Apache::compat|Apache::compat> compatibility layer.

=head1 INSTALLATION

In order to install and use this package you will need Perl version 5.005 or
better.

Prerequisites:

=over 4

=item * mod_perl 1 or 2 (of course)

=item * Syntax::Highlight::Universal >= 0.4

=item * File::MimeInfo >= 0.11

=item * CGI.pm >= 3.08

=back 

Installation as usual:

   % perl Makefile.PL
   % make
   % make test
   % su
     Password: *******
   % make install
   
=head1 CONFIGURATION

In order to enable Perl file syntax highlighting you could modify I<httpd.conf>
or I<.htaccess> files.

=head1 DIRECTIVES

You can control the behaviour of this module by configuring the following
variables with C<PerlSetVar> directive  in the I<httpd.conf> (or I<.htaccess>
files)

=over 4

=item C<HighlightCSS> string

This single directive sets the URL (or URI) of the custom CCS file.

   PerlSetVar HighlightCSS /highlight/perl.css

It can be placed in server config, <VirtualHost>, <Directory>, <Location>,
<Files> and F<.htaccess> context.  

The CSS file is used to define styles for all the syntactical elements that
L<Syntax::Highlight::Universal|Syntax::Highlight::Universal> currently recognizes.

The L<Syntax::Highlight::Universal|Syntax::Highlight::Universal> tarball contains
some sample CSS stylesheets which you can use as a starting point.

=item C<HighlightShowLineNumbers> On|Off

This single directive displays line numbers to the right of the text

   PerlSetVar HighlightShowLineNumbers On

It can be placed in server config, <VirtualHost>, <Directory>, <Location>,
<Files> and F<.htaccess> context. The default value is C<Off>.

=item C<HighlightEnableCaching> On|Off

This directive enables a very simple cache layer of already and unchanged
highlighted files:

   PerlSetVar HighlightEnableCaching On

Default is C<Off>.

=item C<HighlightCacheDir> string

This directive sets cache directory 

   PerlSetVar HighlightCacheDir /tmp/highlight

Default is C</tmp>.

=item C<HighlightCachePrefixLen> integer

This directive sets how many characters should be used for subdirectories
of the cache directory.

	PerlSetVar HighlightCachePrefixLen 2
	
By default L<Syntax::Highlight::Universal|Syntax::Highlight::Universal> will
set this value to C<2>, which allows to create up to 256 subdirectories.

=item C<HighlightEnablePrecompiledConfig> On|Off

This directive causes L<Syntax::Highlight::Universal|Syntax::Highlight::Universal>
to use a precompiled configuration file. A precompiled configuration file may result
in a faster highlighting process.

	PerlSetVar HighlightEnablePrecompiledConfig On
	
Default is C<Off>.

=item C<HighlightPrecompiledConfig> string

This directive points to a precompiled (*.hrcc) configuration file.

	PerlSetVar hrc/proto.hrcc
	
This directive has no default value! Note - You can use either C<HighlightPrecompiledConfig>
or C<HighlightConfigFile> at a time. If you use both directives at the same time you may
cause a runtime exception.

=item C<HighlightConfigFile> string

This directive points to a standard (*hrc) configuration file.

	PerlSetVar HighlightConfigFile hrc/proto.hrc
	
This directive has no default value! Note - You can use either C<HighlightPrecompiledConfig>
or C<HighlightConfigFile> at a time. If you use both directives at the same time you may
cause a runtime exception.

=item C<HighlightFormat> string

This directive sets the format of the original source file. For example if you are
trying to highlight a C++ file, you should set this directive to C<cpp>. A complete
list of possible values is contained within the L<Syntax::Highlight::Universal|Syntax::Highlight::Universal>
documentation.

If you really do not know which value to use, you may use C<auto> to cause
Apache::Syntax::Highlight::Universal to try to automatically determine the
format of the source that should be highlighted. Note - There are a couple
of file types which can't be determined automatically. Please read the
section TODO to get a glimpse which file types can't be determined automatically.

	PerlSetVar HighlightFormat auto
	
Default is C<default>.

=item C<HighlightEnableXHTMLEncoding> On|Off

This directive allows people to make Apache::Syntax::Highlight::Universal to emit
valid XHTML 1.0 markup even if the user agent does not send the ...

	Accept: application/xhtml+xml
	
header. I mainly did add this directive to allow the emission of valid XHTML markup
to Microsoft IE users.

Default is C<Off>.

=back

=head1 RUN TIME CONFIGURATION

In addition, you can control the module behaviour at run time by adding
some values via the query string. In particular:

=over 4

=item download

Forces the module to exit with DECLINED status, for example by allowing
users to download the file (according to Apache configuration):

   http://myhost.com/myproject/sample.pl?download

=item showlinenumbers

Forces showing of code line numbers. For example:

   http://myhost.com/myproject/sample.pl?showlinenumbers

=item enablexhtml

Forces the module to generate valid XHTMLmarkup, even if the user agent
does not support rendering XHTML compliant markup. For example:

   http://myhost.com/myproject/sample.pl?enablexhtml

=item format

Forces the module to use a particular format to be used if instantiating
L<Syntax::Highlight::Universal|Syntax::Highlight::Universal>. You may use
this variable in your query string, if you do have the impression that
the module is not picking the correct format or if you want to switch
the default format without restarting your Apache daemon.

   http://myhost.com/myproject/sample.pl?format=perl

=back

=head1 BUGS 

Currently I am running my own issue tracker at:

http://tracker.daniel.stefan.haischt.name/projects/dsh.name/

In the future you may be required to submit bugs to CPAN RT system at
http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Apache%3A%3ASyntax%3A%3AHighlight%3A%3AUniversal
or by email at bug-apache-syntax-highlight-universal@rt.cpan.org

Patches are welcome and I'll update the module if any problems will be found.

=head1 VERSION

Version 0.0.2

=head1 TODO

=over 4

=item *

At the time the following file types won't be determined appropriately:

	*.vb, *.jsl, *.4th, *.fs, *.jsp, *.aspx, *.cfc, *.cfm, *.vbs,
	*.prg, *.jsql/*.sqlj, *.bat, *.conf, *.jj, *.properties, *.lex,
	*.yacc, *.nsi, *.abap, *.aut/*.au3, *.awk, *.cob, *.e, *.lisp,
	*.m3, *.rex, *.ml, *.v
	
If you are still experiencing problems if using the C<auto> to make
Apache::Syntax::Highlight::Universal to determine the file type automatically,
please take a look at the Apache::Syntax::Highlight::Universal source code
whether the corresponding file type is marked with a C<TODO> tag.

Alternatively you may fill a bug report.

=back

=head1 SEE ALSO

L<Syntax::Highlight::Universal|Syntax::Highlight::Universal>, L<Apache|Apache>,
L<CGI.pm|CGI.pm>, L<IO::File|IO::File>, L<File::MimeInfo::Magic|File::MimeInfo::Magic>, perl

=head1 AUTHOR

Daniel S. Haischt, E<lt>me@daniel.stefan.haischt.nameE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Daniel S. Haischt

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself, either Perl version 5.8.2 or, at your option,
any later version of Perl 5 you may have available.

=cut
