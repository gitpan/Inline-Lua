use 5.006;
use ExtUtils::MakeMaker;
use Config;

sub have_lua {
    my $CC = $Config{cc};
    my %args = map { split /\s*=\s*/ } @ARGV;
    my $LIBS = $args{ LIBS } || "-llua -llualib";
    my $INC = $args{ INC };
    return 1 if system("$CC check.c $INC $LIBS 2>/dev/null") == 0;
    return 0;
}

if (! have_lua()) {
    die <<EOD;
*******************************************
Couldn't find a working Lua installation 
on this matchine. This is required for
this module.

To obtain it, go to
    http://www.lua.org/download.html
*******************************************
EOD
}

WriteMakefile(
    NAME              => 'Inline::Lua',
    VERSION_FROM      => 'lib/Inline/Lua.pm', 
    PREREQ_PM         => {
	'Test::More' => 0,
	'Inline'     => 0,
    }, 
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Inline/Lua.pm', # retrieve abstract from module
       AUTHOR         => 'Tassilo von Parseval <tassilo.von.parseval@rwth-aachen.de>') : ()),
    LIBS              => ['-llua -llualib'], 
    DEFINE            => '', 
    INC               => '-I.', 
    clean	      => { FILES => "_Inline a.out" },
);
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.
  my @names = (qw());
  ExtUtils::Constant::WriteConstants(
                                     NAME         => 'Inline::Lua',
                                     NAMES        => \@names,
                                     DEFAULT_TYPE => 'IV',
                                     C_FILE       => 'const-c.inc',
                                     XS_FILE      => 'const-xs.inc',
                                  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}
