package Text::LineEditor;
#
# ObLegalStuff:
#    Copyright (c) 1998 Bek Oberin. All rights reserved. This program is
#    free software; you can redistribute it and/or modify it under the
#    same terms as Perl itself.
#
# Last updated by gossamer on Tue Aug 25 18:52:18 EST 1998
#

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

use Term::ReadLine;

@ISA = qw(Exporter);
@EXPORT = qw( line_editor );
@EXPORT_OK = qw();

$VERSION = "0.02";

#
# Constants
#

# When starting editing
my $Initial_Prompt = 
   "Enter your message: ('.' by itself on a line to end, ~h for help)";

# Before each line is input
my $Line_Prompt = "> ";

# Before editor messages
my $Message_Prompt = "*** ";

my $Tempfile_Name = "/tmp/lineeditor.$$";

#
# Function
#

sub find_editor {
   return $ENV{"visual"} || "vim" || "vi";
}

sub line_editor {
   my $text;

   my $finished = 0;

   my $Input = new Term::ReadLine 'LineEditor';

   print $Initial_Prompt . "\n";
   while (!$finished) {

      my $line = $Input->readline($Line_Prompt);  # NB  readline() removes \n

      if ($line =~ m/^\.$/) {
         # dot by itself - end
         $finished++;

      } elsif ($line =~ m/^~(.)(.*)$/) {
         # Something magic

         if ($1 eq 'w') {
            # write to a file
            open(OUTFILE, ">$2");
            print OUTFILE $text;
            close(OUTFILE);
         } elsif (($1 eq 'e') || ($1 eq 'v')) {
            # visual editor
            my $editor = &find_editor;
            if ($editor) {
               open(OUTFILE, ">$Tempfile_Name");
               print OUTFILE $text;
               close(OUTFILE);

               system($editor, $Tempfile_Name);

               open(OUTFILE, "<$Tempfile_Name");
               undef $/;
               $text = <OUTFILE>;
               close(OUTFILE);

               print "DEBUG:  '$text'\n";
            } else {
               print $Message_Prompt . "Can't find an editor to use!\n";
            }

         } else {
            print $Message_Prompt . "Unknown tilde escape '$line'\n";
         }

      } else {
         # regular line

         $text .= $line . "\n"; 
      }
   }

   return $text;
}

#
# End.
#
1;
