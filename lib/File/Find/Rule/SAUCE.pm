package File::Find::Rule::SAUCE;

use strict;
use File::Find::Rule;
use base qw( File::Find::Rule );
use vars qw( @EXPORT $VERSION );

@EXPORT  = @File::Find::Rule::EXPORT;
$VERSION = '0.03';

use File::SAUCE;

sub File::Find::Rule::sauce {
	my $self = shift()->_force_object;

	# Procedural interface allows passing arguments as a hashref.
	my %criteria = UNIVERSAL::isa( $_[ 0 ], 'HASH' ) ? %{ $_[ 0 ] } : @_;

	$self->exec( sub {
		my $file = shift;

		return if -d $file;

		my $info = File::SAUCE->new( $file ) or return;

		# deal with files (not) having SAUCE records first
		if( exists $criteria{ has_sauce } ) {
			return if $info->has_sauce ^ $criteria{ has_sauce };
		}
		else {
			# if has_sauce was not specified, there's no point in continuing
			# when the file has no SAUCE record
			return unless $info->has_sauce;
		}

		# passed has_sauce - check the other criteria
		for my $fld ( keys %criteria ) {
			next if $fld =~ /^has_sauce$/;

			if ( $fld eq 'comments' ) {

				my $comments = $info->get_comments;

				if ( ref $criteria{ $fld } eq 'Regexp' ) {
					if ( scalar @$comments > 0 ) {
						return unless grep( $_ =~ $criteria{ $fld }, @{ $comments } );
					}
					else {
						return unless '' =~ $criteria{ $fld };
					}
				}
				else {
					if ( scalar @$comments > 0 ) {
						return unless grep( $_ eq $criteria{ $fld }, @{ $comments } );
					}
					else {
						return unless $criteria{ $fld } eq '';
					}
				}	
			}
			elsif ( ref $criteria{ $fld } eq 'Regexp' ) {
				return unless $info->get( lc( $fld ) ) =~ $criteria{ $fld };
			}
			else {
				return unless $info->get( lc( $fld ) ) eq $criteria{ $fld };
			}
		}
		return 1;
	} );
}

1;

=pod

=head1 NAME

File::Find::Rule::SAUCE - Rule to match on title, author, etc from a file's SAUCE record

=head1 SYNOPSIS

	use File::Find::Rule::SAUCE;

	# get all files where 'Brian' is the author
	my @files = find( sauce => { author => qr/Brian/ }, in => '/ansi' );

	# get all files without a SAUCE rec
	@files    = find( sauce => { has_sauce => 0 }, in => '/ansi' );


=head1 DESCRIPTION

This module will search through a file's SAUCE metadata (using File::SAUCE) and match on the
specified fields.

=head1 METHODS

	my @files = find( sauce => { title => qr/My Ansi/ }, in => '/ansi' );

If more than one field is specified, it will only return the file if ALL of the criteria
are met. You can specify a regex (qr//) or just a string.

Matching on the comments field will search each line of comments for the requested string.

has_sauce is a special field which should be matched against true or false values (no regexes).
has_sauce => 1 is implied if not specified.

See File::SAUCE for a list of all the fields that can be matched.

=head1 BUGS

If you have any questions, comments, bug reports or feature suggestions, 
email them to Brian Cassidy <brian@alternation.net>.

=head1 CREDITS

This module was written by Brian Cassidy (http://www.alternation.net/). It borrows heavily
from File::Find::Rule::MP3Info.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms
of the Artistic License, distributed with Perl.

=head1 SEE ALSO

	File::SAUCE
	File::Find::Rule
	File::Find::Rule::MP3Info

=cut