use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use Config;

{
    my $CC = $Config{cc};
    my @config;

    sub get_lua_config {
        my %args = map { split /\s*=\s*/ } @ARGV;

        my $libs = $args{'LIBS'};
        my $inc  = $args{'INC'};

        return ( $inc, $libs ) if defined($inc) && defined($libs);

        my @candidates = (
            'lua-config',
            'pkg-config lua',
            'pkg-config lua5.1',
            'pkg-config lua-5.1',
        );

        foreach my $command (@candidates) {
            my $status = system "$command >/dev/null 2>/dev/null"; # XXX *nix-specific

            if($status == 0) {
                my $extra_args = `$command --libs --cflags`;
                chomp $extra_args;
                $status = system("$CC check.c $extra_args 2>/dev/null");

                if($status == 0) {
                    $libs ||= `$command --libs`;
                    $inc  ||= `$command --cflags`;

                    chomp for $libs, $inc;

                    use feature qw(say);
                    say "inc = $inc, libs = $libs";

                    return ( $inc, $libs );
                }
            }
        }

        return;
    }
}



my ( $inc, $libs ) = get_lua_config();

if (!$inc && !$libs ) {
    die <<EOD;
*******************************************
Couldn't find a working Lua installation
on this machine. This is required for
this module.

To obtain it, go to
    http://www.lua.org/download.html
*******************************************

If Makefile.PL failed to find your Lua installation,
you can specify INC and LIBS flags directly:

  perl Makefile.PL INC=-I/usr/include/lua5.1 LIBS=-llua5.1

(You can also specify INC/LIBS using PERL_MM_OPT)
EOD
}

WriteMakefile(
    NAME              => 'Inline::Lua',
  'ABSTRACT' => 'Perl extension for embedding Lua scripts into Perl code',
  'AUTHOR' => 'Rob Hoelz <rob@hoelz.ro>',
  'LICENSE' => 'perl',
  'VERSION' => '0.09',
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'PREREQ_PM' => {
    'Inline' => '0'
  },
  'TEST_REQUIRES' => {
    'File::Spec' => '0',
    'IO::Handle' => '0',
    'IPC::Open3' => '0',
    'Test::More' => '0'
  },
    LIBS              => [ $libs ],
    DEFINE            => '',
    INC               => "-I. " . $inc,
    clean             => { FILES => "_Inline a.out" },
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


