#!/usr/bin/perl -w
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
  if 0;    #$running_under_some_shell

use strict;
use File::Find ();

sub glob2pat
{
   my $globstr = shift;
   my %patmap  = (
      '*' => '.*',
      '?' => '.',
      '[' => '[',
      ']' => ']',
   );
   $globstr =~ s{(.)} { $patmap{$1} || "\Q$1" }ge;
   return '^' . $globstr . '$';
}

use Getopt::Long;
use Data::Dumper;

my @exclude_dirs;
my @file_extensions;

if ( GetOptions( 'exclude-dirs:s{,}' => \@exclude_dirs, 'file-exts:s{,}' => \@file_extensions ) )
{
   my @re_exclude_dirs    = map { glob2pat($_) } @exclude_dirs;
   my @re_file_extensions = map { glob2pat($_) } @file_extensions;

   # Traverse desired filesystems
   File::Find::find(
      {
         preprocess => sub {

            my @filter = ();

            foreach my $dir (@_)
            {
               my $exclude = 0;

               foreach my $re (@re_exclude_dirs)
               {
                  if ( $dir =~ $re )
                  {
                     $exclude = 1;
                     last;
                  }
               }

               push @filter, $dir
                 if ( !$exclude );
            }

            return @filter;
         },

         wanted => sub {
            my $file = $_;

            if ( my ( $dev, $ino, $mode, $nlink, $uid, $gid ) = lstat($_) )
            {
               if ( -f _ && !-B _ && ( $dev == $File::Find::topdev ) )
               {
                  my $include = 0;

                  foreach my $re (@re_file_extensions)
                  {
                     if ( $file =~ $re )
                     {
                        $include = 1;
                        last;
                     }
                  }

                  print("$File::Find::name\n")
                    if ($include);
               }
            }
           }
      },
      '.'
   );
}
